USE KIPP_NJ
GO

ALTER PROCEDURE sp_ILLUMINATE$agg_student_responses_standard#MERGE AS

BEGIN 

  IF OBJECT_ID(N'tempdb..#stds_update') IS NOT NULL
    BEGIN
      DROP TABLE #stds_update
    END;

  BEGIN
    SELECT *      
    INTO #stds_update
    FROM OPENQUERY(ILLUMINATE,'  
      SELECT sa.student_assessment_id
            ,sa.updated_at
            ,s.local_student_id  
            ,r.assessment_id
            ,r.standard_id
            ,r.performance_band_id
            ,r.performance_band_level
            ,r.mastered
            ,r.percent_correct        
            ,r.points
            ,r.points_possible	
            ,r.answered	            
            ,r.number_of_questions
      FROM dna_assessments.students_assessments sa    
      JOIN dna_assessments.agg_student_responses_standard r    
        ON sa.student_assessment_id = r.student_assessment_id
      JOIN public.students s 
        ON sa.student_id = s.student_id    
      WHERE sa.created_at >= ''2015-07-01''
    ');
  END

  BEGIN
    MERGE KIPP_NJ..ILLUMINATE$agg_student_responses_standard AS TARGET
      USING #stds_update AS SOURCE
         ON TARGET.student_assessment_id = SOURCE.student_assessment_id
        AND TARGET.standard_id = SOURCE.standard_id
      WHEN MATCHED THEN
       UPDATE
        SET TARGET.updated_at = SOURCE.updated_at
           ,TARGET.local_student_id = SOURCE.local_student_id
           ,TARGET.assessment_id = SOURCE.assessment_id
           ,TARGET.performance_band_id = SOURCE.performance_band_id
           ,TARGET.performance_band_level = SOURCE.performance_band_level
           ,TARGET.mastered = SOURCE.mastered
           ,TARGET.percent_correct = SOURCE.percent_correct
           ,TARGET.points = SOURCE.points
           ,TARGET.points_possible	 = SOURCE.points_possible	
           ,TARGET.answered	= SOURCE.answered	           
           ,TARGET.number_of_questions = SOURCE.number_of_questions
      WHEN NOT MATCHED BY TARGET THEN
       INSERT
        (student_assessment_id
        ,updated_at
        ,local_student_id
        ,assessment_id
        ,standard_id
        ,performance_band_id
        ,performance_band_level
        ,mastered
        ,percent_correct
        ,points
        ,points_possible	
        ,answered	        
        ,number_of_questions)
       VALUES
        (SOURCE.student_assessment_id
        ,SOURCE.updated_at
        ,SOURCE.local_student_id
        ,SOURCE.assessment_id
        ,SOURCE.standard_id
        ,SOURCE.performance_band_id
        ,SOURCE.performance_band_level
        ,SOURCE.mastered
        ,SOURCE.percent_correct
        ,SOURCE.points
        ,SOURCE.points_possible	
        ,SOURCE.answered	        
        ,SOURCE.number_of_questions)
      WHEN NOT MATCHED BY SOURCE AND CONVERT(DATE,TARGET.updated_at) >= '2015-07-01' THEN
       DELETE
      --OUTPUT $ACTION, deleted.*
      ;
  END

END
GO
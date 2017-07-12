USE KIPP_NJ
GO

--ALTER VIEW TABLEAU$PARCC_dashboard AS

WITH external_prof AS (
  SELECT academic_year        
        ,testcode
        ,grade_level
        ,[NJ]
        ,[NPS]
        ,[CPS]
        ,[PARCC]        
  FROM
      (
       SELECT academic_year
             ,testcode
             ,grade_level
             ,entity
             ,pct_proficient
       FROM KIPP_NJ..AUTOLOAD$GDOCS_PARCC_external_proficiency_rates WITH(NOLOCK)
       WHERE (testcode IN ('ALG01','ALG02','GEO01') AND grade_level IS NULL)
          OR (testcode NOT IN ('ALG01','ALG02','GEO01') AND grade_level IS NOT NULL)
      ) sub
  PIVOT(
    MAX(pct_proficient)
    FOR entity IN ([NJ]
                  ,[NPS]
                  ,[PARCC]
                  ,[CPS])
   ) p
 ) 

SELECT co.student_number
      ,co.SID
      ,co.lastfirst
      ,co.year AS academic_year
      ,co.reporting_schoolid AS schoolid           
      ,co.grade_level            
      ,co.school_level     
      ,CASE WHEN co.schoolid LIKE '1799%' THEN 'Camden' ELSE 'Newark' END AS region      
      ,co.SPEDLEP      
      ,co.LEP_STATUS
      ,co.lunchstatus
      ,co.enroll_status
      
      ,'PARCC' AS test_type
      ,parcc.testcode
      ,parcc.subject      
      ,parcc.summativescalescore      
      ,parcc.summativeperformancelevel
      ,parcc.summativereadingscalescore            
      ,parcc.summativewritingscalescore                        

      ,parcc.pbatotaltestitems      
      ,parcc.pbatotaltestitemsattempted
      ,parcc.eoytotaltestitems                  
      ,parcc.eoytotaltestitemsattempted

      ,CASE WHEN co.enroll_status != 2 AND parcc.localstudentidentifier IS NULL THEN 1 ELSE 0 END AS is_optout
      ,CASE
        WHEN parcc.summativeperformancelevel >= 4 THEN 1
        WHEN parcc.summativeperformancelevel < 4 THEN 0
        ELSE NULL
       END AS is_prof

      ,ext.NJ AS pct_prof_NJ
      ,ext.NPS AS pct_prof_NPS
      ,ext.CPS AS pct_prof_CPS
      ,ext.PARCC AS pct_prof_PARCC       
FROM KIPP_NJ..PARCC$district_summative_record_file parcc WITH(NOLOCK)
JOIN KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK)
  ON parcc.statestudentidentifier = co.SID
 AND LEFT(parcc.assessmentYear, 4) = co.year
 AND co.rn = 1
LEFT OUTER JOIN external_prof ext WITH(NOLOCK)
  ON co.year = ext.academic_year
 AND parcc.testcode = ext.testcode   

UNION ALL

/* NJASK & HSPA */
SELECT co.student_number
      ,co.SID
      ,co.lastfirst
      ,co.year AS academic_year
      ,co.reporting_schoolid AS schoolid           
      ,co.grade_level            
      ,co.school_level     
      ,CASE WHEN co.schoolid LIKE '1799%' THEN 'Camden' ELSE 'Newark' END AS region      
      ,co.SPEDLEP
      ,co.LEP_STATUS
      ,co.lunchstatus
      ,co.enroll_status
      
      ,CASE
        WHEN co.schoolid = 73253 THEN 'HSPA'
        ELSE 'NJASK' 
       END AS test_type
      ,CONCAT(nj.subject, ' ', co.grade_level)  AS testcode
      ,nj.subject      
      ,nj.scale_score AS summativescalescore      
      ,CASE
        WHEN nj.prof_level IN ('Below Proficient','Partially Proficient') THEN 1
        WHEN nj.prof_level = 'Proficient' THEN 4
        WHEN nj.prof_level = 'Advanced Proficient' THEN 5
       END AS summativeperformancelevel      
      ,NULL AS summativereadingscalescore            
      ,NULL AS summativewritingscalescore                        

      ,NULL AS pbatotaltestitems      
      ,NULL AS pbatotaltestitemsattempted
      ,NULL AS eoytotaltestitems                  
      ,NULL AS eoytotaltestitemsattempted

      ,NULL AS is_optout
      ,nj.is_prof

      ,ext.NJ AS pct_prof_NJ
      ,ext.NPS AS pct_prof_NPS
      ,ext.CPS AS pct_prof_CPS
      ,ext.PARCC AS pct_prof_PARCC
FROM KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK)
JOIN KIPP_NJ..AUTOLOAD$GDOCS_STATE_njask_hspa_scores nj WITH(NOLOCK)
  ON co.student_number = nj.student_number
 AND co.year = nj.academic_year 
 AND nj.void_reason IS NULL
LEFT OUTER JOIN external_prof ext
  ON co.year = ext.academic_year
 AND co.grade_level = ext.grade_level
 AND nj.subject = ext.testcode
WHERE co.rn = 1

UNION ALL

/* NJASK SCIENCE */
SELECT co.student_number
      ,co.SID
      ,co.lastfirst
      ,co.year AS academic_year
      ,co.reporting_schoolid AS schoolid           
      ,co.grade_level            
      ,co.school_level     
      ,CASE WHEN co.schoolid LIKE '1799%' THEN 'Camden' ELSE 'Newark' END AS region      
      ,co.SPEDLEP
      ,co.LEP_STATUS
      ,co.lunchstatus
      ,co.enroll_status
      
      ,CASE
        WHEN co.schoolid = 73253 THEN 'HSPA'
        ELSE 'NJASK' 
       END AS test_type
      ,CONCAT('Science ', co.grade_level)  AS testcode
      ,'Science' AS subject      
      ,sci.science_scale_score AS summativescalescore      
      ,CASE
        WHEN sci.science_proficiency_level IN ('1','PARTIALLY PROFICIENT') THEN 1
        WHEN sci.science_proficiency_level IN ('2','PROFICIENT') THEN 4
        WHEN sci.science_proficiency_level IN ('3','ADVANCED PROFICIENT') THEN 5
       END AS summativeperformancelevel      
      ,NULL AS summativereadingscalescore            
      ,NULL AS summativewritingscalescore                        

      ,NULL AS pbatotaltestitems      
      ,NULL AS pbatotaltestitemsattempted
      ,NULL AS eoytotaltestitems                  
      ,NULL AS eoytotaltestitemsattempted

      ,NULL AS is_optout
      ,CASE
        WHEN sci.science_proficiency_level IN ('2','3','PROFICIENT','ADVANCED PROFICIENT') THEN 1
        WHEN sci.science_proficiency_level IN ('1','PARTIALLY PROFICIENT') THEN 0
       END AS is_prof

      ,ext.NJ AS pct_prof_NJ
      ,ext.NPS AS pct_prof_NPS
      ,ext.CPS AS pct_prof_CPS
      ,ext.PARCC AS pct_prof_PARCC
FROM KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK)
JOIN KIPP_NJ..AUTOLOAD$GDOCS_STATE_njask_science sci WITH(NOLOCK)
  ON co.SID = sci.SID
 AND co.year = (sci.testing_year - 1) 
 AND sci.science_proficiency_level IS NOT NULL
LEFT OUTER JOIN external_prof ext
  ON co.year = ext.academic_year
 AND co.grade_level = ext.grade_level
 AND ext.testcode = 'SCI'
WHERE co.rn = 1
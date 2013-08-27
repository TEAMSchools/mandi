USE KIPP_NJ
GO

ALTER VIEW LIT$FP_test_events_long#identifiers AS
SELECT openq.*
      ,cohort.schoolid
      ,cohort.grade_level
      ,cohort.abbreviation
      ,cohort.year
       --helps to determine first test event FOR a student IN a year
      ,ROW_NUMBER() OVER
         (PARTITION BY openq.studentid
                      ,cohort.year
          ORDER BY openq.test_date ASC) AS rn_asc
       --helps to determine last test event FOR a student IN a year
      ,ROW_NUMBER() OVER
         (PARTITION BY openq.studentid
                      ,cohort.year
          ORDER BY openq.test_date DESC) AS rn_desc

FROM OPENQUERY(PS_TEAM, '
  SELECT s.id AS studentid                                    
        ,s.lastfirst
        ,CAST(s.student_number AS VARCHAR(20)) AS student_number
        ,user_defined_date AS test_date
        ,CAST(user_defined_text AS VARCHAR(20)) AS step_level
        ,foreignkey_alpha AS testid
        ,user_defined_text2 AS status            
        ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field1'')  AS fp_wpmrate                  
        ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field2'')  AS fp_fluency
        ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field3'')  AS fp_accuracy
        ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field4'')  AS fp_comp_within
        ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field5'')  AS fp_comp_beyond
        ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field6'')  AS fp_comp_about
        ,CAST(PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field7'') AS VARCHAR(20)) AS fp_keylever
        --,CAST(PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field1'') AS VARCHAR(20)) AS read_teacher
  FROM virtualtablesdata3 scores
  JOIN students s
    ON s.id = scores.foreignKey 
  WHERE scores.related_to_table = ''readingScores'' 
    AND user_defined_text IS NOT NULL 
    AND foreignkey_alpha = ''3273''
') openq
JOIN COHORT$comprehensive_long cohort
  ON openq.studentid = cohort.studentid
 AND openq.test_date >= cohort.entrydate
 AND openq.test_date <= cohort.exitdate
 AND cohort.rn = 1
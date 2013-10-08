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
         (PARTITION BY openq.studentid, cohort.year
              ORDER BY openq.test_date ASC) AS rn_asc
       --helps to determine last test event FOR a student IN a year
      ,ROW_NUMBER() OVER
         (PARTITION BY openq.studentid, cohort.year
              ORDER BY openq.test_date DESC) AS rn_desc
      ,CASE
        WHEN letter_level = 'AA' THEN 0.0
        WHEN letter_level = 'A' THEN 0.3
        WHEN letter_level = 'B' THEN 0.5
        WHEN letter_level = 'C' THEN 0.7
        WHEN letter_level = 'D' THEN 1.0
        WHEN letter_level = 'E' THEN 1.2
        WHEN letter_level = 'F' THEN 1.4
        WHEN letter_level = 'G' THEN 1.6
        WHEN letter_level = 'H' THEN 1.8
        WHEN letter_level = 'I' THEN 2.0
        WHEN letter_level = 'J' THEN 2.2
        WHEN letter_level = 'K' THEN 2.4
        WHEN letter_level = 'L' THEN 2.6
        WHEN letter_level = 'M' THEN 2.8
        WHEN letter_level = 'N' THEN 3.0
        WHEN letter_level = 'O' THEN 3.5
        WHEN letter_level = 'P' THEN 3.8
        WHEN letter_level = 'Q' THEN 4.0
        WHEN letter_level = 'R' THEN 4.5
        WHEN letter_level = 'S' THEN 4.8
        WHEN letter_level = 'T' THEN 5.0
        WHEN letter_level = 'U' THEN 5.5
        WHEN letter_level = 'V' THEN 6.0
        WHEN letter_level = 'W' THEN 6.3
        WHEN letter_level = 'X' THEN 6.7
        WHEN letter_level = 'Y' THEN 7.0
        WHEN letter_level = 'Z' THEN 7.5
        WHEN letter_level = 'Z+' THEN 8.0
        ELSE NULL
       END AS GLEQ
      ,CASE
        WHEN letter_level = 'AA' THEN 0
        WHEN letter_level = 'A' THEN 1
        WHEN letter_level = 'B' THEN 2
        WHEN letter_level = 'C' THEN 3
        WHEN letter_level = 'D' THEN 4
        WHEN letter_level = 'E' THEN 5
        WHEN letter_level = 'F' THEN 6
        WHEN letter_level = 'G' THEN 7
        WHEN letter_level = 'H' THEN 8
        WHEN letter_level = 'I' THEN 9
        WHEN letter_level = 'J' THEN 10
        WHEN letter_level = 'K' THEN 11
        WHEN letter_level = 'L' THEN 12
        WHEN letter_level = 'M' THEN 13
        WHEN letter_level = 'N' THEN 14
        WHEN letter_level = 'O' THEN 15
        WHEN letter_level = 'P' THEN 16
        WHEN letter_level = 'Q' THEN 17
        WHEN letter_level = 'R' THEN 18
        WHEN letter_level = 'S' THEN 19
        WHEN letter_level = 'T' THEN 20
        WHEN letter_level = 'U' THEN 21
        WHEN letter_level = 'V' THEN 22
        WHEN letter_level = 'W' THEN 23
        WHEN letter_level = 'X' THEN 24
        WHEN letter_level = 'Y' THEN 25
        WHEN letter_level = 'Z' THEN 26
        WHEN letter_level = 'Z+' THEN 27
        ELSE NULL
       END AS level_number

FROM OPENQUERY(PS_TEAM,'
  SELECT s.id AS studentid                                    
        ,s.lastfirst        
        ,CAST(s.student_number AS VARCHAR(20)) AS student_number
        ,user_defined_date AS test_date
        ,CAST(user_defined_text AS VARCHAR(20)) AS letter_level
        ,foreignkey_alpha AS testid
        ,user_defined_text2 AS status           
        ,ROUND(PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field1''),0)  AS fp_wpmrate                  
        ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field2'')  AS fp_fluency
        ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field3'')  AS fp_accuracy
        ,CAST(PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field4'') AS INT)  AS fp_comp_within
        ,CAST(PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field5'') AS INT)  AS fp_comp_beyond
        ,CAST(PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field6'') AS INT)  AS fp_comp_about
        ,CAST(PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field7'') AS VARCHAR(20)) AS fp_keylever
        ,CAST(PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field21'') AS VARCHAR(20)) AS read_teacher
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
GROUP BY openq.studentid, openq.lastfirst, openq.student_number, openq.test_date, openq.letter_level, openq.testid, openq.status, openq.fp_wpmrate, openq.fp_fluency, openq.fp_accuracy, openq.fp_comp_within, openq.fp_comp_beyond, openq.fp_comp_about, openq.fp_keylever, openq.read_teacher, cohort.schoolid, cohort.grade_level, cohort.abbreviation, cohort.year
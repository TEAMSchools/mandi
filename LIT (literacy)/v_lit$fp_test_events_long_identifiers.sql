USE KIPP_NJ
GO

ALTER VIEW LIT$FP_test_events_long#identifiers AS
SELECT s.id AS studentid
      ,s.student_number
      ,cohort.schoolid
      ,cohort.grade_level
      ,cohort.abbreviation
      ,cohort.year    
      ,scores.test_date
      ,scores.step_ltr_level AS letter_level
      ,scores.testid
      ,scores.status           
      ,scores.fp_wpmrate                  
      ,scores.fp_fluency
      ,scores.fp_accuracy
      ,scores.fp_comp_within
      ,scores.fp_comp_beyond
      ,scores.fp_comp_about
      ,scores.fp_keylever
      ,scores.read_teacher
       --helps to determine first test ACHIEVED for a student IN a year
      ,ROW_NUMBER() OVER(
          PARTITION BY scores.studentid, cohort.year
              ORDER BY scores.test_date ASC) AS rn_asc       
       --helps to determine last test event FOR a student IN a year
      ,ROW_NUMBER() OVER(
          PARTITION BY scores.studentid, cohort.year
              ORDER BY scores.test_date DESC) AS rn_desc
      ,CASE
        WHEN scores.status = 'Did Not Achieve' THEN NULL
        ELSE ROW_NUMBER() OVER(
             PARTITION BY scores.studentid, cohort.year, scores.status
                 ORDER BY scores.test_date ASC)
       END AS achv_base
       --helps to determine last test event FOR a student IN a year
      ,CASE
        WHEN scores.status = 'Did Not Achieve' THEN NULL
        ELSE ROW_NUMBER() OVER(
             PARTITION BY scores.studentid, cohort.year, scores.status
                 ORDER BY scores.test_date DESC)
       END AS achv_curr      
FROM STUDENTS s
JOIN READINGSCORES scores
  ON s.id = scores.studentid
LEFT OUTER JOIN COHORT$comprehensive_long#static cohort
  ON scores.studentid = cohort.studentid
 AND scores.test_date >= cohort.entrydate
 AND scores.test_date <= cohort.exitdate
 AND cohort.rn = 1
WHERE scores.testid = 3273
  AND s.ENROLL_STATUS = 0
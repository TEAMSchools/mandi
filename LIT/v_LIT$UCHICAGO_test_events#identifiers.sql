USE KIPP_NJ
GO

ALTER VIEW LIT$UCHICAGO_test_events#identifiers AS

SELECT DISTINCT 
       CONCAT('UC', KIPP_NJ.dbo.fn_DateToSY(CONVERT(DATE,step.date)), step.[index]) AS unique_id      
      ,step.studentid AS student_number      
      ,KIPP_NJ.dbo.fn_DateToSY(CONVERT(DATE,step.date)) AS academic_year      
      ,CONVERT(DATE,step.date) AS test_date
      ,CASE WHEN step.step = 0 THEN 'Pre' ELSE CONVERT(VARCHAR,step.step) END AS read_lvl
      ,CONVERT(INT,step.step) AS lvl_num            
      ,CASE 
        WHEN step.passed = 1 THEN 'Achieved'
        WHEN step.passed = 0 THEN 'Did Not Achieve'
       END AS status                 
      ,CASE               
        WHEN CONVERT(INT,step.step) = 0 THEN 3280
        WHEN CONVERT(INT,step.step) = 1 THEN 3281
        WHEN CONVERT(INT,step.step) = 2 THEN 3282
        WHEN CONVERT(INT,step.step) = 3 THEN 3380
        WHEN CONVERT(INT,step.step) = 4 THEN 3397
        WHEN CONVERT(INT,step.step) = 5 THEN 3411
        WHEN CONVERT(INT,step.step) = 6 THEN 3425
        WHEN CONVERT(INT,step.step) = 7 THEN 3441
        WHEN CONVERT(INT,step.step) = 8 THEN 3458
        WHEN CONVERT(INT,step.step) = 9 THEN 3474
        WHEN CONVERT(INT,step.step) = 10 THEN 3493
        WHEN CONVERT(INT,step.step) = 11 THEN 3511
        WHEN CONVERT(INT,step.step) = 12 THEN 3527
       END AS ps_testid      
      ,step.book AS color                  
      ,CONVERT(VARCHAR,step.notes) AS notes
      ,step.Recorder AS recorder

      ,gleq.gleq      
      
      ,co.studentid
      ,co.lastfirst      
      ,co.schoolid
      ,co.grade_level      

      ,dt.time_per_name AS test_round
      ,CASE
        WHEN dt.time_per_name = 'DR' THEN 1
        WHEN dt.time_per_name = 'Q1' THEN 2
        WHEN dt.time_per_name = 'Q2' THEN 3
        WHEN dt.time_per_name = 'Q3' THEN 4
        WHEN dt.time_per_name = 'Q4' THEN 5
       END AS round_num     
FROM KIPP_NJ..[AUTOLOAD$STEP_Level_Assessment_Data_long] step WITH(NOLOCK)
LEFT OUTER JOIN KIPP_NJ..AUTOLOAD$GDOCS_LIT_gleq gleq WITH(NOLOCK)
  ON CONVERT(INT,step.step) = gleq.lvl_num
 AND gleq.testid != 3273
LEFT OUTER JOIN KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK)
  ON step.studentid = co.student_number
 AND KIPP_NJ.dbo.fn_DateToSY(CONVERT(DATE,step.date)) = co.year
 AND co.rn = 1
LEFT OUTER JOIN KIPP_NJ..REPORTING$dates dt WITH(NOLOCK)
  ON co.schoolid = dt.schoolid
 AND CONVERT(DATE,step.date) BETWEEN dt.start_date AND dt.end_date
 AND dt.identifier = 'LIT'

UNION ALL

/* ACHIEVED PRE DNA */
SELECT DISTINCT 
       CONCAT('UC', KIPP_NJ.dbo.fn_DateToSY(CONVERT(DATE,step.date)), step.[index]) AS unique_id      
      ,step.studentid AS student_number      
      ,KIPP_NJ.dbo.fn_DateToSY(CONVERT(DATE,step.date)) AS academic_year      
      ,CONVERT(DATE,step.date) AS test_date
      ,'Pre DNA' AS read_lvl
      ,-1 AS lvl_num            
      ,'Achieved' AS status                 
      ,3280 AS ps_testid      
      ,step.book AS color                  
      ,CONVERT(VARCHAR,step.notes) AS notes
      ,step.Recorder AS recorder

      ,-1 AS gleq
      
      ,co.studentid
      ,co.lastfirst      
      ,co.schoolid
      ,co.grade_level      

      ,dt.time_per_name AS test_round
      ,CASE
        WHEN dt.time_per_name = 'DR' THEN 1
        WHEN dt.time_per_name = 'Q1' THEN 2
        WHEN dt.time_per_name = 'Q2' THEN 3
        WHEN dt.time_per_name = 'Q3' THEN 4
        WHEN dt.time_per_name = 'Q4' THEN 5
       END AS round_num     
FROM KIPP_NJ..[AUTOLOAD$STEP_Level_Assessment_Data_long] step WITH(NOLOCK)
LEFT OUTER JOIN KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK)
  ON step.studentid = co.student_number
 AND KIPP_NJ.dbo.fn_DateToSY(CONVERT(DATE,step.date)) = co.year
 AND co.rn = 1
LEFT OUTER JOIN KIPP_NJ..REPORTING$dates dt WITH(NOLOCK)
  ON co.schoolid = dt.schoolid
 AND CONVERT(DATE,step.date) BETWEEN dt.start_date AND dt.end_date
 AND dt.identifier = 'LIT'
WHERE step.Step = 0
  AND step.Passed = 0

UNION ALL

/* ARCHIVE */
SELECT DISTINCT 
       CONCAT('UC', step.academic_year, step.[index]) AS unique_id      
      ,step.studentid AS student_number      
      ,step.academic_year      
      ,CONVERT(DATE,step.date) AS test_date
      ,CASE WHEN step.step = 0 THEN 'Pre' ELSE CONVERT(VARCHAR,step.step) END AS read_lvl
      ,CONVERT(INT,step.step) AS lvl_num            
      ,CASE 
        WHEN step.passed = 1 THEN 'Achieved'
        WHEN step.passed = 0 THEN 'Did Not Achieve'
       END AS status                 
      ,CASE               
        WHEN CONVERT(INT,step.step) = 0 THEN 3280
        WHEN CONVERT(INT,step.step) = 1 THEN 3281
        WHEN CONVERT(INT,step.step) = 2 THEN 3282
        WHEN CONVERT(INT,step.step) = 3 THEN 3380
        WHEN CONVERT(INT,step.step) = 4 THEN 3397
        WHEN CONVERT(INT,step.step) = 5 THEN 3411
        WHEN CONVERT(INT,step.step) = 6 THEN 3425
        WHEN CONVERT(INT,step.step) = 7 THEN 3441
        WHEN CONVERT(INT,step.step) = 8 THEN 3458
        WHEN CONVERT(INT,step.step) = 9 THEN 3474
        WHEN CONVERT(INT,step.step) = 10 THEN 3493
        WHEN CONVERT(INT,step.step) = 11 THEN 3511
        WHEN CONVERT(INT,step.step) = 12 THEN 3527
       END AS ps_testid      
      ,step.book AS color                  
      ,CONVERT(VARCHAR,step.notes) AS notes
      ,step.Recorder AS recorder

      ,gleq.gleq      
      
      ,co.studentid
      ,co.lastfirst      
      ,co.schoolid
      ,co.grade_level      

      ,dt.time_per_name AS test_round
      ,CASE
        WHEN dt.time_per_name = 'DR' THEN 1
        WHEN dt.time_per_name = 'Q1' THEN 2
        WHEN dt.time_per_name = 'Q2' THEN 3
        WHEN dt.time_per_name = 'Q3' THEN 4
        WHEN dt.time_per_name = 'Q4' THEN 5
       END AS round_num     
FROM KIPP_NJ..LIT$STEP_Level_Assessment_Data#archive step WITH(NOLOCK)
LEFT OUTER JOIN KIPP_NJ..AUTOLOAD$GDOCS_LIT_gleq gleq WITH(NOLOCK)
  ON CONVERT(INT,step.step) = gleq.lvl_num
 AND gleq.testid != 3273
LEFT OUTER JOIN KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK)
  ON step.studentid = co.student_number
 AND KIPP_NJ.dbo.fn_DateToSY(CONVERT(DATE,step.date)) = co.year
 AND co.rn = 1
LEFT OUTER JOIN KIPP_NJ..REPORTING$dates dt WITH(NOLOCK)
  ON co.schoolid = dt.schoolid
 AND CONVERT(DATE,step.date) BETWEEN dt.start_date AND dt.end_date
 AND dt.identifier = 'LIT'
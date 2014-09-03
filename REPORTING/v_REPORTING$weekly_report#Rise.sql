USE KIPP_NJ
GO

--ALTER VIEW REPORTING$weekly_report#Rise AS

WITH roster AS (
  SELECT s.STUDENT_NUMBER
        ,s.id AS studentid
        ,s.LASTFIRST
        ,s.FIRST_NAME + ' ' + s.LAST_NAME AS full_name
        ,s.team
  FROM STUDENTS s WITH(NOLOCK)
  WHERE s.ENROLL_STATUS = 0
    AND s.SCHOOLID = 73252
    AND s.GRADE_LEVEL = 8
 )

-- thurs to wed
,reporting_week AS (
  SELECT date
        ,day_of_week
  FROM UTIL$reporting_days days WITH(NOLOCK)
  WHERE CONVERT(INT,CONVERT(VARCHAR,days.year_part) + CONVERT(VARCHAR,days.week_part) + CONVERT(VARCHAR,dw_numeric)) >= CONVERT(INT,CONVERT(VARCHAR,DATEPART(YEAR,GETDATE())) + CONVERT(VARCHAR,DATEPART(WEEK,GETDATE()) - 1) + '5')
    AND CONVERT(INT,CONVERT(VARCHAR,days.year_part) + CONVERT(VARCHAR,days.week_part) + CONVERT(VARCHAR,dw_numeric)) <= CONVERT(INT,CONVERT(VARCHAR,DATEPART(YEAR,GETDATE())) + CONVERT(VARCHAR,DATEPART(WEEK,GETDATE())) + '4')
  --WHERE date >= '2014-08-14'
  --  AND date <= '2014-09-03'
 )

-- start and end days
,date_strings AS (
  SELECT LEFT(CONVERT(VARCHAR,MIN(date), 1), 5) AS start_date      
        ,LEFT(CONVERT(VARCHAR,MAX(date), 1), 5) AS end_date
        ,DATENAME(WEEKDAY,MIN(date)) AS start_date_str
        ,DATENAME(WEEKDAY,MAX(date)) AS end_date_str
  FROM reporting_week
 )

-- long data from daily tracking
,ccr_long AS (
  SELECT dt.studentid
        ,att_date        
        ,dt.class
        ,CASE WHEN dt.class = 'other' AND dt.ccr NOT IN ('N', 'U') THEN NULL ELSE dt.ccr END AS ccr
        ,CASE WHEN dt.class = 'other' AND dt.ccr NOT IN ('N', 'U') THEN NULL ELSE dt.ccr_score END AS ccr_score
  FROM DAILY$tracking_long#Rise dt WITH(NOLOCK)
)

-- ccr data wide by class and day of week
,ccr_wide AS (
  SELECT studentid
        ,[mon_adv_behavior]
        ,NULL AS [mon_adv_logistic]
        ,NULL AS [mon_elec]
        ,[mon_history]
        ,[mon_math]
        ,[mon_other]
        ,[mon_reading]
        ,[mon_science]
        ,[mon_writing]      
        ,[tue_adv_behavior]
        ,NULL AS [tue_adv_logistic]
        ,NULL AS [tue_elec]
        ,[tue_history]
        ,[tue_math]
        ,[tue_other]
        ,[tue_reading]
        ,[tue_science]
        ,[tue_writing]
        ,[wed_adv_behavior]
        ,NULL AS [wed_adv_logistic]
        ,NULL AS [wed_elec]
        ,[wed_history]
        ,[wed_math]
        ,[wed_other]
        ,[wed_reading]
        ,[wed_science]
        ,[wed_writing]
        ,[thu_adv_behavior]
        ,NULL AS [thu_adv_logistic]
        ,NULL AS [thu_elec]
        ,[thu_history]
        ,[thu_math]
        ,[thu_other]
        ,[thu_reading]
        ,[thu_science]
        ,[thu_writing]
        ,[fri_adv_behavior]
        ,NULL AS [fri_adv_logistic]
        ,NULL AS [fri_elec]
        ,[fri_history]
        ,[fri_math]
        ,[fri_other]
        ,[fri_reading]
        ,[fri_science]
        ,[fri_writing]
  FROM
      (
       SELECT ccr_long.studentid           
             ,LEFT(LOWER(wk.day_of_week), 3) + '_' + ccr_long.class AS hash
             ,ccr_long.ccr      
       FROM ccr_long
       JOIN reporting_week wk  
         ON wk.date = ccr_long.att_date
      ) sub

  PIVOT (
    MAX(ccr)
    FOR hash IN ([mon_adv_behavior]
                ,[mon_adv_logistic]
                ,[mon_elec]
                ,[mon_history]
                ,[mon_math]
                ,[mon_other]
                ,[mon_reading]
                ,[mon_science]
                ,[mon_writing]
                ,[thu_adv_behavior]
                ,[thu_adv_logistic]
                ,[thu_elec]
                ,[thu_history]
                ,[thu_math]
                ,[thu_other]
                ,[thu_reading]
                ,[thu_science]
                ,[thu_writing]
                ,[tue_adv_behavior]
                ,[tue_adv_logistic]
                ,[tue_elec]
                ,[tue_history]
                ,[tue_math]
                ,[tue_other]
                ,[tue_reading]
                ,[tue_science]
                ,[tue_writing]
                ,[wed_adv_behavior]
                ,[wed_adv_logistic]
                ,[wed_elec]
                ,[wed_history]
                ,[wed_math]
                ,[wed_other]
                ,[wed_reading]
                ,[wed_science]
                ,[wed_writing]
                ,[fri_adv_behavior]
                ,[fri_adv_logistic]
                ,[fri_elec]
                ,[fri_history]
                ,[fri_math]
                ,[fri_other]
                ,[fri_reading]
                ,[fri_science]
                ,[fri_writing])
   ) p
 )

-- totals based on days entered
-- denominator will be smaller if students aren't present or if data is not entered for that day
,ccr_totals AS (
  SELECT studentid
        ,SUM(ccr_score) AS ccr_total
        ,COUNT(ccr_score) AS ccr_poss
        ,ROUND(SUM(CONVERT(FLOAT,ccr_score)) / COUNT(CONVERT(FLOAT,ccr_score)) * 100, 0) AS ccr_pct
  FROM ccr_long
  GROUP BY studentid
 )

SELECT r.STUDENT_NUMBER
      ,r.studentid
      ,r.LASTFIRST
      ,r.full_name
      ,r.TEAM      
      
      -- date stuff
      ,ds.start_date_str
      ,ds.start_date      
      ,ds.end_date_str
      ,ds.end_date
      
      --  ccr totals
      ,ccr_totals.ccr_poss
      ,ccr_totals.ccr_total
      ,ccr_totals.ccr_pct
      
      -- hw totals
      ,NULL AS hwc_avg
      ,NULL AS hwq_avg
      ,NULL AS fun_friday_avg
      
      -- ccr wide
      ,ccr_wide.mon_adv_behavior
      ,ccr_wide.mon_adv_logistic
      ,ccr_wide.mon_elec
      ,ccr_wide.mon_history
      ,ccr_wide.mon_math
      ,ccr_wide.mon_other
      ,ccr_wide.mon_reading
      ,ccr_wide.mon_science
      ,ccr_wide.mon_writing      
      ,ccr_wide.tue_adv_behavior
      ,ccr_wide.tue_adv_logistic
      ,ccr_wide.tue_elec
      ,ccr_wide.tue_history
      ,ccr_wide.tue_math
      ,ccr_wide.tue_other
      ,ccr_wide.tue_reading
      ,ccr_wide.tue_science
      ,ccr_wide.tue_writing
      ,ccr_wide.wed_adv_behavior
      ,ccr_wide.wed_adv_logistic
      ,ccr_wide.wed_elec
      ,ccr_wide.wed_history
      ,ccr_wide.wed_math
      ,ccr_wide.wed_other
      ,ccr_wide.wed_reading
      ,ccr_wide.wed_science
      ,ccr_wide.wed_writing
      ,ccr_wide.thu_adv_behavior
      ,ccr_wide.thu_adv_logistic
      ,ccr_wide.thu_elec
      ,ccr_wide.thu_history
      ,ccr_wide.thu_math
      ,ccr_wide.thu_other
      ,ccr_wide.thu_reading
      ,ccr_wide.thu_science
      ,ccr_wide.thu_writing
      ,ccr_wide.fri_adv_behavior
      ,ccr_wide.fri_adv_logistic
      ,ccr_wide.fri_elec
      ,ccr_wide.fri_history
      ,ccr_wide.fri_math
      ,ccr_wide.fri_other
      ,ccr_wide.fri_reading
      ,ccr_wide.fri_science
      ,ccr_wide.fri_writing
      
      -- hw wide
      ,NULL AS hist_asmt_1
      ,NULL AS hist_asmt_2
      ,NULL AS hist_score_1
      ,NULL AS hist_score_2
      ,NULL AS math_asmt_1
      ,NULL AS math_asmt_2
      ,NULL AS math_score_1
      ,NULL AS math_score_2
      ,NULL AS read_asmt_1
      ,NULL AS read_asmt_2
      ,NULL AS read_score_1
      ,NULL AS read_score_2
      ,NULL AS rhet_asmt_1
      ,NULL AS rhet_asmt_2
      ,NULL AS rhet_score_1
      ,NULL AS rhet_score_2
      ,NULL AS sci_asmt_1
      ,NULL AS sci_asmt_2
      ,NULL AS sci_score_1
      ,NULL AS sci_score_2
      ,NULL AS soc_asmt_1
      ,NULL AS soc_asmt_2
      ,NULL AS soc_score_1
      ,NULL AS soc_score_2
FROM roster r
JOIN date_strings ds
  ON 1 = 1
JOIN ccr_totals
  ON r.studentid = ccr_totals.studentid
JOIN ccr_wide
  ON r.studentid = ccr_wide.studentid
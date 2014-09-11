USE KIPP_NJ
GO

ALTER VIEW REPORTING$weekly_report#Rise AS

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
    AND DATEPART(DAY,date) NOT IN (6,7)
  --WHERE date >= '2014-08-14' -- in case of vacations
    --AND date <= '2014-09-03' -- in case of vacations
 )

-- start and end days
,date_strings AS (
  SELECT LEFT(CONVERT(VARCHAR,MIN(date), 1), 5) AS start_date      
        ,LEFT(CONVERT(VARCHAR,MAX(date), 1), 5) AS end_date
        ,DATENAME(WEEKDAY,MIN(date)) AS start_date_str
        ,DATENAME(WEEKDAY,MAX(date)) AS end_date_str
  FROM reporting_week WITH(NOLOCK)
 )

-- long data from daily tracking
,ccr_long AS (
  SELECT dt.studentid
        ,att_date        
        ,dt.class
        ,CASE WHEN dt.class = 'other' AND dt.ccr NOT IN ('N', 'U') THEN NULL ELSE dt.ccr END AS ccr
        ,CASE WHEN dt.class = 'other' AND dt.ccr NOT IN ('N', 'U') THEN NULL ELSE dt.ccr_score END AS ccr_score
  FROM DAILY$tracking_long#Rise#static dt WITH(NOLOCK)
  WHERE att_date IN (SELECT date FROM reporting_week WITH(NOLOCK))
)

-- ccr data wide by class and day of week
,ccr_wide AS (
  SELECT studentid
        ,[mon_adv_behavior]
        ,[mon_adv_logistic]
        ,[mon_elec]
        ,[mon_history]
        ,[mon_math]
        ,[mon_other]
        ,[mon_reading]
        ,[mon_science]
        ,[mon_writing]      
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
        ,[thu_adv_behavior]
        ,[thu_adv_logistic]
        ,[thu_elec]
        ,[thu_history]
        ,[thu_math]
        ,[thu_other]
        ,[thu_reading]
        ,[thu_science]
        ,[thu_writing]
        ,[fri_adv_behavior]
        ,[fri_adv_logistic]
        ,[fri_elec]
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
       FROM ccr_long WITH(NOLOCK)
       JOIN reporting_week wk WITH(NOLOCK)
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
  FROM ccr_long WITH(NOLOCK)
  GROUP BY studentid
 )

,weekly_assignments AS (
  SELECT asmt.sectionid
        ,sec.course_number
        ,cou.credittype
        ,asmt.ASSIGNMENTID
        ,asmt.ASSIGN_NAME
        ,asmt.POINTSPOSSIBLE
        ,asmt.CATEGORY        
  FROM GRADES$assignments#static asmt WITH(NOLOCK)
  JOIN sections sec WITH(NOLOCK)
    ON asmt.sectionid = sec.id
   AND sec.SCHOOLID = 73252
   AND sec.termid = dbo.fn_Global_Term_Id()
   AND sec.GRADE_LEVEL = 8
  JOIN COURSES cou WITH(NOLOCK)
    ON sec.COURSE_NUMBER = cou.COURSE_NUMBER
  WHERE asmt.ASSIGN_DATE IN (SELECT date FROM reporting_week WITH(NOLOCK))
    AND asmt.CATEGORY IN ('HQ','HWQ','HWA','Q')
 )

,assignment_scores AS (
  SELECT s.ASSIGNMENTID
        ,STUDENT_NUMBER
        ,CONVERT(FLOAT,ROUND(s.SCORE / a.POINTSPOSSIBLE * 100,0)) AS score_numeric        
        ,CASE WHEN EXEMPT = 1 THEN 'Ex' ELSE CONVERT(VARCHAR,CONVERT(FLOAT,ROUND(s.SCORE / a.POINTSPOSSIBLE * 100,0))) END AS score_text
  FROM GRADES$assignment_scores#static s WITH(NOLOCK)
  JOIN weekly_assignments a WITH(NOLOCK)
    ON s.ASSIGNMENTID = a.ASSIGNMENTID
  WHERE s.ASSIGNMENTID IN (SELECT ASSIGNMENTID FROM weekly_assignments WITH(NOLOCK))
 )

,names_wide AS (
  SELECT *
  FROM
      (
       SELECT LOWER(asmt.credittype) + '_assign_'
                + CONVERT(VARCHAR,ROW_NUMBER() OVER(
                    PARTITION BY asmt.credittype, scores.student_number
                      ORDER BY asmt.assign_name)) AS name_hash           
             ,asmt.assign_name
             ,scores.student_number           
       FROM weekly_assignments asmt WITH(NOLOCK)
       JOIN assignment_scores scores WITH(NOLOCK)
         On asmt.assignmentid = scores.assignmentid
      ) sub
  PIVOT (
    MAX(assign_name)
    FOR name_hash IN ([eng_assign_1]
                     ,[eng_assign_2]
                     ,[eng_assign_3]
                     ,[eng_assign_4]
                     ,[eng_assign_5]
                     ,[math_assign_1]
                     ,[math_assign_2]
                     ,[math_assign_3]
                     ,[math_assign_4]
                     ,[math_assign_5]
                     ,[sci_assign_1]
                     ,[sci_assign_2]
                     ,[sci_assign_3]
                     ,[sci_assign_4]
                     ,[sci_assign_5]
                     ,[rhet_assign_1]
                     ,[rhet_assign_2]
                     ,[rhet_assign_3]
                     ,[rhet_assign_4]
                     ,[rhet_assign_5]
                     ,[soc_assign_1]
                     ,[soc_assign_2]
                     ,[soc_assign_3]
                     ,[soc_assign_4]
                     ,[soc_assign_5])
   ) p
)

,scores_wide AS (
  SELECT *
  FROM
      (
       SELECT LOWER(asmt.credittype) + '_score_'
                + CONVERT(VARCHAR,ROW_NUMBER() OVER(
                    PARTITION BY asmt.credittype, scores.student_number
                      ORDER BY asmt.assign_name)) AS score_hash           
             ,scores.student_number
             ,scores.score_text
       FROM weekly_assignments asmt WITH(NOLOCK)
       JOIN assignment_scores scores WITH(NOLOCK)
         ON asmt.assignmentid = scores.assignmentid
      ) sub
  PIVOT (
    MAX(score_text)
    FOR score_hash IN ([eng_score_1]
                      ,[eng_score_2]
                      ,[eng_score_3]
                      ,[eng_score_4]
                      ,[eng_score_5]
                      ,[math_score_1]
                      ,[math_score_2]
                      ,[math_score_3]
                      ,[math_score_4]
                      ,[math_score_5]
                      ,[sci_score_1]
                      ,[sci_score_2]
                      ,[sci_score_3]
                      ,[sci_score_4]
                      ,[sci_score_5]
                      ,[rhet_score_1]
                      ,[rhet_score_2]
                      ,[rhet_score_3]
                      ,[rhet_score_4]
                      ,[rhet_score_5]
                      ,[soc_score_1]
                      ,[soc_score_2]
                      ,[soc_score_3]
                      ,[soc_score_4]
                      ,[soc_score_5])
   ) p2
 )

,scores_totals AS (
  SELECT student_number
        ,AVG(score_numeric) AS hwq_avg
  FROM assignment_scores WITH(NOLOCK)
  GROUP BY student_number
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
      ,ROUND(CONVERT(FLOAT,scores_totals.hwq_avg),0) AS hwq_avg
      ,ROUND((scores_totals.hwq_avg + ccr_totals.ccr_pct) / 2, 0) AS fun_friday_avg
      ,CASE         
        WHEN ROUND((scores_totals.hwq_avg + ccr_totals.ccr_pct) / 2, 0) >= 80 THEN 'Yes' 
        WHEN ROUND((scores_totals.hwq_avg + ccr_totals.ccr_pct) / 2, 0) < 80 THEN 'No' 
        ELSE NULL
       END AS fun_friday_status
      ,ROUND(CONVERT(FLOAT,scores_totals.hwq_avg),0) AS dress_down_avg
      ,CASE 
        WHEN ROUND(CONVERT(FLOAT,scores_totals.hwq_avg),0) >= 85 THEN 'Yes' 
        WHEN ROUND(CONVERT(FLOAT,scores_totals.hwq_avg),0) < 85 THEN 'No' 
        ELSE NULL
       END AS dress_down_status
      
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
      ,[eng_assign_1]
      ,[eng_assign_2]
      ,[eng_assign_3]
      ,[eng_assign_4]
      ,[eng_assign_5]
      ,[math_assign_1]
      ,[math_assign_2]
      ,[math_assign_3]
      ,[math_assign_4]
      ,[math_assign_5]
      ,[sci_assign_1]
      ,[sci_assign_2]
      ,[sci_assign_3]
      ,[sci_assign_4]
      ,[sci_assign_5]
      ,[rhet_assign_1]
      ,[rhet_assign_2]
      ,[rhet_assign_3]
      ,[rhet_assign_4]
      ,[rhet_assign_5]
      ,[soc_assign_1]
      ,[soc_assign_2]
      ,[soc_assign_3]
      ,[soc_assign_4]
      ,[soc_assign_5]
      ,[eng_score_1]
      ,[eng_score_2]
      ,[eng_score_3]
      ,[eng_score_4]
      ,[eng_score_5]
      ,[math_score_1]
      ,[math_score_2]
      ,[math_score_3]
      ,[math_score_4]
      ,[math_score_5]
      ,[sci_score_1]
      ,[sci_score_2]
      ,[sci_score_3]
      ,[sci_score_4]
      ,[sci_score_5]
      ,[rhet_score_1]
      ,[rhet_score_2]
      ,[rhet_score_3]
      ,[rhet_score_4]
      ,[rhet_score_5]
      ,[soc_score_1]
      ,[soc_score_2]
      ,[soc_score_3]
      ,[soc_score_4]
      ,[soc_score_5]
FROM roster r WITH(NOLOCK)
JOIN date_strings ds WITH(NOLOCK)
  ON 1 = 1
LEFT OUTER JOIN ccr_totals WITH(NOLOCK)
  ON r.studentid = ccr_totals.studentid
LEFT OUTER JOIN ccr_wide WITH(NOLOCK)
  ON r.studentid = ccr_wide.studentid
LEFT OUTER JOIN names_wide WITH(NOLOCK)
  ON r.STUDENT_NUMBER = names_wide.STUDENT_NUMBER
LEFT OUTER JOIN scores_wide WITH(NOLOCK)
  ON r.STUDENT_NUMBER = scores_wide.STUDENT_NUMBER
LEFT OUTER JOIN scores_totals WITH(NOLOCK)
  ON r.STUDENT_NUMBER = scores_totals.STUDENT_NUMBER
USE KIPP_NJ
GO

ALTER VIEW TABLEAU$leadership_rollup#TEAM AS

WITH roster AS (
  SELECT co.studentid
        ,co.STUDENT_NUMBER
        ,co.schoolid
        ,co.lastfirst
        ,co.grade_level
        ,co.team
        ,co.GENDER
        ,co.SPEDLEP
        ,co.entrydate
        ,co.exitdate
  FROM COHORT$identifiers_long#static co WITH(NOLOCK)  
  WHERE co.year = dbo.fn_Global_Academic_Year()  
    AND co.schoolid = 133570965
    AND co.rn = 1
 )

,reporting_weeks AS (
  SELECT wk.reporting_hash
        ,wk.weekday_start
        ,wk.weekday_end
        ,dt.alt_name AS term
  FROM UTIL$reporting_weeks_days wk WITH(NOLOCK)
  JOIN REPORTING$dates dt WITH(NOLOCK)
    ON wk.weekday_start >= dt.start_date
   AND wk.weekday_end <= dt.end_date
   AND wk.academic_year = dt.academic_year
   AND dt.identifier = 'RT'
   AND dt.schoolid = 133570965
  WHERE wk.academic_year = dbo.fn_Global_Academic_Year()
 )

,term_grades AS (
  SELECT STUDENT_NUMBER      
        ,term
        ,CASE WHEN SUM(term_failing) > 0 THEN 0 ELSE 1 END AS is_passing
        ,SUM(term_failing) AS n_failing
        ,dbo.GROUP_CONCAT_D(CASE WHEN term_failing = 1 THEN COURSE_NAME + ' [' + CONVERT(VARCHAR,term_grade) + ']' END, '; ') AS term_failing      
  FROM
      (
       SELECT STUDENT_NUMBER
             ,COURSE_NAME      
             ,term
             ,term_grade
             ,CASE WHEN term_grade IS NULL THEN NULL WHEN term_grade < 65 THEN 1 ELSE 0 END AS term_failing           
       FROM GRADES$DETAIL#MS WITH(NOLOCK)
       UNPIVOT(
         term_grade
         FOR term IN (t1, t2, t3)
        ) u
       WHERE SCHOOLID = 133570965

       UNION ALL

       SELECT STUDENT_NUMBER
             ,COURSE_NAME      
             ,'Y1' AS term
             ,Y1 AS term_grade
             ,CASE WHEN Y1 IS NULL THEN NULL WHEN Y1 < 65 THEN 1 ELSE 0 END AS term_failing           
       FROM GRADES$DETAIL#MS WITH(NOLOCK)     
       WHERE SCHOOLID = 133570965
      ) sub
  GROUP BY STUDENT_NUMBER
          ,term
 )

,hw_weekly_avg AS (
  SELECT student_number
        ,week_hash
        ,ROUND(AVG(pct),0) AS hw_avg
  FROM
      (
       SELECT student_number
             ,(DATEPART(YEAR,assign_date) * 100) + week AS week_hash
             ,pct
       FROM GRADES$asmt_scores_category_long WITH(NOLOCK)
       WHERE schoolid = 133570965
         AND finalgrade = 'H'       
      ) sub
  GROUP BY student_number
          ,week_hash
 )

,att_weekly_avg AS ( 
  SELECT STUDENTID
        ,week_hash
        ,ROUND(AVG(ATTENDANCEVALUE) * 100,0) AS att_pct
        ,ROUND(AVG(CONVERT(FLOAT,is_tardy)) * 100,0) AS tardy_pct
  FROM
      (
       SELECT mem.STUDENTID
             ,(DATEPART(YEAR,mem.CALENDARDATE) * 100) + DATEPART(WEEK,mem.CALENDARDATE) AS week_hash
             ,CONVERT(FLOAT,mem.ATTENDANCEVALUE) AS attendancevalue
             ,CASE WHEN att.ATT_CODE IS NOT NULL THEN 1 ELSE 0 END AS is_tardy
       FROM KIPP_NJ..ATT_MEM$MEMBERSHIP mem WITH(NOLOCK)
       LEFT OUTER JOIN ATTENDANCE att WITH(NOLOCK)
         ON mem.studentid = att.STUDENTID
        AND mem.CALENDARDATE = att.ATT_DATE        
        AND att.ATT_CODE IN ('T','T10')
       WHERE mem.MEMBERSHIPVALUE = 1
         AND mem.SCHOOLID = 133570965
         AND mem.academic_year = dbo.fn_Global_Academic_Year()
      ) sub
  GROUP BY STUDENTID
          ,week_hash
 )

,chksht_weekly AS (
  SELECT [student_number]            
        ,CONVERT(DATE,week_of) AS week_of
        ,chksht_avg
  FROM [KIPP_NJ].[dbo].[AUTOLOAD$GDOCS_CHK_all_grades] WITH(NOLOCK)
  UNPIVOT(
    chksht_avg
    FOR week_of IN ([8/4/2014]
                   ,[8/11/2014]
                   ,[9/1/2014]
                   ,[9/8/2014]
                   ,[9/15/2014]
                   ,[9/22/2014]
                   ,[9/29/2014]
                   ,[10/6/2014]
                   ,[10/13/2014]
                   ,[10/20/2014]
                   ,[10/27/2014]
                   ,[11/3/2014]
                   ,[11/10/2014]
                   ,[11/17/2014]
                   ,[11/24/2014]
                   ,[12/1/2014]
                   ,[12/8/2014]
                   ,[12/15/2014]
                   ,[12/22/2014]
                   ,[12/29/2014]
                   ,[1/5/2015]
                   ,[1/12/2015]
                   ,[1/19/2015]
                   ,[1/26/2015]
                   ,[2/2/2015]
                   ,[2/9/2015]
                   ,[2/16/2015]
                   ,[2/23/2015]
                   ,[3/2/2015]
                   ,[3/9/2015]
                   ,[3/16/2015]
                   ,[3/23/2015]
                   ,[3/30/2015]
                   ,[4/6/2015]
                   ,[4/13/2015]
                   ,[4/20/2015]
                   ,[4/27/2015]
                   ,[5/4/2015]
                   ,[5/11/2015]
                   ,[5/18/2015]
                   ,[5/25/2015]
                   ,[6/1/2015]
                   ,[6/8/2015]
                   ,[6/15/2015]
                   ,[6/22/2015]
                   ,[6/29/2015])
   ) u
 )

SELECT r.studentid
      ,r.schoolid
      ,r.student_number
      ,r.lastfirst
      ,r.grade_level
      ,r.team
      ,r.gender
      ,r.spedlep      
      ,wk.weekday_start AS week_of
      ,wk.term
      ,gr.is_passing
      ,gr.n_failing
      ,gr.term_failing      
      ,y1.is_passing AS y1_is_passing
      ,y1.n_failing AS y1_n_failing
      ,y1.term_failing AS y1_failing
      ,hw.hw_avg
      ,att.att_pct
      ,att.tardy_pct
      ,chk.chksht_avg
FROM roster r WITH(NOLOCK)
JOIN reporting_weeks wk WITH(NOLOCK)
  ON r.entrydate <= wk.weekday_start
 AND r.exitdate >= wk.weekday_end
 AND wk.weekday_start <= GETDATE()
LEFT OUTER JOIN term_grades gr WITH(NOLOCK)
  ON r.STUDENT_NUMBER = gr.STUDENT_NUMBER
 AND wk.term = gr.term
LEFT OUTER JOIN term_grades y1 WITH(NOLOCK)
  ON r.STUDENT_NUMBER = y1.STUDENT_NUMBER
 AND y1.term = 'Y1'
LEFT OUTER JOIN hw_weekly_avg hw WITH(NOLOCK)
  ON r.STUDENT_NUMBER = hw.student_number
 AND wk.reporting_hash = hw.week_hash
LEFT OUTER JOIN att_weekly_avg att WITH(NOLOCK)
  ON r.studentid = att.STUDENTID
 AND wk.reporting_hash = att.week_hash
LEFT OUTER JOIN chksht_weekly chk WITH(NOLOCK)
  ON r.STUDENT_NUMBER = chk.student_number
 AND wk.weekday_start = chk.week_of
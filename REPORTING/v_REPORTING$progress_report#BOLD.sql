USE KIPP_NJ
GO

ALTER VIEW REPORTING$progress_report#BOLD AS 

WITH AR_progress AS (
  SELECT student_number
        ,[Y1] AS AR_avg_pct_correct_Y1
        ,[CUR]  AS AR_avg_pct_correct_CUR
  FROM
      (
       SELECT ar.student_number      
             ,ROUND(AVG(ar.dpercentcorrect) * 100,0) AS avg_pct_correct
             ,'Y1' AS term
       FROM KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK)
       JOIN KIPP_NJ..AR$test_event_detail#static ar WITH(NOLOCK)
         ON co.student_number = ar.student_number
        AND co.year = ar.academic_year
        AND ar.tiPassed = 1
       WHERE co.schoolid = 73258
         AND co.year = KIPP_NJ.dbo.fn_Global_Academic_Year()
         AND co.rn = 1
       GROUP BY ar.student_number

       UNION ALL

       SELECT ar.student_number      
             ,ROUND(AVG(ar.dpercentcorrect) * 100,0) AS avg_pct_correct
             ,'CUR'
       FROM KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK)
       JOIN KIPP_NJ..AR$test_event_detail#static ar WITH(NOLOCK)
         ON co.student_number = ar.student_number
        AND co.year = ar.academic_year
        AND ar.tiPassed = 1
       JOIN KIPP_NJ..REPORTING$dates dt WITH(NOLOCK)
         ON co.schoolid = dt.schoolid
        AND co.year = dt.academic_year
        AND CONVERT(DATE,ar.dtTakenOriginal) BETWEEN dt.start_date AND dt.end_date 
        AND CONVERT(DATE,GETDATE()) BETWEEN dt.start_date AND dt.end_date 
        AND dt.identifier = 'RT'
       WHERE co.schoolid = 73258
         AND co.year = KIPP_NJ.dbo.fn_Global_Academic_Year()
         AND co.rn = 1
       GROUP BY ar.student_number
      ) sub
  PIVOT(
    MAX(avg_pct_correct)
    FOR term IN ([Y1],[CUR])
   ) p
)

SELECT co.student_number
      ,co.year AS academic_year            
      ,co.LASTFIRST      
      ,REPLACE(CONVERT(VARCHAR,co.GRADE_LEVEL),'0','K') AS grade_level
      ,co.SCHOOLID
      ,co.TEAM
      ,co.LUNCH_BALANCE
      ,CONCAT(co.STREET, ' - ', co.CITY, ', ', co.STATE, ' ', co.ZIP) AS address
      ,co.HOME_PHONE
      ,co.MOTHER AS parent_1_name      
      ,CONCAT(co.MOTHER_CELL + ' / ', co.MOTHER_DAY) AS parent_1_phone
      ,co.FATHER AS parent_2_name
      ,CONCAT(co.FATHER_CELL + ' / ' , co.FATHER_DAY) AS parent_2_phone
      ,REPLACE(CONVERT(NVARCHAR(MAX),co.GUARDIANEMAIL),',','; ') AS guardianemail

      /* date stuff */
      ,FORMAT(GETDATE(),'MMMM dd, yyy') AS today_text
      ,d.alt_name AS curterm      

      /* Attendance & Tardies */    
      /* Year */
      ,CONCAT(att_counts.y1_abs_all, ' - ', ROUND(att_pct.Y1_att_pct_total,0), '%') AS Y1_absences_total
      ,CONCAT(att_counts.y1_t_all, ' - ', ROUND(att_pct.Y1_tardy_pct_total,0), '%') AS Y1_tardies_total
      /* Current */            
      ,CONCAT(att_counts.CUR_ABS_ALL, ' - ', ROUND(att_pct.cur_att_pct_total,0), '%') AS curterm_absences_total      
      ,CONCAT(att_counts.CUR_T_ALL, ' - ', ROUND(att_pct.cur_tardy_pct_total,0), '%') AS curterm_tardies_total
      
      /* daily tracking */
      ,dt.CUR_BOLD_points
      ,dt.CUR_hw_full_pct
      ,dt.CUR_hw_half_pct
      ,dt.CUR_hw_missing_pct
      ,dt.CUR_uniform_pct
      ,dt.Y1_BOLD_points
      ,dt.Y1_hw_full_pct
      ,dt.Y1_hw_half_pct
      ,dt.Y1_hw_missing_pct
      ,dt.Y1_uniform_pct
      
      /* AR */
      ,ar.AR_avg_pct_correct_Y1
      ,ar.AR_avg_pct_correct_CUR

      /* Standards */
      ,fsa.ELA_ADV
      ,fsa.ELA_PROF
      ,fsa.ELA_NY
      ,fsa.MATH_ADV
      ,fsa.MATH_PROF
      ,fsa.MATH_NY

      /* CMA data*/
      ,cma.MATH_short_title
      ,cma.MATH_percent_correct
      ,cma.ELA_short_title
      ,cma.ELA_percent_correct
FROM KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK)
LEFT OUTER JOIN KIPP_NJ..REPORTING$dates d WITH(NOLOCK)
  ON co.schoolid = d.schoolid
 AND co.year = d.academic_year
 AND CONVERT(DATE,GETDATE()) BETWEEN d.start_date AND d.end_date
 AND d.identifier = 'RT'
LEFT OUTER JOIN KIPP_NJ..REPORTING$dates rw WITH(NOLOCK)
  ON co.schoolid = rw.schoolid
 AND co.year = rw.academic_year
 AND DATEADD(DAY, -7, CONVERT(DATE,GETDATE())) BETWEEN rw.start_date AND rw.end_date
 AND rw.identifier = 'REP'
LEFT OUTER JOIN KIPP_NJ..ATT_MEM$attendance_counts#static att_counts WITH(NOLOCK)
  ON co.studentid = att_counts.studentid
LEFT OUTER JOIN KIPP_NJ..ATT_MEM$att_percentages att_pct WITH(NOLOCK)
  ON co.studentid = att_pct.studentid
LEFT OUTER JOIN KIPP_NJ..DAILY$tracking_totals#BOLD#static dt WITH(NOLOCK)
  ON co.studentid = dt.STUDENTID
LEFT OUTER JOIN AR_progress ar
  ON co.student_number = ar.student_number
LEFT OUTER JOIN KIPP_NJ..ILLUMINATE$FSA_scores_wide#static fsa WITH(NOLOCK)
  ON co.student_number = fsa.student_number
 AND rw.time_per_name = fsa.reporting_week
LEFT OUTER JOIN KIPP_NJ..ILLUMINATE$CMA_scores_wide#static cma WITH(NOLOCK)
  ON co.student_number = cma.student_number
 AND co.year = cma.academic_year
WHERE co.year = KIPP_NJ.dbo.fn_Global_Academic_Year()
  AND co.schoolid = 73258
  AND co.rn = 1
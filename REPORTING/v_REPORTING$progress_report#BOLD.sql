USE KIPP_NJ
GO

ALTER VIEW REPORTING$progress_report#BOLD AS 

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
      ,rw.time_per_name
      ,ROW_NUMBER() OVER(
         PARTITION BY co.student_number
           ORDER BY rw.start_date DESC) AS rn_week

      /* Attendance & Tardies */    
      /* Year */
      ,CONCAT(att_counts.y1_abs_all, ' - ', ROUND(att_pct.Y1_att_pct_total,0), '%') AS Y1_absences_total
      ,CONCAT(att_counts.y1_t_all, ' - ', ROUND(att_pct.Y1_tardy_pct_total,0), '%') AS Y1_tardies_total
      /* Current */            
      ,CONCAT(att_counts.CUR_ABS_ALL, ' - ', ROUND(att_pct.cur_att_pct_total,0), '%') AS curterm_absences_total      
      ,CONCAT(att_counts.CUR_T_ALL, ' - ', ROUND(att_pct.cur_tardy_pct_total,0), '%') AS curterm_tardies_total
      
      /* daily tracking */
      ,dt.CUR_BOLD_points
      ,dt.CUR_hw_comp_pct      
      ,dt.CUR_hw_inc_pct
      ,dt.CUR_uniform_pct
      ,dt.Y1_BOLD_points
      ,dt.Y1_hw_comp_pct      
      ,dt.Y1_hw_inc_pct      
      ,dt.Y1_uniform_pct
      
      /* AR */
      ,ar.Y1_avg_pct_correct AS AR_Y1_avg_pct_correct 
      ,ar.CUR_avg_pct_correct AS AR_CUR_avg_pct_correct
--    ,REPLACE(CONVERT(VARCHAR,CONVERT(MONEY,ar.Y1_words_read), 1), '.00', '') AS AR_Y1_words_read
--    ,REPLACE(CONVERT(VARCHAR,CONVERT(MONEY,ar.CUR_words_read), 1), '.00', '') AS AR_CUR_words_read
      ,CONVERT(VARCHAR,ar.Y1_words_read) AS AR_Y1_words_read
      ,CONVERT(VARCHAR,ar.CUR_words_read) AS AR_CUR_words_read


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
 AND CONVERT(DATE,GETDATE()) >= rw.end_date 
 AND rw.identifier = 'REP'
LEFT OUTER JOIN KIPP_NJ..ATT_MEM$attendance_counts#static att_counts WITH(NOLOCK)
  ON co.studentid = att_counts.studentid
LEFT OUTER JOIN KIPP_NJ..ATT_MEM$att_percentages att_pct WITH(NOLOCK)
  ON co.studentid = att_pct.studentid
LEFT OUTER JOIN KIPP_NJ..DAILY$tracking_totals#BOLD#static dt WITH(NOLOCK)
  ON co.studentid = dt.STUDENTID
LEFT OUTER JOIN KIPP_NJ..AR$progress_wide ar WITH(NOLOCK)
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
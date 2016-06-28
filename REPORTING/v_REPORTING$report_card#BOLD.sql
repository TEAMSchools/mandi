USE KIPP_NJ
GO

ALTER VIEW REPORTING$report_card#BOLD AS 

WITH curterm AS (
  SELECT alt_name
        ,time_per_name
        ,start_date
        ,ROW_NUMBER() OVER(
           PARTITION BY schoolid
             ORDER BY end_date DESC) AS rn
  FROM KIPP_NJ..REPORTING$dates WITH(NOLOCK)
  WHERE identifier = 'RT'   
    AND academic_year = KIPP_NJ.dbo.fn_Global_Academic_Year()
    --AND CONVERT(DATE,GETDATE()) >= end_date   
    AND schoolid = 73258
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
      ,CONCAT(att_counts.abs_all_counts_yr, ' - ', ROUND(att_pct.abs_all_pct_yr,0), '%') AS Y1_absences_total
      ,CONCAT(att_counts.tdy_all_counts_yr, ' - ', ROUND(att_pct.tdy_all_pct_yr,0), '%') AS Y1_tardies_total
      /* Current */            
      ,CONCAT(att_counts.abs_all_counts_term, ' - ', ROUND(att_pct.abs_all_pct_term,0), '%') AS curterm_absences_total
      ,CONCAT(att_counts.tdy_all_counts_term, ' - ', ROUND(att_pct.tdy_all_pct_term,0), '%') AS curterm_tardies_total
      
      /* daily tracking */
      ,dt.rc_bold_points AS CUR_BOLD_points
      ,dt.rc_hw_comp_pct AS CUR_hw_comp_pct      
      ,dt.rc_hw_inc_pct AS CUR_hw_inc_pct
      ,dt.rc_uniform_pct AS CUR_uniform_pct
      ,dt.Y1_BOLD_points
      ,dt.Y1_hw_comp_pct      
      ,dt.Y1_hw_inc_pct      
      ,dt.Y1_uniform_pct
      
      /* AR */
      ,ar.mastery AS AR_Y1_avg_pct_correct       
      ,REPLACE(CONVERT(VARCHAR,CONVERT(MONEY,ar.words), 1), '.00', '') AS AR_Y1_words_read
      ,ar.stu_status_words AS AR_Y1_status
      ,REPLACE(CONVERT(VARCHAR,CONVERT(MONEY,ar_cur.words), 1), '.00', '') AS AR_CUR_words_read
      ,ar_CUR.mastery AS AR_CUR_avg_pct_correct
      ,ar_cur.stu_status_words AS AR_CUR_status

      /* standards */      
      ,stds.MATH_PROF_stds
      ,stds.MATH_APPRO_stds
      ,stds.MATH_NY_stds      
      ,stds.MATH_PROF_N
      ,stds.MATH_APPRO_N
      ,stds.MATH_NY_N      
      ,stds.ELA_PROF_stds
      ,stds.ELA_APPRO_stds
      ,stds.ELA_NY_stds                  
      ,stds.ELA_PROF_N
      ,stds.ELA_APPRO_N
      ,stds.ELA_NY_N      
      ,stds.HIST_PROF_stds
      ,stds.HIST_APPRO_stds
      ,stds.HIST_NY_stds                   
      ,stds.HIST_PROF_N
      ,stds.HIST_APPRO_N
      ,stds.HIST_NY_N
      ,stds.SCI_PROF_stds
      ,stds.SCI_APPRO_stds
      ,stds.SCI_NY_stds                   
      ,stds.SCI_PROF_N
      ,stds.SCI_APPRO_N
      ,stds.SCI_NY_N
      ,stds.PERFARTS_PROF_stds
      ,stds.PERFARTS_APPRO_stds
      ,stds.PERFARTS_NY_stds                   
      ,stds.PERFARTS_PROF_N
      ,stds.PERFARTS_APPRO_N
      ,stds.PERFARTS_NY_N      

      /* CMA data*/
      ,cma.MATH_short_title
      ,cma.MATH_percent_correct
      ,cma.ELA_short_title
      ,cma.ELA_percent_correct

      /* exit ticket avgs */
      ,etix.ELA AS ELA_exit_tix
      ,etix.MATH AS MATH_exit_tix
      ,etix.SCI AS SCI_exit_tix
      ,etix.HIST AS HIST_exit_tix
      ,etix.PERFARTS AS PERFARTS_exit_tix

      /* ST Math */
      ,ROUND(stm.total_completion,0) AS stmath_completion
FROM KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK)
LEFT OUTER JOIN curterm d WITH(NOLOCK)
  ON d.rn = 1
LEFT OUTER JOIN KIPP_NJ..ATT_MEM$attendance_counts_long#static att_counts WITH(NOLOCK)
  ON co.studentid = att_counts.studentid
 AND co.year = att_counts.academic_year
 AND d.alt_name = att_counts.term
LEFT OUTER JOIN KIPP_NJ..ATT_MEM$attendance_percentages_long att_pct WITH(NOLOCK)
  ON co.studentid = att_pct.studentid
 AND co.year = att_pct.academic_year
 AND d.alt_name = att_pct.term
LEFT OUTER JOIN KIPP_NJ..DAILY$tracking_totals#BOLD#static dt WITH(NOLOCK)
  ON co.studentid = dt.STUDENTID
LEFT OUTER JOIN KIPP_NJ..AR$progress_to_goals_long#static ar WITH(NOLOCK)
  ON co.student_number = ar.student_number
 AND co.year = ar.academic_year
 AND ar.time_period_name = 'Year'
LEFT OUTER JOIN KIPP_NJ..AR$progress_to_goals_long#static ar_cur WITH(NOLOCK)
  ON co.student_number = ar_cur.student_number
 AND co.year = ar_cur.academic_year
 AND REPLACE(d.alt_name, 'Q', 'RT') = ar_cur.time_period_name
LEFT OUTER JOIN KIPP_NJ..ILLUMINATE$RC_standards_wide#BOLD stds WITH(NOLOCK)
  ON co.student_number = stds.student_number
 AND d.alt_name = stds.term
LEFT OUTER JOIN KIPP_NJ..ILLUMINATE$CMA_scores_wide#static cma WITH(NOLOCK)
  ON co.student_number = cma.student_number
 AND co.year = cma.academic_year
LEFT OUTER JOIN KIPP_NJ..ILLUMINATE$exit_ticket_avg etix WITH(NOLOCK)
  ON co.student_number = etix.local_student_id
 AND d.alt_name = etix.term
LEFT OUTER JOIN STMATH..summary_by_enrollment stm WITH(NOLOCK)
  ON co.student_number = stm.student_number
WHERE co.year = KIPP_NJ.dbo.fn_Global_Academic_Year()
  AND co.schoolid = 73258
  AND co.rn = 1
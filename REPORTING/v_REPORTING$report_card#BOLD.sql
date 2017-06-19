USE KIPP_NJ
GO

ALTER VIEW REPORTING$report_card#BOLD AS 

WITH stmath AS (
  SELECT student_number
        ,start_year
        ,SUM(K_5_Progress) AS total_pct_progress
  FROM
      (
       SELECT stm.school_student_id AS student_number                                          
             ,stm.start_year
             ,stm.K_5_Progress      
             ,ROW_NUMBER() OVER(
                PARTITION BY stm.school_student_id, stm.start_year, stm.GCD
                  ORDER BY stm.week_ending_date DESC) AS rn_gcd
       FROM KIPP_NJ..STMATH$progress_completion_long stm WITH(NOLOCK)
       JOIN KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK)
         ON stm.school_student_id = co.student_number
        AND stm.start_year = co.year
        AND co.rn = 1
       WHERE stm.start_year = KIPP_NJ.dbo.fn_Global_Academic_Year()
      ) sub
  WHERE rn_gcd = 1
  GROUP BY student_number
          ,start_year
 )

,curterm AS (
  SELECT academic_year
        ,start_date
        ,time_per_name
        ,alt_name
        ,ROW_NUMBER() OVER(
           PARTITION BY academic_year
             ORDER BY start_date DESC) AS rn
  FROM KIPP_NJ..REPORTING$dates d WITH(NOLOCK)
  WHERE d.schoolid = 73258  
    AND d.identifier = 'RT'
    --AND d.end_date <= CONVERT(DATE,GETDATE())
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
      ,d.time_per_name
      ,1 AS rn_week

      /* Attendance & Tardies */    
      /* Year */
      ,CONCAT(att_counts.abs_all_counts_yr, ' - ', ROUND(att_pct.abs_all_pct_yr,0), '%') AS Y1_absences_total
      ,CONCAT(att_counts.tdy_all_counts_yr, ' - ', ROUND(att_pct.tdy_all_pct_yr,0), '%') AS Y1_tardies_total
      /* Current */            
      ,CONCAT(att_counts.abs_all_counts_term, ' - ', ROUND(att_pct.abs_all_pct_term,0), '%') AS curterm_absences_total      
      ,CONCAT(att_counts.tdy_all_counts_term, ' - ', ROUND(att_pct.tdy_all_pct_term,0), '%') AS curterm_tardies_total      
      
      /* AR */
      ,ar.mastery AS AR_Y1_avg_pct_correct       
      ,REPLACE(CONVERT(VARCHAR,CONVERT(MONEY,ar.words), 1), '.00', '') AS AR_Y1_words_read
      ,ar.stu_status_words AS AR_Y1_status
      ,REPLACE(CONVERT(VARCHAR,CONVERT(MONEY,ar_cur.words), 1), '.00', '') AS AR_CUR_words_read
      ,ar_CUR.mastery AS AR_CUR_avg_pct_correct
      ,ar_cur.stu_status_words AS AR_CUR_status

      /* Standards */
      ,fsa.ELA_ADV
      ,fsa.ELA_PROF
      ,fsa.ELA_NY

      ,fsa.MATH_ADV
      ,fsa.MATH_PROF
      ,fsa.MATH_NY

      ,fsa.SCI_ADV
      ,fsa.SCI_PROF
      ,fsa.SCI_NY

      ,fsa.SOC_ADV
      ,fsa.SOC_PROF
      ,fsa.SOC_NY

      ,fsa.PERFARTS_ADV
      ,fsa.PERFARTS_PROF
      ,fsa.PERFARTS_NY

      ,fsa.VIZARTS_ADV
      ,fsa.VIZARTS_PROF
      ,fsa.VIZARTS_NY

      /* CMA data*/
      ,cma.MATH_short_title
      ,cma.MATH_percent_correct
      ,cma.ELA_short_title
      ,cma.ELA_percent_correct

      /* exit ticket avgs */
      ,etix.ELA AS ELA_exit_tix
      ,etix.MATH AS MATH_exit_tix      
      ,etix.SCI AS SCI_exit_tix
      ,etix.SOC AS SOC_exit_tix
      ,etix.PERFARTS AS PERFARTS_exit_tix
      ,etix.VIZARTS AS VIZARTS_exit_tix

      /* ST Math */      
      ,ROUND(stmath.total_pct_progress,0) AS stmath_completion
FROM KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK)
LEFT OUTER JOIN curterm d
  ON co.year = d.academic_year
 --AND d.rn = 1
 AND d.alt_name = 'Q4'
LEFT OUTER JOIN KIPP_NJ..ATT_MEM$attendance_counts_long#static att_counts WITH(NOLOCK)
  ON co.studentid = att_counts.studentid
 AND co.year = att_counts.academic_year
 AND d.alt_name = att_counts.term
LEFT OUTER JOIN KIPP_NJ..ATT_MEM$attendance_percentages_long att_pct WITH(NOLOCK)
  ON co.studentid = att_pct.studentid
 AND co.year = att_pct.academic_Year
 AND d.alt_name = att_pct.term
LEFT OUTER JOIN KIPP_NJ..AR$progress_to_goals_long#static ar WITH(NOLOCK)
  ON co.student_number = ar.student_number
 AND co.year = ar.academic_year
 AND ar.time_period_name = 'Year'
LEFT OUTER JOIN KIPP_NJ..AR$progress_to_goals_long#static ar_cur WITH(NOLOCK)
  ON co.student_number = ar_cur.student_number
 AND co.year = ar_cur.academic_year
 AND REPLACE(d.alt_name, 'Q', 'RT') = ar_cur.time_period_name
LEFT OUTER JOIN KIPP_NJ..ILLUMINATE$FSA_scores_wide#static fsa WITH(NOLOCK)
  ON co.student_number = fsa.student_number
 AND co.year = fsa.academic_year
 AND d.time_per_name = fsa.reporting_week
LEFT OUTER JOIN KIPP_NJ..ILLUMINATE$CMA_scores_wide#static cma WITH(NOLOCK)
  ON co.student_number = cma.student_number
 AND co.year = cma.academic_year
LEFT OUTER JOIN KIPP_NJ..ILLUMINATE$exit_ticket_avg etix WITH(NOLOCK)
  ON co.student_number = etix.local_student_id
 AND co.year = etix.academic_year
 AND d.alt_name = etix.term
LEFT OUTER JOIN stmath WITH(NOLOCK)
  ON co.student_number = stmath.student_number
 AND co.year = stmath.start_year
WHERE co.year = KIPP_NJ.dbo.fn_Global_Academic_Year()
  AND co.reporting_schoolid = 73258
  AND co.rn = 1
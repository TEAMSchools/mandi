USE KIPP_NJ
GO

ALTER VIEW TABLEAU$word_work_tracker AS

WITH roster AS (
 SELECT co.STUDENTID
       ,co.STUDENT_NUMBER      
       ,co.LASTFIRST       
       ,co.grade_level
       ,co.SCHOOLID
       ,s.TEAM       
 FROM COHORT$comprehensive_long#static co WITH(NOLOCK)
 JOIN STUDENTS s WITH(NOLOCK)
   ON co.STUDENTID = s.ID
  AND s.ENROLL_STATUS = 0 
 WHERE co.YEAR = dbo.fn_Global_Academic_Year()
   AND co.GRADE_LEVEL < 5
   AND co.RN = 1
 )

,reporting_week AS (
  SELECT schoolid
        ,time_per_name AS week_num
        ,start_date AS week_start
  FROM REPORTING$dates WITH(NOLOCK)    
  WHERE identifier = 'REP'    
    AND school_level = 'ES'
 )

SELECT r.STUDENTID
      ,r.STUDENT_NUMBER
      ,r.LASTFIRST
      ,r.grade_level
      ,r.schoolid
      ,r.TEAM      
      ,rw.week_num
      ,rw.week_start
      ,sw.n_total AS sw_n_total
      ,sw.n_correct AS sw_n_correct
      ,sw.n_missed AS sw_n_missed
      ,sw.pct_correct AS sw_pct_correct
      ,sw.missed_words AS sw_missed_words
      ,sw.n_total_yr AS sw_n_total_yr
      ,sw.n_correct_yr AS sw_n_correct_yr
      ,sw.n_missed_yr AS sw_n_missed_yr
      ,sw.pct_correct_yr AS sw_pct_correct_yr
      ,sw.missed_words_yr AS sw_missed_words_yr
      ,sw.avg_total_yr AS sw_avg_total_yr
      ,sw.avg_correct_yr AS sw_avg_correct_yr
      ,sw.avg_pct_correct_yr AS sw_avg_pct_correct_yr
      ,sp.pct_correct_wk AS sp_pct_correct_wk
      ,sp.pct_correct_yr AS sp_pct_correct_yr
      ,sp.avg_pct_correct_yr AS sp_avg_pct_correct_yr
      ,vocab.pct_correct_wk AS vocab_pct_correct_wk
      ,vocab.pct_correct_yr AS vocab_pct_correct_yr
      ,vocab.avg_pct_correct_yr AS vocab_avg_pct_correct_yr
FROM roster r WITH(NOLOCK)
LEFT OUTER JOIN reporting_week rw WITH(NOLOCK)
  ON r.schoolid = rw.schoolid
LEFT OUTER JOIN LIT$sight_word_totals sw WITH(NOLOCK)
  ON r.STUDENT_NUMBER = sw.student_number
 AND rw.week_num = sw.listweek_num
LEFT OUTER JOIN LIT$spelling_totals sp WITH(NOLOCK)
  ON r.STUDENT_NUMBER = sp.student_number
 AND rw.week_num = sp.listweek_num
LEFT OUTER JOIN LIT$vocab_totals vocab WITH(NOLOCK)
  ON r.STUDENT_NUMBER = vocab.student_number
 AND rw.week_num = vocab.listweek_num
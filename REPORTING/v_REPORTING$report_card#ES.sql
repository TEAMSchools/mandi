USE KIPP_NJ
GO

ALTER VIEW REPORTING$report_card#ES AS

WITH roster AS (
 SELECT cs.STUDENTID
       ,s.STUDENT_NUMBER      
       ,s.LASTFIRST
       ,s.LAST_NAME
       ,s.FIRST_NAME
       ,REPLACE(co.GRADE_LEVEL, 0 ,'K') AS grade_level
       ,co.SCHOOLID
       ,s.TEAM
       ,cs.LUNCH_BALANCE
       ,s.STREET AS address
       ,s.CITY
       ,s.STATE
       ,s.ZIP
       ,s.HOME_PHONE
       ,cs.MOTHER_CELL
       ,cs.MOTHER_DAY
       ,cs.FATHER_CELL
       ,cs.FATHER_DAY
       ,blobs.GUARDIANEMAIL
 FROM COHORT$comprehensive_long#static co WITH(NOLOCK)
 JOIN STUDENTS s WITH(NOLOCK)
   ON co.STUDENTID = s.ID
  AND s.ENROLL_STATUS = 0
 LEFT OUTER JOIN CUSTOM_STUDENTS cs WITH(NOLOCK)
   ON co.STUDENTID = cs.STUDENTID
 LEFT OUTER JOIN PS$student_BLObs#static blobs WITH(NOLOCK)
   ON co.studentid = blobs.studentid
 WHERE co.YEAR = dbo.fn_Global_Academic_Year()
   AND co.GRADE_LEVEL < 5
   AND co.RN = 1
 )

,attendance AS (
  SELECT att.studentid
        ,CUR_ABS_ALL AS cur_absences_total
        ,CUR_AD + CUR_AE AS excused_absences
        ,cur_t_all AS cur_tardies_total
        ,CUR_TE AS cur_tardies_exc
        ,cur_le AS cur_early_dismiss
        ,cur_lex AS cur_early_dismiss_exc
        ,ROUND(cur_trip_abs,1) AS trip_absences
        ,CASE WHEN cur_trip_abs >= 5 THEN 'Off Track' ELSE 'On Track' END AS trip_status
  FROM ATT_MEM$attendance_counts att WITH(NOLOCK)  
 )

,reporting_week AS (
  SELECT schoolid
        ,time_per_name AS week_num        
        ,start_date
        ,end_date
        ,DATENAME(MONTH,start_date) AS month
        ,REPLACE(time_per_name,'_',' ') + ': ' + LEFT(CONVERT(VARCHAR,start_date,101),5) + ' - ' + LEFT(CONVERT(VARCHAR,end_date,101),5) AS week_title
  FROM REPORTING$dates WITH(NOLOCK)    
  WHERE DATEPART(WEEK,GETDATE()) - 1 >= DATEPART(WEEK,start_date)
    AND DATEPART(WEEK,GETDATE()) - 1 <= DATEPART(WEEK,end_date)
    AND identifier = 'REP'    
    AND school_level = 'ES'
 )

,curterm AS (
  SELECT DISTINCT alt_name
                 ,DATENAME(MONTH,end_date) + ' ' + CONVERT(VARCHAR,DATEPART(DAY,end_date)) AS end_date                 
  FROM REPORTING$dates WITH(NOLOCK)
  WHERE identifier = 'RT'
    AND school_level = 'ES'
    AND start_date <= GETDATE()
    AND end_date >= GETDATE()
 )

SELECT r.studentid
      ,r.student_number
      ,r.LASTFIRST
      ,r.LAST_NAME
      ,r.FIRST_NAME
      ,r.GRADE_LEVEL
      ,r.SCHOOLID
      ,r.TEAM
      ,r.LUNCH_BALANCE
      ,r.address
      ,r.CITY
      ,r.STATE
      ,r.ZIP
      ,r.HOME_PHONE
      ,r.MOTHER_CELL
      ,r.MOTHER_DAY
      ,r.FATHER_CELL
      ,r.FATHER_DAY
      ,r.GUARDIANEMAIL
      ,REPLACE(rw.week_num, '_', ' ') AS week_num
      ,rw.week_title
      ,curterm.alt_name AS term_name
      ,curterm.end_date AS term_end      
      ,att.cur_absences_total
      ,att.excused_absences
      ,att.cur_tardies_total
      ,att.cur_tardies_exc
      ,att.cur_early_dismiss
      ,att.cur_early_dismiss_exc
      ,att.trip_absences
      ,att.trip_status      
      ,fsa.pct_mastered_wk
      ,fsa.FSA_subject_1
      ,fsa.FSA_subject_2
      ,fsa.FSA_subject_3
      ,fsa.FSA_subject_4
      ,fsa.FSA_subject_5
      ,fsa.FSA_subject_6
      ,fsa.FSA_subject_7
      ,fsa.FSA_subject_8
      ,fsa.FSA_subject_9
      ,fsa.FSA_subject_10
      ,fsa.FSA_subject_11
      ,fsa.FSA_subject_12
      ,fsa.FSA_subject_13
      ,fsa.FSA_subject_14
      ,fsa.FSA_subject_15
      ,fsa.FSA_standard_1
      ,fsa.FSA_standard_2
      ,fsa.FSA_standard_3
      ,fsa.FSA_standard_4
      ,fsa.FSA_standard_5
      ,fsa.FSA_standard_6
      ,fsa.FSA_standard_7
      ,fsa.FSA_standard_8
      ,fsa.FSA_standard_9
      ,fsa.FSA_standard_10
      ,fsa.FSA_standard_11
      ,fsa.FSA_standard_12
      ,fsa.FSA_standard_13
      ,fsa.FSA_standard_14
      ,fsa.FSA_standard_15
      ,fsa.FSA_obj_1
      ,fsa.FSA_obj_2
      ,fsa.FSA_obj_3
      ,fsa.FSA_obj_4
      ,fsa.FSA_obj_5
      ,fsa.FSA_obj_6
      ,fsa.FSA_obj_7
      ,fsa.FSA_obj_8
      ,fsa.FSA_obj_9
      ,fsa.FSA_obj_10
      ,fsa.FSA_obj_11
      ,fsa.FSA_obj_12
      ,fsa.FSA_obj_13
      ,fsa.FSA_obj_14
      ,fsa.FSA_obj_15
      ,fsa.FSA_score_1
      ,fsa.FSA_score_2
      ,fsa.FSA_score_3
      ,fsa.FSA_score_4
      ,fsa.FSA_score_5
      ,fsa.FSA_score_6
      ,fsa.FSA_score_7
      ,fsa.FSA_score_8
      ,fsa.FSA_score_9
      ,fsa.FSA_score_10
      ,fsa.FSA_score_11
      ,fsa.FSA_score_12
      ,fsa.FSA_score_13
      ,fsa.FSA_score_14
      ,fsa.FSA_score_15
      ,fsa.FSA_prof_1
      ,fsa.FSA_prof_2
      ,fsa.FSA_prof_3
      ,fsa.FSA_prof_4
      ,fsa.FSA_prof_5
      ,fsa.FSA_prof_6
      ,fsa.FSA_prof_7
      ,fsa.FSA_prof_8
      ,fsa.FSA_prof_9
      ,fsa.FSA_prof_10
      ,fsa.FSA_prof_11
      ,fsa.FSA_prof_12
      ,fsa.FSA_prof_13
      ,fsa.FSA_prof_14
      ,fsa.FSA_prof_15
      ,fsa.FSA_nxtstp_1
      ,fsa.FSA_nxtstp_2
      ,fsa.FSA_nxtstp_3
      ,fsa.FSA_nxtstp_4
      ,fsa.FSA_nxtstp_5
      ,fsa.FSA_nxtstp_6
      ,fsa.FSA_nxtstp_7
      ,fsa.FSA_nxtstp_8
      ,fsa.FSA_nxtstp_9
      ,fsa.FSA_nxtstp_10
      ,fsa.FSA_nxtstp_11
      ,fsa.FSA_nxtstp_12
      ,fsa.FSA_nxtstp_13
      ,fsa.FSA_nxtstp_14
      ,fsa.FSA_nxtstp_15      
      ,daily.day_1
      ,daily.day_2
      ,daily.day_3
      ,daily.day_4
      ,daily.day_5
      ,daily.color_day_1
      ,daily.color_day_2
      ,daily.color_day_3
      ,daily.color_day_4
      ,daily.color_day_5
      ,daily.color_am_1
      ,daily.color_am_2
      ,daily.color_am_3
      ,daily.color_am_4
      ,daily.color_am_5
      ,daily.color_pm_1
      ,daily.color_pm_2
      ,daily.color_pm_3
      ,daily.color_pm_4
      ,daily.color_pm_5
      ,daily.hw_missing_days      
      ,ROUND(wk_totals.n_hw_wk,0) AS n_hw_wk
      ,ROUND(wk_totals.hw_complete_wk,0) AS hw_complete_wk
      ,ROUND(wk_totals.hw_missing_wk,0) AS hw_missing_wk
      ,ROUND(wk_totals.hw_pct_wk,0) AS hw_pct_wk
      ,ROUND(mth_totals.uni_pct_mth,0) AS uni_pct_mth
      ,ROUND(CONVERT(FLOAT,mth_totals.purple_pink_mth) / CASE WHEN mth_totals.n_color_mth = 0 THEN NULL ELSE CONVERT(FLOAT,mth_totals.n_color_mth) END * 100, 0) AS purple_pink_mth
      ,ROUND(CONVERT(FLOAT,mth_totals.green_mth) / CASE WHEN mth_totals.n_color_mth = 0 THEN NULL ELSE CONVERT(FLOAT,mth_totals.n_color_mth) END * 100, 0) AS green_mth
      ,ROUND(CONVERT(FLOAT,mth_totals.yellow_mth) / CASE WHEN mth_totals.n_color_mth = 0 THEN NULL ELSE CONVERT(FLOAT,mth_totals.n_color_mth) END * 100, 0) AS yellow_mth
      ,ROUND(CONVERT(FLOAT,mth_totals.orange_mth) / CASE WHEN mth_totals.n_color_mth = 0 THEN NULL ELSE CONVERT(FLOAT,mth_totals.n_color_mth) END * 100, 0) AS orange_mth
      ,ROUND(CONVERT(FLOAT,mth_totals.red_mth) / CASE WHEN mth_totals.n_color_mth = 0 THEN NULL ELSE CONVERT(FLOAT,mth_totals.n_color_mth) END * 100, 0) AS red_mth      
      ,ROUND(mth_totals.pct_ontrack_mth,0) AS pct_ontrack_mth
      ,mth_totals.status_mth AS status_mth
      ,ROUND(cur_totals.n_hw_yr,0) AS n_hw_yr
      ,ROUND(cur_totals.hw_complete_yr,0) AS hw_complete_yr
      ,ROUND(cur_totals.hw_missing_yr,0) AS hw_missing_yr
      ,ROUND(cur_totals.hw_pct_yr      ,0) AS hw_pct_yr      
      ,ROUND(cur_totals.uni_pct_yr,0) AS uni_pct_yr
      ,ROUND(cur_totals.n_color_yr,0) AS n_color_yr
      ,ROUND(CONVERT(FLOAT,cur_totals.purple_pink_yr) / CASE WHEN cur_totals.n_color_yr = 0 THEN NULL ELSE CONVERT(FLOAT,cur_totals.n_color_yr) END * 100, 0) AS purple_pink_yr
      ,ROUND(CONVERT(FLOAT,cur_totals.green_yr) / CASE WHEN cur_totals.n_color_yr = 0 THEN NULL ELSE CONVERT(FLOAT,cur_totals.n_color_yr) END * 100, 0) AS green_yr
      ,ROUND(CONVERT(FLOAT,cur_totals.yellow_yr) / CASE WHEN cur_totals.n_color_yr = 0 THEN NULL ELSE CONVERT(FLOAT,cur_totals.n_color_yr) END * 100, 0) AS yellow_yr
      ,ROUND(CONVERT(FLOAT,cur_totals.orange_yr) / CASE WHEN cur_totals.n_color_yr = 0 THEN NULL ELSE CONVERT(FLOAT,cur_totals.n_color_yr) END * 100, 0) AS orange_yr
      ,ROUND(CONVERT(FLOAT,cur_totals.red_yr) / CASE WHEN cur_totals.n_color_yr = 0 THEN NULL ELSE CONVERT(FLOAT,cur_totals.n_color_yr) END * 100, 0) AS red_yr                  
      ,ROUND(cur_totals.n_hw_tri,0) AS n_hw_tri
      ,ROUND(cur_totals.hw_complete_tri,0) AS hw_complete_tri
      ,ROUND(cur_totals.hw_missing_tri,0) AS hw_missing_tri
      ,ROUND(cur_totals.hw_pct_tri,0) AS hw_pct_tri
      ,ROUND(cur_totals.n_color_tri,0) AS n_color_tri
      ,ROUND(CONVERT(FLOAT,cur_totals.purple_pink_tri) / CASE WHEN cur_totals.n_color_tri = 0 THEN NULL ELSE CONVERT(FLOAT,cur_totals.n_color_tri) END * 100, 0) AS purple_pink_tri
      ,ROUND(CONVERT(FLOAT,cur_totals.green_tri) / CASE WHEN cur_totals.n_color_tri = 0 THEN NULL ELSE CONVERT(FLOAT,cur_totals.n_color_tri) END * 100, 0) AS green_tri
      ,ROUND(CONVERT(FLOAT,cur_totals.yellow_tri) / CASE WHEN cur_totals.n_color_tri = 0 THEN NULL ELSE CONVERT(FLOAT,cur_totals.n_color_tri) END * 100, 0) AS yellow_tri
      ,ROUND(CONVERT(FLOAT,cur_totals.orange_tri) / CASE WHEN cur_totals.n_color_tri = 0 THEN NULL ELSE CONVERT(FLOAT,cur_totals.n_color_tri) END * 100, 0) AS orange_tri
      ,ROUND(CONVERT(FLOAT,cur_totals.red_tri) / CASE WHEN cur_totals.n_color_tri = 0 THEN NULL ELSE CONVERT(FLOAT,cur_totals.n_color_tri) END * 100, 0) AS red_tri      
      ,sw.n_total_yr AS sw_total_yr
      ,sw.n_correct_yr AS sw_correct_yr
      ,sw.n_missed_yr AS sw_missed_yr
      ,sw.pct_correct_yr AS sw_pct_yr
      ,sw.missed_words_yr AS sw_missedwords_yr
      ,sw.avg_total_yr AS sw_avg_total_yr
      ,sw.avg_correct_yr AS sw_avg_correct_yr
      ,sw.avg_pct_correct_yr AS sw_avg_pct_yr
      ,sp.pct_correct_wk AS sp_average_w
      ,sp.pct_correct_yr AS sp_average_yr
      ,vocab.pct_correct_wk AS v_average_w
      ,vocab.pct_correct_yr AS v_average_yr
FROM roster r WITH(NOLOCK)
JOIN curterm WITH(NOLOCK)
  ON 1 = 1
LEFT OUTER JOIN reporting_week rw WITH(NOLOCK)
  ON r.schoolid = rw.schoolid
LEFT OUTER JOIN attendance att WITH(NOLOCK)
  ON r.STUDENTID = att.studentid
LEFT OUTER JOIN ILLUMINATE$FSA_scores_wide#static fsa WITH(NOLOCK)
  ON r.STUDENTID = fsa.studentid
 AND rw.week_num = fsa.fsa_week
LEFT OUTER JOIN ES_DAILY$tracking_wide daily WITH(NOLOCK) 
  ON r.STUDENTID = daily.studentid
 AND rw.week_num = daily.week_num
LEFT OUTER JOIN ES_DAILY$tracking_totals wk_totals WITH(NOLOCK)
  ON r.STUDENTID = wk_totals.studentid
 AND rw.week_num = wk_totals.week_num 
LEFT OUTER JOIN ES_DAILY$tracking_totals mth_totals WITH(NOLOCK)
  ON r.STUDENTID = mth_totals.studentid 
 AND mth_totals.week_num IS NULL
 AND rw.month = mth_totals.month 
LEFT OUTER JOIN ES_DAILY$tracking_totals cur_totals WITH(NOLOCK)
  ON r.STUDENTID = cur_totals.studentid 
 AND cur_totals.week_num IS NULL
 AND cur_totals.month IS NULL
LEFT OUTER JOIN LIT$sight_word_totals sw WITH(NOLOCK)
  ON r.STUDENT_NUMBER = sw.student_number
 AND rw.week_num = sw.listweek_num
LEFT OUTER JOIN LIT$spelling_totals sp WITH(NOLOCK)
  ON r.STUDENT_NUMBER = sp.student_number
 AND rw.week_num = sp.listweek_num
LEFT OUTER JOIN LIT$vocab_totals vocab WITH(NOLOCK)
  ON r.STUDENT_NUMBER = vocab.student_number
 AND rw.week_num = vocab.listweek_num
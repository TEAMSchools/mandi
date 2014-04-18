USE KIPP_NJ
GO

ALTER VIEW REPORTING$report_card#ES AS

WITH roster AS (
 SELECT cs.STUDENTID
       ,s.STUDENT_NUMBER      
       ,s.LASTFIRST
       ,s.LAST_NAME
       ,s.FIRST_NAME
       ,co.GRADE_LEVEL
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
       ,cs.GUARDIANEMAIL
 FROM COHORT$comprehensive_long#static co WITH(NOLOCK)
 JOIN STUDENTS s WITH(NOLOCK)
   ON co.STUDENTID = s.ID
  AND s.ENROLL_STATUS = 0
 LEFT OUTER JOIN CUSTOM_STUDENTS cs WITH(NOLOCK)
   ON co.STUDENTID = cs.STUDENTID
 WHERE co.YEAR = dbo.fn_Global_Academic_Year()
   AND co.GRADE_LEVEL < 5
   AND co.RN = 1
)

,attendance AS (
  SELECT att.id AS studentid
        ,cur_absences_total
        ,cur_absences_doc AS excused_absences
        ,cur_tardies_total
        ,cur_early_dismiss
        ,trip_absences
        ,trip_status
  FROM ATT_MEM$attendance_counts att WITH(NOLOCK)
  WHERE att.grade_level < 5
 )

,reporting_week AS (
  SELECT time_per_name AS week_num        
        ,start_date
        ,end_date
        ,DATENAME(MONTH,start_date) AS month
        ,REPLACE(time_per_name,'_',' ') + ': ' + LEFT(CONVERT(VARCHAR,start_date,101),5) + ' - ' + LEFT(CONVERT(VARCHAR,end_date,101),5) AS week_title
  FROM REPORTING$dates WITH(NOLOCK)
  WHERE time_per_name = 'Week_02'
  --DATEADD(WEEK,-2,GETDATE()) >= start_date -- determines the previous week
  --  AND DATEADD(WEEK,-2,GETDATE()) <= end_date -- determines the previous week
    AND identifier = 'FSA'
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
      ,reporting_week.week_num
      ,reporting_week.start_date
      ,reporting_week.end_date
      ,reporting_week.week_title
      ,att.cur_absences_total
      ,att.excused_absences
      ,att.cur_tardies_total
      ,att.cur_early_dismiss
      ,att.trip_absences
      ,att.trip_status
      ,fsa.fsa_week
      ,fsa.fsa_prof_1
      ,fsa.fsa_prof_2
      ,fsa.fsa_prof_3
      ,fsa.fsa_prof_4
      ,fsa.fsa_prof_5
      ,fsa.fsa_prof_6
      ,fsa.fsa_prof_7
      ,fsa.fsa_prof_8
      ,fsa.fsa_prof_9
      ,fsa.fsa_prof_10
      ,fsa.fsa_score_1
      ,fsa.fsa_score_2
      ,fsa.fsa_score_3
      ,fsa.fsa_score_4
      ,fsa.fsa_score_5
      ,fsa.fsa_score_6
      ,fsa.fsa_score_7
      ,fsa.fsa_score_8
      ,fsa.fsa_score_9
      ,fsa.fsa_score_10
      ,fsa.fsa_subject_1
      ,fsa.fsa_subject_2
      ,fsa.fsa_subject_3
      ,fsa.fsa_subject_4
      ,fsa.fsa_subject_5
      ,fsa.fsa_subject_6
      ,fsa.fsa_subject_7
      ,fsa.fsa_subject_8
      ,fsa.fsa_subject_9
      ,fsa.fsa_subject_10
      ,daily.day_1
      ,daily.day_2
      ,daily.day_3
      ,daily.day_4
      ,daily.day_5
      ,daily.color_am_1
      ,daily.color_am_2
      ,daily.color_am_3
      ,daily.color_am_4
      ,daily.color_am_5
      ,daily.color_day_1
      ,daily.color_day_2
      ,daily.color_day_3
      ,daily.color_day_4
      ,daily.color_day_5
      ,daily.color_mid_1
      ,daily.color_mid_2
      ,daily.color_mid_3
      ,daily.color_mid_4
      ,daily.color_mid_5
      ,daily.color_pm_1
      ,daily.color_pm_2
      ,daily.color_pm_3
      ,daily.color_pm_4
      ,daily.color_pm_5
      ,daily.hw_1
      ,daily.hw_2
      ,daily.hw_3
      ,daily.hw_4
      ,daily.hw_5
      ,totals.n_hw_wk
      ,totals.hw_complete_wk
      ,totals.hw_missing_wk
      ,totals.hw_pct_wk
      ,totals.purple_pink_mth
      ,totals.green_mth
      ,totals.yellow_mth
      ,totals.orange_mth
      ,totals.red_mth
      ,totals.pct_ontrack_mth
      ,totals.status_mth
      ,totals.n_hw_yr
      ,totals.hw_complete_yr
      ,totals.hw_missing_yr
      ,totals.hw_pct_yr
      ,totals.n_color_yr
      ,totals.purple_pink_yr
      ,totals.green_yr
      ,totals.yellow_yr
      ,totals.orange_yr
      ,totals.red_yr
      ,sw.n_total AS sw_total_w
      ,sw.n_correct AS sw_correct_w
      ,sw.n_missed AS sw_missed_w
      ,sw.pct_correct AS sw_average_w
      ,sw.missed_words AS sw_missedwords_w
      ,sw.n_total_yr
      ,sw.n_correct_yr
      ,sw.n_missed_yr
      ,sw.pct_correct_yr
      ,sw.missed_words_yr
FROM roster r
LEFT OUTER JOIN reporting_week
  ON 1 = 1
JOIN attendance att
  ON r.STUDENTID = att.studentid
LEFT OUTER JOIN REPORTING$FSA_scores_wide fsa WITH(NOLOCK)
  ON r.STUDENTID = fsa.studentid
 AND reporting_week.week_num = fsa.fsa_week
LEFT OUTER JOIN REPORTING$daily_tracking_wide daily WITH(NOLOCK) 
  ON r.STUDENTID = daily.studentid
 AND reporting_week.week_num = daily.week_num
LEFT OUTER JOIN REPORTING$daily_tracking_totals totals WITH(NOLOCK)
  ON r.STUDENTID = totals.studentid
 AND r.SCHOOLID = totals.schoolid
 AND reporting_week.week_num = totals.week_num
 AND reporting_week.month = totals.month
LEFT OUTER JOIN REPORTING$sight_word_totals sw WITH(NOLOCK)
  ON r.STUDENT_NUMBER = sw.student_number
 AND reporting_week.week_num = sw.listweek_num
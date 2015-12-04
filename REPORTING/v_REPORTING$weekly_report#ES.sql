USE KIPP_NJ
GO

ALTER VIEW REPORTING$weekly_report#ES AS

WITH reporting_week AS (
  SELECT schoolid
        ,academic_year
        ,week_num
        ,start_date
        ,end_date
        ,month
        ,week_title      
        ,week_rn
  FROM
      (
       SELECT schoolid
             ,academic_year
             ,time_per_name AS week_num        
             ,start_date
             ,end_date
             ,COALESCE(custom, DATENAME(MONTH,start_date)) AS month
             ,COALESCE(report_name_long, CONCAT(REPLACE(time_per_name,'_',' '), ': ', CONVERT(VARCHAR,start_date,1), ' - ', CONVERT(VARCHAR,end_date,1))) AS week_title
             ,report_name_short AS term_end
             ,ROW_NUMBER() OVER(
               PARTITION BY academic_year, schoolid
                 ORDER BY start_date DESC) AS week_rn
       FROM KIPP_NJ..REPORTING$dates WITH(NOLOCK)    
       WHERE identifier = 'REP'    
         AND school_level = 'ES'           
         --AND academic_year = KIPP_NJ.dbo.fn_Global_Academic_Year()
         AND end_date < CONVERT(DATE,GETDATE())
      ) sub  
 )

SELECT r.student_number
      ,r.year AS academic_year      
      ,r.LASTFIRST      
      ,REPLACE(CONVERT(VARCHAR,r.GRADE_LEVEL),'0','K') AS grade_level
      ,r.SCHOOLID
      ,r.TEAM
      ,r.LUNCH_BALANCE
      ,CONCAT(r.STREET, ' - ', r.CITY, ', ', r.STATE, ' ', r.ZIP) AS address
      ,r.HOME_PHONE
      ,r.MOTHER AS parent_1_name      
      ,CONCAT(r.MOTHER_CELL + ' / ', r.MOTHER_DAY) AS parent_1_phone
      ,r.FATHER AS parent_2_name
      ,CONCAT(r.FATHER_CELL + ' / ' , r.FATHER_DAY) AS parent_2_phone
      ,REPLACE(CONVERT(NVARCHAR(MAX),r.GUARDIANEMAIL),',','; ') AS guardianemail
      
      /* reporting week and dates */      
      ,rw.week_title      
      ,rw.week_rn
      
      /* attendance */
      ,CONCAT(att.Y1_ABS_ALL, ' (', att.Y1_AE, ')') AS cur_absences_total
      ,CONCAT(att.Y1_T_ALL, ' (', att.Y1_TE, ')') AS cur_tardies_total      
      ,CONCAT(att.Y1_LE, ' (', att.Y1_LEX, ')') AS cur_early_dismiss  
      ,ROUND(att.cur_trip_abs,1) AS trip_absences
      ,CASE
        WHEN r.schoolid = 73255 AND att.cur_trip_abs >= 10 THEN 'Off Track'
        WHEN r.schoolid != 73255 AND att.cur_trip_abs >= 5 THEN 'Off Track'
        ELSE 'On Track'
       END AS trip_status
      
      /* FSA data */
      ,fsa.ELA_ADV
      ,fsa.ELA_PROF
      ,fsa.ELA_NY
      ,fsa.MATH_ADV
      ,fsa.MATH_PROF
      ,fsa.MATH_NY
      ,fsa.SPEC_ADV
      ,fsa.SPEC_PROF
      ,fsa.SPEC_NY

      /* CMA data*/
      ,cma.MATH_short_title
      ,cma.MATH_percent_correct
      ,cma.ELA_short_title
      ,cma.ELA_percent_correct
      
      /* daily tracking details */
      ,daily.color_hw_header
      ,daily.color_hw_data
      
      /* hw totals */
      ,CASE WHEN wk_totals.n_hw_wk IS NULL THEN NULL ELSE CONCAT(ROUND(wk_totals.hw_complete_wk,0), '/', ROUND(wk_totals.n_hw_wk,0)) END AS n_hw_wk      
      ,ROUND(wk_totals.hw_pct_wk,0) AS hw_pct_wk      
      ,CASE WHEN cur_totals.hw_complete_yr IS NULL THEN NULL ELSE CONCAT(ROUND(cur_totals.hw_complete_yr,0), '/', ROUND(cur_totals.n_hw_yr,0)) END AS n_hw_yr      
      ,ROUND(cur_totals.hw_pct_yr,0) AS hw_pct_yr
      /* uni totals */
      ,ROUND(mth_totals.uni_pct_mth,0) AS uni_pct_mth
      ,ROUND(cur_totals.uni_pct_yr,0) AS uni_pct_yr
      ,ROUND(cur_totals.uni_pct_tri,0) AS uni_pct_tri
      /* color totals */
      ,ROUND(CONVERT(FLOAT,mth_totals.purple_pink_mth) / CASE WHEN mth_totals.n_color_mth = 0 THEN NULL ELSE CONVERT(FLOAT,mth_totals.n_color_mth) END * 100, 0) AS purple_pink_mth
      ,ROUND(CONVERT(FLOAT,mth_totals.green_mth) / CASE WHEN mth_totals.n_color_mth = 0 THEN NULL ELSE CONVERT(FLOAT,mth_totals.n_color_mth) END * 100, 0) AS green_mth
      ,ROUND(CONVERT(FLOAT,mth_totals.yellow_mth) / CASE WHEN mth_totals.n_color_mth = 0 THEN NULL ELSE CONVERT(FLOAT,mth_totals.n_color_mth) END * 100, 0) AS yellow_mth
      ,ROUND(CONVERT(FLOAT,mth_totals.orange_mth) / CASE WHEN mth_totals.n_color_mth = 0 THEN NULL ELSE CONVERT(FLOAT,mth_totals.n_color_mth) END * 100, 0) AS orange_mth
      ,ROUND(CONVERT(FLOAT,mth_totals.red_mth) / CASE WHEN mth_totals.n_color_mth = 0 THEN NULL ELSE CONVERT(FLOAT,mth_totals.n_color_mth) END * 100, 0) AS red_mth            
      ,ROUND(CONVERT(FLOAT,cur_totals.purple_pink_yr) / CASE WHEN cur_totals.n_color_yr = 0 THEN NULL ELSE CONVERT(FLOAT,cur_totals.n_color_yr) END * 100, 0) AS purple_pink_yr
      ,ROUND(CONVERT(FLOAT,cur_totals.green_yr) / CASE WHEN cur_totals.n_color_yr = 0 THEN NULL ELSE CONVERT(FLOAT,cur_totals.n_color_yr) END * 100, 0) AS green_yr
      ,ROUND(CONVERT(FLOAT,cur_totals.yellow_yr) / CASE WHEN cur_totals.n_color_yr = 0 THEN NULL ELSE CONVERT(FLOAT,cur_totals.n_color_yr) END * 100, 0) AS yellow_yr
      ,ROUND(CONVERT(FLOAT,cur_totals.orange_yr) / CASE WHEN cur_totals.n_color_yr = 0 THEN NULL ELSE CONVERT(FLOAT,cur_totals.n_color_yr) END * 100, 0) AS orange_yr
      ,ROUND(CONVERT(FLOAT,cur_totals.red_yr) / CASE WHEN cur_totals.n_color_yr = 0 THEN NULL ELSE CONVERT(FLOAT,cur_totals.n_color_yr) END * 100, 0) AS red_yr                        
      ,ROUND(CONVERT(FLOAT,cur_totals.purple_pink_tri) / CASE WHEN cur_totals.n_color_tri = 0 THEN NULL ELSE CONVERT(FLOAT,cur_totals.n_color_tri) END * 100, 0) AS purple_pink_tri
      ,ROUND(CONVERT(FLOAT,cur_totals.green_tri) / CASE WHEN cur_totals.n_color_tri = 0 THEN NULL ELSE CONVERT(FLOAT,cur_totals.n_color_tri) END * 100, 0) AS green_tri
      ,ROUND(CONVERT(FLOAT,cur_totals.yellow_tri) / CASE WHEN cur_totals.n_color_tri = 0 THEN NULL ELSE CONVERT(FLOAT,cur_totals.n_color_tri) END * 100, 0) AS yellow_tri
      ,ROUND(CONVERT(FLOAT,cur_totals.orange_tri) / CASE WHEN cur_totals.n_color_tri = 0 THEN NULL ELSE CONVERT(FLOAT,cur_totals.n_color_tri) END * 100, 0) AS orange_tri
      ,ROUND(CONVERT(FLOAT,cur_totals.red_tri) / CASE WHEN cur_totals.n_color_tri = 0 THEN NULL ELSE CONVERT(FLOAT,cur_totals.n_color_tri) END * 100, 0) AS red_tri      
      /* culture status */
      ,ROUND(mth_totals.pct_ontrack_mth,0) AS pct_ontrack_mth
      ,mth_totals.status_mth AS status_mth

      /* word study */      
      ,CASE WHEN sw.n_total = 0 OR sw.n_total IS NULL THEN NULL ELSE CONCAT(sw.pct_correct, '% (', sw.n_correct, '/', sw.n_total, ')') END AS sw_pct_wk
      ,CASE WHEN sw.n_total_yr = 0 OR sw.n_total_yr IS NULL THEN NULL ELSE CONCAT(sw.pct_correct_yr, '% (', sw.n_correct_yr, '/', sw.n_total_yr, ')') END AS sw_pct_yr
      ,sw.missed_words_yr AS sw_missedwords_yr      
      ,CASE WHEN sp.n_total = 0 OR sp.n_total IS NULL THEN NULL ELSE CONCAT(sp.pct_correct, '% (', sp.n_correct, '/', sp.n_total, ')') END AS sp_pct_wk
      ,CASE WHEN sp.n_total_yr = 0 OR sp.n_total_yr IS NULL THEN NULL ELSE CONCAT(sp.pct_correct_yr, '% (', sp.n_correct_yr, '/', sp.n_total_yr, ')') END AS sp_pct_yr      
      ,sp.missed_words_yr AS sp_missedwords_yr
FROM KIPP_NJ..COHORT$identifiers_long#static r WITH(NOLOCK) 
LEFT OUTER JOIN reporting_week rw WITH(NOLOCK)
  ON r.schoolid = rw.schoolid
 AND r.year = rw.academic_year
LEFT OUTER JOIN KIPP_NJ..ATT_MEM$attendance_counts#static att WITH(NOLOCK)
  ON r.STUDENTID = att.studentid 
LEFT OUTER JOIN KIPP_NJ..ILLUMINATE$FSA_scores_wide#static fsa WITH(NOLOCK)
  ON r.student_number = fsa.student_number  
 AND r.year = fsa.academic_year
 AND rw.week_num = fsa.reporting_week 
LEFT OUTER JOIN KIPP_NJ..ILLUMINATE$CMA_scores_wide#static cma WITH(NOLOCK)
  ON r.student_number = cma.student_number
 AND r.year = cma.academic_year
LEFT OUTER JOIN KIPP_NJ..DAILY$tracking_wide#ES#static daily WITH(NOLOCK) 
  ON r.STUDENTID = daily.studentid
 AND r.year = daily.academic_year
 AND rw.week_num = daily.week_num
LEFT OUTER JOIN KIPP_NJ..DAILY$tracking_totals#ES#static wk_totals WITH(NOLOCK)
  ON r.STUDENTID = wk_totals.studentid
 AND r.year = wk_totals.academic_year
 AND rw.week_num = wk_totals.week_num 
LEFT OUTER JOIN KIPP_NJ..DAILY$tracking_totals#ES#static mth_totals WITH(NOLOCK)
  ON r.STUDENTID = mth_totals.studentid 
 AND r.year = mth_totals.academic_year
 AND mth_totals.week_num IS NULL
 AND rw.month = mth_totals.month 
LEFT OUTER JOIN KIPP_NJ..DAILY$tracking_totals#ES#static cur_totals WITH(NOLOCK)
  ON r.STUDENTID = cur_totals.studentid 
 AND r.year = cur_totals.academic_year
 AND cur_totals.week_num IS NULL
 AND cur_totals.month IS NULL
LEFT OUTER JOIN KIPP_NJ..LIT$sight_word_totals#static sw WITH(NOLOCK)
  ON r.STUDENT_NUMBER = sw.student_number
 AND r.year = sw.academic_year
 AND rw.week_num = sw.listweek_num
LEFT OUTER JOIN KIPP_NJ..LIT$spelling_totals#static sp WITH(NOLOCK)
  ON r.STUDENT_NUMBER = sp.student_number
 AND r.year = sp.academic_year 
 AND rw.week_num = sp.listweek_num
WHERE r.GRADE_LEVEL <= 4  
  AND r.schoolid != 73252
  AND r.RN = 1
  AND r.enroll_status = 0
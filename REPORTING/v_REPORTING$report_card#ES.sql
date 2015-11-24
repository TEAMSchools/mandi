USE KIPP_NJ
GO

ALTER VIEW REPORTING$report_card#ES AS

WITH curterm AS (
  SELECT schoolid
        ,academic_year
        ,term
        ,rt
        ,start_date
        ,end_date        
        ,term_title      
        ,term_rn
  FROM
      (
       SELECT schoolid
             ,academic_year
             ,time_per_name AS rt
             ,alt_name AS term
             ,start_date
             ,end_date             
             ,COALESCE(report_name_long, CONCAT(REPLACE(alt_name,'_',' '), ': ', CONVERT(VARCHAR,start_date,1), ' - ', CONVERT(VARCHAR,end_date,1))) AS term_title
             ,report_name_short AS term_end
             ,ROW_NUMBER() OVER(
               PARTITION BY academic_year, schoolid
                 ORDER BY start_date DESC) AS term_rn
       FROM KIPP_NJ..REPORTING$dates WITH(NOLOCK)    
       WHERE identifier = 'RT'    
         AND school_level = 'ES'           
         --AND academic_year = KIPP_NJ.dbo.fn_Global_Academic_Year()
         AND end_date <= CONVERT(DATE,GETDATE())
         AND alt_name NOT IN ('Summer School','EOY','Capstone')
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
      ,rw.term
      ,rw.term_title      
      ,rw.term_rn
      
      /* attendance */
      ,CONCAT(att.Y1_ABS_ALL, ' (', att.Y1_AE, ')') AS cur_absences_total
      ,CONCAT(att.Y1_T_ALL, ' (', att.Y1_TE, ')') AS cur_tardies_total      
      ,CONCAT(att.Y1_LE, ' (', att.Y1_LEX, ')') AS cur_early_dismiss        
      
      /* CMA standards */
      ,std.ELA_ADV
      ,std.ELA_PROF
      ,std.ELA_APRO
      ,std.ELA_NY
      
      ,std.MATH_ADV
      ,std.MATH_PROF
      ,std.MATH_APRO
      ,std.MATH_NY
      
      ,std.SPEC_ADV
      ,std.SPEC_PROF
      ,std.SPEC_APRO
      ,std.SPEC_NY

      /* CMA data*/
      ,cma.MATH_short_title
      ,cma.MATH_percent_correct
      ,cma.ELA_short_title
      ,cma.ELA_percent_correct
      
      /* writing rubric */
      ,wrt.writing_header
      ,wrt.Expository_Content 
      ,wrt.Expository_Language
      ,wrt.Narrative_Narrative

      /* hw totals */      
      ,CASE WHEN cur_totals.hw_complete_rc IS NULL THEN NULL ELSE CONCAT(ROUND(cur_totals.hw_complete_rc,0), '/', ROUND(cur_totals.n_hw_rc,0)) END AS n_hw_tri
      ,ROUND(cur_totals.hw_pct_rc,0) AS hw_pct_tri
      ,CASE WHEN cur_totals.hw_complete_yr IS NULL THEN NULL ELSE CONCAT(ROUND(cur_totals.hw_complete_yr,0), '/', ROUND(cur_totals.n_hw_yr,0)) END AS n_hw_yr      
      ,ROUND(cur_totals.hw_pct_yr,0) AS hw_pct_yr
      /* uni totals */      
      ,ROUND(cur_totals.uni_pct_rc,0) AS uni_pct_tri
      ,ROUND(cur_totals.uni_pct_yr,0) AS uni_pct_yr      
      /* color totals */      
      ,ROUND(CONVERT(FLOAT,cur_totals.purple_pink_rc) / CASE WHEN cur_totals.n_color_rc = 0 THEN NULL ELSE CONVERT(FLOAT,cur_totals.n_color_rc) END * 100, 0) AS purple_pink_tri
      ,ROUND(CONVERT(FLOAT,cur_totals.green_rc) / CASE WHEN cur_totals.n_color_rc = 0 THEN NULL ELSE CONVERT(FLOAT,cur_totals.n_color_rc) END * 100, 0) AS green_tri
      ,ROUND(CONVERT(FLOAT,cur_totals.yellow_rc) / CASE WHEN cur_totals.n_color_rc = 0 THEN NULL ELSE CONVERT(FLOAT,cur_totals.n_color_rc) END * 100, 0) AS yellow_tri
      ,ROUND(CONVERT(FLOAT,cur_totals.orange_rc) / CASE WHEN cur_totals.n_color_rc = 0 THEN NULL ELSE CONVERT(FLOAT,cur_totals.n_color_rc) END * 100, 0) AS orange_tri
      ,ROUND(CONVERT(FLOAT,cur_totals.red_rc) / CASE WHEN cur_totals.n_color_rc = 0 THEN NULL ELSE CONVERT(FLOAT,cur_totals.n_color_rc) END * 100, 0) AS red_tri
      ,ROUND(CONVERT(FLOAT,cur_totals.purple_pink_yr) / CASE WHEN cur_totals.n_color_yr = 0 THEN NULL ELSE CONVERT(FLOAT,cur_totals.n_color_yr) END * 100, 0) AS purple_pink_yr
      ,ROUND(CONVERT(FLOAT,cur_totals.green_yr) / CASE WHEN cur_totals.n_color_yr = 0 THEN NULL ELSE CONVERT(FLOAT,cur_totals.n_color_yr) END * 100, 0) AS green_yr
      ,ROUND(CONVERT(FLOAT,cur_totals.yellow_yr) / CASE WHEN cur_totals.n_color_yr = 0 THEN NULL ELSE CONVERT(FLOAT,cur_totals.n_color_yr) END * 100, 0) AS yellow_yr
      ,ROUND(CONVERT(FLOAT,cur_totals.orange_yr) / CASE WHEN cur_totals.n_color_yr = 0 THEN NULL ELSE CONVERT(FLOAT,cur_totals.n_color_yr) END * 100, 0) AS orange_yr
      ,ROUND(CONVERT(FLOAT,cur_totals.red_yr) / CASE WHEN cur_totals.n_color_yr = 0 THEN NULL ELSE CONVERT(FLOAT,cur_totals.n_color_yr) END * 100, 0) AS red_yr          

      /* word study */            
      ,CASE WHEN sw.n_total_yr = 0 OR sw.n_total_yr IS NULL THEN NULL ELSE CONCAT(sw.pct_correct_yr, '% (', sw.n_correct_yr, '/', sw.n_total_yr, ')') END AS sw_pct_yr
      ,sw.missed_words_yr AS sw_missedwords_yr            
      ,CASE WHEN sp.n_total_yr = 0 OR sp.n_total_yr IS NULL THEN NULL ELSE CONCAT(sp.pct_correct_yr, '% (', sp.n_correct_yr, '/', sp.n_total_yr, ')') END AS sp_pct_yr      
      ,sp.missed_words_yr AS sp_missedwords_yr

      /* reading growth */
      ,lit.lvls_grown_yr
      ,lit.DR_read_lvl
      ,lit.DR_goal_lvl
      ,lit.Q1_read_lvl
      ,lit.Q1_goal_lvl
      ,lit.Q2_read_lvl
      ,lit.Q2_goal_lvl
      ,lit.Q3_read_lvl
      ,lit.Q3_goal_lvl
      ,lit.Q4_read_lvl
      ,lit.Q4_goal_lvl

      /* social skills */
      ,soc.social_skills_header
      ,soc.social_skills_grouped

      /* promo status */
      ,promo.offtrack_days_limit
      ,promo.att_ARFR_status
      ,promo.lit_ARFR_status
      ,CASE WHEN CONCAT(promo.att_ARFR_status,promo.lit_ARFR_status) LIKE '%Off Track%' THEN 'At Risk for Retention' ELSE 'On Track' END AS overall_arfr_status
      ,promo.att_pts
      ,promo.att_pts_pct

      /* comments */
      ,comm.math_comments
      ,comm.reading_comments
      ,comm.writing_comments
      ,comm.character_comments
FROM KIPP_NJ..COHORT$identifiers_long#static r WITH(NOLOCK) 
LEFT OUTER JOIN curterm rw WITH(NOLOCK)
  ON r.schoolid = rw.schoolid
 AND r.year = rw.academic_year
LEFT OUTER JOIN KIPP_NJ..ATT_MEM$attendance_counts#static att WITH(NOLOCK)
  ON r.STUDENTID = att.studentid 
LEFT OUTER JOIN KIPP_NJ..ILLUMINATE$CMA_standards_wide#static std WITH(NOLOCK)
  ON r.student_number = std.student_number  
 AND r.year = std.academic_year
 AND rw.term = std.term 
LEFT OUTER JOIN KIPP_NJ..ILLUMINATE$CMA_scores_wide#static cma WITH(NOLOCK)
  ON r.student_number = cma.student_number
 AND r.year = cma.academic_year
LEFT OUTER JOIN KIPP_NJ..DAILY$tracking_totals#ES#static cur_totals WITH(NOLOCK)
  ON r.STUDENTID = cur_totals.studentid 
 AND r.year = cur_totals.academic_year
 AND cur_totals.week_num IS NULL
 AND cur_totals.month IS NULL
LEFT OUTER JOIN KIPP_NJ..LIT$sight_word_totals#static sw WITH(NOLOCK)
  ON r.STUDENT_NUMBER = sw.student_number
 AND r.year = sw.academic_year
 AND sw.listweek_num IS NULL
LEFT OUTER JOIN KIPP_NJ..LIT$spelling_totals#static sp WITH(NOLOCK)
  ON r.STUDENT_NUMBER = sp.student_number
 AND r.year = sp.academic_year 
 AND sp.listweek_num IS NULL
LEFT OUTER JOIN KIPP_NJ..LIT$achieved_wide lit WITH(NOLOCK)
  ON r.studentid = lit.studentid
LEFT OUTER JOIN KIPP_NJ..REPORTING$social_skills_wide#ES soc WITH(NOLOCK)
  ON r.student_number = soc.student_number
 AND rw.term = soc.term
LEFT OUTER JOIN KIPP_NJ..PROMO$promo_status#ES promo WITH(NOLOCK)
  ON r.student_number = promo.student_number
LEFT OUTER JOIN KIPP_NJ..REPORTING$report_card_comments#ES comm WITH(NOLOCK)
  ON r.student_number = comm.student_number
 AND rw.term = comm.term
LEFT OUTER JOIN KIPP_NJ..ILLUMINATE$writing_scores_wide wrt WITH(NOLOCK)
  ON r.student_number = wrt.student_number
WHERE r.GRADE_LEVEL <= 4  
  AND r.schoolid != 73252
  AND r.RN = 1
  AND r.enroll_status = 0
  AND r.year = KIPP_NJ.dbo.fn_Global_Academic_Year()
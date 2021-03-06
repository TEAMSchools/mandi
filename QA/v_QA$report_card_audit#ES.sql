USE KIPP_NJ
GO

ALTER VIEW QA$report_card_audit#ES AS

SELECT *
FROM
    (
     SELECT student_number
           ,LASTFIRST
           ,grade_level
           ,CASE WHEN team LIKE '%pathways%' THEN 732570 ELSE schoolid END AS schoolid
           ,TEAM
           ,term
           /* unpivot columns */
           ,ISNULL(CONVERT(VARCHAR,cur_absences_total),'') AS cur_absences_total
           ,ISNULL(CONVERT(VARCHAR,cur_tardies_total),'') AS cur_tardies_total
           ,ISNULL(CONVERT(VARCHAR,cur_early_dismiss),'') AS cur_early_dismiss
           ,ISNULL(CONVERT(VARCHAR,ELA_ADV),'') AS ELA_ADV
           ,ISNULL(CONVERT(VARCHAR,ELA_PROF),'') AS ELA_PROF
           ,ISNULL(CONVERT(VARCHAR,ELA_APRO),'') AS ELA_APRO
           ,ISNULL(CONVERT(VARCHAR,ELA_NY),'') AS ELA_NY
           ,ISNULL(CONVERT(VARCHAR,MATH_ADV),'') AS MATH_ADV
           ,ISNULL(CONVERT(VARCHAR,MATH_PROF),'') AS MATH_PROF
           ,ISNULL(CONVERT(VARCHAR,MATH_APRO),'') AS MATH_APRO
           ,ISNULL(CONVERT(VARCHAR,MATH_NY),'') AS MATH_NY
           ,ISNULL(CONVERT(VARCHAR,SPEC_ADV),'') AS SPEC_ADV
           ,ISNULL(CONVERT(VARCHAR,SPEC_PROF),'') AS SPEC_PROF
           ,ISNULL(CONVERT(VARCHAR,SPEC_APRO),'') AS SPEC_APRO
           ,ISNULL(CONVERT(VARCHAR,SPEC_NY),'') AS SPEC_NY
           --,ISNULL(CONVERT(VARCHAR,MATH_short_title),'') AS MATH_short_title
           ,ISNULL(CONVERT(VARCHAR,MATH_percent_correct),'') AS MATH_percent_correct
           --,ISNULL(CONVERT(VARCHAR,ELA_short_title),'') AS ELA_short_title
           ,ISNULL(CONVERT(VARCHAR,ELA_percent_correct      ),'') AS ELA_percent_correct      
           ,ISNULL(CONVERT(VARCHAR,Expository_Content),'') AS Expository_Content
           ,ISNULL(CONVERT(VARCHAR,Expository_Language),'') AS Expository_Language
           ,ISNULL(CONVERT(VARCHAR,Narrative_Narrative),'') AS Narrative_Narrative
           ,ISNULL(CONVERT(VARCHAR,n_hw_tri),'') AS n_hw_tri
           ,ISNULL(CONVERT(VARCHAR,hw_pct_tri),'') AS hw_pct_tri
           ,ISNULL(CONVERT(VARCHAR,n_hw_yr),'') AS n_hw_yr
           ,ISNULL(CONVERT(VARCHAR,hw_pct_yr),'') AS hw_pct_yr
           ,ISNULL(CONVERT(VARCHAR,uni_pct_tri),'') AS uni_pct_tri
           ,ISNULL(CONVERT(VARCHAR,uni_pct_yr),'') AS uni_pct_yr
           ,ISNULL(CONVERT(VARCHAR,purple_pink_tri),'') AS purple_pink_tri
           ,ISNULL(CONVERT(VARCHAR,green_tri),'') AS green_tri
           ,ISNULL(CONVERT(VARCHAR,yellow_tri),'') AS yellow_tri
           ,ISNULL(CONVERT(VARCHAR,orange_tri),'') AS orange_tri
           ,ISNULL(CONVERT(VARCHAR,red_tri),'') AS red_tri
           ,ISNULL(CONVERT(VARCHAR,purple_pink_yr),'') AS purple_pink_yr
           ,ISNULL(CONVERT(VARCHAR,green_yr),'') AS green_yr
           ,ISNULL(CONVERT(VARCHAR,yellow_yr),'') AS yellow_yr
           ,ISNULL(CONVERT(VARCHAR,orange_yr),'') AS orange_yr
           ,ISNULL(CONVERT(VARCHAR,red_yr),'') AS red_yr
           ,ISNULL(CONVERT(VARCHAR,sw_pct_yr),'') AS sw_pct_yr
           ,ISNULL(CONVERT(VARCHAR,sw_missedwords_yr),'') AS sw_missedwords_yr
           ,ISNULL(CONVERT(VARCHAR,sp_pct_yr),'') AS sp_pct_yr
           ,ISNULL(CONVERT(VARCHAR,sp_missedwords_yr      ),'') AS sp_missedwords_yr      
           ,ISNULL(CONVERT(VARCHAR,DR_read_lvl),'') AS DR_read_lvl
           ,ISNULL(CONVERT(VARCHAR,DR_goal_lvl),'') AS DR_goal_lvl
           ,ISNULL(CONVERT(VARCHAR,Q1_read_lvl),'') AS Q1_read_lvl
           ,ISNULL(CONVERT(VARCHAR,Q1_goal_lvl),'') AS Q1_goal_lvl
           ,ISNULL(CONVERT(VARCHAR,Q2_read_lvl),'') AS Q2_read_lvl
           ,ISNULL(CONVERT(VARCHAR,Q2_goal_lvl),'') AS Q2_goal_lvl
           ,ISNULL(CONVERT(VARCHAR,Q3_read_lvl),'') AS Q3_read_lvl
           ,ISNULL(CONVERT(VARCHAR,Q3_goal_lvl),'') AS Q3_goal_lvl
           ,ISNULL(CONVERT(VARCHAR,Q4_read_lvl),'') AS Q4_read_lvl
           ,ISNULL(CONVERT(VARCHAR,Q4_goal_lvl      ),'') AS Q4_goal_lvl      
           ,ISNULL(CONVERT(VARCHAR,social_skills_grouped),'') AS social_skills_grouped
           ,ISNULL(CONVERT(VARCHAR,att_ARFR_status),'') AS att_ARFR_status
           ,ISNULL(CONVERT(VARCHAR,lit_ARFR_status),'') AS lit_ARFR_status
           ,ISNULL(CONVERT(VARCHAR,overall_arfr_status),'') AS overall_arfr_status
           --,ISNULL(CONVERT(VARCHAR,offtrack_days_limit      ),'') AS offtrack_days_limit      
           ,ISNULL(CONVERT(VARCHAR,lvls_grown_yr),'') AS lvls_grown_yr
           ,ISNULL(CONVERT(VARCHAR,att_pts),'') AS att_pts
           ,ISNULL(CONVERT(VARCHAR,att_pts_pct),'') AS att_pts_pct
           ,ISNULL(CONVERT(VARCHAR,math_comments),'') AS math_comments
           ,ISNULL(CONVERT(VARCHAR,reading_comments),'') AS reading_comments
           ,ISNULL(CONVERT(VARCHAR,writing_comments),'') AS writing_comments
           ,ISNULL(CONVERT(VARCHAR,character_comments),'') AS character_comments
     FROM KIPP_NJ..REPORTING$report_card#ES WITH(NOLOCK)
     WHERE term_rn = 1
    ) sub
UNPIVOT(
  value
  FOR field IN (cur_absences_total
      ,cur_tardies_total
      ,cur_early_dismiss
      ,ELA_ADV
      ,ELA_PROF
      ,ELA_APRO
      ,ELA_NY
      ,MATH_ADV
      ,MATH_PROF
      ,MATH_APRO
      ,MATH_NY
      ,SPEC_ADV
      ,SPEC_PROF
      ,SPEC_APRO
      ,SPEC_NY
      --,MATH_short_title
      --,ELA_short_title
      ,MATH_percent_correct      
      ,ELA_percent_correct      
      ,Expository_Content
      ,Expository_Language
      ,Narrative_Narrative
      ,n_hw_tri
      ,hw_pct_tri
      ,n_hw_yr
      ,hw_pct_yr
      ,uni_pct_tri
      ,uni_pct_yr
      ,purple_pink_tri
      ,green_tri
      ,yellow_tri
      ,orange_tri
      ,red_tri
      ,purple_pink_yr
      ,green_yr
      ,yellow_yr
      ,orange_yr
      ,red_yr
      ,sw_pct_yr
      ,sw_missedwords_yr
      ,sp_pct_yr
      ,sp_missedwords_yr      
      ,DR_read_lvl
      ,DR_goal_lvl
      ,Q1_read_lvl
      ,Q1_goal_lvl
      ,Q2_read_lvl
      ,Q2_goal_lvl
      ,Q3_read_lvl
      ,Q3_goal_lvl
      ,Q4_read_lvl
      ,Q4_goal_lvl      
      ,social_skills_grouped
      ,att_ARFR_status
      ,lit_ARFR_status
      ,overall_arfr_status
      --,offtrack_days_limit      
      ,lvls_grown_yr
      ,att_pts
      ,att_pts_pct
      ,math_comments
      ,reading_comments
      ,writing_comments
      ,character_comments)
 ) u
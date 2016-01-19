USE KIPP_NJ
GO

ALTER VIEW QA$promo_status_audit#ES AS

SELECT student_number
      ,lastfirst
      ,CASE WHEN team LIKE '%pathways%' THEN 732570 ELSE schoolid END AS schoolid
      ,grade_level
      ,team
      ,entry_grade_level
      ,SPEDLEP
      ,retained_yr_flag
      ,term
      ,CASE
        WHEN field IN ('read_lvl','goal_lvl','met_goal','base_read_lvl','lvls_grown_yr','lvls_grown_term','lit_ARFR_status') THEN 'LIT'
        WHEN field IN ('offtrack_days_limit','mem_days','abs_days','tardy_days','att_pts','att_pts_pct','overall_ada','att_ARFR_status') THEN 'ATT'
        ELSE 'OVR'
       END AS field_type
      ,field
      ,value
      ,CASE 
        WHEN KIPP_NJ.dbo.GROUP_CONCAT(value) OVER(PARTITION BY student_number, term) LIKE '%At Risk%' THEN -2
        WHEN KIPP_NJ.dbo.GROUP_CONCAT(value) OVER(PARTITION BY student_number, term) LIKE '%Off Track%' THEN -1
        ELSE 0 
       END AS is_ARFR
      ,MAX(CASE WHEN field = 'att_ARFR_status' THEN value ELSE NULL END) OVER(PARTITION BY student_number, term) AS att_arfr_status
      ,MAX(CASE WHEN field = 'lit_ARFR_status' THEN value ELSE NULL END) OVER(PARTITION BY student_number, term) AS lit_arfr_status
FROM
    (
     SELECT student_number      
           ,lastfirst
           ,schoolid
           ,grade_level 
           ,team
           ,entry_grade_level
           ,SPEDLEP
           ,retained_yr_flag
           ,term      
      
           /* lit growth */
           ,CONVERT(VARCHAR,read_lvl) AS read_lvl
           ,CONVERT(VARCHAR,goal_lvl) AS goal_lvl
           ,CONVERT(VARCHAR,met_goal) AS met_goal
           ,CONVERT(VARCHAR,base_read_lvl) AS base_read_lvl
           ,CONVERT(VARCHAR,lvls_grown_yr) AS lvls_grown_yr
           ,CONVERT(VARCHAR,lvls_grown_term) AS lvls_grown_term
           ,CONVERT(VARCHAR,lit_ARFR_status) AS lit_ARFR_status
      
           /* attendance */
           ,CONVERT(VARCHAR,offtrack_days_limit) AS offtrack_days_limit
           ,CONVERT(VARCHAR,mem_days) AS mem_days
           ,CONVERT(VARCHAR,abs_days) AS abs_days
           ,CONVERT(VARCHAR,tardy_days) AS tardy_days
           ,CONVERT(VARCHAR,att_pts) AS att_pts
           ,CONVERT(VARCHAR,att_pts_pct) AS att_pts_pct
           ,CONVERT(VARCHAR,overall_ada) AS overall_ada
           ,CONVERT(VARCHAR,att_ARFR_status) AS att_ARFR_status

           /* overall */
           ,CONVERT(VARCHAR,
              CASE
               WHEN CONCAT(lit_ARFR_status,att_ARFR_status) LIKE '%See Teacher%' THEN 'See Teacher'
               WHEN CONCAT(lit_ARFR_status,att_ARFR_status) LIKE '%ARFR%' THEN 'At Risk'
               WHEN CONCAT(lit_ARFR_status,att_ARFR_status) LIKE '%Off Track%' THEN 'Off Track'
               ELSE 'On Track'
              END) AS overall_ARFR_status
     FROM
         (
          SELECT co.STUDENT_NUMBER           
                ,co.studentid
                ,co.lastfirst
                ,co.team
                ,co.entry_grade_level
                ,co.schoolid
                ,co.grade_level
                ,co.year           
                ,co.spedlep
                ,co.retained_yr_flag           
                ,dt.alt_name AS term           
           
                /* lit */
                ,promo.read_lvl
                ,promo.goal_lvl               
                ,promo.met_goal
                ,promo.lit_goal_status
                ,promo.base_read_lvl
                ,promo.lvls_grown_yr
                ,promo.lvls_grown_term
                ,promo.lit_ARFR_status
           
                /* attendance */
                ,promo.mem_days
                ,promo.abs_days
                ,promo.tardy_days
                ,promo.overall_ada
                ,promo.offtrack_days_limit           
                ,promo.att_pts
                ,promo.att_pts_pct
                ,promo.att_ARFR_status           
          FROM KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK)
          JOIN KIPP_NJ..REPORTING$dates dt WITH(NOLOCK)
            ON co.schoolid = dt.schoolid  
           AND co.year = dt.academic_year
           AND dt.identifier = 'RT'
           AND dt.alt_name != 'Summer School'
          JOIN KIPP_NJ..PROMO$promo_status#ES promo
            ON co.student_number = promo.STUDENT_NUMBER
           AND dt.alt_name = promo.term
          WHERE co.grade_level <= 4 AND co.schoolid != 73252
            AND co.year = KIPP_NJ.dbo.fn_Global_Academic_Year()
            AND co.rn = 1
         ) sub
    ) sub
UNPIVOT(
  value
  FOR field IN (read_lvl
               ,goal_lvl
               ,met_goal
               ,base_read_lvl
               ,lvls_grown_yr
               ,lvls_grown_term
               ,lit_ARFR_status
               ,offtrack_days_limit
               ,mem_days
               ,abs_days
               ,tardy_days
               ,att_pts
               ,att_pts_pct
               ,overall_ada
               ,att_ARFR_status
               ,overall_ARFR_status)
 ) u
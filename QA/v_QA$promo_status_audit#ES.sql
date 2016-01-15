USE KIPP_NJ
GO

ALTER VIEW QA$promo_status_audit#ES AS

WITH lit AS (
  SELECT lit.STUDENTID
        ,lit.academic_year
        ,lit.test_round
        ,lit.read_lvl
        ,lit.goal_lvl      
        ,lit.goal_status
        ,achv.lvls_grown_yr      
        ,CASE 
          WHEN lit.met_goal = '1' THEN 'Y'
          WHEN lit.met_goal = '0' THEN 'N'
         END AS met_goal            
        ,COALESCE(achv.DR_read_lvl, achv.Q1_read_lvl, achv.Q2_read_lvl, achv.Q3_read_lvl, achv.Q4_read_lvl) AS base_read_lvl      
        ,CASE
          WHEN lit.test_round = 'Q1' THEN lit.lvl_num - achv.DR_lvl_num
          WHEN lit.test_round = 'Q2' THEN lit.lvl_num - COALESCE(achv.DR_lvl_num, achv.Q1_lvl_num)
          WHEN lit.test_round = 'Q3' THEN lit.lvl_num - COALESCE(achv.DR_lvl_num, achv.Q1_lvl_num, achv.Q2_lvl_num)
          WHEN lit.test_round = 'Q4' THEN lit.lvl_num - COALESCE(achv.DR_lvl_num, achv.Q1_lvl_num, achv.Q2_lvl_num, achv.Q3_lvl_num)
         END AS lvls_grown_term
  FROM KIPP_NJ..LIT$achieved_by_round#static lit WITH(NOLOCK)  
  JOIN KIPP_NJ..LIT$achieved_wide achv WITH(NOLOCK)
    ON lit.studentid = achv.studentid
  WHERE lit.academic_year = KIPP_NJ.dbo.fn_Global_Academic_Year()
 )

,attendance AS (
  SELECT student_number
        ,CEILING(SUM(membershipvalue) * 0.1) AS offtrack_days_limit              
        ,CONVERT(FLOAT,ROUND(SUM(ISNULL(attendance_points, 0)), 1, 1)) AS att_pts
        ,ROUND(((SUM(membershipvalue) - SUM(ISNULL(attendance_points,0))) / SUM(membershipvalue)) * 100, 0) AS att_pts_pct      
        ,SUM(membershipvalue) AS mem_days
        ,SUM(is_absent) AS abs_days
        ,SUM(is_tardy) AS tardy_days
        ,ROUND((AVG(ATTENDANCEVALUE) * 100), 0) AS overall_ada
  FROM
      (
       SELECT co.student_number
             ,cal.date_value
             ,CONVERT(FLOAT,cal.membershipvalue) AS membershipvalue             
             ,CASE
               WHEN att.ATT_CODE IN ('A') THEN 1.0
               WHEN att.ATT_CODE IN ('T', 'T10') THEN (1.0/3.0) + 0.000001 /* pushes the 3rd tardy over the edge from .999... */
              END AS attendance_points
             ,CASE WHEN mem.membershipvalue = 1 AND (att.ATT_CODE != 'A' OR att. ATT_CODE IS NULL) THEN 1.0 ELSE 0.0 END AS attendancevalue
             ,CASE WHEN att.ATT_CODE IN ('A') THEN 1 ELSE 0 END AS is_absent
             ,CASE WHEN att.ATT_CODE IN ('T', 'T10') THEN 1 ELSE 0 END AS is_tardy
       FROM KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK)
       JOIN KIPP_NJ..PS$CALENDAR_DAY cal WITH(NOLOCK)
         ON co.schoolid = cal.schoolid
        AND co.year = cal.academic_year
        AND cal.insession = 1
        AND cal.date_value <= CONVERT(DATE,GETDATE())
       LEFT OUTER JOIN KIPP_NJ..ATT_MEM$MEMBERSHIP mem WITH(NOLOCK)
         ON co.studentid = mem.STUDENTID
        AND cal.date_value = mem.CALENDARDATE
       LEFT OUTER JOIN KIPP_NJ..ATT_MEM$ATTENDANCE att WITH(NOLOCK)
         ON co.studentid = att.STUDENTID
        AND cal.date_value = att.ATT_DATE
       WHERE co.year = KIPP_NJ.dbo.fn_Global_Academic_Year()
         AND co.grade_level <= 4 AND co.schoolid != 73252
         AND co.rn = 1
      ) sub
  GROUP BY student_number
 )

SELECT student_number
      ,lastfirst
      ,schoolid
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
                ,lit.read_lvl
                ,lit.goal_lvl               
                ,lit.met_goal
                ,lit.goal_status AS lit_goal_status
                ,lit.base_read_lvl
                ,lit.lvls_grown_yr
                ,lit.lvls_grown_term
                ,CASE        
                  WHEN co.SPEDLEP = 'SPED' OR co.retained_yr_flag = 1 THEN 'See Teacher'                        
                  WHEN (co.schoolid = 73257 AND (co.grade_level - (year - 2014)) > 0) AND lit.lvls_grown_term IS NULL THEN NULL        
                  WHEN (co.schoolid = 73257 AND (co.grade_level - (year - 2014)) > 0) AND lit.lvls_grown_term > 0 THEN 'On Track' /* Life Upper students have different promo criteria */
                  WHEN (co.schoolid = 73257 AND (co.grade_level - (year - 2014)) > 0) AND lit.lvls_grown_term = 0 THEN 'ARFR' /* Life Upper students have different promo criteria */                
                  ELSE lit.goal_status
                 END AS lit_ARFR_status
           
                /* attendance */
                ,att.mem_days
                ,att.abs_days
                ,att.tardy_days
                ,att.overall_ada
                ,att.offtrack_days_limit           
                ,att.att_pts
                ,att.att_pts_pct
                ,CASE 
                  WHEN co.SPEDLEP = 'SPED' OR co.retained_yr_flag = 1 THEN 'See Teacher'
                  WHEN att.att_pts_pct < 90 THEN 'ARFR'
                  ELSE 'On Track'
                 END AS att_ARFR_status           
          FROM KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK)
          JOIN KIPP_NJ..REPORTING$dates dt WITH(NOLOCK)
            ON co.schoolid = dt.schoolid  
           AND co.year = dt.academic_year
           AND dt.identifier = 'RT'
           AND dt.alt_name != 'Summer School'
          JOIN lit
            ON co.studentid = lit.STUDENTID
           AND co.year = lit.academic_year
           AND dt.alt_name = lit.test_round     
          JOIN attendance att
            ON co.student_number = att.student_number
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
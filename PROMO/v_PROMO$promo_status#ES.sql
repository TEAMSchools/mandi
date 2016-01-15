USE KIPP_NJ
GO

ALTER VIEW PROMO$promo_status#ES AS

WITH curterm AS (
  SELECT dt.schoolid        
        ,dt.alt_name AS term
        ,ROW_NUMBER() OVER(
           PARTITION BY dt.schoolid
             ORDER BY dt.end_date DESC) AS rn
  FROM KIPP_NJ..REPORTING$dates dt WITH(NOLOCK)
  WHERE dt.academic_year = KIPP_NJ.dbo.fn_Global_Academic_Year()
    AND dt.identifier = 'RT'
    AND dt.alt_name NOT IN ('Summer School', 'EOY', 'Capstone')
    AND dt.end_date <= CONVERT(DATE,GETDATE())
 )

,lit AS (
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
        --,SUM(membershipvalue) AS mem_days
        --,SUM(is_absent) AS abs_days
        --,SUM(is_tardy) AS tardy_days
        --,ROUND((AVG(ATTENDANCEVALUE) * 100), 0) AS overall_ada
  FROM
      (
       SELECT co.student_number
             ,cal.date_value
             ,CONVERT(FLOAT,cal.membershipvalue) AS membershipvalue             
             ,CASE
               WHEN att.ATT_CODE IN ('A') THEN 1.0
               WHEN att.ATT_CODE IN ('T', 'T10') THEN (1.0/3.0) + 0.000001 /* pushes the 3rd tardy over the edge from .999... */
              END AS attendance_points
             --,CASE WHEN mem.membershipvalue = 1 AND (att.ATT_CODE != 'A' OR att. ATT_CODE IS NULL) THEN 1.0 ELSE 0.0 END AS attendancevalue
             --,CASE WHEN att.ATT_CODE IN ('A') THEN 1 ELSE 0 END AS is_absent
             --,CASE WHEN att.ATT_CODE IN ('T', 'T10') THEN 1 ELSE 0 END AS is_tardy
       FROM KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK)
       JOIN KIPP_NJ..PS$CALENDAR_DAY cal WITH(NOLOCK)
         ON co.schoolid = cal.schoolid
        AND co.year = cal.academic_year
        AND cal.insession = 1
        AND cal.date_value <= CONVERT(DATE,GETDATE())
       --LEFT OUTER JOIN KIPP_NJ..ATT_MEM$MEMBERSHIP mem WITH(NOLOCK)
       --  ON co.studentid = mem.STUDENTID
       -- AND cal.date_value = mem.CALENDARDATE
       LEFT OUTER JOIN KIPP_NJ..ATT_MEM$ATTENDANCE att WITH(NOLOCK)
         ON co.studentid = att.STUDENTID
        AND cal.date_value = att.ATT_DATE
       WHERE co.year = KIPP_NJ.dbo.fn_Global_Academic_Year()
         AND co.grade_level <= 4 AND co.schoolid != 73252
         AND co.rn = 1
      ) sub
  GROUP BY student_number
 )

SELECT co.STUDENT_NUMBER           
      ,co.studentid
      ,co.schoolid
      ,co.grade_level
      ,co.year           
      ,co.spedlep
      ,co.retained_yr_flag           
      ,dt.term           
           
      /* lit */
      ,lit.met_goal
      ,lit.goal_status AS lit_goal_status
      ,lit.base_read_lvl
      ,lit.lvls_grown_yr
      ,lit.lvls_grown_term
      ,CASE        
        WHEN co.SPEDLEP = 'SPED' OR co.retained_yr_flag = 1 THEN 'See Teacher'                        
        WHEN lit.lvls_grown_term IS NULL THEN NULL        
        WHEN (co.schoolid = 73257 AND (co.grade_level - (year - 2014)) > 0) AND lit.lvls_grown_term > 0 THEN 'On Track' /* Life Upper students have different promo criteria */
        WHEN (co.schoolid = 73257 AND (co.grade_level - (year - 2014)) > 0) AND lit.lvls_grown_term = 0 THEN 'ARFR' /* Life Upper students have different promo criteria */                
        ELSE lit.goal_status
       END AS lit_ARFR_status
           
      /* attendance */
      ,att.offtrack_days_limit           
      ,att.att_pts
      ,att.att_pts_pct
      ,CASE 
        WHEN co.SPEDLEP = 'SPED' OR co.retained_yr_flag = 1 THEN 'See Teacher'
        WHEN att.att_pts_pct < 90 THEN 'ARFR'
        ELSE 'On Track'
       END AS att_ARFR_status           
FROM KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK)
JOIN curterm dt WITH(NOLOCK)
  ON co.schoolid = dt.schoolid  
 AND dt.rn = 1
JOIN lit
  ON co.studentid = lit.STUDENTID
 AND co.year = lit.academic_year
 AND dt.term = lit.test_round     
JOIN attendance att
  ON co.student_number = att.student_number
WHERE co.grade_level <= 4 AND co.schoolid != 73252
  AND co.year = KIPP_NJ.dbo.fn_Global_Academic_Year()
  AND co.rn = 1
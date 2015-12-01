USE KIPP_NJ
GO

ALTER VIEW PROMO$promo_status#ES AS

WITH attendance AS (
  SELECT student_number
        ,CEILING(SUM(membershipvalue) * 0.1) AS offtrack_days_limit      
        ,SUM(membershipvalue) AS mem_days
        ,SUM(is_absent) AS abs_days
        ,SUM(is_tardy) AS tardy_days
        ,CONVERT(FLOAT,ROUND(SUM(ISNULL(attendance_points, 0)), 1, 1)) AS att_pts
        ,ROUND(((SUM(membershipvalue) - SUM(ISNULL(attendance_points,0))) / SUM(membershipvalue)) * 100, 0) AS att_pts_pct      
        ,ROUND((AVG(ATTENDANCEVALUE) * 100), 0) AS overall_ada
  FROM
      (
       SELECT co.student_number
             ,cal.date_value
             ,CONVERT(FLOAT,cal.membershipvalue) AS membershipvalue
             ,CONVERT(FLOAT,mem.ATTENDANCEVALUE) AS attendancevalue
             ,CASE WHEN att.ATT_CODE IN ('A', 'AD') THEN 1 ELSE 0 END AS is_absent
             ,CASE WHEN att.ATT_CODE IN ('T', 'T10') THEN 1 ELSE 0 END AS is_tardy
             ,CASE
               WHEN att.ATT_CODE IN ('A', 'AD') THEN 1.0
               WHEN att.ATT_CODE IN ('T', 'T10') THEN (1.0/3.0) + 0.000001 /* pushes the 3rd tardy over the edge from .999... */
              END AS attendance_points
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

,curterm AS (
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

SELECT student_number            
      ,studentid
      ,schoolid      
      ,grade_level
      ,SPEDLEP
      ,retained_yr_flag
      ,term      
      ,met_goal
      ,lvls_grown_term
      ,CASE        
        WHEN SPEDLEP = 'SPED' OR retained_yr_flag = 1 THEN 'See Teacher'        
        WHEN met_goal = 1 THEN 'On Track'
        WHEN lvls_grown_term IS NULL THEN NULL
        /* Life Upper students have different promo criteria */
        WHEN (schoolid = 73257 AND (grade_level - (year - 2014)) > 0) AND lvls_grown_term > 0 THEN 'On Track'
        WHEN (schoolid = 73257 AND (grade_level - (year - 2014)) > 0) AND lvls_grown_term = 0 THEN 'Off Track'
        WHEN met_goal = 0 THEN 'Off Track'
        ELSE 'On Track'
       END AS lit_ARFR_status
      
      /* attendance */
      ,offtrack_days_limit            
      ,att_pts
      ,att_pts_pct      
      ,CASE 
        WHEN SPEDLEP = 'SPED' OR retained_yr_flag = 1 THEN 'See Teacher'
        WHEN att_pts_pct < 90 THEN 'Off Track'
        ELSE 'On Track'
       END AS att_ARFR_status
FROM
    (
     SELECT co.STUDENT_NUMBER           
           ,co.studentid
           ,co.schoolid
           ,co.grade_level
           ,co.year
           --,co.entry_grade_level
           --,co.year_in_network
           ,co.spedlep
           ,co.retained_yr_flag           
           ,dt.term           
           ,lit.met_goal
           --,lit.read_lvl
           --,lit.goal_lvl      
           --,lit.lvl_num
           --,lit.goal_num
           --,lit.levels_behind      
           ,COALESCE(achv.DR_read_lvl, achv.Q1_read_lvl, achv.Q2_read_lvl, achv.Q3_read_lvl, achv.Q4_read_lvl) AS base_read_lvl
           ,achv.lvls_grown_yr
           ,CASE
             WHEN dt.term = 'Q1' THEN lit.lvl_num - COALESCE(achv.DR_lvl_num, achv.Q1_lvl_num)
             WHEN dt.term = 'Q2' THEN lit.lvl_num - COALESCE(achv.DR_lvl_num, achv.Q1_lvl_num, achv.Q2_lvl_num)
             WHEN dt.term = 'Q3' THEN lit.lvl_num - COALESCE(achv.DR_lvl_num, achv.Q1_lvl_num, achv.Q2_lvl_num, achv.Q3_lvl_num)
             WHEN dt.term = 'Q4' THEN lit.lvl_num - COALESCE(achv.DR_lvl_num, achv.Q1_lvl_num, achv.Q2_lvl_num, achv.Q3_lvl_num, achv.Q4_lvl_num)
            END AS lvls_grown_term
           ,att.offtrack_days_limit           
           ,att.att_pts
           ,att.att_pts_pct
           --,att.mem_days
           --,att.abs_days
           --,att.tardy_days
           --,att.overall_ada           
     FROM KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK)
     JOIN curterm dt WITH(NOLOCK)
       ON co.schoolid = dt.schoolid  
      AND dt.rn = 1
     JOIN KIPP_NJ..LIT$achieved_by_round#static lit WITH(NOLOCK)
       ON co.studentid = lit.STUDENTID
      AND co.year = lit.academic_year
      AND dt.term = lit.test_round
     JOIN KIPP_NJ..LIT$achieved_wide achv WITH(NOLOCK)
       ON co.studentid = achv.studentid
     JOIN attendance att
       ON co.student_number = att.student_number
     WHERE co.grade_level <= 4 AND co.schoolid != 73252
       AND co.year = KIPP_NJ.dbo.fn_Global_Academic_Year()
       AND co.rn = 1
    ) sub
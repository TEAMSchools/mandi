USE KIPP_NJ
GO

ALTER VIEW TABLEAU$attendance_action_list AS

WITH dates AS (
  SELECT schoolid
        ,date_value
        ,ROW_NUMBER() OVER(
           PARTITION BY schoolid
             ORDER BY date_value DESC) AS rn
  FROM KIPP_NJ..PS$CALENDAR_DAY WITH(NOLOCK)
  WHERE insession = 1
    AND academic_year = KIPP_NJ.dbo.fn_Global_Academic_Year()
    AND date_value <= CONVERT(DATE,GETDATE())
 )

SELECT STUDENT_NUMBER
      ,LASTFIRST
      ,GRADE_LEVEL
      ,SCHOOLID
      ,HOME_PHONE      
      
      ,ATT_CODE            
      ,is_absent      
      ,is_tardy            
      ,ABS_all_counts_yr
      ,TDY_all_counts_yr      
      ,is_absent + prev_is_absent AS absent_streak
      ,is_tardy + prev_is_tardy AS tardy_streak
      ,attendance_points
      ,y1_att_pts_pct
      ,days_to_90      
      ,promo_att_rise      
      
      ,teacher_name                
      ,mother_name
      ,MOTHER_CELL
      
      --calendardate
      --,prev_is_absent
      --,prev_att_code
      --,prev_is_tardy      
      --,FATHER_CELL
      --,guardianemail
      --,section_number      
FROM
    (
     SELECT CONVERT(DATE,mem.CALENDARDATE) AS calendardate                 
           
           ,att.ATT_CODE
           ,CASE WHEN att.PRESENCE_STATUS_CD = 'Absent' OR att.ATT_CODE LIKE 'A%' THEN 1 ELSE 0 END AS is_absent
           ,LAG(CASE WHEN att.PRESENCE_STATUS_CD = 'Absent' OR att.ATT_CODE LIKE 'A%' THEN 1 ELSE 0 END, 1) OVER(PARTITION BY mem.studentid ORDER BY mem.calendardate) AS prev_is_absent                 
           ,CASE WHEN att.ATT_CODE LIKE 'T%' THEN 1 ELSE 0 END AS is_tardy
           ,LAG(CASE WHEN att.ATT_CODE LIKE 'T%' THEN 1 ELSE 0 END, 1) OVER(PARTITION BY mem.studentid ORDER BY mem.calendardate) AS prev_is_tardy
           --,LAG(att.att_code, 1) OVER(PARTITION BY mem.studentid ORDER BY mem.calendardate) AS prev_att_code
      
           ,promo.promo_att_rise           
           ,promo.y1_att_pts_pct           
           ,promo.days_to_90
           ,promo.attendance_points

           ,s.STUDENT_NUMBER
           ,s.LASTFIRST
           ,s.GRADE_LEVEL
           ,s.SCHOOLID
           ,con.HOME_PHONE
           ,con.MOTHER AS mother_name
           ,con.MOTHER_CELL
           --,s.FATHER_CELL
           --,s.guardianemail

           ,ac.ABS_all_counts_yr
           ,ac.TDY_all_counts_yr

           ,enr.teacher_name
           --,enr.section_number
     FROM KIPP_NJ..ATT_MEM$MEMBERSHIP mem WITH(NOLOCK)
     LEFT OUTER JOIN KIPP_NJ..ATT_MEM$ATTENDANCE att WITH(NOLOCK)
       ON mem.STUDENTID = att.STUDENTID
      AND mem.CALENDARDATE = att.ATT_DATE
     LEFT OUTER JOIN KIPP_NJ..REPORTING$promo_status#MS promo WITH(NOLOCK)
       ON mem.STUDENTID = promo.studentid
      AND promo.is_curterm = 1
     JOIN KIPP_NJ..PS$STUDENTS#static s WITH(NOLOCK)
       ON mem.STUDENTID = s.id --studentid
      --AND mem.academic_year = s.year
      --AND s.rn = 1
     LEFT OUTER JOIN KIPP_NJ..PS$student_contact#static con WITH(NOLOCK)
       ON mem.STUDENTID = con.STUDENTID
     JOIN KIPP_NJ..REPORTING$dates dt WITH(NOLOCK)
       ON s.schoolid = dt.schoolid
      AND mem.academic_year = dt.academic_year
      AND CONVERT(DATE,GETDATE()) BETWEEN dt.start_date AND dt.end_date
      AND dt.identifier = 'RT'
     JOIN KIPP_NJ..ATT_MEM$attendance_counts_long#static ac WITH(NOLOCK)
       ON mem.STUDENTID = ac.studentid
      AND mem.academic_year = ac.academic_year
      AND dt.alt_name = ac.term
     LEFT OUTER JOIN KIPP_NJ..PS$course_enrollments#static enr WITH(NOLOCK)
       ON s.id = enr.studentid
      AND mem.academic_year = enr.academic_year
      AND enr.course_number = 'HR'
      AND enr.drop_flags = 0
     WHERE CONVERT(DATE,mem.CALENDARDATE) IN (SELECT date_value FROM dates WHERE rn IN (1,2))       
    ) sub
WHERE calendardate = CONVERT(DATE,GETDATE())
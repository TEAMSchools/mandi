USE KIPP_NJ
GO

ALTER VIEW TABLEAU$truancy_watchlist AS

SELECT strk.studentid
      ,co.lastfirst
      ,co.school_name
      ,co.grade_level
      ,co.team
      ,co.HOME_PHONE
      ,co.MOTHER_CELL
      ,co.FATHER_CELL
      ,co.guardianemail
      ,gpa.gpa_y1 AS GPA_y1_all
      ,strk.att_code
      ,strk.streak_start
      ,strk.streak_end
      ,strk.streak_length_membership
      ,CASE WHEN CONVERT(DATE,GETDATE()) >= strk.streak_start AND CONVERT(DATE,GETDATE()) <= streak_end THEN 1 ELSE 0 END AS is_current
      ,CASE WHEN strk.streak_start >= DATEADD(WEEK,-1,CONVERT(DATE,GETDATE())) THEN 1 ELSE 0 END AS is_week      
      ,CASE WHEN strk.streak_start >= DATEADD(WEEK,-2,CONVERT(DATE,GETDATE())) THEN 1 ELSE 0 END AS is_two_weeks
      ,CASE WHEN strk.streak_start >= DATEADD(MONTH,-1,CONVERT(DATE,GETDATE())) THEN 1 ELSE 0 END AS is_month
FROM KIPP_NJ..ATT_MEM$attendance_streak strk WITH(NOLOCK)
JOIN KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK)
  ON strk.studentid = co.studentid
 AND strk.academic_year = co.year
 AND co.rn = 1
LEFT OUTER JOIN KIPP_NJ..GRADES$GPA_detail_long#static gpa WITH(NOLOCK)
  ON co.student_number = gpa.student_number
 AND co.year = gpa.academic_year
 AND gpa.is_curterm = 1
WHERE strk.academic_year = KIPP_NJ.dbo.fn_Global_Academic_Year()
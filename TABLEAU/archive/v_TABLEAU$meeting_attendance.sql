USE KIPP_NJ
GO

ALTER VIEW TABLEAU$meeting_attendance AS

SELECT co.STUDENTID      
      ,co.LASTFIRST
      ,co.GRADE_LEVEL
      ,co.advisor
      ,co.year
      ,co.term      
      ,co.date AS date_value
      
      ,per.ABBREVIATION AS period      
      ,cc.sectionid            
      ,cou.COURSE_NAME
      ,t.LASTFIRST AS teacher_name
      
      ,m.att_code
      ,CASE WHEN m.att_code IN ('T','T10') THEN 1.0 ELSE 0.0 END AS is_tardy
      ,CASE WHEN att.PRESENCE_STATUS_CD = 'Absent' OR m.att_code IN ('A','AD','OSS','ISS','CS','CR','PLE','EV') THEN 1.0 ELSE 0.0 END AS is_absent      
      ,att.ATT_CODE AS daily_att_code
FROM KIPP_NJ..COHORT$identifiers_scaffold#static co WITH(NOLOCK)
JOIN KIPP_NJ..PS$CALENDAR_DAY cal WITH(NOLOCK)
  ON co.schoolid = cal.schoolid
 AND co.date = cal.date_value
 AND cal.date_value BETWEEN co.entrydate AND co.exitdate  
 AND cal.insession = 1 
JOIN KIPP_NJ..PS$PERIOD#static per WITH(NOLOCK)
  ON co.schoolid = per.SCHOOLID
 AND co.year = per.academic_year 
JOIN KIPP_NJ..PS$CC#static cc WITH(NOLOCK)
  ON co.studentid = cc.studentid 
  AND co.year = cc.academic_year
 AND co.date BETWEEN cc.dateenrolled AND cc.dateleft 
 AND CHARINDEX(CONCAT(';', per.PERIOD_NUMBER,'(A)'), CONCAT(';',REPLACE(cc.EXPRESSION,' ', ';'))) > 0
 AND cc.SECTIONID > 0
 AND cc.COURSE_NUMBER != 'HR'
JOIN KIPP_NJ..PS$SECTIONS#static sec WITH(NOLOCK)
  ON cc.SECTIONID = sec.id
JOIN KIPP_NJ..PS$TEACHERS#static t WITH(NOLOCK)
  ON sec.TEACHER = t.id
JOIN KIPP_NJ..PS$COURSES#static cou WITH(NOLOCK)
  ON cc.COURSE_NUMBER = cou.COURSE_NUMBER
LEFT OUTER JOIN KIPP_NJ..ATT_MEM$PS_ATTENDANCE_MEETING m WITH(NOLOCK)  
  ON co.studentid = m.studentid 
 AND co.date = m.att_date
 AND cc.sectionid = m.sectionid
LEFT OUTER JOIN KIPP_NJ..ATT_MEM$ATTENDANCE att WITH(NOLOCK)  
  ON co.studentid = att.studentid 
 AND co.date = att.att_date 
WHERE co.schoolid = 73253
  AND co.year = KIPP_NJ.dbo.fn_Global_Academic_Year()
  AND co.date <= CONVERT(DATE,GETDATE())
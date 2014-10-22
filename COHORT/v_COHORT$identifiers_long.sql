USE KIPP_NJ
GO

ALTER VIEW COHORT$identifiers_long AS

SELECT co.year      
      ,co.schoolid
      ,sch.abbreviation AS school_name
      ,co.grade_level
      ,co.studentid
      ,co.student_number      
      ,co.lastfirst
      ,co.entrydate
      ,co.exitdate
      ,s.TEAM
      ,cs.ADVISOR
      ,s.GENDER
      ,s.ETHNICITY
      ,s.LUNCHSTATUS      
      ,cs.SPEDLEP            
      ,s.enroll_status
FROM KIPP_NJ..COHORT$comprehensive_long#static co WITH (NOLOCK)
JOIN KIPP_NJ..SCHOOLS sch WITH (NOLOCK)
  ON co.schoolid = sch.school_number
JOIN KIPP_NJ..STUDENTS s WITH(NOLOCK)
  ON co.studentid = s.ID
JOIN KIPP_NJ..CUSTOM_STUDENTS cs WITH(NOLOCK)
  ON co.studentid = cs.STUDENTID
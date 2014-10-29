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
      ,co.rn
      ,co.year_in_network
      ,ms.school AS entry_school_name
      ,ms.schoolid AS entry_schoolid
      ,gr.grade_level AS entry_grade_level
FROM KIPP_NJ..COHORT$comprehensive_long#static co WITH (NOLOCK)
JOIN KIPP_NJ..SCHOOLS sch WITH (NOLOCK)
  ON co.schoolid = sch.school_number
JOIN KIPP_NJ..STUDENTS s WITH(NOLOCK)
  ON co.studentid = s.ID
JOIN KIPP_NJ..CUSTOM_STUDENTS cs WITH(NOLOCK)
  ON co.studentid = cs.STUDENTID
LEFT OUTER JOIN KIPP_NJ..COHORT$middle_school_attended ms WITH(NOLOCK)
  ON co.studentid = ms.studentid
LEFT OUTER JOIN KIPP_NJ..COHORT$comprehensive_long#static gr WITH(NOLOCK)
  ON co.studentid = gr.studentid
 AND gr.year_in_network = 1
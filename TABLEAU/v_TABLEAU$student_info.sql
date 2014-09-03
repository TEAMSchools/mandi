USE KIPP_NJ
GO

ALTER VIEW TABLEAU$student_info AS

SELECT sch.ABBREVIATION AS school_name
      ,s.grade_level
      ,s.team
      ,s.student_number
      ,s.lastfirst      
      ,cs.advisor      
      ,s.home_phone
      ,s.mother
      ,cs.mother_cell
      ,s.father
      ,cs.father_cell
      ,CONVERT(VARCHAR,s.DOB,101) AS DOB
      ,s.gender
      ,s.student_web_id
      ,CASE WHEN s.student_web_password LIKE '%{B64}%' THEN NULL ELSE s.student_web_password END AS student_web_password
      ,s.street
      ,s.city
      ,s.ZIP
      ,cs.guardianemail
FROM STUDENTS s WITH(NOLOCK)
LEFT OUTER JOIN CUSTOM_STUDENTS cs WITH(NOLOCK)
  ON s.id = cs.studentid
JOIN SCHOOLS sch WITH(NOLOCK)
  ON s.schoolid = sch.school_number
WHERE s.enroll_status = 0
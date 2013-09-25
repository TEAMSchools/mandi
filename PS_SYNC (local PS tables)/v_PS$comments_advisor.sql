USE KIPP_NJ
GO

ALTER VIEW PS$comments_advisors AS
SELECT s.id
      ,sect.course_number
      ,comments.finalgradename
      ,comments.teacher_comment
FROM STUDENTS s
JOIN CC
  ON cc.studentid = s.id
 AND cc.termid >= 2300
JOIN SECTIONS sect
  ON sect.id = cc.sectionid
 AND sect.course_number IN ('HR','Adv')
JOIN PS$comments_gradebooks comments
  ON comments.sectionid = sect.id
 AND comments.studentid = s.id
WHERE s.enroll_status = 0
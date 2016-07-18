USE KIPP_NJ
GO

ALTER VIEW PS$comments_advisors AS
SELECT 'DEPRECATED -- USE STATIC TABLE -- PS$comments#static' AS [DO NOT ENTER]

/*
CC.studentid
      ,sect.course_number
      ,comments.finalgradename
      ,comments.teacher_comment AS advisor_comment
FROM CC  
JOIN SECTIONS sect
  ON sect.id = cc.sectionid
 AND sect.course_number IN ('HR','Adv')
JOIN PS$comments_gradebooks comments
  ON comments.sectionid = sect.id
 AND comments.studentid = cc.studentid
WHERE cc.termid >= dbo.fn_Global_Term_Id()
*/
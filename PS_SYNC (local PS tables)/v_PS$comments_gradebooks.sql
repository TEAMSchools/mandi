USE KIPP_NJ
GO

ALTER VIEW PS$comments_gradebooks AS
SELECT *
FROM OPENQUERY(KIPP_NWK,'
       SELECT *
       FROM local_gradebook_comments
       ')

/*
SELECT *
FROM OPENQUERY(PS_TEAM,'
     SELECT s.id 
           ,pgf.sectionid
           ,pgf.studentid
           ,pgf.finalgradename
           ,CAST(SUBSTR(pgf.comment_value,1,4000) AS varchar2(4000)) AS teacher_comment
     FROM STUDENTS s
     LEFT OUTER JOIN pgfinalgrades pgf
       ON s.id = pgf.studentid
     WHERE (pgf.finalgradename LIKE ''T%'' OR pgf.finalgradename LIKE ''Q%'')
       AND pgf.sectionid >= 4121
       AND pgf.comment_value IS NOT NULL
       AND s.enroll_status = 0
     ')
*/
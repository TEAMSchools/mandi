USE KIPP_NJ
GO

ALTER VIEW PS$student_BLOBs AS

SELECT *
FROM OPENQUERY(PS_TEAM,'
  SELECT id AS studentid      
        ,TRIM(guardianemail) AS guardianemail
        ,TRIM(s.transfercomment) AS transfercomment
        ,TRIM(s.exitcomment) AS exitcomment
  FROM students s
');
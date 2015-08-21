USE KIPP_NJ
GO

ALTER VIEW PS$student_BLOBs AS

SELECT *
FROM OPENQUERY(PS_TEAM,'
  SELECT id AS studentid      
        ,guardianemail     
        ,s.transfercomment
        ,s.exitcomment
  FROM students s
');
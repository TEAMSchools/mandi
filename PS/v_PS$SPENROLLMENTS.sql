USE KIPP_NJ
GO

ALTER VIEW PS$SPENROLLMENTS AS

SELECT studentid
      ,KIPP_NJ.dbo.fn_DateToSY(enter_date) AS academic_year
      ,CONVERT(DATE,enter_date) AS enter_date
      ,CONVERT(DATE,exit_date) AS exit_date
      ,programid
      ,name AS program_name
FROM OPENQUERY(PS_TEAM,'
  SELECT s.studentid
        ,s.enter_date        
        ,s.exit_date
        ,s.programid
        ,g.name
  FROM SPEnrollments s
  JOIN GEN g
    ON s.programid = g.id
   AND g.cat = ''specprog''
')
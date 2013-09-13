USE KIPP_NJ
GO

ALTER VIEW PS$local_emails AS
SELECT *
FROM OPENQUERY(PS_TEAM, '
  SELECT id AS studentid
        ,DBMS_LOB.SUBSTR(guardianemail,2000,1) AS guardianemail
  FROM STUDENTS
')
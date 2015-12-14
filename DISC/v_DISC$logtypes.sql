USE KIPP_NJ
GO

ALTER VIEW DISC$logtypes AS

SELECT id AS logtypeid
      ,name AS logtype
FROM OPENQUERY(PS_TEAM,'
  SELECT id
        ,name
  FROM gen
  WHERE cat = ''logtype''
')
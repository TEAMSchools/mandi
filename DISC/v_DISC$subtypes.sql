USE KIPP_NJ
GO

ALTER VIEW DISC$subtypes AS

SELECT name AS logtypeid
      ,value AS subtypeid
      ,CONVERT(VARCHAR,valuet) AS subtype
FROM OPENQUERY(PS_TEAM,'
  SELECT name
        ,value
        ,valuet
  FROM gen
  WHERE cat = ''subtype''
')
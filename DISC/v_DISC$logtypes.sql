USE KIPP_NJ
GO

ALTER VIEW DISC$logtypes AS

WITH subtypes AS (
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
 )

,logtypes AS (
  SELECT id AS logtypeid
        ,name AS logtype
  FROM OPENQUERY(PS_TEAM,'
    SELECT *
    FROM gen
    WHERE cat = ''logtype''
  ')
)

SELECT lt.logtypeid
      ,lt.logtype
      ,st.subtypeid
      ,st.subtype
FROM logtypes lt
LEFT OUTER JOIN subtypes st
  ON lt.logtypeid = st.logtypeid
USE KIPP_NJ
GO

ALTER VIEW DISC$entrycodes AS

WITH logentrycodes AS (
  SELECT CONVERT(VARCHAR(MAX),name) AS field
        ,CONVERT(VARCHAR(MAX),valuet2) AS valuet2      
  FROM OPENQUERY(PS_TEAM,'
    SELECT name
          ,valuet2
    FROM gen
    WHERE cat = ''logentrycodes''
      AND name IN (''Discipline_IncidentType'',''Discipline_ActionTaken'',''Discipline_ActionTakenDetail'')
  ')
)

,codes_long AS (
  SELECT field
        ,SPLIT.sub.value('.', 'VARCHAR(250)') AS string
  FROM
      (
       SELECT field
             ,CAST('<M>' + REPLACE(valuet2,CHAR(13),'</M><M>') + '</M>' AS XML) AS string
       FROM logentrycodes
      ) sub
  CROSS APPLY string.nodes('/M') AS SPLIT(sub)
)

SELECT CONVERT(VARCHAR(64),field) AS field      
      ,string
      ,CONVERT(VARCHAR(8),KIPP_NJ.dbo.fn_StripCharacters(LEFT(string, CHARINDEX(';',string) - 1), '^a-z')) AS code      
      ,RIGHT(string, CHARINDEX(';', REVERSE(string)) - 1) AS detail
FROM codes_long
WHERE string NOT LIKE '%office use%'
  AND string NOT LIKE '%please select%'
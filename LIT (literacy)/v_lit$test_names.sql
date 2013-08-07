USE KIPP_NJ
GO
CREATE VIEW LIT$TEST_NAMES AS
SELECT *
FROM OPENQUERY(PS_TEAM, '
  SELECT rt.dcid
        ,rt.id
        ,rt.name
        ,count(rtf.id)numFields
  FROM   Gen rt
  LEFT JOIN Gen rtf ON rt.id = rtf.valueli 
        AND rtf.cat = ''rdgTestField''
  WHERE rt.cat = ''rdgTest''
  GROUP BY rt.dcid, rt.id, rt.name
  ORDER BY rt.name');
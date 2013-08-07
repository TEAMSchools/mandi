USE KIPP_NJ
GO
CREATE VIEW LIT$TEST_SUBSCORES AS
SELECT fields.*
      ,names.name AS subscore_name
FROM OPENQUERY(PS_TEAM, '
  SELECT rtf.dcid
        ,rtf.valueli
        ,rtf.name
        ,rtf.value
        ,rtf.value2
        g,rtf.sortorder
  FROM Gen rtf 
  WHERE rtf.cat = ''rdgTestField'' 
    AND sortorder > 2
  ORDER BY rtf.valueli, rtf.sortorder') fields
 JOIN LIT$TEST_NAMES names
   ON fields.valueli = names.id

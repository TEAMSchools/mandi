USE KIPP_NJ
GO

ALTER VIEW DISC$log_entry_text AS

SELECT *
FROM OPENQUERY(PS_TEAM,'
  SELECT dcid
        ,entry
  FROM log
  WHERE logtypeid = 4578
') /* only Pathways comments needed at the moment */
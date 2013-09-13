USE KIPP_NJ
GO

ALTER VIEW PS$comments_advisors AS
SELECT *
FROM OPENQUERY(KIPP_NWK,'
     SELECT *
     FROM y_rc_advisor_comments
')
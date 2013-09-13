USE KIPP_NJ
GO

ALTER VIEW PS$local_emails AS
SELECT *
FROM OPENQUERY(KIPP_NWK,'
     SELECT *
     FROM local_emails
')
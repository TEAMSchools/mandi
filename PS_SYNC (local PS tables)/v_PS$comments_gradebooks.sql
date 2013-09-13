USE KIPP_NJ
GO

ALTER VIEW PS$comments_gradebooks AS
SELECT *
FROM OPENQUERY(KIPP_NWK,'
     SELECT *
     FROM local_gradebook_comments
')
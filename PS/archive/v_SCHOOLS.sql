USE KIPP_NJ
GO

ALTER VIEW SCHOOLS AS

SELECT *
FROM PS$SCHOOLS#static WITH(NOLOCK)
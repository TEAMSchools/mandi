USE KIPP_NJ
GO

ALTER VIEW SECTIONS AS

SELECT *
FROM KIPP_NJ..PS$SECTIONS#static WITH(NOLOCK)
USE KIPP_NJ
GO

ALTER VIEW STUDENTS AS

SELECT *
FROM KIPP_NJ..PS$STUDENTS#static WITH(NOLOCK)
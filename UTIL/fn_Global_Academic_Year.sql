USE [KIPP_NJ]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER FUNCTION [fn_Global_Academic_Year]()
RETURNS INT
AS
BEGIN
	RETURN CASE
         WHEN DATEPART(MM,GETDATE()) >= 01 AND DATEPART(MM,GETDATE()) <= 06 THEN (DATEPART(YEAR,GETDATE()) - 1)
         ELSE DATEPART(YEAR,GETDATE())
        END;
END

GO
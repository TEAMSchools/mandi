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
 	RETURN 2017;
END

GO
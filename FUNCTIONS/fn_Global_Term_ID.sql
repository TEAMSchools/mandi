USE [KIPP_NJ]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER FUNCTION [dbo].[fn_Global_Term_Id]()
RETURNS INT
AS

BEGIN
  RETURN 2700;
END

GO
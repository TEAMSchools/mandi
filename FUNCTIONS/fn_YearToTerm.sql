USE [KIPP_NJ]
GO

/****** Object:  UserDefinedFunction [dbo].[ASCII_CONVERT]    Script Date: 7/25/2014 2:07:50 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE FUNCTION [dbo].[YearToTerm] (@year INT)
  RETURNS INT
  AS

BEGIN
  RETURN @year * 100 - CONVERT(FLOAT, '1.990000e+05');
END
GO



USE [KIPP_NJ]
GO

/****** Object:  UserDefinedFunction [dbo].[fn_DateToSY]    Script Date: 10/15/2014 3:45:06 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER FUNCTION [dbo].[fn_ExprToPeriod] (@expression VARCHAR(5))
  RETURNS VARCHAR(2)
  AS

BEGIN
  RETURN 
   CASE        
    WHEN @expression = '1(A)' THEN 'HR'
    WHEN @expression = '2(A)' THEN '1'
    WHEN @expression = '3(A)' THEN '2'
    WHEN @expression = '4(A)' THEN '3'
    WHEN @expression = '5(A)' THEN '4A'
    WHEN @expression = '6(A)' THEN '4B'
    WHEN @expression = '7(A)' THEN '4C'
    WHEN @expression = '8(A)' THEN '4D'
    WHEN @expression = '9(A)' THEN '5A'
    WHEN @expression = '10(A)' THEN '5B'
    WHEN @expression = '11(A)' THEN '5C'
    WHEN @expression = '12(A)' THEN '5D'
    WHEN @expression = '13(A)' THEN '6'
    WHEN @expression = '14(A)' THEN '7'
    ELSE NULL
   END;
END


GO



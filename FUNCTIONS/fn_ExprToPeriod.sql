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
    WHEN @expression = '1(A)' THEN 'HRA'
    WHEN @expression = '2(A)' THEN 'C1'
    WHEN @expression = '3(A)' THEN 'C2'
    WHEN @expression = '4(A)' THEN 'C3'
    WHEN @expression = '5(A)' THEN 'C4'
    WHEN @expression = '6(A)' THEN 'C5'
    WHEN @expression = '7(A)' THEN 'C7'
    WHEN @expression = '8(A)' THEN 'C7'
    WHEN @expression = '9(A)' THEN 'C8'
    WHEN @expression = '10(A)' THEN 'LA'
    WHEN @expression = '11(A)' THEN 'LB'    
    WHEN @expression = '12(A)' THEN 'INT'    
    ELSE NULL
   END;
END


GO



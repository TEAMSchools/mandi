SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER FUNCTION utility.Global_Academic_Year()
    RETURNS int
  AS

BEGIN		

  RETURN 2016

END

GO


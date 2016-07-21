--Alphabetic only:         SELECT dbo.fn_StripCharacters('a1!s2@d3#f4$', '^a-z')
--Numeric only:            SELECT dbo.fn_StripCharacters('a1!s2@d3#f4$', '^0-9')
--Alphanumeric only:       SELECT dbo.fn_StripCharacters('a1!s2@d3#f4$', '^a-z0-9')
--Non-alphanumeric only:   SELECT dbo.fn_StripCharacters('a1!s2@d3#f4$', 'a-z0-9')

USE KIPP_NJ
GO

ALTER FUNCTION [dbo].[fn_StripCharacters]
  (
   @String NVARCHAR(MAX), 
   @MatchExpression VARCHAR(255)
  )
RETURNS NVARCHAR(MAX)
AS

BEGIN
    SET @MatchExpression =  '%['+@MatchExpression+']%'

    WHILE PatIndex(@MatchExpression, @String) > 0
        SET @String = Stuff(@String, PatIndex(@MatchExpression, @String), 1, '')

    RETURN @String

END
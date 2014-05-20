USE KIPP_NJ
GO

ALTER FUNCTION ASCII_CONVERT (@ascii_string NVARCHAR(MAX))
  RETURNS NVARCHAR(MAX)
  AS

BEGIN

  DECLARE @string NVARCHAR(MAX)
         ,@in_string NVARCHAR(MAX) 
         ,@out_string NVARCHAR(MAX)
         ,@char NVARCHAR(MAX)
         ,@len INT
         ,@ascii_start INT
         ,@ascii_end INT         
         ,@index INT;
  
  --intitalize variables
  SET @string = @ascii_string
  SET @in_string = ''
  SET @out_string = ''
  SET @char = ''
  SET @len = LEN(@string)
  SET @ascii_start = NULL
  SET @ascii_end = NULL  
  SET @index = 1;

  WHILE @index <= @len AND CHARINDEX('&#',@string, @index) > 0  -- walk the length of the string, but break if there aren't any remaining ASCII flags
  BEGIN
  
   SET @ascii_start = CHARINDEX('&#', @string, @index); -- find the start of the ASCII code
   SET @ascii_end = CHARINDEX(';',@string,@ascii_start); -- find the end of the ASCII code, relative to the start
   SET @in_string = SUBSTRING(@string, @index, @ascii_start - @index); -- extract the leading text string before the ASCII code
   SET @char = CHAR(REPLACE(REPLACE(SUBSTRING(@string, @ascii_start, @ascii_end - @ascii_start + 1),'&#',''),';','')); -- convert ASCII code to CHAR
   SET @out_string = @out_string + @in_string + @char; -- append to results string   
   SET @index = (@ascii_end + 1); -- set index to character after ASCII code
  
  END

  SET @out_string = @out_string + SUBSTRING(@string, @ascii_end + 1, @len - @ascii_end); -- when the loop breaks, append the residual string

  RETURN @out_string;

END
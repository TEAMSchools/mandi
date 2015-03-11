USE KIPP_NJ
GO

ALTER VIEW LIT$test_cleanup AS

WITH valid_tests AS (
  SELECT unique_id
  FROM OPENQUERY(PS_TEAM,'
    SELECT unique_id
    FROM virtualtablesdata3 scores
    WHERE related_to_table = ''readingScores''
  ')
 ) 

SELECT r.UNIQUE_ID      
FROM LIT$READINGSCORES#STAGING r WITH(NOLOCK)
LEFT JOIN valid_tests v
  ON r.UNIQUE_ID = v.unique_id
WHERE v.unique_id IS NULL
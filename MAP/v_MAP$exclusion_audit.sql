USE KIPP_NJ
GO

ALTER VIEW MAP$exclusion_audit AS

WITH cdf_file AS (
  SELECT [TermName]
        ,[TestID]
  FROM KIPP_NJ..[AUTOLOAD$NWEA_AssessmentResults]
 )

,cdf_table AS (
  SELECT [TermName]
        ,[TestID]
  FROM KIPP_NJ..MAP$CDF WITH(NOLOCK)
 )

SELECT TermName
      ,table_testid AS testid
      ,is_excluded
FROM
    (
     SELECT t.TermName
           ,t.TestID AS table_testid
           ,f.TestID AS cdf_testid
           ,CASE WHEN f.TestID IS NULL THEN 1 ELSE 0 END AS is_excluded
     FROM cdf_table t WITH(NOLOCK)
     LEFT OUTER JOIN cdf_file f WITH(NOLOCK)
       ON t.TestID = f.testid
     WHERE t.TermName IN (SELECT TermName FROM cdf_file WITH(NOLOCK))
    ) sub
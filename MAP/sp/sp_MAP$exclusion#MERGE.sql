USE KIPP_NJ
GO

ALTER PROCEDURE sp_MAP$exclusion#MERGE AS

BEGIN 
  
  /* drop temp table */
  IF OBJECT_ID(N'tempdb..#exclusion_audit') IS NOT NULL
		  BEGIN
						  DROP TABLE #exclusion_audit
		  END;
  
  /* populate temp table with audit results */
  WITH cdf_file AS (
    SELECT [TermName]
          ,[TestID]
    FROM KIPP_NJ..[AUTOLOAD$NWEA_AssessmentResults] WITH(NOLOCK)
   )

  ,cdf_table AS (
    SELECT [TermName]
          ,[TestID]
    FROM KIPP_NJ..MAP$CDF WITH(NOLOCK)
   )

  SELECT TermName
        ,table_testid AS testid
        ,is_excluded
  INTO #exclusion_audit
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
      ) sub;

  /* merge into destination table */
  MERGE KIPP_NJ..MAP$exclusion_audit#static AS TARGET
  USING #exclusion_audit AS SOURCE
     ON TARGET.termname = SOURCE.termname
    AND TARGET.testid = SOURCE.testid
  WHEN MATCHED THEN 
   UPDATE
    SET TARGET.is_excluded = SOURCE.is_excluded
  WHEN NOT MATCHED THEN 
   INSERT
    (termname
    ,testid
    ,is_excluded)
   VALUES
    (SOURCE.termname
    ,SOURCE.testid
    ,SOURCE.is_excluded);

END

GO
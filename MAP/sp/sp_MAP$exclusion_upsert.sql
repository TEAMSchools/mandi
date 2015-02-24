USE KIPP_NJ
GO

ALTER PROCEDURE sp_MAP$exclusion_upsert AS

BEGIN 

  WITH exclusion_audit AS (
    SELECT TermName
          ,testid
          ,is_excluded
    FROM KIPP_NJ..MAP$exclusion_audit WITH(NOLOCK)
   )

  MERGE KIPP_NJ..MAP$exclusion_audit#static AS TARGET
  USING exclusion_audit AS SOURCE
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
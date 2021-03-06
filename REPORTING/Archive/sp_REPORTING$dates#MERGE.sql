USE KIPP_NJ
GO

ALTER PROCEDURE sp_REPORTING$dates#MERGE AS

BEGIN

  MERGE KIPP_NJ..REPORTING$dates AS TARGET
    USING [KIPP_NJ].[dbo].[AUTOLOAD$GDOCS_REP_Reporting_Dates]  AS SOURCE
       ON TARGET.[academic_year] = SOURCE.[academic_year]
      AND TARGET.[identifier] = SOURCE.[identifier]
      AND TARGET.[schoolid] = SOURCE.[schoolid]
      AND TARGET.[time_per_name] = SOURCE.[time_per_name]
    WHEN MATCHED THEN
     UPDATE
      SET TARGET.[yearid] = SOURCE.[yearid]              
         ,TARGET.[school_level] = SOURCE.[school_level]              
         ,TARGET.[alt_name] = SOURCE.[alt_name]
         ,TARGET.[start_date] = SOURCE.[start_date]
         ,TARGET.[end_date] = SOURCE.[end_date]
         ,TARGET.[time_hierarchy] = SOURCE.[time_hierarchy]
         ,TARGET.[report_name_long] = SOURCE.[report_name_long]
         ,TARGET.[report_name_short] = SOURCE.[report_name_short]
         ,TARGET.[report_issued] = SOURCE.[report_issued]
         ,TARGET.[next_report] = SOURCE.[next_report]
         ,TARGET.[custom] = SOURCE.[custom]
         ,TARGET.[reporting_hash] = SOURCE.[reporting_hash]
    WHEN NOT MATCHED BY TARGET AND SOURCE.schoolid IS NOT NULL THEN
     INSERT
      ([academic_year]
      ,[yearid]
      ,[termid]
      ,[identifier]
      ,[school_level]
      ,[schoolid]
      ,[time_per_name]
      ,[alt_name]
      ,[start_date]
      ,[end_date]
      ,[time_hierarchy]
      ,[report_name_long]
      ,[report_name_short]
      ,[report_issued]
      ,[next_report]
      ,[custom]
      ,[reporting_hash])
     VALUES
      (SOURCE.[academic_year]
      ,SOURCE.[yearid]
      ,SOURCE.[termid]
      ,SOURCE.[identifier]
      ,SOURCE.[school_level]
      ,SOURCE.[schoolid]
      ,SOURCE.[time_per_name]
      ,SOURCE.[alt_name]
      ,SOURCE.[start_date]
      ,SOURCE.[end_date]
      ,SOURCE.[time_hierarchy]
      ,SOURCE.[report_name_long]
      ,SOURCE.[report_name_short]
      ,SOURCE.[report_issued]
      ,SOURCE.[next_report]
      ,SOURCE.[custom]
      ,SOURCE.[reporting_hash])
    WHEN NOT MATCHED BY SOURCE AND TARGET.schoolid IS NOT NULL THEN
     DELETE
    OUTPUT $ACTION, deleted.*;

END

GO
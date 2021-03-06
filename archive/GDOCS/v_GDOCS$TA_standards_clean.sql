USE KIPP_NJ
GO

ALTER VIEW GDOCS$TA_standards_clean AS

WITH dirty_data AS (
  SELECT CASE
          WHEN school = 'SPARK' THEN 73254
          WHEN school = 'THRIVE' THEN 73255
          WHEN school = 'Seek' THEN 73256
          WHEN school = 'Life' THEN 73257
          WHEN school = 'Revolution' THEN 179901
         END AS schoolid
        ,CASE WHEN CONVERT(VARCHAR,[Gr#]) = 'K' OR [Gr#] IS NULL THEN 0 ELSE [Gr#] END AS grade_level
        ,subject
        ,[TA] AS TA_num
        ,[CCSS Standard] AS ccss_standard
        ,[Other Standard _(If CCSS not used, copy directly from Illuminate] AS other_standard
        ,[Parent Friendly Objective] AS objective
  FROM [AUTOLOAD$GDOCS_TA_CCSS_Standards] WITH(NOLOCK)
  WHERE school != 'All'

  UNION ALL

  SELECT sch.SCHOOL_NUMBER AS schoolid  
        ,CASE WHEN CONVERT(VARCHAR,[Gr#]) = 'K' OR [Gr#] IS NULL THEN 0 ELSE [Gr#] END AS grade_level
        ,[subject]
        ,[TA] AS TA_num
        ,[CCSS Standard] AS ccss_standard
        ,[Other Standard _(If CCSS not used, copy directly from Illuminate] AS other_standard
        ,[Parent Friendly Objective] AS objective
  FROM [AUTOLOAD$GDOCS_TA_CCSS_Standards] std WITH(NOLOCK)
  JOIN PS$SCHOOLS#static sch WITH(NOLOCK)
    ON std.school = 'All'
   AND sch.LOW_GRADE = 0
   AND sch.SCHOOL_NUMBER != 999999
  WHERE std.School = 'All'

  UNION ALL

  SELECT 73254 AS schoolid
        ,CASE WHEN CONVERT(VARCHAR,[Gr#]) = 'K' OR [Gr#] IS NULL THEN 0 ELSE [Gr#] END AS grade_level
        ,[subject]
        ,[TA] AS TA_num
        ,NULL AS ccss_standard
        ,[Standard_(Standard MUST match Illuminate)] AS other_standard
        ,[Parent Friendly Objective] AS objective
  FROM [AUTOLOAD$GDOCS_TA_SPARK_specials] std WITH(NOLOCK)

  UNION ALL

  SELECT 73255 AS schoolid
        ,CASE WHEN CONVERT(VARCHAR,[Gr#]) = 'K' OR [Gr#] IS NULL THEN 0 ELSE [Gr#] END AS grade_level
        ,[subject]
        ,[TA] AS TA_num
        ,NULL AS ccss_standard
        ,[Standard_(Standard MUST match Illuminate)] AS other_standard
        ,[Parent Friendly Objective] AS objective
  FROM [AUTOLOAD$GDOCS_TA_Thrive_BZ] std WITH(NOLOCK)

  UNION ALL

  SELECT 73256 AS schoolid
        ,CASE WHEN CONVERT(VARCHAR,[Gr#]) = 'K' OR [Gr#] IS NULL THEN 0 ELSE [Gr#] END AS grade_level
        ,[subject]
        ,[TA] AS TA_num
        ,NULL AS ccss_standard
        ,[Standard_(Standard MUST match Illuminate)] AS other_standard
        ,[Parent Friendly Objective] AS objective
  FROM [AUTOLOAD$GDOCS_TA_seek_specials] std WITH(NOLOCK)

  UNION ALL

  SELECT 73257 AS schoolid
        ,CASE WHEN CONVERT(VARCHAR,[Gr#]) = 'K' OR [Gr#] IS NULL THEN 0 ELSE [Gr#] END AS grade_level
        ,[subject]
        ,[TA] AS TA_num
        ,NULL AS ccss_standard
        ,[Standard_(Standard MUST match Illuminate)] AS other_standard
        ,[Parent Friendly Objective] AS objective
  FROM [AUTOLOAD$GDOCS_TA_Life_Upper_Specials] std WITH(NOLOCK)

  UNION ALL

  SELECT 73257 AS schoolid
        ,CASE WHEN CONVERT(VARCHAR,[Gr#]) = 'K' OR [Gr#] IS NULL THEN 0 ELSE [Gr#] END AS grade_level
        ,[subject]
        ,[TA] AS TA_num
        ,NULL AS ccss_standard
        ,[Standard_(Standard MUST match Illuminate)] AS other_standard
        ,[Parent Friendly Objective] AS objective
  FROM [AUTOLOAD$GDOCS_TA_Life_Lower_Specials] std WITH(NOLOCK)

  UNION ALL

  SELECT 179901 AS schoolid
        ,CASE WHEN CONVERT(VARCHAR,[Gr#]) = 'K' OR [Gr#] IS NULL THEN 0 ELSE [Gr#] END AS grade_level
        ,[subject]
        ,[TA] AS TA_num
        ,NULL AS ccss_standard
        ,[Standard_(Standard MUST match Illuminate)] AS other_standard
        ,[Parent Friendly Objective] AS objective
  FROM [AUTOLOAD$GDOCS_TA_Revolution_Specials] std WITH(NOLOCK)
 )

SELECT schoolid
      ,grade_level
      ,subject
      ,term
      ,ccss_standard
      ,other_standard
      ,objective
      ,objective_dirty
      ,ROW_NUMBER() OVER (
         PARTITION BY grade_level
                     ,schoolid
                     ,subject
                     ,term
                     ,ccss_standard
           ORDER BY ccss_standard) AS dupe_audit
FROM
    (
     SELECT dirty_data.schoolid
           ,dirty_data.grade_level
           ,REPLACE(dirty_data.subject, 'Math', 'Mathematics') AS subject
           ,REPLACE(dirty_data.ta_num,'A','') AS term
           ,COALESCE(
              LTRIM(RTRIM(dbo.fn_StripCharacters(REPLACE(REPLACE(REPLACE(CONVERT(NVARCHAR(512),dirty_data.ccss_standard), 'Êº', ''''), '€™', ''''), '€˜', ''''), '"Â'))),
              LTRIM(RTRIM(dbo.fn_StripCharacters(REPLACE(REPLACE(REPLACE(CONVERT(NVARCHAR(512),dirty_data.other_standard), 'Êº', ''''), '€™', ''''), '€˜', ''''), '"Â')))
             ) AS ccss_standard
           ,LTRIM(RTRIM(dbo.fn_StripCharacters(REPLACE(REPLACE(REPLACE(CONVERT(NVARCHAR(512),dirty_data.other_standard), 'Êº', ''''), '€™', ''''), '€˜', ''''), '"Â'))) AS other_standard
           ,dirty_data.objective AS objective_dirty      
           ,LTRIM(RTRIM(dbo.fn_StripCharacters(REPLACE(REPLACE(REPLACE(CONVERT(NVARCHAR(512),dirty_data.objective), 'Êº', ''''), '€™', ''''), '€˜', ''''), '"Â'))) AS objective            
     FROM dirty_data
     WHERE dirty_data.grade_level IS NOT NULL
       AND dirty_data.subject IS NOT NULL
       AND dirty_data.TA_num IS NOT NULL  
    ) sub
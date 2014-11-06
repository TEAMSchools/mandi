USE KIPP_NJ
GO

ALTER VIEW GDOCS$TA_standards_clean AS

WITH dirty_data AS (
  SELECT CASE WHEN CONVERT(VARCHAR,grade_level) = 'K' OR grade_level IS NULL THEN 0 ELSE grade_level END AS grade_level
        ,subject
        ,TA_num
        ,ccss_standard
        ,other_standard
        ,objective        
  FROM [AUTOLOAD$GDOCS_TA_All] WITH(NOLOCK)
 )

SELECT dirty_data.grade_level
      ,REPLACE(dirty_data.subject, 'Math', 'Mathematics') AS subject
      ,REPLACE(dirty_data.ta_num,'A','') AS term
      ,COALESCE(dirty_data.ccss_standard, dirty_data.other_standard) AS ccss_standard
      ,COALESCE(dirty_data.other_standard, dirty_data.ccss_standard) AS other_standard
      ,dirty_data.objective AS objective_dirty      
      ,dbo.fn_StripCharacters(REPLACE(REPLACE(REPLACE(CONVERT(NVARCHAR(512),dirty_data.objective), 'Êº', ''''), '€™', ''''), '€˜', ''''), '"Â') AS objective      
      ,ROW_NUMBER() OVER (
         PARTITION BY dirty_data.grade_level
                     ,dirty_data.subject
                     ,dirty_data.ta_num
                     ,dirty_data.ccss_standard
           ORDER BY dirty_data.ccss_standard) AS dupe_audit
FROM dirty_data
WHERE dirty_data.grade_level IS NOT NULL
  AND dirty_data.subject IS NOT NULL
  AND dirty_data.TA_num IS NOT NULL  
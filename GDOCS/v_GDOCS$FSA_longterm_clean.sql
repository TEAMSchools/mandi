USE KIPP_NJ
GO

ALTER VIEW GDOCS$FSA_longterm_clean AS

WITH dirty_data AS (
  SELECT 73254 AS schoolid
        ,CASE WHEN CONVERT(VARCHAR,grade_level) = 'K' OR grade_level IS NULL THEN 0 ELSE grade_level END AS grade_level
        ,subject
        ,LEFT(week_num, 7) AS week_num
        ,ccss_standard
        ,other_standard
        ,objective
        ,next_steps_mastered
        ,next_steps_notmastered
  FROM AUTOLOAD$GDOCS_FSA_SPARK WITH(NOLOCK)

  UNION ALL

  SELECT 73255
        ,CASE WHEN CONVERT(VARCHAR,grade_level) = 'K' OR grade_level IS NULL THEN 0 ELSE grade_level END AS grade_level
        ,subject
        ,LEFT(week_num, 7) AS week_num
        ,ccss_standard
        ,other_standard
        ,objective
        ,next_steps_mastered
        ,next_steps_notmastered
  FROM AUTOLOAD$GDOCS_FSA_THRIVE WITH(NOLOCK)

  UNION ALL

  SELECT 73256
        ,CASE WHEN CONVERT(VARCHAR,grade_level) = 'K' OR grade_level IS NULL THEN 0 ELSE grade_level END AS grade_level
        ,subject
        ,LEFT(week_num, 7) AS week_num
        ,ccss_standard
        ,other_standard
        ,objective
        ,next_steps_mastered
        ,next_steps_notmastered
  FROM AUTOLOAD$GDOCS_FSA_Seek WITH(NOLOCK)

  UNION ALL

  SELECT 73257
        ,CASE WHEN CONVERT(VARCHAR,grade_level) = 'K' OR grade_level IS NULL THEN 0 ELSE grade_level END AS grade_level
        ,subject
        ,LEFT(week_num, 7) AS week_num
        ,ccss_standard
        ,other_standard
        ,objective
        ,next_steps_mastered
        ,next_steps_notmastered
  FROM AUTOLOAD$GDOCS_FSA_Life WITH(NOLOCK)

  UNION ALL
  
  SELECT 73257
        ,CASE WHEN CONVERT(VARCHAR,grade_level) = 'K' OR grade_level IS NULL THEN 0 ELSE grade_level END AS grade_level
        ,subject
        ,LEFT(week_num, 7) AS week_num
        ,ccss_standard
        ,other_standard
        ,objective
        ,next_steps_mastered
        ,next_steps_notmastered
  FROM AUTOLOAD$GDOCS_FSA_Life_Upper WITH(NOLOCK)

  UNION ALL

  SELECT 179901
        ,CASE WHEN CONVERT(VARCHAR,grade_level) = 'K' OR grade_level IS NULL THEN 0 ELSE grade_level END AS grade_level
        ,subject
        ,LEFT(week_num, 7) AS week_num
        ,ccss_standard
        ,other_standard
        ,objective
        ,next_steps_mastered
        ,next_steps_notmastered
  FROM AUTOLOAD$GDOCS_FSA_Revolution WITH(NOLOCK)
 )

SELECT dirty_data.schoolid
      ,dirty_data.grade_level
      ,REPLACE(dirty_data.subject, 'Math', 'Mathematics') AS subject
      ,dirty_data.week_num
      ,COALESCE(dirty_data.ccss_standard, dirty_data.other_standard) AS ccss_standard
      ,COALESCE(dirty_data.other_standard, dirty_data.ccss_standard) AS other_standard
      ,dirty_data.objective AS objective_dirty
      ,dirty_data.next_steps_mastered AS nxtstp_mastered_dirty
      ,dirty_data.next_steps_notmastered AS nxtstp_notmastered_dirty
      ,dbo.fn_StripCharacters(REPLACE(REPLACE(REPLACE(CONVERT(NVARCHAR(512),dirty_data.objective), 'Êº', ''''), '€™', ''''), '€˜', ''''), '"Â') AS objective
      ,dbo.fn_StripCharacters(REPLACE(REPLACE(REPLACE(CONVERT(NVARCHAR(512),dirty_data.next_steps_mastered), 'Êº', ''''), '€™', ''''), '€˜', ''''), '"Â') AS next_steps_mastered
      ,dbo.fn_StripCharacters(REPLACE(REPLACE(REPLACE(CONVERT(NVARCHAR(512),dirty_data.next_steps_notmastered), 'Êº', ''''), '€™', ''''), '€˜', ''''), '"Â') AS next_steps_notmastered
      ,ROW_NUMBER() OVER (
         PARTITION BY dirty_data.schoolid
                     ,dirty_data.grade_level
                     ,dirty_data.subject
                     ,dirty_data.week_num
                     ,dirty_data.ccss_standard
           ORDER BY dirty_data.ccss_standard) AS dupe_audit
FROM dirty_data
WHERE dirty_data.grade_level IS NOT NULL
  AND dirty_data.subject IS NOT NULL
  AND dirty_data.week_num IS NOT NULL  
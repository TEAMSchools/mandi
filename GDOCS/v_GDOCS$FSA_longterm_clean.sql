USE KIPP_NJ
GO

ALTER VIEW GDOCS$FSA_longterm_clean AS

WITH dirty_data AS (
  SELECT 73254 AS schoolid
        ,REPLACE(grade_level, 'K', 0) AS grade_level
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
        ,REPLACE(grade_level, 'K', 0) AS grade_level
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
        ,REPLACE(grade_level, 'K', 0) AS grade_level
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
        ,REPLACE(grade_level, 'K', 0) AS grade_level
        ,subject
        ,LEFT(week_num, 7) AS week_num
        ,ccss_standard
        ,other_standard
        ,objective
        ,next_steps_mastered
        ,next_steps_notmastered
  FROM AUTOLOAD$GDOCS_FSA_Life WITH(NOLOCK)

  UNION ALL

  SELECT 179901
        ,REPLACE(grade_level, 'K', 0) AS grade_level
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
      ,dirty_data.subject
      ,dirty_data.week_num
      ,dirty_data.ccss_standard
      ,dirty_data.other_standard
      ,REPLACE(REPLACE(REPLACE(CONVERT(NVARCHAR(512),dirty_data.objective), 'ʺ', '"'), '’', ''''), '�', '') AS objective
      ,REPLACE(REPLACE(REPLACE(CONVERT(NVARCHAR(512),dirty_data.next_steps_mastered), 'ʺ', '"'), '’', ''''), '�', '') AS next_steps_mastered
      ,REPLACE(REPLACE(REPLACE(CONVERT(NVARCHAR(512),dirty_data.next_steps_notmastered), 'ʺ', '"'), '’', ''''), '�', '') AS next_steps_notmastered
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
  AND dirty_data.ccss_standard IS NOT NULL
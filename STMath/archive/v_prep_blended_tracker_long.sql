USE STMath
GO

ALTER VIEW prep_blended_tracker_long AS

WITH st_libraries AS (
  SELECT 'Kindergarten' AS grade_lib
        ,0 AS gcd_sort
        ,'lib_K' AS short_code
  UNION
  SELECT 'First Grade'
        ,1
        ,'lib_1st'
  UNION 
  SELECT 'Second Grade'
        ,2
        ,'lib_2nd'
  UNION
  SELECT 'Third Grade'
        ,3
        ,'lib_3rd'
  UNION
  SELECT 'Fourth Grade'
        ,4
        ,'lib_4th'
  UNION 
  SELECT 'Fifth Grade'
        ,5
        ,'lib_5th'
  UNION
  SELECT 'Sixth Grade'
        ,6
        ,'lib_6th'
  UNION
  SELECT 'Sixth MSS'
        ,7
        ,'lib_6th_MSS'
  UNION
  SELECT 'Seventh MSS'
        ,8
        ,'lib_7th_MSS'
  UNION
  SELECT 'Eighth MSS'
        ,9
        ,'lib_8th_MSS'
 )
    
,min_lib AS (
  SELECT p.studentid
        ,MIN(st_libraries.gcd_sort) AS min_sort
  FROM STMath..progress_completion#identifiers p
  JOIN st_libraries
    ON p.GCD = st_libraries.grade_lib
  GROUP BY p.studentid
 )

SELECT min_lib.studentid
      ,st_libraries.short_code
      ,'Implicit' AS comp_type
      ,NULL AS school_year
      ,100 AS K_5_Progress
FROM min_lib WITH(NOLOCK)
JOIN st_libraries WITH(NOLOCK)
  ON st_libraries.gcd_sort < min_lib.min_sort

UNION ALL

--observed completion
SELECT st.studentid
      ,st_libraries.short_code
      ,'Observed' AS comp_type
      ,st.start_year
      ,CAST(MAX(K_5_Progress) AS NUMERIC(4,1))
FROM STMath..completion_by_week st WITH(NOLOCK)
JOIN st_libraries WITH(NOLOCK)
  ON st.GCD = st_libraries.grade_lib
 AND st.start_year = KIPP_NJ.dbo.fn_Global_Academic_Year()
GROUP BY st.studentid
        ,st_libraries.short_code
        ,st.start_year
        ,st.gcd_sort
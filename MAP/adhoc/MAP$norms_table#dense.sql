WITH measurementscales (measurementscale) AS (
  SELECT 'Mathematics' UNION
  SELECT 'Reading' UNION
  SELECT 'Language Usage' UNION
  SELECT 'Science - General Science'
 )

,terms (term) AS (
  SELECT 'Fall' UNION
  SELECT 'Winter' UNION
  SELECT 'Spring'
 )

,grade_levels AS (
  SELECT N AS grade_level
  FROM KIPP_NJ..UTIL$row_generator WITH(NOLOCK)
  WHERE N BETWEEN 0 AND 12
 )

,scaffold AS (
  SELECT m.measurementscale
        ,t.term
        ,gr.grade_level
        ,COALESCE(u.n, n.student_percentile) AS testpercentile
        ,n.testritscore
  FROM KIPP_NJ..UTIL$row_generator u
  CROSS JOIN measurementscales m
  CROSS JOIN terms t
  CROSS JOIN grade_levels gr
  LEFT OUTER JOIN KIPP_NJ..AUTOLOAD$GDOCS_MAP_norms_table n WITH(NOLOCK)
    ON u.n = n.student_percentile
   AND m.measurementscale = n.measurementscale
   AND t.term = n.term
   AND gr.grade_level = n.grade_level
   AND n.norms_year = 2015
  WHERE u.n BETWEEN 1 AND 99  
 )

,norms_dense AS (
  SELECT measurementscale
        ,term
        ,grade_level
        ,testpercentile
        ,COALESCE(testritscore, testritscore_dense) AS testritscore
  FROM
      (
       SELECT measurementscale
             ,term
             ,grade_level
             ,testpercentile
             ,testritscore
             ,testritscore_dense      
             ,ROW_NUMBER() OVER(
                PARTITION BY measurementscale, term, grade_level, testpercentile
                  ORDER BY testritscore_dense ASC) AS rn
       FROM
           (
            SELECT s1.measurementscale 
                  ,s1.term
                  ,s1.grade_level
                  ,s1.testpercentile
                  ,s1.testritscore
                  ,s2.testritscore AS testritscore_dense
            FROM scaffold s1
            JOIN scaffold s2
              ON s1.measurementscale = s2.measurementscale
             AND s1.term = s2.term
             AND s1.grade_level = s2.grade_level
             AND s1.testpercentile <= s2.testpercentile
            ) sub
       WHERE testritscore_dense IS NOT NULL
      ) sub
  WHERE rn = 1

  UNION

  SELECT measurementscale
        ,term
        ,grade_level
        ,student_percentile
        ,testritscore
  FROM KIPP_NJ..AUTOLOAD$GDOCS_MAP_norms_table WITH(NOLOCK)
  WHERE student_percentile IN (1,99)
 )

SELECT *
INTO KIPP_NJ..MAP$norms_table#dense
FROM norms_dense
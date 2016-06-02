USE KIPP_NJ
GO

ALTER VIEW MAP$comprehensive#outlier_scored AS

WITH global_min_tested AS (
  SELECT grade_level
        ,measurementscale
        ,AVG(CAST(testdurationminutes AS int)) AS mean_min_tested
        ,STDEV(CAST(testdurationminutes AS int)) AS stdev_min_tested
  FROM KIPP_NJ..MAP$CDF#identifiers#static m WITH(NOLOCK)
  WHERE m.measurementscale != 'Science - Concepts and Processes'
    AND m.grade_level IS NOT NULL
    AND m.rn = 1
  GROUP BY grade_level
          ,measurementscale
 )

,stu_min_tested AS ( 
  SELECT studentid
        ,measurementscale
        ,AVG(CAST(testdurationminutes AS int) + 0.0) AS mean_min_tested
        ,STDEV(CAST(testdurationminutes AS int)) AS stdev_min_tested
  FROM KIPP_NJ..MAP$CDF#identifiers#static m WITH(NOLOCK)
  WHERE m.measurementscale != 'Science - Concepts and Processes'
    AND m.grade_level IS NOT NULL
    AND m.rn=1
  GROUP BY studentid
          ,measurementscale
  HAVING COUNT(*) >= 4
 )

,npr_ahead AS (
  SELECT m.measurementscale
        ,m.grade_level
        ,m.term AS fws
        ,m_next.term AS fws_next
        ,AVG(m_next.percentile_2011_norms - m.percentile_2011_norms + 0.0) AS mean_npr_change
        ,STDEV(m_next.percentile_2011_norms - m.percentile_2011_norms + 0.0) AS stdev_npr_change
        ,COUNT(*) AS n
  FROM KIPP_NJ..MAP$CDF#identifiers#static m WITH(NOLOCK)
  JOIN KIPP_NJ..MAP$CDF#identifiers#static m_next WITH(NOLOCK)
    ON m.studentid = m_next.studentid
   AND m.measurementscale = m_next.measurementscale
   AND m.rn_asc + 1 = m_next.rn_asc
   AND m.term != m_next.term
   AND m_next.academic_year - m.academic_year <= 1
   AND m_next.rn = 1
  WHERE m.measurementscale != 'Science - Concepts and Processes'
    AND m.grade_level IS NOT NULL
    AND m.rn=1
  GROUP BY m.measurementscale
          ,m.grade_level
          ,m.term
          ,m_next.term 
  HAVING COUNT(*) >= 100
 )

,npr_behind AS (
  SELECT m.measurementscale
        ,m.grade_level
        ,m.term AS fws
        ,m_prev.term fws_prev
        ,AVG(m.percentile_2011_norms - m_prev.percentile_2011_norms + 0.0) AS mean_npr_change
        ,STDEV(m.percentile_2011_norms - m_prev.percentile_2011_norms + 0.0) AS stdev_npr_change
        ,COUNT(*) AS n
  FROM KIPP_NJ..MAP$CDF#identifiers#static m WITH(NOLOCK)
  JOIN KIPP_NJ..MAP$CDF#identifiers#static m_prev WITH(NOLOCK)
    ON m.studentid = m_prev.studentid
   AND m.measurementscale = m_prev.measurementscale
   AND m.rn_asc - 1 = m_prev.rn_asc
   AND m.term != m_prev.term
   AND m.academic_year - m_prev.academic_year >= 1
   AND m_prev.rn = 1
  WHERE m.measurementscale != 'Science - Concepts and Processes'
    AND m.grade_level IS NOT NULL
    AND m.rn = 1
  GROUP BY m.measurementscale
          ,m.grade_level
          ,m.term
          ,m_prev.term 
  HAVING COUNT(*) >= 100
 )

SELECT sub.*
      ,CAST(ISNULL(global_min_tested_z, 0) + 2*ISNULL(stu_min_tested_z, 0) + ISNULL(npr_behind_z, 0) + 2*ISNULL(v_dip_signature_z,0) AS NUMERIC(5,3)) AS total_z
FROM
    (
     SELECT sub.*
           ,CASE WHEN npr_behind_z < 0 AND npr_ahead_z < 0 THEN npr_behind_z + npr_ahead_z ELSE NULL END AS v_dip_signature_z
     FROM
         (
          SELECT m.*
                ,m_next.termname AS next_term
                ,m_next.testritscore AS next_rit
                ,m_next.percentile_2011_norms AS next_npr
                ,m_prev.termname AS prev_term
                ,m_prev.testritscore AS prev_rit
                ,m_prev.percentile_2011_norms AS prev_npr
                ,CAST((m.testdurationminutes - global_min_tested.mean_min_tested) / 
                   global_min_tested.stdev_min_tested AS numeric(5,3)) AS global_min_tested_z
                ,CAST((m.testdurationminutes - stu_min_tested.mean_min_tested) / 
                   stu_min_tested.stdev_min_tested AS numeric(5,3)) AS stu_min_tested_z
                ,((m.percentile_2011_norms - m_prev.percentile_2011_norms) - npr_behind.mean_npr_change) / 
                    npr_behind.stdev_npr_change AS npr_behind_z
                ,-1*((m_next.percentile_2011_norms - m.percentile_2011_norms) - npr_ahead.mean_npr_change) / 
                    npr_ahead.stdev_npr_change AS npr_ahead_z
          FROM KIPP_NJ..MAP$CDF#identifiers#static m
          LEFT OUTER JOIN KIPP_NJ..MAP$CDF#identifiers#static m_next
            ON m.studentid = m_next.studentid
           AND m.measurementscale = m_next.measurementscale
           AND m.rn_asc + 1 = m_next.rn_asc
           AND m.term != m_next.term
           AND m_next.academic_year - m.academic_year <= 1
           AND m_next.rn = 1
          LEFT OUTER JOIN KIPP_NJ..MAP$CDF#identifiers#static m_prev
            ON m.studentid = m_prev.studentid
           AND m.measurementscale = m_prev.measurementscale
           AND m.rn_asc - 1 = m_prev.rn_asc
           AND m.term != m_prev.term
           AND m.academic_year - m_prev.academic_year >= 1
           AND m_prev.rn = 1
          LEFT OUTER JOIN global_min_tested
            ON m.measurementscale = global_min_tested.measurementscale
           AND m.grade_level = global_min_tested.grade_level
          LEFT OUTER JOIN stu_min_tested
            ON m.measurementscale = stu_min_tested.measurementscale
           AND m.studentid = stu_min_tested.studentid
          LEFT OUTER JOIN npr_ahead
            ON m_next.measurementscale = npr_ahead.measurementscale
           AND m.grade_level = npr_ahead.grade_level
           AND m.term = npr_ahead.fws
           AND m_next.term = npr_ahead.fws_next
          LEFT OUTER JOIN npr_behind
            ON m_next.measurementscale = npr_behind.measurementscale
           AND m.grade_level = npr_behind.grade_level
           AND m.term = npr_behind.fws
           AND m_prev.term = npr_behind.fws_prev
          WHERE m.rn = 1
         ) sub
    ) sub
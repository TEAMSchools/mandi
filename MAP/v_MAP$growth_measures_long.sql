WITH cohort AS
     (SELECT cohort.studentid
            ,cohort.grade_level
            ,cohort.schoolid
            ,cohort.year
            ,cohort.cohort
            ,cohort.year_in_network
      FROM KIPP_NJ..COHORT$comprehensive_long#static cohort
      WHERE cohort.grade_level <= 12
                   AND cohort.rn = 1
      )

    ,periods AS
     (SELECT 4 AS start_term_numeric
            ,2 AS end_term_numeric
            ,42 AS period_numeric
            ,0 AS lookback_modifier
            ,'Fall' AS start_term_string
            ,'Spring' AS end_term_string
            ,'Fall to Spring' AS period_string
      UNION ALL
      SELECT 2
            ,2
            ,22
            ,-1
            ,'Spring'
            ,'Spring'
            ,'Spring to Spring'
      UNION ALL
      SELECT 4
            ,4
            ,44
            ,-1
            ,'Fall'
            ,'Fall'
            ,'Fall to Fall'
      UNION ALL
      SELECT 4
            ,1
            ,41
            ,0
            ,'Fall'
            ,'Winter'
            ,'Fall to Winter'
      UNION ALL
      SELECT 1
            ,2
            ,12
            ,0
            ,'Winter'
            ,'Spring'
            ,'Winter to Spring'
      /*
      UNION ALL
      SELECT 2
            ,1
            ,22
            ,-1
            ,'Spring'
            ,'Winter'
            ,'Spring to psuedo-Spring (Spring goal, Winter actual)'
      UNION ALL
      SELECT 4
            ,1
            ,42
            ,0
            ,'Fall'
            ,'Winter'
            ,'Fall to psuedo-Spring (Spring goal, Winter actual)'
      */
      )

    ,scales AS
     (SELECT 'Mathematics' AS measurementscale
      UNION ALL
      SELECT 'Reading'
      UNION ALL
      SELECT 'Language Usage'
      UNION ALL
      SELECT 'Concepts and Processes'
      UNION ALL
      SELECT 'General Science'
     )


SELECT cohort.*
      ,periods.*
      ,scales.*
FROM cohort
JOIN periods
  ON 1=1
JOIN scales
  ON 1=1
USE STMath
GO

CREATE VIEW completion_by_week AS
WITH week_nums AS
    (SELECT week_ending_date
           ,ROW_NUMBER() OVER
                      (ORDER BY week_ending_date
                      ) AS week_num
     FROM           
           (SELECT DISTINCT p.week_ending_date
            FROM STMath..progress_completion#identifiers p
            WHERE p.start_year = 2014
            ) sub
     )
    --ordering of ST math libraries
    ,st_libraries AS
    (SELECT 'Kindergarten' AS grade_lib
           ,0 AS sort_order
     UNION
     SELECT 'First Grade'
           ,1
     UNION 
     SELECT 'Second Grade'
           ,2
     UNION
     SELECT 'Third Grade'
           ,3
     UNION
     SELECT 'Fourth Grade'
           ,4
     UNION 
     SELECT 'Fifth Grade'
           ,5
     UNION
     SELECT 'Sixth Grade'
           ,6
     )
    ,progress_with_week AS 
    (SELECT p.*
           ,week_nums.week_num
           ,st_libraries.sort_order AS gcd_sort
     FROM STMath..progress_completion#identifiers p
     JOIN week_nums
       ON p.week_ending_date = week_nums.week_ending_date
     JOIN st_libraries
       ON p.GCD = st_libraries.grade_lib
    )
SELECT p_base.studentid
      ,s.grade_level AS stu_grade
      ,s.lastfirst
      ,p_base.start_year
      ,p_base.week_ending_date
      ,p_base.week_num
      ,p_base.GCD
      ,p_base.gcd_sort
      ,CASE
         WHEN p_base.gcd_sort < p_next.gcd_sort THEN 100
         ELSE p_base.K_5_Progress
       END AS K_5_Progress
FROM progress_with_week p_base
JOIN KIPP_NJ..STUDENTS s
  ON p_base.studentid = s.id
--look ahead one week to find implicit completion, where a kid
--got moved ahead a library the next week.  in those cases, 
--tag the progress as 100
LEFT OUTER JOIN progress_with_week p_next
  ON p_base.UUID = p_next.UUID
 AND p_base.week_num + 1 = p_next.week_num 

USE KIPP_NJ
GO

ALTER VIEW GRADES$rc_grades_by_term AS

SELECT *
FROM
    (
     SELECT studentid
           ,student_number
           ,LEFT(field, 3) AS class
           ,RIGHT(field, 2) AS term
           ,grade
     FROM
         (
          SELECT student_number
                ,studentid
                ,rc1_t1
                ,rc1_t2
                ,rc1_t3
                ,rc2_t1
                ,rc2_t2
                ,rc2_t3
                ,rc3_t1
                ,rc3_t2
                ,rc3_t3
                ,rc4_t1
                ,rc4_t2
                ,rc4_t3
                ,rc5_t1
                ,rc5_t2
                ,rc5_t3
                ,rc6_t1
                ,rc6_t2
                ,rc6_t3
                ,rc7_t1
                ,rc7_t2
                ,rc7_t3
                ,rc8_t1
                ,rc8_t2
                ,rc8_t3
          FROM GRADES$wide_all#MS WITH(NOLOCK)
         ) sub

     UNPIVOT (
       grade
       FOR field IN (rc1_t1
                    ,rc1_t2
                    ,rc1_t3
                    ,rc2_t1
                    ,rc2_t2
                    ,rc2_t3
                    ,rc3_t1
                    ,rc3_t2
                    ,rc3_t3
                    ,rc4_t1
                    ,rc4_t2
                    ,rc4_t3
                    ,rc5_t1
                    ,rc5_t2
                    ,rc5_t3
                    ,rc6_t1
                    ,rc6_t2
                    ,rc6_t3
                    ,rc7_t1
                    ,rc7_t2
                    ,rc7_t3
                    ,rc8_t1
                    ,rc8_t2
                    ,rc8_t3)
       ) u
    ) sub

PIVOT (
  MAX(grade)
  FOR class IN ([rc1],[rc2],[rc3],[rc4],[rc5],[rc6],[rc7],[rc8])
 ) p
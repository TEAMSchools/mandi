USE KIPP_NJ
GO

ALTER VIEW GRADES$rc_grades_by_term AS

SELECT studentid
      ,student_number
      ,term
      ,[rc1]
      ,[rc2]
      ,[rc3]
      ,[rc4]
      ,[rc5]
      ,[rc6]
      ,[rc7]
      ,[rc8]
      ,[rc9]
      ,[rc10]
FROM
    (
     SELECT studentid
           ,student_number           
           ,RIGHT(field, 2) AS term
           ,LEFT(field, 3) AS class
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
                ,NULL AS rc1_q1
                ,NULL AS rc1_q2
                ,NULL AS rc1_q3
                ,NULL AS rc1_q4
                ,NULL AS rc2_q1
                ,NULL AS rc2_q2
                ,NULL AS rc2_q3
                ,NULL AS rc2_q4
                ,NULL AS rc3_q1
                ,NULL AS rc3_q2
                ,NULL AS rc3_q3
                ,NULL AS rc3_q4
                ,NULL AS rc4_q1
                ,NULL AS rc4_q2
                ,NULL AS rc4_q3
                ,NULL AS rc4_q4
                ,NULL AS rc5_q1
                ,NULL AS rc5_q2
                ,NULL AS rc5_q3
                ,NULL AS rc5_q4
                ,NULL AS rc6_q1
                ,NULL AS rc6_q2
                ,NULL AS rc6_q3
                ,NULL AS rc6_q4
                ,NULL AS rc7_q1
                ,NULL AS rc7_q2
                ,NULL AS rc7_q3
                ,NULL AS rc7_q4
                ,NULL AS rc8_q1
                ,NULL AS rc8_q2
                ,NULL AS rc8_q3
                ,NULL AS rc8_q4
                ,NULL AS rc9_q1
                ,NULL AS rc9_q2
                ,NULL AS rc9_q3
                ,NULL AS rc9_q4
                ,NULL AS rc10_q1
                ,NULL AS rc10_q2
                ,NULL AS rc10_q3
                ,NULL AS rc10_q4
          FROM GRADES$wide_all#MS#static WITH(NOLOCK)

          UNION ALL

          SELECT student_number
                ,studentid
                ,NULL AS rc1_t1
                ,NULL AS rc1_t2
                ,NULL AS rc1_t3
                ,NULL AS rc2_t1
                ,NULL AS rc2_t2
                ,NULL AS rc2_t3
                ,NULL AS rc3_t1
                ,NULL AS rc3_t2
                ,NULL AS rc3_t3
                ,NULL AS rc4_t1
                ,NULL AS rc4_t2
                ,NULL AS rc4_t3
                ,NULL AS rc5_t1
                ,NULL AS rc5_t2
                ,NULL AS rc5_t3
                ,NULL AS rc6_t1
                ,NULL AS rc6_t2
                ,NULL AS rc6_t3
                ,NULL AS rc7_t1
                ,NULL AS rc7_t2
                ,NULL AS rc7_t3
                ,NULL AS rc8_t1
                ,NULL AS rc8_t2
                ,NULL AS rc8_t3
                ,rc1_q1
                ,rc1_q2
                ,rc1_q3
                ,rc1_q4
                ,rc2_q1
                ,rc2_q2
                ,rc2_q3
                ,rc2_q4
                ,rc3_q1
                ,rc3_q2
                ,rc3_q3
                ,rc3_q4
                ,rc4_q1
                ,rc4_q2
                ,rc4_q3
                ,rc4_q4
                ,rc5_q1
                ,rc5_q2
                ,rc5_q3
                ,rc5_q4
                ,rc6_q1
                ,rc6_q2
                ,rc6_q3
                ,rc6_q4
                ,rc7_q1
                ,rc7_q2
                ,rc7_q3
                ,rc7_q4
                ,rc8_q1
                ,rc8_q2
                ,rc8_q3
                ,rc8_q4
                ,rc9_q1
                ,rc9_q2
                ,rc9_q3
                ,rc9_q4
                ,rc10_q1
                ,rc10_q2
                ,rc10_q3
                ,rc10_q4
          FROM GRADES$wide_all#NCA#static WITH(NOLOCK)
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
                    ,rc8_t3
                    ,rc1_q1
                    ,rc1_q2
                    ,rc1_q3
                    ,rc1_q4
                    ,rc2_q1
                    ,rc2_q2
                    ,rc2_q3
                    ,rc2_q4
                    ,rc3_q1
                    ,rc3_q2
                    ,rc3_q3
                    ,rc3_q4
                    ,rc4_q1
                    ,rc4_q2
                    ,rc4_q3
                    ,rc4_q4
                    ,rc5_q1
                    ,rc5_q2
                    ,rc5_q3
                    ,rc5_q4
                    ,rc6_q1
                    ,rc6_q2
                    ,rc6_q3
                    ,rc6_q4
                    ,rc7_q1
                    ,rc7_q2
                    ,rc7_q3
                    ,rc7_q4
                    ,rc8_q1
                    ,rc8_q2
                    ,rc8_q3
                    ,rc8_q4
                    ,rc9_q1
                    ,rc9_q2
                    ,rc9_q3
                    ,rc9_q4
                    ,rc10_q1
                    ,rc10_q2
                    ,rc10_q3
                    ,rc10_q4)
       ) u
    ) sub

PIVOT (
  MAX(grade)
  FOR class IN ([rc1],[rc2],[rc3],[rc4],[rc5],[rc6],[rc7],[rc8],[rc9],[rc10])
 ) p
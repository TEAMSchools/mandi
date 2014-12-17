USE KIPP_NJ
GO

ALTER VIEW GRADES$rc_elements_by_term AS

SELECT studentid
      ,student_number
      ,term
      ,[rc1_A]
      ,[rc1_C]
      ,[rc1_H]
      ,[rc1_P]
      ,[rc1_Q]
      ,[rc1_S]
      ,[rc2_A]
      ,[rc2_C]
      ,[rc2_H]
      ,[rc2_P]
      ,[rc2_Q]
      ,[rc2_S]
      ,[rc3_A]
      ,[rc3_C]
      ,[rc3_H]
      ,[rc3_P]
      ,[rc3_Q]
      ,[rc3_S]
      ,[rc4_A]
      ,[rc4_C]
      ,[rc4_H]
      ,[rc4_P]
      ,[rc4_Q]
      ,[rc4_S]
      ,[rc5_A]
      ,[rc5_C]
      ,[rc5_H]
      ,[rc5_P]
      ,[rc5_Q]
      ,[rc5_S]
      ,[rc6_A]
      ,[rc6_C]
      ,[rc6_H]
      ,[rc6_P]
      ,[rc6_S]
      ,[rc6_Q]
      ,[rc7_A]
      ,[rc7_C]
      ,[rc7_H]
      ,[rc7_P]
      ,[rc7_S]
      ,[rc7_Q]
      ,[rc8_A]
      ,[rc8_C]
      ,[rc8_H]
      ,[rc8_P]
      ,[rc8_S]
      ,[rc8_Q]
      ,[rc9_A]
      ,[rc9_C]
      ,[rc9_H]
      ,[rc9_P]
      ,[rc10_A]
      ,[rc10_C]
      ,[rc10_H]
      ,[rc10_P]
FROM
    (
     SELECT studentid
           ,student_number           
           --,LEFT(field, 3) AS class           
           --,UPPER(SUBSTRING(REVERSE(field),2,1)) AS element
           ,LEFT(field, 3) + '_' + UPPER(SUBSTRING(REVERSE(field),2,1)) AS pivot_hash
           ,CASE WHEN schoolid = 73253 THEN 'Q' ELSE 'T' END + CONVERT(VARCHAR,RIGHT(field, 1)) AS term           
           ,grade
     FROM
         (
          SELECT student_number
                ,studentid
                ,schoolid
                ,rc1_h1
                ,rc1_h2
                ,rc1_h3
                ,rc1_q1
                ,rc1_q2
                ,rc1_q3
                ,rc1_s1
                ,rc1_s2
                ,rc1_s3
                ,rc2_h1
                ,rc2_h2
                ,rc2_h3
                ,rc2_q1
                ,rc2_q2
                ,rc2_q3
                ,rc2_s1
                ,rc2_s2
                ,rc2_s3
                ,rc3_h1
                ,rc3_h2
                ,rc3_h3
                ,rc3_q1
                ,rc3_q2
                ,rc3_q3
                ,rc3_s1
                ,rc3_s2
                ,rc3_s3
                ,rc4_h1
                ,rc4_h2
                ,rc4_h3
                ,rc4_q1
                ,rc4_q2
                ,rc4_q3
                ,rc4_s1
                ,rc4_s2
                ,rc4_s3
                ,rc5_h1
                ,rc5_h2
                ,rc5_h3
                ,rc5_q1
                ,rc5_q2
                ,rc5_q3
                ,rc5_s1
                ,rc5_s2
                ,rc5_s3
                ,rc6_h1
                ,rc6_h2
                ,rc6_h3
                ,rc6_q1
                ,rc6_q2
                ,rc6_q3
                ,rc6_s1
                ,rc6_s2
                ,rc6_s3
                ,rc7_h1
                ,rc7_h2
                ,rc7_h3
                ,rc7_q1
                ,rc7_q2
                ,rc7_q3
                ,rc7_s1
                ,rc7_s2
                ,rc7_s3
                ,rc8_h1
                ,rc8_h2
                ,rc8_h3
                ,rc8_q1
                ,rc8_q2
                ,rc8_q3
                ,rc8_s1
                ,rc8_s2
                ,rc8_s3
                ,NULL AS rc1_a1
                ,NULL AS rc1_a2
                ,NULL AS rc1_a3
                ,NULL AS rc1_a4
                ,NULL AS rc1_c1
                ,NULL AS rc1_c2
                ,NULL AS rc1_c3
                ,NULL AS rc1_c4                
                ,NULL AS rc1_h4
                ,NULL AS rc1_p1
                ,NULL AS rc1_p2
                ,NULL AS rc1_p3
                ,NULL AS rc1_p4
                ,NULL AS rc10_a1
                ,NULL AS rc10_a2
                ,NULL AS rc10_a3
                ,NULL AS rc10_a4
                ,NULL AS rc10_c1
                ,NULL AS rc10_c2
                ,NULL AS rc10_c3
                ,NULL AS rc10_c4                
                ,NULL AS rc10_h1
                ,NULL AS rc10_h2
                ,NULL AS rc10_h3            
                ,NULL AS rc10_h4
                ,NULL AS rc10_p1
                ,NULL AS rc10_p2
                ,NULL AS rc10_p3
                ,NULL AS rc10_p4
                ,NULL AS rc2_a1
                ,NULL AS rc2_a2
                ,NULL AS rc2_a3
                ,NULL AS rc2_a4
                ,NULL AS rc2_c1
                ,NULL AS rc2_c2
                ,NULL AS rc2_c3
                ,NULL AS rc2_c4                
                ,NULL AS rc2_h4
                ,NULL AS rc2_p1
                ,NULL AS rc2_p2
                ,NULL AS rc2_p3
                ,NULL AS rc2_p4
                ,NULL AS rc3_a1
                ,NULL AS rc3_a2
                ,NULL AS rc3_a3
                ,NULL AS rc3_a4
                ,NULL AS rc3_c1
                ,NULL AS rc3_c2
                ,NULL AS rc3_c3
                ,NULL AS rc3_c4                
                ,NULL AS rc3_h4
                ,NULL AS rc3_p1
                ,NULL AS rc3_p2
                ,NULL AS rc3_p3
                ,NULL AS rc3_p4
                ,NULL AS rc4_a1
                ,NULL AS rc4_a2
                ,NULL AS rc4_a3
                ,NULL AS rc4_a4
                ,NULL AS rc4_c1
                ,NULL AS rc4_c2
                ,NULL AS rc4_c3
                ,NULL AS rc4_c4                
                ,NULL AS rc4_h4
                ,NULL AS rc4_p1
                ,NULL AS rc4_p2
                ,NULL AS rc4_p3
                ,NULL AS rc4_p4
                ,NULL AS rc5_a1
                ,NULL AS rc5_a2
                ,NULL AS rc5_a3
                ,NULL AS rc5_a4
                ,NULL AS rc5_c1
                ,NULL AS rc5_c2
                ,NULL AS rc5_c3
                ,NULL AS rc5_c4                
                ,NULL AS rc5_h4
                ,NULL AS rc5_p1
                ,NULL AS rc5_p2
                ,NULL AS rc5_p3
                ,NULL AS rc5_p4
                ,NULL AS rc6_a1
                ,NULL AS rc6_a2
                ,NULL AS rc6_a3
                ,NULL AS rc6_a4
                ,NULL AS rc6_c1
                ,NULL AS rc6_c2
                ,NULL AS rc6_c3
                ,NULL AS rc6_c4                
                ,NULL AS rc6_h4
                ,NULL AS rc6_p1
                ,NULL AS rc6_p2
                ,NULL AS rc6_p3
                ,NULL AS rc6_p4
                ,NULL AS rc7_a1
                ,NULL AS rc7_a2
                ,NULL AS rc7_a3
                ,NULL AS rc7_a4
                ,NULL AS rc7_c1
                ,NULL AS rc7_c2
                ,NULL AS rc7_c3
                ,NULL AS rc7_c4                
                ,NULL AS rc7_h4
                ,NULL AS rc7_p1
                ,NULL AS rc7_p2
                ,NULL AS rc7_p3
                ,NULL AS rc7_p4
                ,NULL AS rc8_a1
                ,NULL AS rc8_a2
                ,NULL AS rc8_a3
                ,NULL AS rc8_a4
                ,NULL AS rc8_c1
                ,NULL AS rc8_c2
                ,NULL AS rc8_c3
                ,NULL AS rc8_c4                
                ,NULL AS rc8_h4
                ,NULL AS rc8_p1
                ,NULL AS rc8_p2
                ,NULL AS rc8_p3
                ,NULL AS rc8_p4
                ,NULL AS rc9_a1
                ,NULL AS rc9_a2
                ,NULL AS rc9_a3
                ,NULL AS rc9_a4
                ,NULL AS rc9_c1
                ,NULL AS rc9_c2
                ,NULL AS rc9_c3
                ,NULL AS rc9_c4                
                ,NULL AS rc9_h1
                ,NULL AS rc9_h2
                ,NULL AS rc9_h3
                ,NULL AS rc9_h4
                ,NULL AS rc9_p1
                ,NULL AS rc9_p2
                ,NULL AS rc9_p3
                ,NULL AS rc9_p4
          FROM GRADES$wide_all#MS#static WITH(NOLOCK)

          UNION ALL

          SELECT student_number
                ,studentid
                ,schoolid
                ,rc1_h1
                ,rc1_h2
                ,rc1_h3
                ,NULL AS rc1_q1
                ,NULL AS rc1_q2
                ,NULL AS rc1_q3
                ,NULL AS rc1_s1
                ,NULL AS rc1_s2
                ,NULL AS rc1_s3
                ,rc2_h1
                ,rc2_h2
                ,rc2_h3
                ,NULL AS rc2_q1
                ,NULL AS rc2_q2
                ,NULL AS rc2_q3
                ,NULL AS rc2_s1
                ,NULL AS rc2_s2
                ,NULL AS rc2_s3
                ,rc3_h1
                ,rc3_h2
                ,rc3_h3
                ,NULL AS rc3_q1
                ,NULL AS rc3_q2
                ,NULL AS rc3_q3
                ,NULL AS rc3_s1
                ,NULL AS rc3_s2
                ,NULL AS rc3_s3
                ,rc4_h1
                ,rc4_h2
                ,rc4_h3
                ,NULL AS rc4_q1
                ,NULL AS rc4_q2
                ,NULL AS rc4_q3
                ,NULL AS rc4_s1
                ,NULL AS rc4_s2
                ,NULL AS rc4_s3
                ,rc5_h1
                ,rc5_h2
                ,rc5_h3
                ,NULL AS rc5_q1
                ,NULL AS rc5_q2
                ,NULL AS rc5_q3
                ,NULL AS rc5_s1
                ,NULL AS rc5_s2
                ,NULL AS rc5_s3
                ,rc6_h1
                ,rc6_h2
                ,rc6_h3
                ,NULL AS rc6_q1
                ,NULL AS rc6_q2
                ,NULL AS rc6_q3
                ,NULL AS rc6_s1
                ,NULL AS rc6_s2
                ,NULL AS rc6_s3
                ,rc7_h1
                ,rc7_h2
                ,rc7_h3
                ,NULL AS rc7_q1
                ,NULL AS rc7_q2
                ,NULL AS rc7_q3
                ,NULL AS rc7_s1
                ,NULL AS rc7_s2
                ,NULL AS rc7_s3
                ,rc8_h1
                ,rc8_h2
                ,rc8_h3
                ,NULL AS rc8_q1
                ,NULL AS rc8_q2
                ,NULL AS rc8_q3
                ,NULL AS rc8_s1
                ,NULL AS rc8_s2
                ,NULL AS rc8_s3
                ,rc1_a1
                ,rc1_a2
                ,rc1_a3
                ,rc1_a4
                ,rc1_c1
                ,rc1_c2
                ,rc1_c3
                ,rc1_c4                
                ,rc1_h4
                ,rc1_p1
                ,rc1_p2
                ,rc1_p3
                ,rc1_p4
                ,rc10_a1
                ,rc10_a2
                ,rc10_a3
                ,rc10_a4
                ,rc10_c1
                ,rc10_c2
                ,rc10_c3
                ,rc10_c4    
                ,rc10_h1
                ,rc10_h2
                ,rc10_h3            
                ,rc10_h4
                ,rc10_p1
                ,rc10_p2
                ,rc10_p3
                ,rc10_p4
                ,rc2_a1
                ,rc2_a2
                ,rc2_a3
                ,rc2_a4
                ,rc2_c1
                ,rc2_c2
                ,rc2_c3
                ,rc2_c4                
                ,rc2_h4
                ,rc2_p1
                ,rc2_p2
                ,rc2_p3
                ,rc2_p4
                ,rc3_a1
                ,rc3_a2
                ,rc3_a3
                ,rc3_a4
                ,rc3_c1
                ,rc3_c2
                ,rc3_c3
                ,rc3_c4                
                ,rc3_h4
                ,rc3_p1
                ,rc3_p2
                ,rc3_p3
                ,rc3_p4
                ,rc4_a1
                ,rc4_a2
                ,rc4_a3
                ,rc4_a4
                ,rc4_c1
                ,rc4_c2
                ,rc4_c3
                ,rc4_c4                
                ,rc4_h4
                ,rc4_p1
                ,rc4_p2
                ,rc4_p3
                ,rc4_p4
                ,rc5_a1
                ,rc5_a2
                ,rc5_a3
                ,rc5_a4
                ,rc5_c1
                ,rc5_c2
                ,rc5_c3
                ,rc5_c4                
                ,rc5_h4
                ,rc5_p1
                ,rc5_p2
                ,rc5_p3
                ,rc5_p4
                ,rc6_a1
                ,rc6_a2
                ,rc6_a3
                ,rc6_a4
                ,rc6_c1
                ,rc6_c2
                ,rc6_c3
                ,rc6_c4                
                ,rc6_h4
                ,rc6_p1
                ,rc6_p2
                ,rc6_p3
                ,rc6_p4
                ,rc7_a1
                ,rc7_a2
                ,rc7_a3
                ,rc7_a4
                ,rc7_c1
                ,rc7_c2
                ,rc7_c3
                ,rc7_c4                
                ,rc7_h4
                ,rc7_p1
                ,rc7_p2
                ,rc7_p3
                ,rc7_p4
                ,rc8_a1
                ,rc8_a2
                ,rc8_a3
                ,rc8_a4
                ,rc8_c1
                ,rc8_c2
                ,rc8_c3
                ,rc8_c4                
                ,rc8_h4
                ,rc8_p1
                ,rc8_p2
                ,rc8_p3
                ,rc8_p4
                ,rc9_a1
                ,rc9_a2
                ,rc9_a3
                ,rc9_a4
                ,rc9_c1
                ,rc9_c2
                ,rc9_c3
                ,rc9_c4                
                ,rc9_h1
                ,rc9_h2
                ,rc9_h3
                ,rc9_h4
                ,rc9_p1
                ,rc9_p2
                ,rc9_p3
                ,rc9_p4
          FROM GRADES$wide_all#NCA#static WITH(NOLOCK)
         ) sub

     UNPIVOT (
       grade
       FOR field IN (rc1_h1
                    ,rc1_h2
                    ,rc1_h3
                    ,rc1_q1
                    ,rc1_q2
                    ,rc1_q3
                    ,rc1_s1
                    ,rc1_s2
                    ,rc1_s3
                    ,rc2_h1
                    ,rc2_h2
                    ,rc2_h3
                    ,rc2_q1
                    ,rc2_q2
                    ,rc2_q3
                    ,rc2_s1
                    ,rc2_s2
                    ,rc2_s3
                    ,rc3_h1
                    ,rc3_h2
                    ,rc3_h3
                    ,rc3_q1
                    ,rc3_q2
                    ,rc3_q3
                    ,rc3_s1
                    ,rc3_s2
                    ,rc3_s3
                    ,rc4_h1
                    ,rc4_h2
                    ,rc4_h3
                    ,rc4_q1
                    ,rc4_q2
                    ,rc4_q3
                    ,rc4_s1
                    ,rc4_s2
                    ,rc4_s3
                    ,rc5_h1
                    ,rc5_h2
                    ,rc5_h3
                    ,rc5_q1
                    ,rc5_q2
                    ,rc5_q3
                    ,rc5_s1
                    ,rc5_s2
                    ,rc5_s3
                    ,rc6_h1
                    ,rc6_h2
                    ,rc6_h3
                    ,rc6_q1
                    ,rc6_q2
                    ,rc6_q3
                    ,rc6_s1
                    ,rc6_s2
                    ,rc6_s3
                    ,rc7_h1
                    ,rc7_h2
                    ,rc7_h3
                    ,rc7_q1
                    ,rc7_q2
                    ,rc7_q3
                    ,rc7_s1
                    ,rc7_s2
                    ,rc7_s3
                    ,rc8_h1
                    ,rc8_h2
                    ,rc8_h3
                    ,rc8_q1
                    ,rc8_q2
                    ,rc8_q3
                    ,rc8_s1
                    ,rc8_s2
                    ,rc8_s3
                    ,rc1_a1
                    ,rc1_a2
                    ,rc1_a3
                    ,rc1_a4
                    ,rc1_c1
                    ,rc1_c2
                    ,rc1_c3
                    ,rc1_c4                    
                    ,rc1_h4
                    ,rc1_p1
                    ,rc1_p2
                    ,rc1_p3
                    ,rc1_p4
                    ,rc10_a1
                    ,rc10_a2
                    ,rc10_a3
                    ,rc10_a4
                    ,rc10_c1
                    ,rc10_c2
                    ,rc10_c3
                    ,rc10_c4
                    ,rc10_h1
                    ,rc10_h2
                    ,rc10_h3
                    ,rc10_h4
                    ,rc10_p1
                    ,rc10_p2
                    ,rc10_p3
                    ,rc10_p4
                    ,rc2_a1
                    ,rc2_a2
                    ,rc2_a3
                    ,rc2_a4
                    ,rc2_c1
                    ,rc2_c2
                    ,rc2_c3
                    ,rc2_c4                    
                    ,rc2_h4
                    ,rc2_p1
                    ,rc2_p2
                    ,rc2_p3
                    ,rc2_p4
                    ,rc3_a1
                    ,rc3_a2
                    ,rc3_a3
                    ,rc3_a4
                    ,rc3_c1
                    ,rc3_c2
                    ,rc3_c3
                    ,rc3_c4                    
                    ,rc3_h4
                    ,rc3_p1
                    ,rc3_p2
                    ,rc3_p3
                    ,rc3_p4
                    ,rc4_a1
                    ,rc4_a2
                    ,rc4_a3
                    ,rc4_a4
                    ,rc4_c1
                    ,rc4_c2
                    ,rc4_c3
                    ,rc4_c4                    
                    ,rc4_h4
                    ,rc4_p1
                    ,rc4_p2
                    ,rc4_p3
                    ,rc4_p4
                    ,rc5_a1
                    ,rc5_a2
                    ,rc5_a3
                    ,rc5_a4
                    ,rc5_c1
                    ,rc5_c2
                    ,rc5_c3
                    ,rc5_c4                    
                    ,rc5_h4
                    ,rc5_p1
                    ,rc5_p2
                    ,rc5_p3
                    ,rc5_p4
                    ,rc6_a1
                    ,rc6_a2
                    ,rc6_a3
                    ,rc6_a4
                    ,rc6_c1
                    ,rc6_c2
                    ,rc6_c3
                    ,rc6_c4                    
                    ,rc6_h4
                    ,rc6_p1
                    ,rc6_p2
                    ,rc6_p3
                    ,rc6_p4
                    ,rc7_a1
                    ,rc7_a2
                    ,rc7_a3
                    ,rc7_a4
                    ,rc7_c1
                    ,rc7_c2
                    ,rc7_c3
                    ,rc7_c4                    
                    ,rc7_h4
                    ,rc7_p1
                    ,rc7_p2
                    ,rc7_p3
                    ,rc7_p4                    
                    ,rc8_a1
                    ,rc8_a2
                    ,rc8_a3
                    ,rc8_a4
                    ,rc8_c1
                    ,rc8_c2
                    ,rc8_c3
                    ,rc8_c4                    
                    ,rc8_h4
                    ,rc8_p1
                    ,rc8_p2
                    ,rc8_p3
                    ,rc8_p4
                    ,rc9_a1
                    ,rc9_a2
                    ,rc9_a3
                    ,rc9_a4
                    ,rc9_c1
                    ,rc9_c2
                    ,rc9_c3
                    ,rc9_c4
                    ,rc9_h1
                    ,rc9_h2
                    ,rc9_h3
                    ,rc9_h4
                    ,rc9_p1
                    ,rc9_p2
                    ,rc9_p3
                    ,rc9_p4)
       ) u
    ) sub
PIVOT (
  MAX(grade)
  FOR pivot_hash IN ([rc1_A]
                    ,[rc1_C]
                    ,[rc1_H]
                    ,[rc1_P]
                    ,[rc1_Q]
                    ,[rc1_S]
                    ,[rc2_A]
                    ,[rc2_C]
                    ,[rc2_H]
                    ,[rc2_P]
                    ,[rc2_Q]
                    ,[rc2_S]
                    ,[rc3_A]
                    ,[rc3_C]
                    ,[rc3_H]
                    ,[rc3_P]
                    ,[rc3_Q]
                    ,[rc3_S]
                    ,[rc4_A]
                    ,[rc4_C]
                    ,[rc4_H]
                    ,[rc4_P]
                    ,[rc4_Q]
                    ,[rc4_S]
                    ,[rc5_A]
                    ,[rc5_C]
                    ,[rc5_H]
                    ,[rc5_P]
                    ,[rc5_Q]
                    ,[rc5_S]
                    ,[rc6_A]
                    ,[rc6_C]
                    ,[rc6_H]
                    ,[rc6_P]
                    ,[rc6_S]
                    ,[rc6_Q]
                    ,[rc7_A]
                    ,[rc7_C]
                    ,[rc7_H]
                    ,[rc7_P]
                    ,[rc7_S]
                    ,[rc7_Q]
                    ,[rc8_A]
                    ,[rc8_C]
                    ,[rc8_H]
                    ,[rc8_P]
                    ,[rc8_S]
                    ,[rc8_Q]
                    ,[rc9_A]
                    ,[rc9_C]
                    ,[rc9_H]
                    ,[rc9_P]
                    ,[rc10_A]
                    ,[rc10_C]
                    ,[rc10_H]
                    ,[rc10_P])
 ) p
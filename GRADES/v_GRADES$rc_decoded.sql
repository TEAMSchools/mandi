USE KIPP_NJ
GO

ALTER VIEW GRADES$rc_decoded AS

SELECT studentid                 
      ,student_number
      ,LEFT(field, (CHARINDEX('_', field) - 1)) AS rc
      ,course_number
FROM
    (
     SELECT student_number
           ,studentid
           ,rc1_course_number                
           ,rc2_course_number
           ,rc3_course_number
           ,rc4_course_number
           ,rc5_course_number
           ,rc6_course_number
           ,rc7_course_number
           ,rc8_course_number
           ,rc9_course_number
           ,rc10_course_number
     FROM GRADES$wide_all#MS#static WITH(NOLOCK)

     UNION ALL

     SELECT student_number
           ,studentid
           ,rc1_course_number
           ,rc2_course_number
           ,rc3_course_number
           ,rc4_course_number
           ,rc5_course_number
           ,rc6_course_number
           ,rc7_course_number
           ,rc8_course_number
           ,rc9_course_number
           ,rc10_course_number
     FROM GRADES$wide_all#NCA#static WITH(NOLOCK)
    ) sub

UNPIVOT (
  course_number
  FOR field IN (rc1_course_number
               ,rc2_course_number
               ,rc3_course_number
               ,rc4_course_number
               ,rc5_course_number
               ,rc6_course_number
               ,rc7_course_number
               ,rc8_course_number
               ,rc9_course_number
               ,rc10_course_number)
  ) u
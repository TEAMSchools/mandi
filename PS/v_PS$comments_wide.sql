USE KIPP_NJ
GO

ALTER VIEW PS$comments_wide AS

SELECT studentid      
      ,term
      ,[rc1_comment]
      ,[rc2_comment]
      ,[rc3_comment]
      ,[rc4_comment]
      ,[rc5_comment]
      ,[rc6_comment]
      ,[rc7_comment]
      ,[rc8_comment]
      ,[rc9_comment]
      ,[rc10_comment]
      ,[advisor_comment]
FROM
    (
     SELECT comm.studentid           
           ,comm.term      
           --,ISNULL(rc.course_number, 'HR') AS course_number
           ,COALESCE(comm.teacher_comment, comm.advisor_comment) AS teacher_comment
           ,ISNULL(rc.rc, 'advisor') + '_comment' AS pivot_hash
     FROM PS$comments#static comm WITH(NOLOCK)
     LEFT OUTER JOIN GRADES$rc_decoded rc WITH(NOLOCK)
       ON comm.studentid = rc.studentid
      AND comm.course_number = rc.course_number
     ) sub
PIVOT(
  MAX(teacher_comment)
  FOR pivot_hash IN ([rc1_comment]
                    ,[rc2_comment]
                    ,[rc3_comment]
                    ,[rc4_comment]
                    ,[rc5_comment]
                    ,[rc6_comment]
                    ,[rc7_comment]
                    ,[rc8_comment]
                    ,[rc9_comment]
                    ,[rc10_comment]
                    ,[advisor_comment])
 ) p
USE KIPP_NJ
GO

ALTER VIEW QA$transfer_record_audit AS

WITH all_enrollments AS (
  SELECT STUDENTID
        ,academic_year
        ,SCHOOLID
        ,GRADE_LEVEL      
        ,EXITCODE
        ,LEAD(GRADE_LEVEL,1) OVER(PARTITION BY studentid ORDER BY academic_year) AS next_gradelevel
        ,LEAD(ENTRYDATE,1) OVER(PARTITION BY studentid ORDER BY academic_year) AS next_entrydate
        ,LEAD(EXITDATE,1) OVER(PARTITION BY studentid ORDER BY academic_year) AS next_exitdate
  FROM
      (
       SELECT STUDENTID
             ,KIPP_NJ.dbo.fn_DateToSY(ENTRYDATE) AS academic_year           
             ,SCHOOLID
             ,GRADE_LEVEL           
             ,ENTRYDATE
             ,EXITDATE
             ,EXITCODE           
       FROM KIPP_NJ..PS$REENROLLMENTS#static WITH(NOLOCK)
       UNION ALL
       SELECT id 
             ,KIPP_NJ.dbo.fn_DateToSY(ENTRYDATE) + 1 AS academic_year           
             ,SCHOOLID
             ,GRADE_LEVEL           
             ,ENTRYDATE
             ,EXITDATE
             ,EXITCODE
       FROM KIPP_NJ..PS$STUDENTS#static WITH(NOLOCK)
      ) sub
 )  

SELECT s.STUDENT_NUMBER
      ,s.LASTFIRST
      ,s.ENROLL_STATUS
      ,t.*
      ,'Promoted Next School - No Show' AS audit_type
FROM all_enrollments t
JOIN KIPP_NJ..PS$STUDENTS#static s
  ON t.STUDENTID = s.id
WHERE t.next_gradelevel != 99
  AND t.EXITCODE != 'G1'
  AND t.next_gradelevel > t.GRADE_LEVEL
  AND t.next_exitdate <= next_entrydate
  AND t.GRADE_LEVEL IN (4,8)
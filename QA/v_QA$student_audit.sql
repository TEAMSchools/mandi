USE KIPP_NJ
GO

ALTER VIEW QA$student_audit AS

WITH dupe_enrollments AS (
  SELECT STUDENTID
        ,KIPP_NJ.dbo.GROUP_CONCAT_D(dupe_enrollments, CHAR(13) + CHAR(10)) AS dupe_enrollments
  FROM
      (
       SELECT STUDENTID
             ,CONCAT(COURSE_NUMBER, ' (', KIPP_NJ.dbo.GROUP_CONCAT_D(SECTION_NUMBER, ', '), ')') AS dupe_enrollments
       FROM
           (
            SELECT STUDENTID
                  ,COURSE_NUMBER
                  ,SECTION_NUMBER
                  ,COUNT(sectionid) OVER(PARTITION BY studentid, course_number) AS N_enrollments
            FROM KIPP_NJ..PS$CC#static cc WITH(NOLOCK)
            WHERE cc.academic_year = KIPP_NJ.dbo.fn_Global_Academic_Year()
              AND cc.sectionid > 0
              AND CONVERT(DATE,GETDATE()) BETWEEN DATEENROLLED AND DATELEFT       
           ) sub
       WHERE N_enrollments > 1
       GROUP BY STUDENTID, COURSE_NUMBER
      ) sub
  GROUP BY STUDENTID
 )

,fte AS (
  SELECT SCHOOLID
        ,KIPP_NJ.dbo.GROUP_CONCAT_D(ID, ';') AS fte_id
  FROM KIPP_NJ..PS$FTE#static WITH(NOLOCK)
  WHERE academic_year = KIPP_NJ.dbo.fn_Global_Academic_Year()
  GROUP BY SCHOOLID
 )

SELECT co.student_number
      ,co.LASTFIRST
      ,co.GRADE_LEVEL
      ,co.SCHOOLID
      ,co.enroll_status      
      
      ,'Valid Ethnicity' AS audit      
      ,co.ETHNICITY AS audit_data      
FROM KIPP_NJ..PS$STUDENTS#static co WITH(NOLOCK)
WHERE (co.ETHNICITY IS NULL OR co.ETHNICITY NOT IN ('T','W','H','A','B','I','P'))

UNION ALL

SELECT co.student_number
      ,co.LASTFIRST
      ,co.GRADE_LEVEL
      ,co.SCHOOLID
      ,co.enroll_status      
      
      ,'Valid Gender' AS audit      
      ,co.gender AS audit_data      
FROM KIPP_NJ..PS$STUDENTS#static co WITH(NOLOCK)
WHERE (co.gender IS NULL OR co.GENDER NOT IN ('M','F'))

UNION ALL

SELECT co.student_number
      ,co.LASTFIRST
      ,co.GRADE_LEVEL
      ,co.SCHOOLID
      ,co.enroll_status      
      
      ,'Valid SID' AS audit      
      ,CONVERT(VARCHAR,co.STATE_STUDENTNUMBER) AS audit_data      
FROM KIPP_NJ..PS$STUDENTS#static co WITH(NOLOCK)
WHERE (co.STATE_STUDENTNUMBER IS NULL OR LEN(co.STATE_STUDENTNUMBER) < 10)

UNION ALL

SELECT s.student_number
      ,s.LASTFIRST
      ,s.GRADE_LEVEL
      ,s.SCHOOLID
      ,s.enroll_status      
      
      ,'Valid Enrollment Schoolid' AS audit      
      ,CONVERT(VARCHAR,s.enrollment_schoolid) AS audit_data
FROM KIPP_NJ..PS$STUDENTS#static s WITH(NOLOCK)
WHERE s.enroll_status != 3
  AND s.enrollment_schoolid != s.schoolid

UNION ALL

SELECT s.student_number
      ,s.LASTFIRST
      ,s.GRADE_LEVEL
      ,s.SCHOOLID
      ,s.enroll_status      
      
      ,'Valid Entry/Exit Dates' AS audit      
      ,CONCAT(CONVERT(VARCHAR,s.entrydate,101), ' - ', CONVERT(VARCHAR,s.exitdate,101)) AS audit_data
      
      --,hr.sectionid AS hr_sectionid -- NOT NULL      
      --,dupe.dupe_enrollments -- IS NULL      
      --,s.fteid, fte.fte_id AS school_fteid /* IS NOT NULL & LIKE school fteid if enrolled */      
FROM KIPP_NJ..PS$STUDENTS#static s WITH(NOLOCK)
WHERE s.entrydate > s.exitdate
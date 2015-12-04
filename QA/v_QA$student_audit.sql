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
              AND CONVERT(DATE,CONCAT(KIPP_NJ.dbo.fn_Global_Academic_Year(),'-06-01')) BETWEEN DATEENROLLED AND DATELEFT       
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

SELECT co.year
      ,co.student_number
      ,co.LASTFIRST
      ,co.GRADE_LEVEL
      ,co.SCHOOLID
      ,co.enroll_status
      ,co.exitcode
      ,co.highest_achieved
      ,co.lunchstatus -- F, R, P
      ,co.ethnicity -- 'T','W','H','A','B','I','P'
      ,co.gender -- 'M', 'F'
      ,co.spedlep -- 'No IEP', 'SPED', 'SPED SPEECH'
      ,s.state_studentnumber -- NOT NULL
      ,co.TEAM -- NOT NULL
      ,hr.sectionid AS hr_sectionid -- NOT NULL      
      ,dupe.dupe_enrollments -- IS NULL
      /* IS NOT NULL & LIKE school fteid if enrolled */
      ,s.fteid
      ,fte.fte_id AS school_fteid      
      
      ,s.allowwebaccess -- = 1 
      ,s.student_allowwebaccess -- = 1
      ,s.web_id -- IS NOT NULL
      ,s.student_web_id -- IS NOT NULL
      ,s.enrollment_schoolid -- = schoolid (unless graduated)
      /* ENTRYDATE > EXITDATE */
      ,co.ENTRYDATE
      ,co.EXITDATE            
FROM KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK)
JOIN KIPP_NJ..PS$STUDENTS#static s WITH(NOLOCK)
  ON co.studentid = s.id
LEFT OUTER JOIN KIPP_NJ..PS$CC#static hr WITH(NOLOCK)
  ON s.id = hr.STUDENTID
 AND co.year = hr.academic_year
	AND CONVERT(DATE,GETDATE()) BETWEEN hr.dateenrolled AND hr.dateleft
	AND hr.COURSE_NUMBER = 'HR'
LEFT OUTER JOIN dupe_enrollments dupe
  ON s.id = dupe.STUDENTID
LEFT OUTER JOIN fte WITH(NOLOCK)
  ON s.SCHOOLID = fte.SCHOOLID
WHERE co.rn = 1
USE KIPP_NJ
GO

--ALTER VIEW QA$data_audit AS

--Added by AM2 on 9/10/2013
--testing to see if there are any *currently enrolled* students w/o a HR active on today's date.
SELECT 'HR audit' AS audit_type
      ,sub_2.assertion + ' | ' + sub_2.elements AS 'result'
FROM
     (SELECT sub.assertion
            ,COUNT(*) AS N
            ,dbo.GROUP_CONCAT(hash) AS elements
             --there I fixed it
            ,ROW_NUMBER() OVER(ORDER BY sub.assertion ASC) AS Row
      FROM
	           (SELECT s.id
		                 ,s.lastfirst
		                 ,s.first_name + ' ' + s.last_name + ' (' + sch.abbreviation + ')' AS hash
		                 ,sch.abbreviation AS school
		                 ,enr.course_number
		                 ,CASE 
		                    WHEN enr.course_number IS NULL THEN 'Fail'
		                    ELSE 'Pass'
		                  END AS assertion
	           FROM KIPP_NJ..STUDENTS s
	           JOIN KIPP_NJ..SCHOOLS sch
	             ON s.schoolid = sch.school_number
	           LEFT OUTER JOIN 
	               (SELECT cc.studentid
			                    ,cc.course_number
	                FROM KIPP_NJ..CC
	                WHERE cc.termid >= 2300
	                  AND cc.dateenrolled < GETDATE()
	                  AND cc.dateleft > GETDATE()
	                  AND cc.COURSE_NUMBER = 'HR'
	               ) enr
	             ON s.id = enr.studentid
	           WHERE s.enroll_status = 0
	           ) sub
      GROUP BY sub.assertion
      ) sub_2
WHERE row = 1

UNION ALL

SELECT 'example_audit' AS audit_type
      ,'Pass' AS result


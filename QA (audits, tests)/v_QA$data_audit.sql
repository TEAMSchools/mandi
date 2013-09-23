USE KIPP_NJ
GO

ALTER VIEW QA$data_audit AS


SELECT '>>DEMOGRAPHIC AUDITS<<' AS audit_type
      ,NULL AS result

UNION ALL 

--Added by AM2 on 9/23/2013
--Any FARM status not in P, R, F?
SELECT 'FARM data quality' AS audit_type
      ,sub_2.assertion + ' | ' + CASE WHEN sub_2.N < 50 THEN sub_2.elements ELSE '50+ students' END AS result
FROM
     (SELECT sub_1.assertion
            ,COUNT(*) AS N
            ,dbo.GROUP_CONCAT(sub_1.hash) AS elements
             --there I fixed it
            ,ROW_NUMBER() OVER(ORDER BY sub_1.assertion ASC) AS rn
      FROM
            (SELECT s.first_name + ' ' + s.last_name + ' (' + sch.abbreviation + ')' AS hash
                   ,CASE 
                      WHEN s.lunchstatus IN ('F', 'P', 'R') THEN 'Pass'
                      ELSE 'Fail'
                    END AS assertion
             FROM KIPP_NJ..STUDENTS s
             JOIN KIPP_NJ..SCHOOLS sch
               ON s.schoolid = sch.school_number
             WHERE s.enroll_status = 0
             ) sub_1
      GROUP BY sub_1.assertion
      ) sub_2
WHERE rn = 1

--Added by AM2 on 9/10/2013
--testing to see if there are any *currently enrolled* students w/o a HR active on today's date.
UNION ALL

SELECT 'HR audit' AS audit_type
      ,sub_2.assertion + ' | ' + CASE WHEN sub_2.N < 50 THEN sub_2.elements ELSE '50+ students' END AS result
FROM
     (SELECT sub.assertion
            ,COUNT(*) AS N
            ,dbo.GROUP_CONCAT(hash) AS elements
             --there I fixed it
            ,ROW_NUMBER() OVER(ORDER BY sub.assertion ASC) AS rn
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
WHERE rn = 1

--UNION ALL


USE KIPP_NJ
GO

--ALTER VIEW QA$data_audit AS

--Added by AM2 on 9/23/2013
--Any FARM status not in P, R, F?
SELECT 'Demographic' AS audit_category
      ,'FARM data quality' AS audit_type
      ,sub_2.assertion + ' (n=' + CAST(sub_2.n AS NVARCHAR) + ')' + ' | ' +
         CASE 
           WHEN sub_2.assertion = 'Pass' THEN ''
           WHEN sub_2.N < 50 THEN sub_2.elements 
           ELSE '50+ students' 
         END AS result
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

UNION ALL

--Added by AM2 on 9/23/2013
--Any students with ethnicities?
SELECT 'Demographic' AS audit_category
      ,'Missing Ethnicities' AS audit_type
      ,sub_2.assertion + ' (n=' + CAST(sub_2.n AS NVARCHAR) + ')' + ' | ' +
         CASE 
           WHEN sub_2.assertion = 'Pass' THEN ''
           WHEN sub_2.N < 50 THEN sub_2.elements 
           ELSE '50+ students' 
         END AS result
FROM
     (SELECT sub_1.assertion
            ,COUNT(*) AS N
            ,dbo.GROUP_CONCAT(sub_1.hash) AS elements
             --there I fixed it
            ,ROW_NUMBER() OVER(ORDER BY sub_1.assertion ASC) AS rn
      FROM
            (SELECT s.first_name + ' ' + s.last_name + ' (' + sch.abbreviation + ')' AS hash
                   ,CASE 
                      WHEN s.ethnicity IN ('T','W','H','A','B','I') THEN 'Pass'
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

UNION ALL

--Added by AM2 on 9/23/2013
--Any Gender status not in M, F?
SELECT 'Demographic' AS audit_category
      ,'Gender data quality' AS audit_type
      ,sub_2.assertion + ' (n=' + CAST(sub_2.n AS NVARCHAR) + ')' + ' | ' +
         CASE 
           WHEN sub_2.assertion = 'Pass' THEN ''
           WHEN sub_2.N < 50 THEN sub_2.elements 
           ELSE '50+ students' 
         END AS result
FROM
     (SELECT sub_1.assertion
            ,COUNT(*) AS N
            ,dbo.GROUP_CONCAT(sub_1.hash) AS elements
            ,ROW_NUMBER() OVER(ORDER BY sub_1.assertion ASC) AS rn
      FROM
            (SELECT s.first_name + ' ' + s.last_name + ' (' + sch.abbreviation + ')' AS hash
                   ,CASE 
                      WHEN s.gender IN ('M', 'F') THEN 'Pass'
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

UNION ALL

--Added by AM2 on 9/23/2013
--Any SPED status not in ?
SELECT 'Demographic' AS audit_category
      ,'IEP determination data quality' AS audit_type
      ,sub_2.assertion + ' (n=' + CAST(sub_2.n AS NVARCHAR) + ')' + ' | ' +
         CASE 
           WHEN sub_2.assertion = 'Pass' THEN ''
           WHEN sub_2.N < 50 THEN sub_2.elements 
           ELSE '50+ students' 
         END AS result
FROM
     (SELECT sub_1.assertion
            ,COUNT(*) AS N
            ,dbo.GROUP_CONCAT(sub_1.hash) AS elements
            ,ROW_NUMBER() OVER(ORDER BY sub_1.assertion ASC) AS rn
      FROM
            (SELECT s.first_name + ' ' + s.last_name + ' (' + sch.abbreviation + ')' AS hash
                   ,CASE 
                      WHEN cust.spedlep IN ('No IEP', 'SPED', 'SPED SPEECH') THEN 'Pass'
                      ELSE 'Fail'
                    END AS assertion
             FROM KIPP_NJ..STUDENTS s
             JOIN KIPP_NJ..SCHOOLS sch
               ON s.schoolid = sch.school_number
             JOIN KIPP_NJ..PS$CUSTOM_STUDENTS cust
               ON s.id = cust.studentid
             WHERE s.enroll_status = 0
             ) sub_1
      GROUP BY sub_1.assertion
      ) sub_2
WHERE rn = 1

UNION ALL

--Added by AM2 on 9/23/2013
--Any students with missing state IDs?
SELECT 'Demographic' AS audit_category
      ,'Missing State Student IDs' AS audit_type
      ,sub_2.assertion + ' (n=' + CAST(sub_2.n AS NVARCHAR) + ')' + ' | ' +
         CASE 
           WHEN sub_2.assertion = 'Pass' THEN ''
           WHEN sub_2.N < 50 THEN sub_2.elements 
           ELSE '50+ students' 
         END AS result
FROM
     (SELECT sub_1.assertion
            ,COUNT(*) AS N
            ,dbo.GROUP_CONCAT(sub_1.hash) AS elements
             --there I fixed it
            ,ROW_NUMBER() OVER(ORDER BY sub_1.assertion ASC) AS rn
      FROM
            (SELECT s.first_name + ' ' + s.last_name + ' (' + sch.abbreviation + ')' AS hash
                   ,CASE 
                      WHEN s.state_studentnumber IS NOT NULL THEN 'Pass'
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

UNION ALL

SELECT 'PS Config' AS audit_category
      ,'HR audit' AS audit_type
      ,sub_2.assertion + ' (n=' + CAST(sub_2.n AS NVARCHAR) + ')' + ' | ' +
         CASE 
           WHEN sub_2.assertion = 'Pass' THEN ''
           WHEN sub_2.N < 50 THEN sub_2.elements 
           ELSE '50+ students' 
         END AS result
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

UNION ALL

--Added by AM2 on 9/24/2013
--Any students with double enrollments in the same course?
SELECT 'PS Config' AS audit_category
      ,'Same Student / Course Cur Enrollments' AS audit_type
      ,sub_3.assertion + ' (n=' + CAST(sub_3.n AS NVARCHAR) + ')' + ' | ' +
         CASE 
           WHEN sub_3.assertion = 'Pass' THEN ''
           WHEN sub_3.N < 50 THEN sub_3.elements 
           ELSE '50+ students' 
         END AS result
FROM
      (SELECT sub_2.assertion
             ,COUNT(*) AS N
             ,dbo.GROUP_CONCAT(sub_2.hash) AS elements
             ,ROW_NUMBER() OVER(ORDER BY sub_2.assertion ASC) AS rn
       FROM
             (SELECT sub_1.*
                    ,sub_1.name + ' (' + sub_1.school + ')|' + sub_1.course_number AS hash
                    ,CASE
                       WHEN sub_1.n = 1 THEN 'Pass'
                       WHEN sub_1.n > 1 THEN 'Fail'
                     END AS assertion
              FROM
                    (SELECT s.id AS studentid
                           ,s.first_name + ' ' + s.last_name AS name
                           ,sch.abbreviation AS school
                           ,sect.course_number
                           ,COUNT(*) AS N
                     FROM KIPP_NJ..STUDENTS s
                     JOIN KIPP_NJ..CC
                       ON s.id = cc.studentid
                      --exclude dropped classes
                      AND cc.sectionid > 0
                      AND cc.termid >= 2300
                      --has already started
                      AND DATEDIFF(day, cc.dateenrolled, CURRENT_TIMESTAMP) >= 0
                      --isn't in future
                      AND DATEDIFF(day, CURRENT_TIMESTAMP, cc.dateleft) >= 0
                     JOIN KIPP_NJ..SECTIONS sect
                       ON cc.sectionid = sect.id
                     JOIN KIPP_NJ..SCHOOLS sch
                       ON s.schoolid = sch.school_number
                     WHERE s.enroll_status = 0
                     GROUP BY s.id
                             ,sch.abbreviation
                             ,s.first_name + ' ' + s.last_name
                             ,sect.course_number
                     ) sub_1
              ) sub_2
       GROUP BY sub_2.assertion
       ) sub_3
WHERE rn = 1

UNION ALL

--Added by AM2 on 9/23/2013
--Any students with missing FTE IDs?
SELECT 'PS Config' AS audit_category
      ,'Missing FTE IDs' AS audit_type
      ,sub_2.assertion + ' (n=' + CAST(sub_2.n AS NVARCHAR) + ')' + ' | ' +
         CASE 
           WHEN sub_2.assertion = 'Pass' THEN ''
           WHEN sub_2.N < 50 THEN sub_2.elements 
           ELSE '50+ students' 
         END AS result
FROM
     (SELECT sub_1.assertion
            ,COUNT(*) AS N
            ,dbo.GROUP_CONCAT(sub_1.hash) AS elements
            ,ROW_NUMBER() OVER(ORDER BY sub_1.assertion ASC) AS rn
      FROM
            (SELECT s.first_name + ' ' + s.last_name + ' (' + sch.abbreviation + ')' AS hash
                   ,CASE 
                      WHEN s.fteid IS NOT NULL THEN 'Pass'
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

UNION ALL

--Added by AM2 on 9/23/2013
--Any students with missing web IDs?
SELECT 'PS Config' AS audit_category
      ,'Student/parent web accounts issues' AS audit_type
      ,sub_2.assertion + ' (n=' + CAST(sub_2.n AS NVARCHAR) + ')' + ' | ' +
         CASE 
           WHEN sub_2.assertion = 'Pass' THEN ''
           WHEN sub_2.N < 50 THEN sub_2.elements 
           ELSE '50+ students' 
         END AS result
FROM
     (SELECT sub_1.assertion
            ,COUNT(*) AS N
            ,dbo.GROUP_CONCAT(sub_1.hash) AS elements
            ,ROW_NUMBER() OVER(ORDER BY sub_1.assertion ASC) AS rn
      FROM
            (SELECT s.first_name + ' ' + s.last_name + ' (' + sch.abbreviation + ')' AS hash
                   ,CASE 
                      WHEN s.allowwebaccess = 0 OR s.student_allowwebaccess = 0 THEN 'Fail'
                      WHEN s.web_id IS NOT NULL OR s.student_web_id IS NOT NULL THEN 'Pass'
                      WHEN s.web_id IS NULL OR s.student_web_id IS NULL THEN 'Fail'
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

SELECT 'Data Integration' AS audit_category
      ,'Ren Learn auto-import' AS audit_type
      ,CASE
         WHEN AR_freshness > 23 THEN 'Fail (' + CAST(AR_freshness AS NVARCHAR) + ' hours old)'
         WHEN AR_freshness <= 23 THEN 'Pass (' + CAST(AR_freshness AS NVARCHAR) + ' hours old)'
       END AS result
FROM
      (SELECT DateDiff(hour, MAX(import_time), CURRENT_TIMESTAMP) AS AR_freshness      
       FROM [RM9-DSCHEDULER\SQLEXPRESS].[RL_IMPORT_LOG].[dbo].[IMPORT_LOG]
       ) sub

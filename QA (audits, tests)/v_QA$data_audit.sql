USE KIPP_NJ
GO

ALTER VIEW QA$data_audit AS

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
             JOIN KIPP_NJ..CUSTOM_STUDENTS cust
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
--Removed 'STUDY10' and 'HR' since there are current practices with double enrollments in those courses
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
                      AND cc.course_number  NOT IN ('HR','STUDY10')
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

UNION ALL

--Added by AM2 on 10/21/2013
--are there any illuminate assessments in the next two weeks with a problematic created on / administered on date.
  --Modified by CB on 11/07/2013
  --grade1 = grade_level, description = test_descr, no deleted_tests

SELECT 'Illuminate' AS audit_category
      ,'Date administered errors' AS audit_type
      ,sub.assertion + ' (n=' + CAST(sub.n AS NVARCHAR) + ')' + ' | ' +
         CASE 
           WHEN sub.assertion = 'Pass' THEN ''
           WHEN sub.N < 50 THEN sub.elements 
           ELSE '50+ assessments' 
         END AS result
FROM 
      (SELECT sub.assertion
             ,COUNT(*) AS N
             ,dbo.GROUP_CONCAT_D(sub.hash, ' | ') AS elements
             ,ROW_NUMBER() OVER
               (ORDER BY sub.assertion) AS rn
       FROM
             (SELECT illu.title
                    ,illu.tags
                    ,illu.user_id
                    ,staff_decode.staff_name
                    ,staff_decode.school
                    ,illu.grade_level AS grade_lev        
                    ,illu.created_at
                    ,illu.administered_at
                    ,illu.assertion
                    ,staff_decode.school + ': ' + CAST(illu.grade_level AS VARCHAR) + ' ' + staff_decode.staff_name + ' (' + illu.title + ' | ' + illu.tags + ' ' + CAST(illu.created_at AS VARCHAR)+ '/' + CAST(illu.administered_at AS VARCHAR) +')' AS hash
              FROM
                    (SELECT [assessment_id]
                           ,[title]
                           ,[test_descr]
                           ,[user_id]
                           ,CAST([created_at] AS DATE) AS created_at
                           ,[updated_at]
                           ,[administered_at]
                           ,[tags]
                           ,[subject]
                           ,[scope]
                           ,[grade_level]
                           ,CASE
                              --created at should probably not equal administered at
                              WHEN CAST(asmt.created_at AS DATE) = asmt.administered_at THEN 'Fail'
                              ELSE 'Pass'
                            END AS assertion
                       FROM [KIPP_NJ].[dbo].[ILLUMINATE$assessments#static] asmt
                       WHERE asmt.tags LIKE '%FSA%'
                       --exclude deleted FSAs
                       --AND deleted_at IS NULL
                       --if it's older than 2 weeks, whatever
                       AND DATEDIFF(day, GETDATE(), CAST(asmt.administered_at AS DATE)) > -14
                       --if it was updated 2 + days after administration, probably stef or someone looked at it and it is OK
                       AND DATEDIFF(day, administered_at, CAST(asmt.updated_at AS DATE)) < 2
                     ) illu
              LEFT OUTER JOIN 
                  (SELECT oq.user_id AS illu_id
                          ,oq.first_name
                          ,oq.last_name
                          ,oq.first_name + ' ' + oq.last_name AS staff_name
                          ,oq.local_user_id
                          ,oq.username
                          ,oq.active
                          ,sch.abbreviation AS school
                    FROM OPENQUERY(ILLUMINATE,'
                            SELECT u.*
                            FROM public.users u
                            ') oq
                    LEFT OUTER JOIN KIPP_NJ..TEACHERS tch
                      ON oq.local_user_id = CAST(tch.id AS VARCHAR)
                    LEFT OUTER JOIN KIPP_NJ..SCHOOLS sch
                      ON tch.schoolid = sch.school_number
                    WHERE oq.active = 1)
                staff_decode
                ON CAST(illu.user_id AS VARCHAR) = CAST(staff_decode.illu_id AS VARCHAR)
              ) sub
       GROUP BY sub.assertion
       ) sub
WHERE rn = 1

UNION ALL

--Added by AM2 on 10/22/2013
--all views on KIPP_NJ should be tagged static cache/no static cache.
SELECT 'Data Warehouse Config' AS audit_category
      ,'Views lacking static/nonstatic tags' AS audit_type
      ,sub.assertion + ' (n=' + CAST(sub.n AS NVARCHAR) + ')' + ' | ' +
         CASE 
           WHEN sub.assertion = 'Pass' THEN ''
           WHEN sub.N < 50 THEN sub.elements 
           ELSE '50+ assessments' 
         END AS result
FROM      
      (SELECT sub.assertion
             ,COUNT(*) AS N
             ,dbo.GROUP_CONCAT_D(sub.name, '|') AS elements
             ,ROW_NUMBER() OVER
               (ORDER BY sub.assertion) AS rn
       FROM
            (SELECT views.name
                   ,props.name AS prop_name
                   ,props.value AS prop_value
                   ,CASE
                      WHEN props.name IS NOT NULL THEN 'Pass'
                      WHEN props.name IS NULL THEN 'Fail'
                    END AS assertion
              FROM KIPP_NJ.sys.views views
              LEFT OUTER JOIN KIPP_NJ.sys.extended_properties props
                ON views.object_id = props.major_id
               AND props.name IN ('has_static_cache')
              WHERE is_ms_shipped=0 
            ) sub
       GROUP BY sub.assertion
       ) sub
WHERE rn = 1

UNION ALL

--Added by AM2 on 10/22/2013
--are there any illuminate assessments that don't have three tags?
  --Modified by CB on 11/07/2013
  --grade1 = grade_level, description = test_descr, no deleted_tests

SELECT 'Illuminate' AS audit_category
      ,'Tag count' AS audit_type
      ,sub.assertion + ' (n=' + CAST(sub.n AS NVARCHAR) + ')' + ' | ' +
         CASE 
           WHEN sub.assertion = 'Pass' THEN ''
           WHEN sub.N < 50 THEN sub.elements 
           ELSE '50+ FSAs' 
         END AS result
FROM 
      (SELECT sub.assertion
             ,COUNT(*) AS N
             ,dbo.GROUP_CONCAT_D(sub.hash, ' | ') AS elements
             ,ROW_NUMBER() OVER
               (ORDER BY sub.assertion) AS rn
       FROM
             (SELECT illu.title
                    ,illu.tags
                    ,illu.user_id
                    ,staff_decode.staff_name
                    ,staff_decode.school
                    ,illu.grade_level AS grade_lev        
                    ,illu.created_at
                    ,illu.administered_at
                    ,illu.assertion
                    ,staff_decode.school + ': ' + CAST(illu.grade_level AS VARCHAR) + ' ' + staff_decode.staff_name + ' (' + illu.title + ' | ' + illu.tags + ' ' + CAST(illu.created_at AS VARCHAR)+ '/' + CAST(illu.administered_at AS VARCHAR) +')' AS hash
              FROM
                    (SELECT [assessment_id]
                           ,[title]
                           ,[test_descr]
                           ,[user_id]
                           ,CAST([created_at] AS DATE) AS created_at
                           ,[updated_at]
                           ,[administered_at]
                           ,[tags]
                           ,[subject]
                           ,[scope]
                           ,[grade_level]
                           ,CASE
                              --tags should have three or more items (ie two commas)
                              WHEN len(asmt.tags) - len(replace(asmt.tags,',','')) >= 2 THEN 'Pass'
                              ELSE 'Fail'
                            END AS assertion
                       FROM [KIPP_NJ].[dbo].[ILLUMINATE$assessments#static] asmt
                       WHERE asmt.tags LIKE '%FSA%'
                       --exclude deleted FSAs
                       --AND deleted_at IS NULL
                       --if it's older than 2 weeks, whatever
                       AND DATEDIFF(day, GETDATE(), CAST(asmt.administered_at AS DATE)) > -14
                       --if it was updated 2 + days after administration, probably stef or someone looked at it and it is OK
                       AND DATEDIFF(day, administered_at, CAST(asmt.updated_at AS DATE)) < 2
                     ) illu
              LEFT OUTER JOIN 
                  (SELECT oq.user_id AS illu_id
                          ,oq.first_name
                          ,oq.last_name
                          ,oq.first_name + ' ' + oq.last_name AS staff_name
                          ,oq.local_user_id
                          ,oq.username
                          ,oq.active
                          ,sch.abbreviation AS school
                    FROM OPENQUERY(ILLUMINATE,'
                            SELECT u.*
                            FROM public.users u
                            ') oq
                    LEFT OUTER JOIN KIPP_NJ..TEACHERS tch
                      ON oq.local_user_id = CAST(tch.id AS VARCHAR)
                    LEFT OUTER JOIN KIPP_NJ..SCHOOLS sch
                      ON tch.schoolid = sch.school_number
                    WHERE oq.active = 1)
                staff_decode
                ON CAST(illu.user_id AS VARCHAR) = CAST(staff_decode.illu_id AS VARCHAR)
              ) sub
       GROUP BY sub.assertion
       ) sub
WHERE rn = 1

--Added by AM2 on 11/03/2013
--Do FASTT Math logins work?
UNION ALL

SELECT 'Student Account' AS audit_category
      ,'FASTT Math' AS audit_type
      ,sub.assertion + ' (n=' + CAST(sub.n AS NVARCHAR) + ')' + ' | ' +
         CASE 
           WHEN sub.assertion = 'Pass' THEN ''
           WHEN sub.N < 50 THEN sub.elements 
           ELSE '50+ students' 
         END AS result
FROM
      (SELECT sub.assertion
             ,dbo.GROUP_CONCAT(sub.hash) AS elements  
             ,COUNT(*) AS N
             ,ROW_NUMBER() OVER(ORDER BY sub.assertion ASC) AS rn
       FROM
             (SELECT SUBSTRING(s.first_name, 1, 1) + '. ' + s.last_name + ' [' + tests.outcome + ']' hash
                    ,CASE 
                       WHEN tests.outcome LIKE 'FAILED%' THEN 'Fail'
                       WHEN tests.outcome = 'PASSED' THEN 'Pass'
                     END AS assertion 
              FROM KIPP_NJ..STUDENTS s
             LEFT OUTER JOIN 
               (SELECT tests.*
                FROM KIPP_NJ..[QA$student_login_tests] tests
                WHERE tests.product = 'FASTT Math'
                AND CAST(tests.tested_on AS DATE) = CAST(GETDATE() AS DATE)
               ) tests
              ON s.id = tests.studentid
              WHERE s.schoolid = 73254
                AND s.enroll_status = 0
                AND s.grade_level > 0
              ) sub
       WHERE sub.assertion IS NOT NULL
       GROUP BY sub.assertion
       ) sub
WHERE rn = 1

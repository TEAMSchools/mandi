/*
NJSMART COURSE SUBMISSION MONSTER QUERY
MS & HS Y1 GRADES, TEACHERS AND PS$SECTIONS#static
ES PLACEHOLDER PS$COURSES#static FOR MATH AND ELA WITH PASS/FAIL BASED ON EOY STATUS
MISSING DATA TO BE INDEX MATCHED
       STAFF SMIDS
       COURSE MAPPINGS TO NJSMART
       CHANGE gradespan = 0000 to KGKG

MAINTENANCE NEEDED: CHANGE ALL TERMS

LAST UPDATE 2015-07-29
*/

USE KIPP_NJ
GO

ALTER VIEW COMPLIANCE$NJSMART_course_submission AS

WITH section_long AS ( --PS$SECTIONS#static & teachers all terms
       SELECT CAST(sec.id AS VARCHAR(20)) as LocalSectionCode
                ,sec.course_number
                ,t.id
                ,t.TEACHERNUMBER
                ,t.lastfirst
                ,t.last_name
                ,t.first_name
       FROM PS$SECTIONS#static sec WITH(NOLOCK)
       JOIN PS$TEACHERS#static t WITH(NOLOCK)
         ON sec.teacher = t.id
       WHERE sec.termid >= 2400
)

,teacher_distinct AS ( --roster of teachers and sectionid for teacher match to student roster
       SELECT DISTINCT
              sec.course_number
          ,c.course_name
          ,sec.schoolid
          ,c.credit_hours
          ,c.credittype
       FROM PS$SECTIONS#static sec WITH(NOLOCK)
       JOIN PS$COURSES#static c WITH(NOLOCK)
         ON sec.COURSE_NUMBER = c.COURSE_NUMBER
       WHERE sec.termid >= 2400
         AND c.COURSE_NUMBER NOT IN ('HR','Adv')
)

,grades_ms AS (-- MS Student Data & Y1 Grades
       SELECT 
        CAST(s.STUDENT_NUMBER AS VARCHAR(20)) 
              + '_' 
              + CAST(grades.course_number AS VARCHAR(20)) 
              + '_' 
              + CAST(COALESCE (grades.T3_ENR_SECTIONID
                       ,grades.T2_ENR_SECTIONID
                       ,grades.T1_ENR_SECTIONID
                       ) AS VARCHAR(20)) 
        AS x_hash
       ,cohort.grade_level as x_grade_level
       ,s.student_number AS LocalIdentificationNumber
       ,cohortid.SID as StateIdentificationNumber
       ,s.first_name AS FirstName
       ,s.last_name AS LastName
       ,CONVERT(VARCHAR(8), s.DOB, 112) AS DateOfBirth
       ,80 AS CountyCodeAssigned
       ,7325 AS DistrictCodeAssigned
       ,965 AS SchoolCodeAssigned
    ,CONVERT(VARCHAR(8), cohort.entrydate, 112) AS SectionEntryDate
    ,CONVERT(VARCHAR(8), cohort.exitdate, 112) AS SectionExitDate
       ,NULL AS SubjectArea 
       ,NULL AS CourseIdentifier 
       ,NULL AS CourseLevel 
       ,NULL AS GradeSpan
       ,NULL as AvailableCredit
       ,11 AS PS$COURSES#staticequence 
       ,grades.COURSE_NAME AS LocalCourseTitle
       ,grades.COURSE_NUMBER AS LocalCourseCode
       ,COALESCE (CAST(grades.T3_ENR_SECTIONID AS VARCHAR(20)) 
                       ,CAST(grades.T2_ENR_SECTIONID AS VARCHAR(20))
                       ,CAST(grades.T1_ENR_SECTIONID AS VARCHAR(20))
                       ) AS LocalSectionCode
       ,NULL AS CreditsEarned
       ,grades.Y1 AS NumericGradeEarned
       ,NULL AS AlphaGradeEarned
       ,NULL AS CompletionStatus
       ,'S1' AS CourseType
       ,CONVERT(VARCHAR(8), cohortid.exitdate, 112) AS x_stu_exitdate
       ,cohortid.EOY_status AS x_eoy_status                   
       ,'MS' as x_grade_range
       ,cohortid.schoolid AS x_schoolid
FROM COHORT$comprehensive_long#static cohort WITH(NOLOCK)
JOIN GRADES$DETAIL#MS grades WITH(NOLOCK)
  ON cohort.studentid = grades.studentid   
JOIN PS$STUDENTS#static s WITH(NOLOCK)
  ON cohort.studentid = s.id
JOIN COHORT$identifiers_long#static cohortid WITH(NOLOCK)
  ON cohort.STUDENT_NUMBER = cohortid.student_number
AND cohortid.year = 2014
WHERE cohort.year = 2014 
 AND grades.credit_hours_y1 > 0
  AND cohort.exitdate >= '2015-06-30'
  AND s.schoolid != 999999
  AND cohort.GRADE_LEVEL >= 5
)

,grades_hs AS (-- HS Student Data & Y1 Grades
       SELECT 
               CAST(s.STUDENT_NUMBER AS VARCHAR(20)) 
               + '_' 
               + CAST(grades.course_number AS VARCHAR(20)) 
               + '_' 
               + CAST(COALESCE (grades.Q4_ENR_SECTIONID
                           ,grades.Q3_ENR_SECTIONID
                           ,grades.Q2_ENR_SECTIONID
                           ,grades.Q1_ENR_SECTIONID
                           ) AS VARCHAR(20)) 
               AS x_hash
              ,cohort.grade_level as x_grade_level
              ,s.student_number AS LocalIdentificationNumber
              ,cohortid.SID AS StateIdentificationNumber
              ,s.first_name AS FirstName
              ,s.last_name AS LastName
              ,CONVERT(VARCHAR(8), s.DOB, 112) AS DateOfBirth
              ,80 AS CountyCodeAssigned
              ,7325 AS DistrictCodeAssigned
              ,965 AS SchoolCodeAssigned
              ,CONVERT(VARCHAR(8), cohort.entrydate, 112) AS SectionEntryDate
              ,CONVERT(VARCHAR(8), cohort.exitdate, 112) AS SectionExitDate
              ,NULL AS SubjectArea 
              ,NULL AS CourseIdentifier 
              ,NULL AS CourseLevel 
              ,NULL AS GradeSpann
              ,grades.credit_hours_y1 as AvailableCredit
              ,11 AS PS$COURSES#staticequence 
              ,grades.COURSE_NAME AS LocalCourseTitle
              ,grades.COURSE_NUMBER AS LocalCourseCode
              ,COALESCE (CAST(grades.Q4_ENR_SECTIONID AS VARCHAR(20)) 
                                  ,CAST(grades.Q3_ENR_SECTIONID AS VARCHAR(20))
                                  ,CAST(grades.Q2_ENR_SECTIONID AS VARCHAR(20))
                                  ,CAST(grades.Q1_ENR_SECTIONID AS VARCHAR(20))
                           ) AS LocalSectionCode
              ,CASE WHEN grades.promo_test = 0 THEN grades.credit_hours_y1
                           ELSE 0
                     END AS CreditsEarned
              ,grades.Y1 AS NumericGradeEarned
              ,NULL AS AlphaGradeEarned
              ,NULL AS CompletionStatus
              ,'S1' AS CourseType
              ,CONVERT(VARCHAR(8), cohortid.exitdate, 112) AS x_stu_exitdate
              ,cohortid.EOY_status AS x_eoy_status
              ,'HS' as x_grade_range
              ,cohortid.schoolid AS x_schoolid
       FROM COHORT$comprehensive_long#static cohort WITH(NOLOCK)
       JOIN GRADES$DETAIL#NCA grades WITH(NOLOCK)
              ON cohort.studentid = grades.studentid
       JOIN PS$STUDENTS#static s WITH(NOLOCK)
              ON cohort.studentid = s.id
       JOIN COHORT$identifiers_long#static cohortid WITH(NOLOCK)
              ON cohort.STUDENT_NUMBER = cohortid.student_number
              AND cohortid.year = 2014
       WHERE cohort.year = 2014 
              AND grades.credit_hours_y1 > 0
              AND cohort.exitdate >= '2015-06-30'
              AND s.schoolid != 999999
              AND cohort.GRADE_LEVEL >= 5
)

,grades_es AS (--K-4 Students and Pass/Fail ELA and Math
       SELECT 
        CAST(
       CASE WHEN row_gen.n = 0 
                THEN CAST(s.student_number AS VARCHAR(20)) + CAST('ELA' AS VARCHAR(20)) + CAST(cohort.grade_level AS VARCHAR(20)) + CAST(cc.sectionid AS VARCHAR(20))
                ELSE CAST(s.student_number AS VARCHAR(20)) + CAST('MATH' AS VARCHAR(20)) + CAST(cohort.grade_level AS VARCHAR(20)) + CAST(cc.sectionid AS VARCHAR(20))
                END           AS VARCHAR(20)) AS x_hash
       ,cohort.grade_level as x_grade_level
       ,s.student_number AS LocalIdentificationNumber
       ,cohortid.SID AS StateIdentificationNumber
       ,s.first_name AS FirstName
       ,s.last_name AS LastName
       ,CONVERT(VARCHAR(8), s.DOB, 112) AS DateOfBirth
       ,80 AS CountyCodeAssigned
       ,7325 AS DistrictCodeAssigned
       ,965 AS SchoolCodeAssigned
    ,CONVERT(VARCHAR(8), cohort.entrydate, 112) AS SectionEntryDate
    ,CONVERT(VARCHAR(8), cohort.exitdate, 112) AS SectionExitDate
       ,NULL AS SubjectArea 
       ,NULL AS CourseIdentifier 
       ,NULL AS CourseLevel 
       ,NULL AS GradeSpan
       ,NULL AS AvailableCredit
       ,NULL AS PS$COURSES#staticequence 

       ,CASE WHEN row_gen.n = 0 THEN 'ELA' + CAST(cohort.grade_level AS VARCHAR(20))
                ELSE 'MATH' + CAST(cohort.grade_level AS VARCHAR(20))
                END AS LocalCourseTitle

       ,CASE WHEN row_gen.n = 0 THEN 'ELA' + CAST(cohort.grade_level AS VARCHAR(20))
                ELSE 'MATH' + CAST(cohort.grade_level AS VARCHAR(20))
                END AS LocalCourseCode

       ,CASE WHEN row_gen.n = 0 THEN 'ELA' + CAST(cohort.grade_level AS VARCHAR(20)) + CAST(cc.sectionid AS VARCHAR(20))
                ELSE 'MATH' + CAST(cohort.grade_level AS VARCHAR(20)) + CAST(cc.sectionid AS VARCHAR(20))
                END AS LocalSectionCode
    ,NULL AS CreditsEarned
       ,NULL AS NumericGradeEarned
       ,NULL AS AlphaGradeEarned
              ,CASE WHEN cohortid.EOY_status LIKE '%Retained%' THEN 'F'
                ELSE 'P'
                END AS CompletionStatus  
       ,'S1' AS CourseType
       ,CONVERT(VARCHAR(8), cohortid.exitdate, 112) AS x_stu_exitdate
       ,cohortid.EOY_status AS x_eoy_status
    ,'ES' AS x_grade_range
    ,cohortid.schoolid AS x_schoolid
       ,t.TEACHERNUMBER as x_t_teachernumber
       ,t.LASTFIRST as x_t_lastfirst
       FROM COHORT$comprehensive_long#static cohort WITH(NOLOCK)
       JOIN PS$STUDENTS#static s WITH(NOLOCK)
         ON cohort.STUDENTID = s.id
       JOIN UTIL$row_generator row_gen WITH(NOLOCK)
         ON cohort.STUDENTID != row_gen.n
       JOIN PS$CC#static cc WITH(NOLOCK)
         ON cohort.studentid = cc.studentid 
        AND cc.COURSE_NUMBER = 'HR' 
        AND cc.TERMID = 2400
       JOIN PS$SECTIONS#static sec WITH(NOLOCK)
         ON cc.SECTIONID = sec.id
       JOIN teachers t WITH(NOLOCK)
         ON sec.TEACHER = t.id
       JOIN COHORT$identifiers_long#static cohortid WITH(NOLOCK)
         ON cohort.STUDENT_NUMBER = cohortid.student_number
       AND cohortid.year = 2014
       WHERE cohort.year = 2014
         AND cohort.exitdate >= '2015-06-30'
         AND s.schoolid != 999999
         AND row_gen.n <= 1
         AND cohort.GRADE_LEVEL <= 4
)

SELECT grades_ms.*
      ,section_long.TEACHERNUMBER AS x_t_teachernumber
         ,section_long.LASTFIRST AS x_t_lastifrst
FROM grades_ms
JOIN section_long
  ON grades_ms.LocalSectionCode = section_long.LocalSectionCode

UNION ALL

SELECT grades_hs.*
      ,section_long.TEACHERNUMBER AS x_t_teachernumber
         ,section_long.LASTFIRST AS x_t_lastifrst
FROM grades_hs
JOIN section_long
  ON grades_hs.LocalSectionCode = section_long.LocalSectionCode

UNION ALL

SELECT grades_es.*
FROM grades_es
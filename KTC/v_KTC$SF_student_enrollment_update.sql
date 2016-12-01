USE KIPP_NJ
GO

ALTER VIEW KTC$SF_student_enrollment_update AS

WITH roster AS (
  SELECT 'NWK' AS [KIPP Region]
        ,s.Id AS [Salesforce ID]
        ,co.last_name AS [Last Name]
        ,co.first_name AS [First Name]        
        ,CONVERT(DATE,co.dob) AS [Birthdate]
        ,co.cohort AS [KIPP HS Class]        
        ,MIN(CONVERT(DATE,co.entrydate)) OVER(PARTITION BY co.student_number, co.schoolid) AS start_date
        ,MAX(CONVERT(DATE,co.exitdate)) OVER(PARTITION BY co.student_number, co.schoolid) AS end_date
        ,MIN(co.grade_level) OVER(PARTITION BY co.student_number, co.schoolid) AS start_grade
        ,MAX(co.grade_level) OVER(PARTITION BY co.student_number, co.schoolid) AS end_grade
        ,CASE
          WHEN co.schoolid = 133570965 THEN 'TEAM Academy, a KIPP school'
          WHEN co.schoolid = 73252 THEN 'Rise Academy, a KIPP school'
          WHEN co.schoolid = 73253 THEN 'Newark Collegiate Academy, a KIPP school'
          WHEN co.schoolid = 179902 THEN 'KIPP Lanning Square Middle School'
         END AS school_name
        ,CASE           
          WHEN co.school_level = 'HS' THEN 'High School'
          WHEN co.school_level = 'MS' THEN 'Middle School'
         END AS school_type        
        ,CASE WHEN co.school_level = 'HS' THEN 'High School Diploma' END AS pursuing_degree_type
        ,CASE          
          WHEN co.year = KIPP_NJ.dbo.fn_Global_Academic_Year() AND co.enroll_status = 0 THEN 'Attending'
          WHEN co.year = KIPP_NJ.dbo.fn_Global_Academic_Year() AND co.enroll_status = 2 THEN 'Transferred Out'
          WHEN co.year = KIPP_NJ.dbo.fn_Global_Academic_Year() AND co.enroll_status = 3 THEN 'Graduated'
          WHEN co.grade_level = 8 AND LEAD(co.grade_level) OVER(PARTITION BY co.student_number ORDER BY co.year) = 9 THEN 'Graduated'
          WHEN LEAD(co.grade_level) OVER(PARTITION BY co.student_number ORDER BY co.year) = 99 THEN 'Graduated'
          WHEN LEAD(co.grade_level) OVER(PARTITION BY co.student_number ORDER BY co.year) IS NULL THEN 'Transferred Out'
          WHEN (co.year + 1) != LEAD(co.year) OVER(PARTITION BY co.student_number ORDER BY co.year) THEN 'Transferred Out'
          ELSE 'Transferred Out'
         END AS status     
        ,MAX(co.year_in_school) OVER(PARTITION BY co.student_number, co.schoolid) - co.year_in_school + 1 AS year_in_school_rn           
  FROM KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK)
  JOIN AlumniMirror..Contact s WITH(NOLOCK)
    ON co.student_number = s.School_Specific_ID__c
 )

,enrollments AS (
  SELECT e.Student__c AS student_salesforce_id
        ,a.Name AS school_name
        ,e.Id AS enrollment_id            
  FROM AlumniMirror..Enrollment__c e WITH(NOLOCK)
  JOIN AlumniMirror..Account a WITH(NOLOCK)
    ON e.School__c = a.Id
 )

,roster_enrollments AS (
  SELECT r.[KIPP Region]
        ,r.[Salesforce ID]
        ,r.[Last Name]
        ,r.[First Name]
        ,r.Birthdate
        ,r.[KIPP HS Class]
        ,r.school_type
        ,e.enrollment_id
        ,r.school_name
        ,r.pursuing_degree_type
        ,r.start_grade
        ,r.end_grade
        ,r.start_date
        ,r.end_date
        ,r.status
        ,ROW_NUMBER() OVER(
           PARTITION BY r.[Salesforce ID]
             ORDER BY r.start_date ASC) AS enrollment_base
        ,ROW_NUMBER() OVER(
           PARTITION BY r.[Salesforce ID]
             ORDER BY r.start_date DESC) AS enrollment_curr
  FROM roster r
  JOIN enrollments e
    ON r.[Salesforce ID] = e.student_salesforce_id
   AND r.school_name = e.school_name
  WHERE r.year_in_school_rn = 1
    AND r.school_name IS NOT NULL
 )

SELECT r1.[KIPP Region]
      ,r1.[Salesforce ID]
      ,r1.[Last Name]
      ,r1.[First Name]
      ,r1.Birthdate
      ,r1.[KIPP HS Class]
      
      ,r1.school_name AS existing_school_name
      ,r1.enrollment_id AS existing_enrollment_id
      ,r1.end_date AS existing_end_date
      ,r1.end_grade AS existing_end_grade
      ,r1.status AS existing_status
      
      ,r2.school_name AS new_school_name
      ,r2.start_date AS new_start_date
      ,r2.start_grade AS new_start_grade
      ,r2.pursuing_degree_type AS new_pursuing_degree_type
      ,r2.school_type AS new_school_type
      ,r2.status AS new_status
FROM roster_enrollments r1
LEFT OUTER JOIN roster_enrollments r2
  ON r1.[Salesforce ID] = r2.[Salesforce ID]
 AND r2.status = 'Attending'
WHERE r1.status IN ('Transferred Out','Graduated')
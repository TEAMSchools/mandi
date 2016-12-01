USE KIPP_NJ
GO

ALTER VIEW KTC$SF_student_enrollment_update AS

WITH roster AS (
  SELECT 'KIPP New Jersey' AS KIPP_Region
        ,s.Id AS Salesforce_ID
        ,co.last_name AS Last_Name
        ,co.first_name AS First_Name
        ,CONVERT(DATE,co.dob) AS Birthdate
        ,co.cohort AS KIPP_HS_Class
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
        ,co.student_number
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
  SELECT r.KIPP_Region
        ,r.Salesforce_ID
        ,r.Last_Name
        ,r.First_Name
        ,r.Birthdate
        ,r.KIPP_HS_Class
        ,r.student_number
        ,r.status
        ,r.school_type
        ,r.school_name
        ,r.pursuing_degree_type
        ,r.start_grade
        ,r.end_grade
        ,r.start_date
        ,r.end_date             
        ,e.enrollment_id        
  FROM roster r
  LEFT OUTER JOIN enrollments e
    ON r.Salesforce_ID = e.student_salesforce_id
   AND r.school_name = e.school_name
  WHERE r.year_in_school_rn = 1
    AND r.school_name IS NOT NULL    
 )

SELECT r1.KIPP_Region
      ,r1.Salesforce_ID
      ,r1.Last_Name
      ,r1.First_Name
      ,r1.Birthdate
      ,r1.KIPP_HS_Class
      
      ,r1.School_Name AS close_School_Name
      ,r1.Enrollment_ID AS close_Enrollment_ID
      ,r1.End_Date AS close_End_Date
      ,r1.End_Grade AS close_End_Grade
      ,r1.Status AS close_Status

      ,r2.School_Name AS create_School_Name
      ,r2.Start_Date AS create_Start_Date
      ,r2.Start_Grade AS create_Start_Grade
      ,r2.Pursuing_Degree_Type AS create_Pursuing_Degree_Type
      ,r2.School_Type AS create_School_Type
      ,r2.Status AS create_Status  
      
      ,r1.student_number
FROM
    (
     SELECT r1.KIPP_Region
           ,r1.Salesforce_ID
           ,r1.Last_Name
           ,r1.First_Name
           ,r1.Birthdate
           ,r1.KIPP_HS_Class
           ,r1.School_Name
           ,r1.Enrollment_ID
           ,r1.End_Date
           ,r1.End_Grade
           ,r1.Status
           ,r1.student_number
     FROM roster_enrollments r1
     WHERE r1.status NOT IN ('Attending', 'Deferred', 'Did Not Enroll', 'Matriculated')
    ) r1
LEFT OUTER JOIN roster_enrollments r2
  ON r1.student_number = r2.student_number
 AND r2.enrollment_id IS NULL 
 AND r2.status IN ('Attending', 'Deferred', 'Did Not Enroll', 'Matriculated')
USE KIPP_NJ
GO

ALTER VIEW KTC$SF_student_import AS

SELECT [KIPP School of Enrollment]
      ,[Last Name]
      ,[First Name]
      ,[Middle Initial]
      ,MAX([HS Class Cohort]) AS [HS Class Cohort]
      ,[Student ID Type]
      ,[Student ID #]
      ,[Contact Owner Name]
      ,[Contact Owner Salesforce ID]
      ,MIN([School Enrollment Date]) AS [School Enrollment Date]
      ,MIN([School Enrollment Grade]) AS [School Enrollment Grade]
      ,CASE
        WHEN MAX([Enrollment Status]) = 0 THEN 'Attending'
        WHEN MAX([Enrollment Status]) = 2 THEN 'Transferred out'
        WHEN MAX([Enrollment Status]) = 3 THEN 'Graduated'
       END AS [Enrollment Status]
      ,MAX([School Ending Grade]) AS [School Ending Grade]
      ,MAX([School Exit Date]) AS [School Exit Date]
      ,[Date of Birth]
      ,[Gender]
      ,[Ethnicity]
      ,[Street Address]
      ,[City]
      ,[State]
      ,[Zip]
      ,[Student E-mail]
      ,[Student Mobile]
      ,[Student Home Phone]
      ,[Parent1 First Name]
      ,[Parent1 Last Name]
      ,[Parent1 Work Phone]
      ,[Parent 1 Home Phone]
      ,[Parent1 E-mail]
      ,[Parent2 First Name]
      ,[Parent2 Last Name]
      ,[Parent2 Work Phone]
      ,[Parent2 Home Phone]
      ,[Parent2 E-mail]
      ,ROW_NUMBER() OVER(
         PARTITION BY [Student ID #]
           ORDER BY MAX([School Exit Date]) DESC) AS rn
FROM
    (
     SELECT CASE
             WHEN co.schoolid = 133570965 THEN 'TEAM Academy, a KIPP school'
             WHEN co.schoolid = 73252 THEN 'Rise Academy, a KIPP school'
             WHEN co.schoolid = 73253 THEN 'Newark Collegiate Academy, a KIPP school'
             WHEN co.schoolid = 179902 THEN 'KIPP Lanning Square Middle School'
            END AS [KIPP School of Enrollment]
           ,co.last_name AS [Last Name]
           ,co.first_name AS [First Name]
           ,LEFT(co.MIDDLE_NAME,1) AS [Middle Initial]
           ,co.cohort AS [HS Class Cohort]
           ,'PowerSchool ID' AS [Student ID Type]
           ,co.student_number AS [Student ID #]
           ,u.Name AS [Contact Owner Name]
           ,u.Id AS [Contact Owner Salesforce ID]
           ,CONVERT(DATE,co.entrydate) AS [School Enrollment Date]
           ,co.grade_level AS [School Enrollment Grade]
           ,co.enroll_status AS [Enrollment Status]
           ,co.grade_level AS [School Ending Grade]
           ,CONVERT(DATE,co.exitdate) AS [School Exit Date]
           ,CONVERT(DATE,co.DOB) AS [Date of Birth]
           ,CASE 
             WHEN co.GENDER = 'M' THEN 'Male'
             WHEN co.GENDER = 'F' THEN 'Female'
            END AS [Gender]
           ,CASE 
             WHEN co.ETHNICITY = 'I' THEN 'American Indian/Alaska Native'
             WHEN co.ETHNICITY = 'A' THEN 'Asian'
             WHEN co.ETHNICITY = 'B' THEN 'Black/African American'
             WHEN co.ETHNICITY = 'H' THEN 'Hispanic/Latino'
             WHEN co.ETHNICITY = 'P' THEN 'Native Hawaiian/Pacific Islander'
             WHEN co.ETHNICITY = 'W' THEN 'White'
             WHEN co.ETHNICITY = 'T' THEN 'Two or More Races'
            END AS [Ethnicity]
           ,co.STREET AS [Street Address]
           ,co.CITY AS [City]
           ,co.STATE AS [State]
           ,co.ZIP AS [Zip]
           ,CONCAT(co.student_web_id,'@teamstudents.org') AS [Student E-mail]
           ,NULL AS [Student Mobile]
           ,co.home_phone AS [Student Home Phone]
           ,LTRIM(RTRIM(CASE
                         WHEN CHARINDEX(',', co.mother) = 0 AND CHARINDEX(' ', co.MOTHER) = 0 THEN NULL
                         WHEN CHARINDEX(',', co.MOTHER)-1 < 0 THEN LEFT(co.MOTHER, CHARINDEX(' ', co.MOTHER)-1) 
                         ELSE SUBSTRING(co.MOTHER, CHARINDEX(',', co.MOTHER)+2, LEN(co.MOTHER)) 
                        END)) AS [Parent1 First Name]
           ,LTRIM(RTRIM(CASE
                         WHEN CHARINDEX(',', co.MOTHER) = 0 AND CHARINDEX(' ', co.MOTHER) = 0 THEN NULL
                         WHEN CHARINDEX(',', co.MOTHER)-1 < 0 THEN SUBSTRING(co.MOTHER, CHARINDEX(' ', co.MOTHER)+1, LEN(co.MOTHER)) 
                         ELSE LEFT(co.MOTHER, CHARINDEX(',', co.MOTHER)-1)         
                        END)) AS [Parent1 Last Name]
           ,co.MOTHER_DAY AS [Parent1 Work Phone]
           ,co.MOTHER_HOME AS [Parent 1 Home Phone]
           ,REPLACE(REPLACE(CONVERT(VARCHAR(MAX),co.guardianemail),CHAR(10),''),CHAR(13),'') AS [Parent1 E-mail]
           ,LTRIM(RTRIM(CASE
                         WHEN CHARINDEX(',', co.FATHER) = 0 AND CHARINDEX(' ', co.FATHER) = 0 THEN NULL
                         WHEN CHARINDEX(',', co.FATHER)-1 < 0 THEN LEFT(co.FATHER, CHARINDEX(' ', co.FATHER)-1) 
                         ELSE SUBSTRING(co.FATHER, CHARINDEX(',', co.FATHER)+2, LEN(co.FATHER)) 
                        END)) AS [Parent2 First Name]
           ,LTRIM(RTRIM(CASE
                         WHEN CHARINDEX(',', co.FATHER) = 0 AND CHARINDEX(' ', co.FATHER) = 0 THEN NULL
                         WHEN CHARINDEX(',', co.FATHER)-1 < 0 THEN SUBSTRING(co.FATHER, CHARINDEX(' ', co.FATHER)+1, LEN(co.FATHER)) 
                         ELSE LEFT(co.FATHER, CHARINDEX(',', co.FATHER)-1)         
                        END)) AS [Parent2 Last Name]
           ,co.FATHER_DAY AS [Parent2 Work Phone]
           ,co.FATHER_HOME AS [Parent2 Home Phone]
           ,REPLACE(REPLACE(CONVERT(VARCHAR(MAX),co.guardianemail),CHAR(10),''),CHAR(13),'') AS [Parent2 E-mail]           
           --'NWK' AS [Region Code]
           --,CASE WHEN co.schoolid = 73253 THEN 'High School' ELSE 'Middle School' END AS [School Type],
     FROM KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK)
     LEFT OUTER JOIN AlumniMirror..Contact s WITH(NOLOCK)
       ON co.student_number = s.School_Specific_ID__c
     LEFT OUTER JOIN AlumniMirror..User2 u WITH(NOLOCK)
       ON s.OwnerId = u.Id
     WHERE co.schoolid IN (73252, 73253, 133570965, 179902)       
    ) sub
GROUP BY [KIPP School of Enrollment]
        ,[Last Name]
        ,[First Name]
        ,[Middle Initial]        
        ,[Student ID Type]
        ,[Student ID #]
        ,[Contact Owner Name]
        ,[Contact Owner Salesforce ID]
        ,[Date of Birth]
        ,[Gender]
        ,[Ethnicity]
        ,[Street Address]
        ,[City]
        ,[State]
        ,[Zip]
        ,[Student E-mail]
        ,[Student Mobile]
        ,[Student Home Phone]
        ,[Parent1 First Name]
        ,[Parent1 Last Name]
        ,[Parent1 Work Phone]
        ,[Parent 1 Home Phone]
        ,[Parent1 E-mail]
        ,[Parent2 First Name]
        ,[Parent2 Last Name]
        ,[Parent2 Work Phone]
        ,[Parent2 Home Phone]
        ,[Parent2 E-mail]
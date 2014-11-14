USE KIPP_NJ
GO

ALTER VIEW TABLEAU$KTC_alumni_detail AS 

WITH max_grade AS (
  SELECT co.year AS academic_year
        ,co.studentid
        ,co.lastfirst
        ,co.grade_level
        ,co.cohort
        ,co.schoolid        
        ,ROW_NUMBER() OVER(
           PARTITION BY co.studentid
             ORDER BY co.year DESC) AS rn
  FROM COHORT$identifiers_long#static co WITH(NOLOCK)
  WHERE co.schoolid != 999999         
    AND co.rn = 1
 )

,roster AS (
  SELECT co.year AS academic_year
        ,co.STUDENT_NUMBER
        ,co.lastfirst
        ,max_grade.grade_level + (dbo.fn_Global_Academic_Year() - co.year) AS grade_level
        ,max_grade.cohort
        ,max_grade.schoolid        
  FROM COHORT$identifiers_long#static co WITH(NOLOCK)
  JOIN max_grade WITH(NOLOCK)
    ON co.studentid = max_grade.studentid
   AND co.year >= max_grade.cohort
   AND max_grade.rn = 1
  WHERE co.rn = 1
    AND co.schoolid = 999999
    AND co.year = dbo.fn_Global_Academic_Year()
 )

,alumni_roster AS (
  SELECT contact_id AS salesforce_id
        ,sis_id AS student_number        
        ,cohort
        ,composite_status
        ,User2.id AS advisor_id
        ,ktc_contact AS advisor_name
        ,last_advisor_activity
        ,last_successful_contact
        ,school_enroll_date
        ,school_exit_date
        ,school_name
        ,school_type
        ,school_id      
  FROM [AlumniMirror].[dbo].[vwRoster_Basic] r WITH(NOLOCK)
  LEFT OUTER JOIN AlumniMirror.dbo.User2 WITH(NOLOCK)
    ON r.ktc_contact = user2.name
 )

,combined_roster AS (
  SELECT r.STUDENT_NUMBER
        ,r.lastfirst
        ,r.grade_level
        ,r.cohort
        ,alum.salesforce_id
        ,alum.composite_status        
        ,alum.advisor_id
        ,ISNULL(alum.advisor_name,'Unassigned') AS advisor_name
        ,alum.last_advisor_activity
        ,alum.last_successful_contact
        ,alum.school_name
        ,alum.school_type
        ,alum.school_id
  FROM roster r WITH(NOLOCK)
  LEFT OUTER JOIN alumni_roster alum WITH(NOLOCK)
    ON r.STUDENT_NUMBER = alum.student_number  
 )

,colleges AS (
  SELECT [salesforce_id]
        ,[Name]
        ,[Type]                        
        ,[X6_yr_minority_completion_rate__c] AS minority_grad_rate
        ,[Adjusted_6_year_minority_graduation_rate__c] AS adj_minority_grad_rate
  FROM [AlumniMirror].[dbo].[CollegeMatch$college_list] WITH(NOLOCK)
 )

,enrollments AS (
  SELECT c.[Name] AS school_name
        ,REPLACE(RIGHT(c.type, 4),' ','') AS track
        ,c.minority_grad_rate
        ,c.adj_minority_grad_rate
        ,[Student__c] AS student_id
        ,[School__c] AS school_id
        ,[Start_Date__c] AS start_date
        ,Type__c AS type
        ,[Actual_End_Date__c]            
        ,[Date_Last_Verified__c]
        ,[Highest_SAT_Score__c]      
        ,[Notes__c]
        ,[Pursuing_Degree_Type__c]  
        ,[Status__c]
        ,[Transfer_Reason__c]      
        ,[Major_Area__c]            
        ,[Major__c] AS major
        ,[Anticipated_Graduation__c] AS proj_grad_date
        ,ROW_NUMBER() OVER(
           PARTITION BY student__c
             ORDER BY start_date__c DESC) AS rn_cur
        ,ROW_NUMBER() OVER(
           PARTITION BY student__c
             ORDER BY start_date__c ASC) AS rn_base
  FROM [AlumniMirror].[dbo].[Enrollment__c] enr WITH(NOLOCK)
  JOIN colleges c WITH(NOLOCK)
    ON enr.School__c = c.salesforce_id
  WHERE Type__c NOT IN ('Middle School','High School')
    AND IsDeleted = 0
    AND status__c != 'Did Not Enroll'
 )

SELECT r.student_number
      ,r.lastfirst
      ,r.cohort
      ,r.advisor_name
      ,r.composite_status      
      ,r.school_name
      ,r.school_type      
      ,enr_cur.track
      ,enr_cur.minority_grad_rate
      ,enr_cur.start_date
      ,enr_cur.proj_grad_date
      ,enr_cur.major      
      ,enr_base.school_name AS initial_school
      ,enr_base.minority_grad_rate AS init_minority_grad_rate
      ,r.last_successful_contact
      ,CASE
        WHEN r.composite_status = 'College Withdrawn' THEN 'Dropped out of ' + enr_cur.track
        ELSE enr_base.track + ' to ' + enr_cur.track
       END AS transfer
      ,CASE WHEN r.composite_status = 'College Persisting' AND enr_cur.track = '4yr' THEN 1.0 END AS is_4yr
      ,CASE WHEN r.composite_status = 'College Persisting' AND enr_cur.track = '2yr' THEN 1.0 END AS is_2yr
      ,CASE WHEN r.composite_status LIKE '%Grad%' THEN 1.0 END AS is_grad
      ,CASE WHEN r.composite_status IN ('College Withdrawn', 'HS Dropout', 'No College', 'Declared, Not Yet Matriculated') THEN 1.0 END AS not_enrolled
      ,CASE WHEN r.school_type = 'Technical School' THEN 1.0 END AS is_trade      
FROM combined_roster r WITH(NOLOCK)
LEFT OUTER JOIN enrollments enr_cur WITH(NOLOCK)
  ON r.salesforce_id = enr_cur.student_id
 AND enr_cur.rn_cur = 1
LEFT OUTER JOIN enrollments enr_base WITH(NOLOCK)
  ON r.salesforce_id = enr_base.student_id
 AND r.school_id != enr_base.school_id
 AND enr_base.rn_base = 1
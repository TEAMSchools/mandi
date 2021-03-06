USE KIPP_NJ
GO

ALTER VIEW KTC$team_and_family_roster AS 

WITH hs_grads AS (
  SELECT co.student_number        
  FROM KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK)
  WHERE co.grade_level = 12
    AND co.exitcode = 'G1'               
 ) 

,ms_grads AS (
  SELECT co.studentid
        ,co.student_number
        ,co.first_name
        ,co.last_name
        ,co.lastfirst        
        ,co.DOB
        ,co.schoolid        
        ,co.school_name
        ,co.grade_level                        
        ,(KIPP_NJ.dbo.fn_Global_Academic_Year() - co.year) + co.grade_level AS curr_grade_level
        ,co.exitdate
        ,co.cohort
        ,co.highest_achieved        
        ,CONVERT(VARCHAR(MAX),co.guardianemail) AS guardianemail
        ,ROW_NUMBER() OVER(
           PARTITION BY co.student_number
             ORDER BY co.exitdate DESC) AS rn
  FROM KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK)
  WHERE co.grade_level = 8
    AND co.exitcode IN ('G1','T2')
    AND co.student_number NOT IN (2026,3049,3012)
    AND co.rn = 1
    AND co.enroll_status != 0
    AND co.student_number NOT IN (SELECT student_number FROM hs_grads)
 )

,transfers AS (
  SELECT sub.studentid
        ,sub.student_number
        ,sub.first_name
        ,sub.last_name
        ,sub.lastfirst                
        ,sub.DOB
        ,sub.curr_grade_level
        ,sub.cohort
        ,sub.highest_achieved        
        ,sub.final_exitdate
        ,CASE WHEN s.GRADUATED_SCHOOLID = 0 THEN s.SCHOOLID ELSE s.GRADUATED_SCHOOLID END AS schoolid       
        ,CASE WHEN s.GRADUATED_SCHOOLID = 0 THEN sch2.ABBREVIATION ELSE sch.ABBREVIATION END AS school_name                 
        ,sub.guardianemail
  FROM
      (
       SELECT co.studentid             
             ,co.student_number
             ,co.first_name
             ,co.last_name
             ,co.lastfirst
             ,co.DOB                          
             ,MAX(co.cohort) AS cohort
             ,co.highest_achieved
             ,MAX(CONVERT(VARCHAR(MAX),co.guardianemail)) AS guardianemail
             ,(KIPP_NJ.dbo.fn_Global_Academic_Year() - MAX(co.year)) + MAX(co.grade_level) AS curr_grade_level
             ,DATEDIFF(YEAR, MIN(co.entrydate), MAX(co.exitdate)) AS years_enrolled             
             ,MIN(co.entrydate) AS orig_entrydate
             ,MAX(co.exitdate) AS final_exitdate
             ,DATEPART(YEAR,MAX(co.exitdate)) AS year_final_exitdate             
       FROM KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK)
       WHERE co.grade_level >= 9
         AND co.enroll_status NOT IN (0,3)
         AND co.studentid NOT IN (SELECT studentid FROM ms_grads) 
       GROUP BY co.studentid, co.student_number, co.lastfirst, co.first_name, co.last_name, co.highest_achieved, co.DOB
      ) sub
  LEFT OUTER JOIN KIPP_NJ..PS$STUDENTS#static s WITH(NOLOCK)
    ON sub.student_number = s.STUDENT_NUMBER  
  LEFT OUTER JOIN KIPP_NJ..PS$SCHOOLS#static sch WITH(NOLOCK)
    ON s.GRADUATED_SCHOOLID = sch.SCHOOL_NUMBER
  LEFT OUTER JOIN KIPP_NJ..PS$SCHOOLS#static sch2 WITH(NOLOCK)
    ON s.SCHOOLID = sch2.SCHOOL_NUMBER
  WHERE (sub.cohort >= 2018 AND ((years_enrolled = 1 AND final_exitdate >= CONVERT(DATE,CONVERT(VARCHAR,year_final_exitdate) + '-10-01')) OR (years_enrolled > 1)))
 )

,enrollments AS (
  SELECT s.ID AS salesforce_contact_id
        ,s.School_Specific_ID__c AS student_number        
        ,s.mobilephone AS SF_MOBILE_PHONE
        ,s.homephone AS SF_HOME_PHONE
        ,s.otherphone AS SF_OTHER_PHONE
        ,s.email AS SF_EMAIL
        ,s.KIPP_HS_Class__c
        ,s.Expected_HS_Graduation__c
        ,u.Id AS contact_owner_id
        ,u.Name AS ktc_counselor
        ,enr.Type__c AS enrollment_type
        ,enr.Status__c AS enrollment_status
        ,enr.name AS enrollment_name        
        ,ROW_NUMBER() OVER(
          PARTITION BY s.School_Specific_ID__c
            ORDER BY enr.Start_Date__c DESC) AS rn
  FROM AlumniMirror..Contact s WITH(NOLOCK)
  JOIN AlumniMirror..User2 u WITH(NOLOCK)
    ON s.OwnerId = u.Id
  JOIN AlumniMirror..Enrollment__c enr WITH(NOLOCK)
    ON s.id = enr.Student__c
  WHERE s.isdeleted = 0
    AND s.School_Specific_ID__c IS NOT NULL
 )

,sped AS (
  SELECT studentid
        ,SPEDLEP
        ,SPEDCODE
        ,ROW_NUMBER() OVER(
           PARTITION BY studentid
             ORDER BY academic_year DESC) AS rn
  FROM KIPP_NJ..PS$SPED#ARCHIVE WITH(NOLOCK)
 )

SELECT r.student_number
      ,r.lastfirst
      ,r.schoolid
      ,r.school_name
      ,r.curr_grade_level AS approx_grade_level      
      ,enr.KIPP_HS_Class__c AS cohort
      ,CONVERT(DATE,enr.Expected_HS_Graduation__c) AS Expected_HS_Graduation_Date
      ,CASE WHEN r.highest_achieved = 99 THEN 1 ELSE 0 END AS is_grad
      ,sped.SPEDLEP
      ,sped.SPEDCODE AS SPED_code      
      ,enr.ktc_counselor      
      ,enr.enrollment_type
      ,enr.enrollment_name
      ,enr.enrollment_status
      ,enr.SF_HOME_PHONE
      ,enr.SF_MOBILE_PHONE
      ,enr.SF_OTHER_PHONE
      ,enr.SF_EMAIL      
      ,con.HOME_PHONE AS PS_HOME_PHONE
      ,con.MOTHER AS PS_MOTHER
      ,con.MOTHER_HOME AS PS_MOTHER_HOME
      ,con.MOTHER_CELL AS PS_MOTHER_CELL
      ,con.MOTHER_DAY AS PS_MOTHER_DAY
      ,con.FATHER AS PS_FATHER
      ,con.FATHER_HOME AS PS_FATHER_HOME
      ,con.FATHER_CELL AS PS_FATHER_CELL
      ,con.FATHER_DAY AS PS_FATHER_DAY
      ,r.guardianemail AS PS_EMAIL
      ,con.DOCTOR_NAME AS PS_DOCTOR_NAME
      ,con.DOCTOR_PHONE AS PS_DOCTOR_PHONE
      ,con.EMERG_CONTACT_1 AS PS_EMERG_CONTACT_1
      ,con.EMERG_1_REL AS PS_EMERG_1_REL
      ,con.EMERG_PHONE_1 AS PS_EMERG_PHONE_1
      ,con.EMERG_CONTACT_2 AS PS_EMERG_CONTACT_2
      ,con.EMERG_2_REL AS PS_EMERG_2_REL
      ,con.EMERG_PHONE_2 AS PS_EMERG_PHONE_2
      ,con.EMERG_CONTACT_3 AS PS_EMERG_CONTACT_3
      ,con.EMERG_3_REL AS PS_EMERG_3_REL
      ,con.EMERG_3_PHONE AS PS_EMERG_3_PHONE
      ,con.EMERG_4_NAME AS PS_EMERG_4_NAME
      ,con.EMERG_4_REL AS PS_EMERG_4_REL
      ,con.EMERG_4_PHONE AS PS_EMERG_4_PHONE
      ,con.EMERG_5_NAME AS PS_EMERG_5_NAME
      ,con.EMERG_5_REL AS PS_EMERG_5_REL
      ,con.EMERG_5_PHONE AS PS_EMERG_5_PHONE
      ,con.RELEASE_1_NAME AS PS_RELEASE_1_NAME
      ,con.RELEASE_1_PHONE AS PS_RELEASE_1_PHONE
      ,con.RELEASE_1_RELATION AS PS_RELEASE_1_RELATION
      ,con.RELEASE_2_NAME AS PS_RELEASE_2_NAME
      ,con.RELEASE_2_PHONE AS PS_RELEASE_2_PHONE
      ,con.RELEASE_2_RELATION AS PS_RELEASE_2_RELATION
      ,con.RELEASE_3_NAME AS PS_RELEASE_3_NAME
      ,con.RELEASE_3_PHONE AS PS_RELEASE_3_PHONE
      ,con.RELEASE_3_RELATION AS PS_RELEASE_3_RELATION
      ,con.RELEASE_4_NAME AS PS_RELEASE_4_NAME
      ,con.RELEASE_4_PHONE AS PS_RELEASE_4_PHONE
      ,con.RELEASE_4_RELATION AS PS_RELEASE_4_RELATION
      ,con.RELEASE_5_NAME AS PS_RELEASE_5_NAME
      ,con.RELEASE_5_PHONE AS PS_RELEASE_5_PHONE
      ,con.RELEASE_5_RELATION AS PS_RELEASE_5_RELATION
      ,r.first_name
      ,r.last_name
      ,r.DOB
      ,r.exitdate
      ,enr.contact_owner_id
      ,enr.salesforce_contact_id
FROM
    (
     SELECT studentid
           ,student_number
           ,first_name
           ,last_name
           ,lastfirst
           ,DOB
           ,exitdate
           ,schoolid
           ,school_name
           ,curr_grade_level
           ,cohort
           ,highest_achieved        
           ,guardianemail
     FROM ms_grads  
     UNION  
     SELECT studentid
           ,student_number
           ,first_name
           ,last_name           
           ,lastfirst
           ,DOB
           ,final_exitdate
           ,schoolid
           ,school_name
           ,curr_grade_level
           ,cohort
           ,highest_achieved        
           ,guardianemail
     FROM transfers    
    ) r
LEFT OUTER JOIN enrollments enr
  ON r.student_number = enr.student_number
 AND enr.rn = 1
LEFT OUTER JOIN sped
  ON r.studentid = sped.studentid
 AND sped.rn = 1
LEFT OUTER JOIN KIPP_NJ..PS$STUDENTS_contact#static con WITH(NOLOCK)
  ON r.studentid = con.STUDENTID
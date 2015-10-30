USE KIPP_NJ
GO

ALTER VIEW KTC$combined_roster_long AS

WITH graduates AS (
  SELECT co.year AS academic_year        
        ,co.STUDENT_NUMBER
        ,co.lastfirst        
        ,sub.grade_level + (co.year - sub.cohort) AS grade_level        
        ,sub.cohort
        ,sub.schoolid        
        ,r.Id AS salesforce_id                
        ,u.id AS counselor_id
        ,u.Name AS counselor_name
        ,0 AS is_tf
  FROM
      (
       SELECT co.year AS academic_year
             ,co.student_number
             ,co.lastfirst
             ,co.grade_level
             ,co.cohort        
             ,co.schoolid                        
             ,ROW_NUMBER() OVER(
               PARTITION BY co.student_number
                 ORDER BY co.year DESC) AS rn
       FROM KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK)
       WHERE co.rn = 1
         AND co.exitcode = 'G1'       
         AND co.student_number NOT IN (2026,3049,3012)
      ) sub
  JOIN COHORT$identifiers_long#static co WITH(NOLOCK)
    ON sub.student_number = co.student_number   
   AND co.schoolid = 999999
   AND co.rn = 1
  LEFT OUTER JOIN AlumniMirror.dbo.Contact r WITH(NOLOCK)
    ON co.student_number = r.School_Specific_ID__c  
  LEFT OUTER JOIN AlumniMirror.dbo.User2 u WITH(NOLOCK)
    ON r.OwnerId = u.Id
  WHERE sub.rn = 1    
 )  

,team_and_fam AS (
  SELECT KIPP_NJ.dbo.fn_Global_Academic_Year() AS academic_year
        ,tf.student_number
        ,tf.lastfirst
        ,tf.approx_grade_level AS grade_level
        ,tf.cohort
        ,tf.schoolid         
        ,r.Id AS salesforce_id                
        ,u.id AS counselor_id
        ,u.Name AS counselor_name
        ,1 is_tf             
  FROM KIPP_NJ..KTC$team_and_family_roster tf WITH(NOLOCK)     
  LEFT OUTER JOIN AlumniMirror.dbo.Contact r WITH(NOLOCK)
    ON tf.student_number = r.School_Specific_ID__c  
  LEFT OUTER JOIN AlumniMirror.dbo.User2 u WITH(NOLOCK)
    ON r.OwnerId = u.Id
  WHERE tf.student_number NOT IN (SELECT student_number FROM graduates)
 )

SELECT *
      ,ROW_NUMBER() OVER(
         PARTITION BY student_number, academic_year
           ORDER BY academic_year) AS rn
FROM
    (
     SELECT *
     FROM graduates
     UNION ALL
     SELECT *
     FROM team_and_fam
    ) sub

--/* temp fix */
--SELECT KIPP_NJ.dbo.fn_Global_Academic_Year() AS academic_year
--      ,r.School_Specific_ID__c AS student_number
--      ,r.Name AS lastfirst                
--      ,r.Id AS salesforce_id                
--      ,u.id AS counselor_id
--      ,u.Name AS counselor_name    
--FROM AlumniMirror.dbo.Contact r WITH(NOLOCK)  
--LEFT OUTER JOIN AlumniMirror.dbo.User2 u WITH(NOLOCK)
--  ON r.OwnerId = u.Id  
--*/
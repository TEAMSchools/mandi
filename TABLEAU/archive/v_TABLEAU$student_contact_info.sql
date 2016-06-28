USE KIPP_NJ
GO

ALTER VIEW TABLEAU$student_contact_info AS

SELECT schoolid
      ,year
      ,student_number
      ,SID
      ,NEWARK_ENROLLMENT_NUMBER
      ,lastfirst
      ,grade_level
      ,advisor
      ,team
      ,field
      ,value
FROM
    (
     SELECT co.schoolid
           ,co.year
           ,co.student_number
           ,co.sid
           ,co.newark_enrollment_number
           ,co.lastfirst
           ,co.grade_level      
           ,co.advisor
           ,co.team
           ,CONVERT(VARCHAR(MAX),home_phone) AS home_phone
           ,CONVERT(VARCHAR(MAX),mother) AS parent_1_name
           ,CONVERT(VARCHAR(MAX),mother_cell) AS parent_1_cell
           ,CONVERT(VARCHAR(MAX),father) AS parent_2_name
           ,CONVERT(VARCHAR(MAX),father_cell) AS parent_2_cell
           ,CONVERT(VARCHAR(MAX),dob,101) AS dob
           ,CONVERT(VARCHAR(MAX),gender) AS gender
           ,CONVERT(VARCHAR(MAX),CONCAT(street,', ', city, ', NJ ', zip)) AS full_address
           ,CONVERT(VARCHAR(MAX),guardianemail) AS guardianemail
           ,CONVERT(VARCHAR(MAX),student_web_id) AS student_web_id
           ,CONVERT(VARCHAR(MAX),student_web_password) AS student_web_password
           ,CONVERT(VARCHAR(MAX),family_web_id) AS family_web_id
           ,CONVERT(VARCHAR(MAX),family_web_password) AS family_web_password
           ,CONVERT(VARCHAR(MAX),lunch_balance) AS lunch_balance
     FROM COHORT$identifiers_long#static co WITH(NOLOCK)
     WHERE co.rn = 1  
    ) sub
UNPIVOT(
  value
  FOR field IN (home_phone
               ,parent_1_cell
               ,parent_2_cell
               ,parent_1_name
               ,parent_2_name
               ,dob
               ,gender
               ,full_address               
               ,guardianemail
               ,student_web_id
               ,student_web_password
               ,family_web_id
               ,family_web_password
               ,lunch_balance)
 ) u
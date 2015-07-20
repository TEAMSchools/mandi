USE KIPP_NJ
GO

ALTER VIEW REPORTING$student_contact_info AS

SELECT co.schoolid
      ,co.student_number AS SN
      ,co.lastfirst AS Name
      ,co.grade_level AS Grade
      /*
      ,CASE         
        WHEN CONVERT(VARCHAR,s.transfercomment) LIKE 'Retain%' THEN 'Retained' 
        WHEN CONVERT(VARCHAR,s.transfercomment) LIKE 'Promote Same School%' THEN 'Promoted'
        WHEN CONVERT(VARCHAR,s.transfercomment) LIKE 'Promoted%' THEN 'Network 8th Gr Grad'
        WHEN CONVERT(VARCHAR,s.transfercomment) LIKE 'Demoted%' THEN 'Demoted'
        WHEN CONVERT(VARCHAR,cs.transfercomment) LIKE 'Re-enroll%' THEN 'Re-enrolled'
        ELSE 'New to Network'
       END AS Enroll_Status
       --*/      
      ,co.Advisor
      ,co.team AS [Travel Group]
      ,co.home_phone AS Home
      ,co.mother_cell AS [Mother Cell]
      ,co.father_cell AS [Father Cell]
      ,co.mother [Mother]
      ,co.father [Father]
      ,CONVERT(VARCHAR,co.DOB,101) AS DOB      
      ,co.Gender      
      ,co.Street
      ,co.City
      ,co.Zip
      ,co.GuardianEmail
      ,co.STUDENT_WEB_ID AS [Student Login]
      ,co.student_web_password AS [Student PW]
      ,co.family_web_id AS [Family Login]
      ,co.FAMILY_WEB_PASSWORD AS [Family PW]
      ,co.LUNCH_BALANCE AS [Lunch Balance]
      ,co.NEWARK_ENROLLMENT_NUMBER
FROM COHORT$identifiers_long#static co WITH(NOLOCK)
WHERE co.enroll_status = 0
  AND co.year = KIPP_NJ.dbo.fn_Global_Academic_Year() + 1
  AND co.rn = 1
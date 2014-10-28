USE KIPP_NJ
GO

ALTER VIEW REPORTING$student_contact_info AS

SELECT s.schoolid
      ,s.student_number AS SN
      ,s.lastfirst AS Name
      ,s.grade_level AS Grade
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
      ,cs.Advisor
      ,s.team AS [Travel Group]
      ,s.home_phone AS Home
      ,cs.mother_cell AS [Mother Cell]
      ,cs.father_cell AS [Father Cell]
      ,s.mother [Mother]
      ,s.father [Father]
      ,CONVERT(VARCHAR,s.DOB,101) AS DOB      
      ,s.Gender      
      ,s.Street
      ,s.City
      ,s.Zip
      ,blobs.GuardianEmail
      ,cs.default_student_web_id AS [Student Login]
      ,cs.default_student_web_password AS [Student PW]
      ,cs.DEFAULT_FAMILY_WEB_ID AS [Family Login]
      ,cs.DEFAULT_FAMILY_WEB_PASSWORD AS [Family PW]
FROM STUDENTS s WITH(NOLOCK)
LEFT OUTER JOIN CUSTOM_STUDENTS cs WITH(NOLOCK)
  ON s.id = cs.studentid
LEFT OUTER JOIN PS$student_BLObs#static blobs WITH(NOLOCK)
  ON s.id = blobs.STUDENTID
WHERE s.enroll_status = 0  
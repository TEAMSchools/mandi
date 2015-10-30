USE KIPP_NJ
GO

ALTER VIEW COMPLIANCE$KIPP_student_attrition AS

SELECT roster.d_schoolid
      ,roster.student_number
      ,roster.FIRST_NAME
      ,roster.MIDDLE_NAME
      ,roster.LAST_NAME
      ,roster.d_grade_level
      ,roster.ETHNICITY
      ,roster.GENDER      
      ,roster.DOB
      ,NULL AS NULL_FIELD --because KF has put a hidden column in the middle of the paste field
      ,roster.special_needs
      ,roster.entrydate
      ,CASE WHEN (roster.attr_flag = 1 OR roster.grad_flag = 1) THEN roster.exitdate ELSE NULL END AS exitdate
      ,roster.grad_flag
      ,CASE 
         WHEN  custom.transfer_kipp_code = 'Dropped out of school' THEN 1
         WHEN  custom.transfer_kipp_code = 'Family relocated home out of charter boundary or reasonable proximity to KIPP school' THEN 2
         WHEN  custom.transfer_kipp_code = 'Transportation issues' THEN 3 
         WHEN  custom.transfer_kipp_code = 'School expelled student' THEN 4
         WHEN  custom.transfer_kipp_code = 'Student left for social, emotional, behavioral reasons (please explain)' THEN 5
         WHEN  custom.transfer_kipp_code = 'Student left for academic reasons (please explain)' THEN 6
         WHEN  custom.transfer_kipp_code = 'Family withdrew student to avoid grade retention' THEN 7
         WHEN  custom.transfer_kipp_code = 'Due to special education needs' THEN 8
         WHEN  custom.transfer_kipp_code = 'Other (please explain)' THEN 9
         WHEN  custom.transfer_kipp_code = 'Transferred to another KIPP school' THEN 10
         ELSE NULL
       END AS Exit_Reason
	  ,'"' + CONVERT(VARCHAR,roster.EXITCOMMENT) + '"' AS exitcomment

FROM DEVFIN$mobility_long#KIPP roster WITH(NOLOCK) 

LEFT OUTER JOIN KIPP_NJ..PS$CUSTOM_STUDENTS#static custom WITH(NOLOCK)
  ON roster.d_studentid = custom.STUDENTID

WHERE YEAR = 2014


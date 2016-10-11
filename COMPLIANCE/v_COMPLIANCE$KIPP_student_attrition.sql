USE KIPP_NJ
GO

ALTER VIEW COMPLIANCE$KIPP_student_attrition AS

SELECT roster.year AS academic_year
      ,roster.d_schoolid AS schoolid
      ,roster.student_number AS student_id
      ,roster.FIRST_NAME
      ,roster.MIDDLE_NAME
      ,roster.LAST_NAME
      ,roster.d_grade_level AS grade_level
      ,CASE
        WHEN roster.ETHNICITY = 'I' THEN 1
        WHEN roster.ETHNICITY = 'A' THEN 2
        WHEN roster.ETHNICITY = 'B' THEN 3
        WHEN roster.ETHNICITY = 'H' THEN 4
        WHEN roster.ETHNICITY = 'P' THEN 5
        WHEN roster.ETHNICITY = 'W' THEN 6
        WHEN roster.ETHNICITY = 'T' THEN 9
       END AS race_id
      ,roster.GENDER      
      ,roster.DOB
      ,NULL AS NULL_FIELD --because KF has put a hidden column in the middle of the paste field
      ,roster.special_needs
      ,roster.school_entrydate AS entrydate
      ,CASE WHEN (roster.attr_flag = 1 OR roster.grad_flag = 1) THEN roster.exitdate END AS exitdate
      ,CASE WHEN roster.d_grade_level IN (4, 8, 12) AND roster.d_grade_level < roster.n_grade_level THEN 1 ELSE 0 END AS graduation
      ,CASE 
        WHEN roster.attr_flag = 0 THEN NULL
        WHEN custom.transfer_kipp_code = 'Dropped out of school' THEN 1
        WHEN custom.transfer_kipp_code = 'Family relocated home out of charter boundary or reasonable proximity to KIPP school' THEN 2
        WHEN custom.transfer_kipp_code = 'Transportation issues' THEN 3 
        WHEN custom.transfer_kipp_code = 'School expelled student' THEN 4
        WHEN custom.transfer_kipp_code = 'Student left for social, emotional, behavioral reasons (please explain)' THEN 5
        WHEN custom.transfer_kipp_code = 'Student left for academic reasons (please explain)' THEN 6
        WHEN custom.transfer_kipp_code = 'Family withdrew student to avoid grade retention' THEN 7
        WHEN custom.transfer_kipp_code = 'Due to special education needs' THEN 8
        WHEN custom.transfer_kipp_code = 'Other (please explain)' THEN 9
        WHEN custom.transfer_kipp_code = 'Don''t know (Please Explain)' THEN 10
        WHEN custom.transfer_kipp_code = 'Transferred to another KIPP school' THEN 11
       END AS exit_reason
	     ,CASE
        WHEN roster.d_grade_level IN (8, 12) AND roster.grad_flag = 1 THEN 'Non-KIPP'        
        WHEN roster.d_grade_level IN (4, 8) AND roster.d_grade_level < roster.n_grade_level AND s.enroll_status = 0 THEN 'KIPP'
        WHEN s.ENROLL_STATUS = 0 THEN NULL
        WHEN roster.attr_flag = 0 THEN NULL
        ELSE CONCAT('"', roster.EXITCOMMENT, '"')
       END AS exitcomment      
FROM DEVFIN$mobility_long#KIPP roster WITH(NOLOCK) 
LEFT OUTER JOIN KIPP_NJ..PS$STUDENTS#static s WITH(NOLOCK)
  ON roster.d_studentid = s.id
LEFT OUTER JOIN KIPP_NJ..PS$STUDENTS_custom#static custom WITH(NOLOCK)
  ON roster.d_studentid = custom.STUDENTID
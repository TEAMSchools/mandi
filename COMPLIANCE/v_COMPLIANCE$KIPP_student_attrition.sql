USE KIPP_NJ
GO

ALTER VIEW COMPLIANCE$KIPP_student_attrition AS

SELECT d_schoolid
      ,student_number
      ,FIRST_NAME
      ,MIDDLE_NAME
      ,LAST_NAME
      ,d_grade_level
      ,ETHNICITY
      ,GENDER      
      ,DOB
      ,NULL AS these_fucking_assholes_added_a_hidden_column_in_the_middle_of_the_goddamn_paste_range
      ,special_needs
      ,entrydate
      ,CASE WHEN (attr_flag = 1 OR grad_flag = 1) THEN exitdate ELSE NULL END AS exitdate
      ,grad_flag
      ,NULL AS exit_reason
      ,'"' + CONVERT(VARCHAR,EXITCOMMENT) + '"' AS exitcomment
FROM DEVFIN$mobility_long#KIPP
WHERE YEAR = 2013
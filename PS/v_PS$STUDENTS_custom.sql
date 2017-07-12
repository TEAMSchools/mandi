USE KIPP_NJ
GO

ALTER VIEW PS$STUDENTS_custom AS

SELECT *
FROM OPENQUERY(PS_TEAM,'
  SELECT s.ID AS STUDENTID
        ,nj.SpecialEd_Classification AS SPECIAL_EDUCATION        
        ,nj.PID_504_TF AS STATUS_504
        ,u.Middle_Name_Custom AS MIDDLE_NAME_CUSTOM        
        ,nj.CityOfBirth AS NJ_CityOfBirth
        ,nj.StateOfBirth AS NJ_StateOfBirth
        ,nj.CountryOfBirth AS NJ_COUNTRYOFBIRTH
        ,nj.LEPBeginDate AS NJ_LEPBeginDate
        ,nj.LEPEndDate AS NJ_LEPEndDate
        ,nj.Migrant_TF AS NJ_Migrant
        ,nj.programtypecode
        
        ,c.SPEDLEP
        ,nj.LEP_TF AS LEP_STATUS        
        ,nj.LEPBeginDate
        ,nj.LEPEndDate
        ,c.HOMELESS_CODE
        
        ,u.NEWARK_ENROLLMENT_NUMBER
        ,u.INFOSNAP_ID
        ,u.TRANSFER_KIPP_CODE
        ,u.CR_PREVSCHOOLNAME
        ,u.ADVISOR
        ,u.ADVISOR_EMAIL
        ,u.ADVISOR_CELL                
        ,u.DEFAULT_STUDENT_WEB_ID
        ,u.DEFAULT_STUDENT_WEB_PASSWORD
        ,u.DEFAULT_FAMILY_WEB_ID
        ,u.DEFAULT_FAMILY_WEB_PASSWORD                
        ,u.LUNCH_BALANCE
        ,u.INFOSNAP_OPT_IN
        ,u.FATHER_REGISTERED_TO_VOTE
        ,u.MOTHER_REGISTERED_TO_VOTE
  FROM STUDENTS s
  LEFT OUTER JOIN STUDENTCOREFIELDS c
    ON s.DCID = c.STUDENTSDCID
  LEFT OUTER JOIN U_STUDENTSUSERFIELDS u
    ON s.DCID = u.STUDENTSDCID  
  LEFT OUTER JOIN S_NJ_STU_X nj
    ON s.DCID = nj.StudentsDCID
')

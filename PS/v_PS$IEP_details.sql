USE KIPP_NJ
GO

ALTER VIEW PS$IEP_details AS

SELECT STUDENTID
      ,CONVERT(DATE,NJ_SE_REFERRALDATE) AS NJ_SE_REFERRALDATE
      ,CONVERT(DATE,NJ_SE_PARENTALCONSENTDATE) AS NJ_SE_PARENTALCONSENTDATE
      ,CONVERT(DATE,NJ_SE_ELIGIBILITYDDATE) AS NJ_SE_ELIGIBILITYDDATE
      ,NJ_SE_EARLYINTERVENTION
      ,CONVERT(DATE,NJ_SE_INITIALIEPMEETINGDATE) AS NJ_SE_INITIALIEPMEETINGDATE
      ,NJ_SE_PARENTALCONSENTOBTAINED
      ,CONVERT(DATE,NJ_SE_CONSENTTOIMPLEMENTDATE) AS NJ_SE_CONSENTTOIMPLEMENTDATE
      ,CONVERT(DATE,NJ_SE_LATESTIEPMEETINGDATE) AS NJ_SE_LATESTIEPMEETINGDATE
      ,SPECIAL_EDUCATION
      ,CONVERT(DATE,NJ_SE_REEVALUATIONDATE) AS NJ_SE_REEVALUATIONDATE
      ,NJ_SE_DELAYREASON
      ,CASE
        WHEN NJ_SE_PLACEMENT = 04 THEN 'Separate class'
        WHEN NJ_SE_PLACEMENT = 05 THEN 'Separate school'
        WHEN NJ_SE_PLACEMENT = 06 THEN 'Residential facility'
        WHEN NJ_SE_PLACEMENT = 07 THEN 'Home'
        WHEN NJ_SE_PLACEMENT = 08 THEN 'Services Provider Location'
        WHEN NJ_SE_PLACEMENT = 18 THEN 'At least 50% of the school week is spent in a regular education early childhood program or Kindergarten'
        WHEN NJ_SE_PLACEMENT = 19 THEN 'Less than 50% of the school week is spent in a regular education early childhood program or Kindergarten'
        WHEN NJ_SE_PLACEMENT = 09 THEN '80% or more of the school day in the presence of regular education students'
        WHEN NJ_SE_PLACEMENT = 10 THEN 'Between 40–79% of the school day in the presence of regular education students'
        WHEN NJ_SE_PLACEMENT = 11 THEN 'Less than 40% of the school day in the presence of regular educations students'
        WHEN NJ_SE_PLACEMENT = 12 THEN 'Public Separate School'
        WHEN NJ_SE_PLACEMENT = 13 THEN 'Private Day School'
        WHEN NJ_SE_PLACEMENT = 14 THEN 'Private Residential'
        WHEN NJ_SE_PLACEMENT = 15 THEN 'Public Residential'
        WHEN NJ_SE_PLACEMENT = 16 THEN 'Home Instruction'
        WHEN NJ_SE_PLACEMENT = 17 THEN 'Correctional Facility'
       END AS NJ_SE_PLACEMENT 
      ,NJ_TIMEINREGULARPROGRAM
      ,TI_SERV_COUNSELING
      ,TI_SERV_OCCUP
      ,TI_SERV_PHYSICAL
      ,TI_SERV_SPEECH
      ,TI_SERV_OTHER
      ,NJ_SE_INELIGIBLE
FROM OPENQUERY(PS_TEAM,'
  SELECT ID AS STUDENTID                
        ,PS_CUSTOMFIELDS.GETCF(''STUDENTS'',ID,''Nj_Se_Referraldate'') AS Nj_Se_Referraldate
        ,PS_CUSTOMFIELDS.GETCF(''STUDENTS'',ID,''Nj_Se_Parentalconsentdate'') AS Nj_Se_Parentalconsentdate
        ,PS_CUSTOMFIELDS.GETCF(''STUDENTS'',ID,''Nj_Se_Eligibilityddate'') AS Nj_Se_Eligibilityddate
        ,PS_CUSTOMFIELDS.GETCF(''STUDENTS'',ID,''Nj_Se_Earlyintervention'') AS Nj_Se_Earlyintervention
        ,PS_CUSTOMFIELDS.GETCF(''STUDENTS'',ID,''Nj_Se_Initialiepmeetingdate'') AS Nj_Se_Initialiepmeetingdate
        ,PS_CUSTOMFIELDS.GETCF(''STUDENTS'',ID,''Nj_Se_ParentalConsentobtained'') AS Nj_Se_ParentalConsentobtained
        ,PS_CUSTOMFIELDS.GETCF(''STUDENTS'',ID,''Nj_Se_Consenttoimplementdate'') AS Nj_Se_Consenttoimplementdate
        ,PS_CUSTOMFIELDS.GETCF(''STUDENTS'',ID,''Nj_Se_Latestiepmeetingdate'') AS Nj_Se_Latestiepmeetingdate
        ,PS_CUSTOMFIELDS.GETCF(''STUDENTS'',ID,''Special_Education'') AS Special_Education
        ,PS_CUSTOMFIELDS.GETCF(''STUDENTS'',ID,''Nj_Se_Reevaluationdate'') AS Nj_Se_Reevaluationdate
        ,PS_CUSTOMFIELDS.GETCF(''STUDENTS'',ID,''Nj_Se_Delayreason'') AS Nj_Se_Delayreason
        ,PS_CUSTOMFIELDS.GETCF(''STUDENTS'',ID,''Nj_Se_Placement'') AS Nj_Se_Placement
        ,PS_CUSTOMFIELDS.GETCF(''STUDENTS'',ID,''Nj_Timeinregularprogram'') AS Nj_Timeinregularprogram
        ,PS_CUSTOMFIELDS.GETCF(''STUDENTS'',ID,''Ti_Serv_Counseling'') AS Ti_Serv_Counseling
        ,PS_CUSTOMFIELDS.GETCF(''STUDENTS'',ID,''Ti_Serv_Occup'') AS Ti_Serv_Occup
        ,PS_CUSTOMFIELDS.GETCF(''STUDENTS'',ID,''Ti_Serv_Physical'') AS Ti_Serv_Physical
        ,PS_CUSTOMFIELDS.GETCF(''STUDENTS'',ID,''Ti_Serv_Speech'') AS Ti_Serv_Speech
        ,PS_CUSTOMFIELDS.GETCF(''STUDENTS'',ID,''Ti_Serv_Other'') AS Ti_Serv_Other
        ,PS_CUSTOMFIELDS.GETCF(''STUDENTS'',ID,''NJ_SE_Ineligible'') AS NJ_SE_Ineligible                
  FROM STUDENTS
  WHERE PS_CUSTOMFIELDS.GETCF(''STUDENTS'',ID,''Special_Education'') IS NOT NULL
')
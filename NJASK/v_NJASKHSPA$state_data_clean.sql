USE KIPP_NJ
GO

ALTER VIEW NJASKHSPA$state_data_clean AS

SELECT *
      ,ROUND((LAL_PP_pct / 100) * LAL_N_Valid,0) AS LAL_approx_N_PP
      ,ROUND((LAL_P_pct / 100) * LAL_N_Valid,0) AS LAL_approx_N_P
      ,ROUND((LAL_AP_pct / 100) * LAL_N_Valid,0) AS LAL_approx_N_AP
      ,ROUND((Math_PP_pct / 100) * Math_N_Valid,0) AS Math_approx_N_PP
      ,ROUND((Math_P_pct / 100) * Math_N_Valid,0) AS Math_approx_N_P
      ,ROUND((Math_AP_pct / 100) * Math_N_Valid,0) AS Math_approx_N_AP
      ,ROUND((SCI_PP_pct / 100) * SCI_N_Valid,0) AS SCI_approx_N_PP
      ,ROUND((SCI_P_pct / 100) * SCI_N_Valid,0) AS SCI_approx_N_P
      ,ROUND((SCI_AP_pct / 100) * SCI_N_Valid,0) AS SCI_approx_N_AP
FROM
    (
     SELECT CASE WHEN [CountyCodeDFGAgrgegationCode] = 'ST' THEN 99 ELSE CONVERT(INT,[CountyCodeDFGAgrgegationCode]) END AS county_code
           ,CASE WHEN [DistrictCode] IS NULL THEN 9999 ELSE [DistrictCode] END AS district_code
           ,CASE WHEN [SchoolCode] IS NULL THEN 999 ELSE SchoolCode END AS school_code      
           ,[TestingYear] AS academic_year
           ,[Grade] AS grade_level
           ,[TOTALPOPULATIONLANGUAGEARTSNumberofValidScaleScores] AS LAL_N_Valid
           ,(CONVERT(FLOAT,[TOTALPOPULATIONLANGUAGEARTSPartiallyProficientPercentage]) / 10) AS LAL_PP_pct
           ,(CONVERT(FLOAT,[TOTALPOPULATIONLANGUAGEARTSProficientPercentage]) / 10) AS LAL_P_pct
           ,(CONVERT(FLOAT,[TOTALPOPULATIONLANGUAGEARTSAdvancedProficientPercentage]) / 10) AS LAL_AP_pct
           ,(CONVERT(FLOAT,[TOTALPOPULATIONLANGUAGEARTSScaleScoreMean]) / 10) AS LAL_AvgScale
           ,[TOTALPOPULATIONMATHEMATICSNumberofValidScaleScores] AS Math_N_Valid
           ,(CONVERT(FLOAT,[TOTALPOPULATIONMATHEMATICSPartiallyProficientPercentage]) / 10) AS Math_PP_pct
           ,(CONVERT(FLOAT,[TOTALPOPULATIONMATHEMATICSProficientPercentage]) / 10) AS Math_P_pct
           ,(CONVERT(FLOAT,[TOTALPOPULATIONMATHEMATICSAdvancedProficientPercentage]) / 10) AS Math_AP_pct
           ,(CONVERT(FLOAT,[TOTALPOPULATIONMATHEMATICSScaleScoreMean]) / 10) AS Math_AvgScale
           ,[TOTALPOPULATIONSCIENCENumberofValidScaleScores] AS SCI_N_Valid
           ,(CONVERT(FLOAT,[TOTALPOPULATIONSCIENCEPartiallyProficientPercentage]) / 10) AS SCI_PP_pct
           ,(CONVERT(FLOAT,[TOTALPOPULATIONSCIENCEProficientPercentage]) / 10) AS SCI_P_pct
           ,(CONVERT(FLOAT,[TOTALPOPULATIONSCIENCEAdvancedProficientPercentage]) / 10) AS SCI_AP_pct
           ,(CONVERT(FLOAT,[TOTALPOPULATIONSCIENCEScaleScoreMean]) / 10) AS SCI_AvgScale        
     FROM NJ_DOE..final_df WITH(NOLOCK)
     WHERE TestingYear IS NOT NULL
       AND CountyCodeDFGAgrgegationCode NOT IN ('NS','SN','A','V','B','CD','DE','FG','GH','I','J','N','R')         
       
     UNION ALL

     SELECT CASE WHEN [County Code] = 'ST' THEN 99 ELSE CONVERT(INT,[County Code]) END AS county_code
           ,CASE WHEN [District Code] IS NULL THEN 9999 ELSE [District Code] END AS district_code
           ,CASE WHEN [School Code] IS NULL THEN 999 ELSE [School Code] END AS school_code      
           ,academic_year
           ,grade_level
           ,REPLACE([TotalValid ScaleELA],'*','') AS LAL_N_Valid
           ,(CONVERT(FLOAT,REPLACE([TotalPPELA],'*',''))) AS LAL_PP_pct
           ,(CONVERT(FLOAT,REPLACE([TotalPELA],'*',''))) AS LAL_P_pct
           ,(CONVERT(FLOAT,REPLACE([TotalAPELA],'*',''))) AS LAL_AP_pct
           ,(CONVERT(FLOAT,REPLACE([TotalMean ScaleELA],'*',''))) AS LAL_AvgScale
           ,REPLACE([TotalValid ScaleMath],'*','') AS Math_N_Valid
           ,(CONVERT(FLOAT,REPLACE([TotalPPMath],'*',''))) AS Math_PP_pct
           ,(CONVERT(FLOAT,REPLACE([TotalPMath],'*',''))) AS Math_P_pct
           ,(CONVERT(FLOAT,REPLACE([TotalAPMath],'*',''))) AS Math_AP_pct
           ,(CONVERT(FLOAT,REPLACE([TotalMean ScaleMath],'*',''))) AS Math_AvgScale
           ,REPLACE([TotalValid ScaleScie],'*','') AS SCI_N_Valid
           ,(CONVERT(FLOAT,REPLACE([TotalPPScie],'*',''))) AS SCI_PP_pct
           ,(CONVERT(FLOAT,REPLACE([TotalPScie],'*',''))) AS SCI_P_pct
           ,(CONVERT(FLOAT,REPLACE([TotalAPScie],'*',''))) AS SCI_AP_pct
           ,(CONVERT(FLOAT,REPLACE([TotalMean ScaleScie],'*',''))) AS SCI_AvgScale        
     FROM NJ_DOE..NJASK$state_data_raw WITH(NOLOCK)
     WHERE academic_year = 2013
       AND [County Code] NOT IN ('NS','SN','A','V','B','CD','DE','FG','GH','I','J','N','R')

     UNION ALL

     SELECT CASE WHEN [County Code] = 'ST' THEN 99 ELSE CONVERT(INT,[County Code]) END AS county_code
           ,CASE WHEN [District Code] IS NULL THEN 9999 ELSE [District Code] END AS district_code
           ,CASE WHEN [School Code] IS NULL THEN 999 ELSE [School Code] END AS school_code      
           ,academic_year
           ,grade_level
           ,REPLACE([Total Valid Scale LANG],'*','') AS LAL_N_Valid
           ,(CONVERT(FLOAT,REPLACE([Total PP LANG],'*',''))) AS LAL_PP_pct
           ,(CONVERT(FLOAT,REPLACE([Total P LANG],'*',''))) AS LAL_P_pct
           ,(CONVERT(FLOAT,REPLACE([Total AP LANG],'*',''))) AS LAL_AP_pct
           ,(CONVERT(FLOAT,REPLACE([Total Scale LANG],'*',''))) AS LAL_AvgScale
           ,REPLACE([Total Valid Scale Math],'*','') AS Math_N_Valid
           ,(CONVERT(FLOAT,REPLACE([Total PP Math],'*',''))) AS Math_PP_pct
           ,(CONVERT(FLOAT,REPLACE([Total P Math],'*',''))) AS Math_P_pct
           ,(CONVERT(FLOAT,REPLACE([Total AP Math],'*',''))) AS Math_AP_pct
           ,(CONVERT(FLOAT,REPLACE([Total Scale Math],'*',''))) AS Math_AvgScale
           ,REPLACE([Total Valid Scale Scie],'*','') AS SCI_N_Valid
           ,(CONVERT(FLOAT,REPLACE([Total PP Scie],'*',''))) AS SCI_PP_pct
           ,(CONVERT(FLOAT,REPLACE([Total P Scie],'*',''))) AS SCI_P_pct
           ,(CONVERT(FLOAT,REPLACE([Total AP Scie],'*',''))) AS SCI_AP_pct
           ,(CONVERT(FLOAT,REPLACE([Total Scale Scie],'*',''))) AS SCI_AvgScale        
     FROM NJ_DOE..HSPA$state_data_raw WITH(NOLOCK)
     WHERE academic_year = 2013
       AND [County Code] NOT IN ('FG','GH','I','J','N','O','R','V','NS','SN','A','B','CD','DE')
    ) sub
--WHERE district_code IN (3310,3570,9999,6212)
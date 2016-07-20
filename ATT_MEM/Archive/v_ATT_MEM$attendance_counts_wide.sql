USE KIPP_NJ
GO

ALTER VIEW ATT_MEM$attendance_counts_wide AS 

WITH att_long AS (
  SELECT studentid
        ,academic_year
        --,term
        ,CONCAT(field,'_',rt) AS pivot_field
        ,CONVERT(FLOAT,value) AS value
  FROM
      (
       SELECT studentid
             ,academic_year
             ,rt
             ,A_counts_term
             ,AD_counts_term
             ,AE_counts_term
             ,ISS_counts_term
             ,OSS_counts_term
             ,T_counts_term
             ,T10_counts_term
             ,TE_counts_term
             ,MEM_counts_term
             ,ABS_all_counts_term
             ,TDY_all_counts_term
       FROM KIPP_NJ..ATT_MEM$attendance_counts_long#static WITH(NOLOCK)  
       WHERE MEM_counts_term > 0
      ) sub
  UNPIVOT(
    value
    FOR field IN (A_counts_term
                 ,AD_counts_term
                 ,AE_counts_term
                 ,ISS_counts_term
                 ,OSS_counts_term
                 ,T_counts_term
                 ,T10_counts_term
                 ,TE_counts_term
                 ,MEM_counts_term
                 ,ABS_all_counts_term
                 ,TDY_all_counts_term)
   ) u  
 )

SELECT studentid
      ,academic_year
      --,term
      ,MAX([A_counts_term_RT1]) OVER(PARTITION BY studentid, academic_year) AS A_counts_term_RT1
      ,MAX([A_counts_term_RT2]) OVER(PARTITION BY studentid, academic_year) AS A_counts_term_RT2
      ,MAX([A_counts_term_RT3]) OVER(PARTITION BY studentid, academic_year) AS A_counts_term_RT3
      ,MAX([A_counts_term_RT4]) OVER(PARTITION BY studentid, academic_year) AS A_counts_term_RT4
      ,MAX([A_counts_term_RT5]) OVER(PARTITION BY studentid, academic_year) AS A_counts_term_RT5
      ,MAX([ABS_all_counts_term_RT1]) OVER(PARTITION BY studentid, academic_year) AS ABS_all_counts_term_RT1
      ,MAX([ABS_all_counts_term_RT2]) OVER(PARTITION BY studentid, academic_year) AS ABS_all_counts_term_RT2
      ,MAX([ABS_all_counts_term_RT3]) OVER(PARTITION BY studentid, academic_year) AS ABS_all_counts_term_RT3
      ,MAX([ABS_all_counts_term_RT4]) OVER(PARTITION BY studentid, academic_year) AS ABS_all_counts_term_RT4
      ,MAX([ABS_all_counts_term_RT5]) OVER(PARTITION BY studentid, academic_year) AS ABS_all_counts_term_RT5
      ,MAX([AD_counts_term_RT1]) OVER(PARTITION BY studentid, academic_year) AS AD_counts_term_RT1
      ,MAX([AD_counts_term_RT2]) OVER(PARTITION BY studentid, academic_year) AS AD_counts_term_RT2
      ,MAX([AD_counts_term_RT3]) OVER(PARTITION BY studentid, academic_year) AS AD_counts_term_RT3
      ,MAX([AD_counts_term_RT4]) OVER(PARTITION BY studentid, academic_year) AS AD_counts_term_RT4
      ,MAX([AD_counts_term_RT5]) OVER(PARTITION BY studentid, academic_year) AS AD_counts_term_RT5
      ,MAX([AE_counts_term_RT1]) OVER(PARTITION BY studentid, academic_year) AS AE_counts_term_RT1
      ,MAX([AE_counts_term_RT2]) OVER(PARTITION BY studentid, academic_year) AS AE_counts_term_RT2
      ,MAX([AE_counts_term_RT3]) OVER(PARTITION BY studentid, academic_year) AS AE_counts_term_RT3
      ,MAX([AE_counts_term_RT4]) OVER(PARTITION BY studentid, academic_year) AS AE_counts_term_RT4
      ,MAX([AE_counts_term_RT5]) OVER(PARTITION BY studentid, academic_year) AS AE_counts_term_RT5
      ,MAX([ISS_counts_term_RT1]) OVER(PARTITION BY studentid, academic_year) AS ISS_counts_term_RT1
      ,MAX([ISS_counts_term_RT2]) OVER(PARTITION BY studentid, academic_year) AS ISS_counts_term_RT2
      ,MAX([ISS_counts_term_RT3]) OVER(PARTITION BY studentid, academic_year) AS ISS_counts_term_RT3
      ,MAX([ISS_counts_term_RT4]) OVER(PARTITION BY studentid, academic_year) AS ISS_counts_term_RT4
      ,MAX([ISS_counts_term_RT5]) OVER(PARTITION BY studentid, academic_year) AS ISS_counts_term_RT5
      ,MAX([MEM_counts_term_RT1]) OVER(PARTITION BY studentid, academic_year) AS MEM_counts_term_RT1
      ,MAX([MEM_counts_term_RT2]) OVER(PARTITION BY studentid, academic_year) AS MEM_counts_term_RT2
      ,MAX([MEM_counts_term_RT3]) OVER(PARTITION BY studentid, academic_year) AS MEM_counts_term_RT3
      ,MAX([MEM_counts_term_RT4]) OVER(PARTITION BY studentid, academic_year) AS MEM_counts_term_RT4
      ,MAX([MEM_counts_term_RT5]) OVER(PARTITION BY studentid, academic_year) AS MEM_counts_term_RT5
      ,MAX([OSS_counts_term_RT1]) OVER(PARTITION BY studentid, academic_year) AS OSS_counts_term_RT1
      ,MAX([OSS_counts_term_RT2]) OVER(PARTITION BY studentid, academic_year) AS OSS_counts_term_RT2
      ,MAX([OSS_counts_term_RT3]) OVER(PARTITION BY studentid, academic_year) AS OSS_counts_term_RT3
      ,MAX([OSS_counts_term_RT4]) OVER(PARTITION BY studentid, academic_year) AS OSS_counts_term_RT4
      ,MAX([OSS_counts_term_RT5]) OVER(PARTITION BY studentid, academic_year) AS OSS_counts_term_RT5
      ,MAX([T_counts_term_RT1]) OVER(PARTITION BY studentid, academic_year) AS T_counts_term_RT1
      ,MAX([T_counts_term_RT2]) OVER(PARTITION BY studentid, academic_year) AS T_counts_term_RT2
      ,MAX([T_counts_term_RT3]) OVER(PARTITION BY studentid, academic_year) AS T_counts_term_RT3
      ,MAX([T_counts_term_RT4]) OVER(PARTITION BY studentid, academic_year) AS T_counts_term_RT4
      ,MAX([T_counts_term_RT5]) OVER(PARTITION BY studentid, academic_year) AS T_counts_term_RT5
      ,MAX([T10_counts_term_RT1]) OVER(PARTITION BY studentid, academic_year) AS T10_counts_term_RT1
      ,MAX([T10_counts_term_RT2]) OVER(PARTITION BY studentid, academic_year) AS T10_counts_term_RT2
      ,MAX([T10_counts_term_RT3]) OVER(PARTITION BY studentid, academic_year) AS T10_counts_term_RT3
      ,MAX([T10_counts_term_RT4]) OVER(PARTITION BY studentid, academic_year) AS T10_counts_term_RT4
      ,MAX([T10_counts_term_RT5]) OVER(PARTITION BY studentid, academic_year) AS T10_counts_term_RT5
      ,MAX([TDY_all_counts_term_RT1]) OVER(PARTITION BY studentid, academic_year) AS TDY_all_counts_term_RT1
      ,MAX([TDY_all_counts_term_RT2]) OVER(PARTITION BY studentid, academic_year) AS TDY_all_counts_term_RT2
      ,MAX([TDY_all_counts_term_RT3]) OVER(PARTITION BY studentid, academic_year) AS TDY_all_counts_term_RT3
      ,MAX([TDY_all_counts_term_RT4]) OVER(PARTITION BY studentid, academic_year) AS TDY_all_counts_term_RT4
      ,MAX([TDY_all_counts_term_RT5]) OVER(PARTITION BY studentid, academic_year) AS TDY_all_counts_term_RT5
      ,MAX([TE_counts_term_RT1]) OVER(PARTITION BY studentid, academic_year) AS TE_counts_term_RT1
      ,MAX([TE_counts_term_RT2]) OVER(PARTITION BY studentid, academic_year) AS TE_counts_term_RT2
      ,MAX([TE_counts_term_RT3]) OVER(PARTITION BY studentid, academic_year) AS TE_counts_term_RT3
      ,MAX([TE_counts_term_RT4]) OVER(PARTITION BY studentid, academic_year) AS TE_counts_term_RT4
      ,MAX([TE_counts_term_RT5]) OVER(PARTITION BY studentid, academic_year) AS TE_counts_term_RT5
FROM att_long
PIVOT(
  MAX(value)
  FOR pivot_field IN ([A_counts_term_RT1]
                     ,[A_counts_term_RT2]
                     ,[A_counts_term_RT3]
                     ,[A_counts_term_RT4]
                     ,[A_counts_term_RT5]
                     ,[ABS_all_counts_term_RT1]
                     ,[ABS_all_counts_term_RT2]
                     ,[ABS_all_counts_term_RT3]
                     ,[ABS_all_counts_term_RT4]
                     ,[ABS_all_counts_term_RT5]
                     ,[AD_counts_term_RT1]
                     ,[AD_counts_term_RT2]
                     ,[AD_counts_term_RT3]
                     ,[AD_counts_term_RT4]
                     ,[AD_counts_term_RT5]
                     ,[AE_counts_term_RT1]
                     ,[AE_counts_term_RT2]
                     ,[AE_counts_term_RT3]
                     ,[AE_counts_term_RT4]
                     ,[AE_counts_term_RT5]
                     ,[ISS_counts_term_RT1]
                     ,[ISS_counts_term_RT2]
                     ,[ISS_counts_term_RT3]
                     ,[ISS_counts_term_RT4]
                     ,[ISS_counts_term_RT5]
                     ,[MEM_counts_term_RT1]
                     ,[MEM_counts_term_RT2]
                     ,[MEM_counts_term_RT3]
                     ,[MEM_counts_term_RT4]
                     ,[MEM_counts_term_RT5]
                     ,[OSS_counts_term_RT1]
                     ,[OSS_counts_term_RT2]
                     ,[OSS_counts_term_RT3]
                     ,[OSS_counts_term_RT4]
                     ,[OSS_counts_term_RT5]
                     ,[T_counts_term_RT1]
                     ,[T_counts_term_RT2]
                     ,[T_counts_term_RT3]
                     ,[T_counts_term_RT4]
                     ,[T_counts_term_RT5]
                     ,[T10_counts_term_RT1]
                     ,[T10_counts_term_RT2]
                     ,[T10_counts_term_RT3]
                     ,[T10_counts_term_RT4]
                     ,[T10_counts_term_RT5]
                     ,[TDY_all_counts_term_RT1]
                     ,[TDY_all_counts_term_RT2]
                     ,[TDY_all_counts_term_RT3]
                     ,[TDY_all_counts_term_RT4]
                     ,[TDY_all_counts_term_RT5]
                     ,[TE_counts_term_RT1]
                     ,[TE_counts_term_RT2]
                     ,[TE_counts_term_RT3]
                     ,[TE_counts_term_RT4]
                     ,[TE_counts_term_RT5])
 ) p
USE KIPP_NJ
GO

ALTER VIEW ATT_MEM$attendance_percentages_long AS

SELECT studentid
      ,academic_year
      ,rt
      ,term
      
      ,ROUND(100 - ((ABS_all_counts_term / mem_counts_term) * 100),0) AS ABS_all_pct_term
      ,ROUND(100 - ((ABS_all_counts_yr / mem_counts_yr) * 100),0) AS ABS_all_pct_yr      
      ,ROUND((TDY_all_counts_term / mem_counts_term) * 100,0) AS TDY_all_pct_term
      ,ROUND((TDY_all_counts_yr / mem_counts_yr) * 100,0) AS TDY_all_pct_yr

      ,(A_counts_term / mem_counts_term) * 100 AS A_pct_term
      ,(A_counts_yr / mem_counts_yr) * 100 AS A_pct_yr      
      ,(AD_counts_term / mem_counts_term) * 100 AS AD_pct_term
      ,(AD_counts_yr / mem_counts_yr) * 100 AS AD_pct_yr
      ,(AE_counts_term / mem_counts_term) * 100 AS AE_pct_term
      ,(AE_counts_yr / mem_counts_yr) * 100 AS AE_pct_yr
      ,(ISS_counts_term / mem_counts_term) * 100 AS ISS_pct_term
      ,(ISS_counts_yr / mem_counts_yr) * 100 AS ISS_pct_yr      
      ,(OSS_counts_term / mem_counts_term) * 100 AS OSS_pct_term
      ,(OSS_counts_yr / mem_counts_yr) * 100 AS OSS_pct_yr
      ,(T_counts_term / mem_counts_term) * 100 AS T_pct_term
      ,(T_counts_yr / mem_counts_yr) * 100 AS T_pct_yr
      ,(T10_counts_term / mem_counts_term) * 100 AS T10_pct_term
      ,(T10_counts_yr / mem_counts_yr) * 100 AS T10_pct_yr      
      ,(TE_counts_term / mem_counts_term) * 100 AS TE_pct_term
      ,(TE_counts_yr / mem_counts_yr) * 100 AS TE_pct_yr      
FROM KIPP_NJ..ATT_MEM$attendance_counts_long#static WITH(NOLOCK)
WHERE mem_counts_term > 0
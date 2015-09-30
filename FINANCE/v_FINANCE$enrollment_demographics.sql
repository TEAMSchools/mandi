USE KIPP_NJ
GO

ALTER VIEW FINANCE$enrollment_demographics AS

SELECT year + 1 AS fiscal_year
      ,date
      ,school_name
      ,grade_level
      ,COUNT(student_number) AS enrollment
      ,SUM(CASE WHEN lunchstatus IN ('F','R') THEN 1 ELSE 0 END) AS N_FR_lunch
      ,SUM(CASE WHEN spedlep = 'SPED' THEN 1 ELSE 0 END) AS N_SPED
      ,SUM(CASE WHEN spedlep = 'SPED SPEECH' THEN 1 ELSE 0 END) AS N_SPEECH      
      ,SUM(CONVERT(INT,ISNULL(lep_status,0))) AS N_LEP      
      ,CASE WHEN CONVERT(DATE,date) LIKE '%-10-15' THEN 1 ELSE 0 END AS is_oct_15      
      ,CASE WHEN date = MAX(date) OVER(PARTITION BY school_name, grade_level) THEN 1 ELSE 0 END AS is_most_recent
FROM KIPP_NJ..COHORT$identifiers_scaffold#static WITH(NOLOCK)
WHERE CONVERT(DATE,date) <= CONVERT(DATE,GETDATE())
  AND ((CONVERT(DATE,date) = CONVERT(DATE,CONVERT(VARCHAR,year) + '-10-15')) OR (DATEPART(DW,CONVERT(DATE,date)) = 6))
GROUP BY year
        ,date
        ,school_name
        ,grade_level
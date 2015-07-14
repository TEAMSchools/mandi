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
      --,LEP_STATUS
      ,CASE WHEN date LIKE '%-10-15' THEN 1 ELSE 0 END AS is_oct_15
      --,CASE WHEN date = CONVERT(DATE,SYSDATETIME()) THEN 1 ELSE 0 END AS is_today
      ,CASE WHEN date = MAX(date) OVER(PARTITION BY school_name, grade_level) THEN 1 ELSE 0 END AS is_most_recent
FROM KIPP_NJ..COHORT$identifiers_scaffold#static WITH(NOLOCK)
WHERE (date = CONVERT(DATE,CONCAT(year,'-10-15')) OR DATEPART(DW,date) = 6)
GROUP BY year, date, school_name, grade_level
--ORDER BY date, school_name
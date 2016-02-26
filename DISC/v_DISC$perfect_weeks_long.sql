USE KIPP_NJ
GO

ALTER VIEW DISC$perfect_weeks_long AS

SELECT *
      ,SUM(perfect_week_merits_term) OVER(PARTITION BY student_number, academic_year ORDER BY rt) AS perfect_week_merits_yr
FROM
    (
     SELECT student_number
           ,studentid
           ,academic_year
           ,term
           ,rt
           ,SUM(is_perfect) AS n_perfect_weeks
           ,SUM(is_perfect) * 3 AS perfect_week_merits_term
     FROM KIPP_NJ..DISC$perfect_weeks#static WITH(NOLOCK)
     GROUP BY student_number
             ,studentid
             ,academic_year
             ,rt
             ,term
    ) sub
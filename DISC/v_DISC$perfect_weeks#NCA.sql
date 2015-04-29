USE KIPP_NJ
GO

ALTER VIEW DISC$perfect_weeks#NCA AS

SELECT sub.studentid
      ,sub.student_number
      ,sub.academic_year
      ,SUM(is_perfect) AS perfect_wks_y1
      ,SUM(is_perfect_rt1) AS perfect_wks_rt1
      ,SUM(is_perfect_rt2) AS perfect_wks_rt2
      ,SUM(is_perfect_rt3) AS perfect_wks_rt3
      ,SUM(is_perfect_rt4) AS perfect_wks_rt4
      ,SUM(is_perfect_cur) AS perfect_wks_cur
FROM
    (
     SELECT student_number
           ,studentid
           ,academic_year
           ,rt           
           ,week_of
           ,is_perfect
           ,is_perfect_cur
           ,CASE WHEN rt = 'RT1' THEN ISNULL(is_perfect, 1) ELSE NULL END AS is_perfect_rt1
           ,CASE WHEN rt = 'RT2' THEN ISNULL(is_perfect, 1) ELSE NULL END AS is_perfect_rt2
           ,CASE WHEN rt = 'RT3' THEN ISNULL(is_perfect, 1) ELSE NULL END AS is_perfect_rt3
           ,CASE WHEN rt = 'RT4' THEN ISNULL(is_perfect, 1) ELSE NULL END AS is_perfect_rt4           
     FROM DISC$perfect_weeks#static WITH(NOLOCK)
     WHERE academic_year = KIPP_NJ.dbo.fn_Global_Academic_Year()
    ) sub
GROUP BY sub.studentid
        ,sub.student_number
        ,sub.academic_year
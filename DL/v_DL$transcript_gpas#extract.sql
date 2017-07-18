USE KIPP_NJ
GO

ALTER VIEW DL$transcript_gpas#extract AS

SELECT student_number
      ,academic_year
      ,GPA_Y1 AS GPA_Y1_weighted
      ,GPA_Y1_unweighted
FROM KIPP_NJ..GRADES$GPA_detail_long#static WITH(NOLOCK)
WHERE is_curterm = 1
  AND academic_year < KIPP_NJ.dbo.fn_Global_Academic_Year()

UNION ALL

SELECT co.student_number
      ,co.year AS academic_year
      ,sg.cumulative_y1_gpa AS GPA_Y1_weighted
      ,sg.cumulative_y1_gpa_unweighted AS GPA_Y1_unweighted
FROM KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK)
JOIN KIPP_NJ..GRADES$GPA_cumulative#static sg WITH(NOLOCK)
  ON co.studentid = sg.studentid
 AND co.schoolid = sg.schoolid
WHERE co.year = KIPP_NJ.dbo.fn_Global_Academic_Year()
  AND co.rn = 1
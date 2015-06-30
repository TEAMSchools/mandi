USE KIPP_NJ
GO

ALTER VIEW LIT$STEP_growth_measures_long AS

SELECT lit_base.studentid
      ,lit_base.schoolid
      ,lit_base.grade_level
      ,lit_base.academic_year AS year
      ,lit_base.lastfirst
      ,lit_base.student_number
      ,lit_base.lvl_num AS base_step
      ,lit_end.lvl_num AS end_step
      ,CONVERT(INT,lit_end.lvl_num) - CONVERT(INT,lit_base.lvl_num) AS step_change
FROM LIT$test_events#identifiers lit_base WITH(NOLOCK)
LEFT OUTER JOIN LIT$test_events#identifiers lit_end WITH(NOLOCK)
  ON lit_base.studentid = lit_end.studentid
 AND lit_base.academic_year = lit_end.academic_year
 AND lit_end.achv_curr_yr = 1
WHERE lit_base.academic_year IS NOT NULL
  AND lit_base.achv_base_yr = 1
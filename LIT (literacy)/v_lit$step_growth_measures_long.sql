USE KIPP_NJ
GO

CREATE VIEW lit$step_growth_measures_long AS
SELECT lit_base.studentid
      ,lit_base.schoolid
      ,lit_base.grade_level
      ,lit_base.year
      ,lit_base.lastfirst
      ,lit_base.student_number
      ,lit_base.step_level_numeric AS base_step
      ,lit_end.step_level_numeric AS end_step
FROM LIT$step_headline_long#identifiers lit_base
LEFT OUTER JOIN LIT$step_headline_long#identifiers lit_end
  ON lit_base.studentid = lit_end.studentid
  AND lit_base.year = lit_end.year
  AND lit_end.status = 'Achieved'
  AND lit_end.rn_desc = 1
WHERE lit_base.[status] = 'Achieved'
  AND lit_base.rn_asc = 1
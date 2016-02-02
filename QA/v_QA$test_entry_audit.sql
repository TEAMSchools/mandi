USE KIPP_NJ
GO

ALTER VIEW LIT$test_entry_audit AS

WITH latest_entry AS (
  SELECT student_number
        ,test_round
        ,read_lvl            
        ,unique_id
        ,ROW_NUMBER() OVER(
           PARTITION BY student_number, test_round
             ORDER BY status, lvl_num DESC, test_date DESC) AS rn
  FROM KIPP_NJ..LIT$test_events#identifiers WITH(NOLOCK)
  WHERE curr_round = 1
    AND academic_year = KIPP_NJ.dbo.fn_Global_Academic_Year()
 )

SELECT co.year AS academic_year
      ,co.student_number
      ,co.studentid
      ,co.lastfirst
      ,CASE WHEN co.team LIKE '%pathways%' THEN 732570 ELSE co.schoolid END AS schoolid
      ,co.grade_level
      ,co.team
      ,co.enroll_status
      ,a.test_round            
      ,CASE WHEN a.start_date <= CONVERT(DATE,GETDATE()) THEN 1 ELSE 0 END AS is_current
      ,a.read_lvl
      ,a.met_goal
      ,a.unique_id
      ,rs.academic_year AS record_academic_year
      ,rs.test_round AS record_test_round
      ,l.read_lvl AS term_read_lvl
      ,l.unique_id AS term_unique_id
FROM KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK)
JOIN KIPP_NJ..LIT$achieved_by_round#static a WITH(NOLOCK)
  ON co.studentid = a.STUDENTID
 AND co.year = a.academic_year
LEFT OUTER JOIN KIPP_NJ..LIT$test_events#identifiers rs WITH(NOLOCK)
  ON a.unique_id = rs.unique_id
LEFT OUTER JOIN latest_entry l
  ON co.student_number = l.student_number
 AND a.test_round = l.test_round
 AND l.rn = 1
WHERE co.year = KIPP_NJ.dbo.fn_Global_Academic_Year()
  AND co.rn = 1
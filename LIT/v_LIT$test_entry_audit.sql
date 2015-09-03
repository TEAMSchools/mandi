USE KIPP_NJ
GO

ALTER VIEW LIT$test_entry_audit AS

SELECT co.year AS academic_year
      ,co.schoolid
      ,co.grade_level      
      ,co.team
      ,co.LASTFIRST
      ,a.test_round      
      ,CASE WHEN a.start_date <= GETDATE() THEN 1 ELSE 0 END AS is_current
      ,rs.academic_year AS record_academic_year
      ,rs.test_round AS record_test_round
FROM COHORT$identifiers_long#static co WITH(NOLOCK)
JOIN KIPP_NJ..LIT$achieved_by_round#static a WITH(NOLOCK)
  ON co.studentid = a.STUDENTID
 AND co.year = a.academic_year
LEFT OUTER JOIN KIPP_NJ..LIT$test_events#identifiers rs WITH(NOLOCK)
  ON a.unique_id = rs.unique_id
WHERE co.year = KIPP_NJ.dbo.fn_Global_Academic_Year()
  AND co.rn = 1
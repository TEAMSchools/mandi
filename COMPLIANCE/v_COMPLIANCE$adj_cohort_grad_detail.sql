USE KIPP_NJ
GO

ALTER VIEW COMPLIANCE$adj_cohort_grad_detail AS

-- first year at NCA, cohort assigned upon entry expecting 4-year graduation
WITH baseline AS ( 
  SELECT studentid
        ,student_number        
        ,entry_school_name
        ,grade_level
        ,year
        ,year + (12 - grade_level) + 1 AS DOE_cohort
  FROM
      (
       SELECT studentid
             ,STUDENT_NUMBER
             ,lastfirst
             ,entry_school_name
             ,grade_level
             ,year
             ,cohort
             ,ROW_NUMBER() OVER(
                PARTITION BY studentid
                  ORDER BY year ASC) AS first_hs_yr
       FROM COHORT$identifiers_long#static WITH(NOLOCK)
       WHERE schoolid = 73253
         AND rn = 1
      ) sub
  WHERE first_hs_yr = 1
 )

-- last year a student was enrolled with us
,ultimate_year AS (
  SELECT *
  FROM
      (
       SELECT co.studentid
             ,co.STUDENT_NUMBER
             ,co.lastfirst
             ,co.year
             ,co.cohort
             ,co.grade_level
             ,co.exitcode             
             ,co.highest_achieved
             ,ROW_NUMBER() OVER(
                PARTITION BY co.studentid
                  ORDER BY co.year DESC) AS rn
       FROM COHORT$comprehensive_long#static co WITH(NOLOCK)
       WHERE co.grade_level >= 9
         AND co.grade_level < 99
         AND co.rn = 1                
      ) sub
  WHERE rn = 1  
 )
 
SELECT *
      ,CASE 
        WHEN is_dropout = 1 THEN 0
        WHEN is_grad = 1 AND yrs_in_hs <= 4 THEN 1 
        WHEN is_grad = 1 AND yrs_in_hs > 4 THEN 0
        ELSE 0
       END AS on_time_grad
FROM
    (
     SELECT f.studentid
           ,f.STUDENT_NUMBER
           ,u.lastfirst
           ,f.DOE_cohort
           ,f.entry_school_name
           ,f.year AS first_year
           ,u.year AS final_year      
           ,u.year - f.year + 1 + (f.grade_level - 9) AS yrs_in_hs -- adjusts for transfers in
           ,u.highest_achieved
           ,ISNULL(u.exitcode,'CURRENT') AS exitcode
           ,f.grade_level AS entry_grade
           ,u.grade_level AS exit_grade
           ,CASE WHEN u.exitcode IN ('D1','D2','D3','D4','D5','D6','D7','D8','D10','D11') THEN 1 ELSE 0 END AS is_dropout
           ,CASE WHEN u.exitcode IN ('D9', 'T3', 'T8', 'T9', 'TP') THEN 1 ELSE 0 END AS is_excluded
           ,CASE WHEN u.exitcode IN ('T4', 'T6', 'T7', 'TC', 'TD', 'TA') THEN 1 ELSE 0 END AS verified_transf
           ,CASE WHEN u.highest_achieved = 99 THEN 1 ELSE 0 END AS is_grad
     FROM baseline f
     JOIN ultimate_year u
       ON f.studentid = u.studentid
    ) sub
WHERE DOE_cohort <= dbo.fn_Global_Academic_Year()
  --AND is_excluded = 0
USE KIPP_NJ
GO

ALTER VIEW ENROLL$NPS_magnet_app AS

WITH njask AS (
  SELECT studentid
        ,[ELA_1] AS LAL_scale_prev1
        ,[ELA_2] AS LAL_scale_prev2
        ,[Math_1] AS MATH_scale_prev1
        ,[Math_2] AS MATH_scale_prev2
  FROM
      (
       SELECT studentid
             ,scale_score
             ,subject + '_' + CONVERT(VARCHAR,rn) AS pivot_hash
       FROM
           (
            SELECT studentid           
                  ,subject
                  ,njask_scale_score AS scale_score
                  ,ROW_NUMBER() OVER(
                     PARTITION BY studentid, subject
                       ORDER BY academic_year DESC) AS rn
            FROM KIPP_NJ..NJASK$detail WITH(NOLOCK)
            WHERE academic_year >= (KIPP_NJ.dbo.fn_Global_Academic_Year() - 2)
           ) sub
      ) sub
  PIVOT(
    MAX(scale_score)
    FOR pivot_hash IN ([ELA_1],[ELA_2],[Math_1],[Math_2])
   ) p
 )

,curr_grades AS (
  SELECT studentid
        ,COALESCE([ENG_T1], [ENG_Q1]) AS READ_MP1
        ,COALESCE([ENG_T2], [ENG_Q2]) AS READ_MP2
        ,COALESCE([MATH_T1],[MATH_Q1]) AS MATH_MP1
        ,COALESCE([MATH_T2], [MATH_Q2]) AS MATH_MP2
        ,COALESCE([SCI_T1], [SCI_Q1]) AS SCI_MP1
        ,COALESCE([SCI_T2], [SCI_Q2]) AS SCI_MP2
        ,COALESCE([SOC_T1], [SOC_Q1]) AS SOC_MP1
        ,COALESCE([SOC_T2], [SOC_Q2]) AS SOC_MP2
  FROM
      (
       SELECT studentid
             ,credittype + '_' + term AS pivot_hash
             ,term_pct
       FROM KIPP_NJ..GRADES$detail_long WITH(NOLOCK)
       WHERE CREDITTYPE IN ('MATH','ENG','SCI','SOC')
         AND term IN ('T1','T2','Q1','Q2')
      ) sub
  PIVOT(
    MAX(term_pct)
    FOR pivot_hash IN ([ENG_T1]
                      ,[ENG_T2]
                      ,[MATH_T1]
                      ,[MATH_T2]
                      ,[SCI_T1]
                      ,[SCI_T2]
                      ,[SOC_T1]
                      ,[SOC_T2]
                      ,[ENG_Q1]
                      ,[ENG_Q2]
                      ,[MATH_Q1]
                      ,[MATH_Q2]
                      ,[SCI_Q1]
                      ,[SCI_Q2]
                      ,[SOC_Q1]
                      ,[SOC_Q2])
   ) p
 )

,stored_grades AS (
  SELECT studentid
        ,[ENG_Y1_prev]
        ,[MATH_Y1_prev]
        ,[SCI_Y1_prev]
        ,[SOC_Y1_prev]
  FROM
      (
       SELECT studentid
             ,CREDITTYPE + '_Y1_prev' AS pivot_hash
             ,grade_pct
       FROM KIPP_NJ..GRADES$storedgrades#identifiers WITH(NOLOCK)
       WHERE academic_year = (KIPP_NJ.dbo.fn_Global_Academic_Year() - 1)
         AND CREDITTYPE IN ('MATH','ENG','SCI','SOC')
         AND term = 'Y1'
      ) sub
  PIVOT(
    MAX(grade_pct)
    FOR pivot_hash IN ([ENG_Y1_prev]
                      ,[MATH_Y1_prev]
                      ,[SCI_Y1_prev]
                      ,[SOC_Y1_prev])
   ) p
 )

,attendance AS (
  SELECT studentid
        ,[n_mem_1] AS n_mem_cur
        ,[n_mem_2] AS n_mem_prev
        ,[n_abs_1] AS n_abs_cur
        ,[n_abs_2] AS n_abs_prev      
  FROM
      (
       SELECT STUDENTID
             ,measure + '_' + CONVERT(VARCHAR,rn) AS pivot_hash
             ,value
       FROM
           (
            SELECT STUDENTID
                  ,ROW_NUMBER() OVER(
                     PARTITION BY studentid
                       ORDER BY academic_year DESC) AS rn
                  ,n_mem
                  ,n_abs
            FROM
                (
                 SELECT STUDENTID
                       ,academic_year           
                       ,SUM(CONVERT(INT,MEMBERSHIPVALUE)) AS n_mem
                       ,SUM(CASE WHEN ATTENDANCEVALUE = 0 THEN 1 ELSE 0 END) AS n_abs
                 FROM MEMBERSHIP WITH(NOLOCK)
                 WHERE academic_year >= (KIPP_NJ.dbo.fn_Global_Academic_Year() - 1)
                 GROUP BY STUDENTID
                         ,academic_year
                ) sub
           ) sub
       UNPIVOT(
         value
         FOR measure IN (n_mem, n_abs)
        ) u
      ) sub
  PIVOT(
    MAX(value)
    FOR pivot_hash IN ([n_abs_1]
                      ,[n_abs_2]
                      ,[n_mem_1]
                      ,[n_mem_2])
   ) p
 )

SELECT co.first_name
      ,co.last_name
      ,co.grade_level
      ,'TEAM Charter Schools' AS current_school
      ,njask.LAL_scale_prev1
      ,njask.MATH_scale_prev1
      ,njask.LAL_scale_prev2
      ,njask.MATH_scale_prev2
      ,curr_grades.MATH_MP1
      ,curr_grades.MATH_MP2
      ,curr_grades.READ_MP1
      ,curr_grades.READ_MP2
      ,curr_grades.SCI_MP1
      ,curr_grades.SCI_MP2
      ,curr_grades.SOC_MP1
      ,curr_grades.SOC_MP2 
      ,stored_grades.MATH_Y1_prev
      ,stored_grades.ENG_Y1_prev AS READ_Y1_prev
      ,stored_grades.SCI_Y1_prev
      ,stored_grades.SOC_Y1_prev
      ,attendance.n_mem_cur
      ,attendance.n_abs_cur
      ,attendance.n_mem_prev
      ,attendance.n_abs_prev
FROM KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK)
LEFT OUTER JOIN njask WITH(NOLOCK)
  ON co.studentid = njask.studentid
LEFT OUTER JOIN curr_grades WITH(NOLOCK)
  ON co.studentid = curr_grades.studentid
LEFT OUTER JOIN stored_grades WITH(NOLOCK)
  ON co.studentid = stored_grades.studentid
LEFT OUTER JOIN attendance WITH(NOLOCK)
  ON co.studentid = attendance.STUDENTID
WHERE co.year = KIPP_NJ.dbo.fn_Global_Academic_Year()
  AND co.rn = 1
  AND co.enroll_status = 0
  AND co.grade_level >= 5
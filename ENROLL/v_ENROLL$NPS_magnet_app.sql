USE KIPP_NJ
GO

ALTER VIEW ENROLL$NPS_magnet_app AS

WITH curr_grades AS (
  SELECT student_number
        ,[ENG_Q1]
        ,[ENG_Q2]
        ,[MATH_Q1]
        ,[MATH_Q2]
        ,[SCI_Q1]
        ,[SCI_Q2]
        ,[SOC_Q1]
        ,[SOC_Q2]
  FROM
      (
       SELECT student_number
             ,credittype + '_' + term AS pivot_hash
             ,term_grade_percent_adjusted AS term_pct
       FROM KIPP_NJ..GRADES$final_grades_long#static WITH(NOLOCK)
       WHERE CREDITTYPE IN ('MATH','ENG','SCI','SOC')
         AND term IN ('Q1','Q2')
         AND academic_year = KIPP_NJ.dbo.fn_Global_Academic_Year()
      ) sub
  PIVOT(
    MAX(term_pct)
    FOR pivot_hash IN ([ENG_Q1]
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
       SELECT sg.STUDENTID
             ,c.CREDITTYPE + '_Y1_prev' AS pivot_hash
             ,sg.[percent] AS grade_pct
       FROM KIPP_NJ..GRADES$storedgrades#static sg WITH(NOLOCK)
       JOIN KIPP_NJ..PS$COURSES#static c WITH(NOLOCK)
         ON sg.COURSE_NUMBER = c.COURSE_NUMBER
        AND CREDITTYPE IN ('MATH','ENG','SCI','SOC')
       WHERE sg.academic_year = (KIPP_NJ.dbo.fn_Global_Academic_Year() - 1)         
         AND sg.STORECODE = 'Y1'
      ) sub
  PIVOT(
    MAX(grade_pct)
    FOR pivot_hash IN ([ENG_Y1_prev]
                      ,[MATH_Y1_prev]
                      ,[SCI_Y1_prev]
                      ,[SOC_Y1_prev])
   ) p
 )

,parcc AS (
  SELECT student_number
        ,[ELA_1] AS ELA_scale_prev1        
        ,[Math_1] AS MATH_scale_prev1
        ,[ELA_2] AS ELA_scale_prev2
        ,[Math_2] AS MATH_scale_prev2
  FROM
      (
       SELECT student_number
             ,scale_score
             ,subject + '_' + CONVERT(VARCHAR,rn) AS pivot_hash
       FROM
           (
            SELECT localstudentidentifier AS student_number
                  ,CASE WHEN testcode LIKE 'ELA%' THEN 'ELA' ELSE 'MATH' END AS subject
                  ,summativescalescore AS scale_score
                  ,ROW_NUMBER() OVER(
                     PARTITION BY localstudentidentifier, CASE WHEN testcode LIKE 'ELA%' THEN 'ELA' ELSE 'MATH' END
                       ORDER BY assessmentyear DESC) AS rn
            FROM KIPP_NJ..PARCC$district_summative_record_file WITH(NOLOCK)
            WHERE CONVERT(INT,LEFT(assessmentyear, 4)) >= (KIPP_NJ.dbo.fn_Global_Academic_Year() - 2)
           ) sub
      ) sub
  PIVOT(
    MAX(scale_score)
    FOR pivot_hash IN ([ELA_1],[ELA_2],[Math_1],[Math_2])
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
                 FROM KIPP_NJ..ATT_MEM$MEMBERSHIP WITH(NOLOCK)
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



SELECT co.NEWARK_ENROLLMENT_NUMBER AS NEN
      ,co.lastfirst AS StudentName            
      ,curr_grades.MATH_Q1 AS [2016-17 Q1 Math]
      ,curr_grades.MATH_Q2 AS [2016-17 Q2 Math]
      ,curr_grades.ENG_Q1 AS [2016-17 Q1 English]
      ,curr_grades.ENG_Q2 AS [2016-17 Q2 English]
      ,curr_grades.SCI_Q1 AS [2016-17 Q1 Science]
      ,curr_grades.SCI_Q2 AS [2016-17 Q2 Science]
      ,curr_grades.SOC_Q1 AS [2016-17 Q1 Social Studies]
      ,curr_grades.SOC_Q2 AS [2016-17 Q2 Social Studies]
      ,stored_grades.MATH_Y1_prev AS [2015-16 Math]
      ,stored_grades.ENG_Y1_prev AS [2015-16 English]
      ,stored_grades.SCI_Y1_prev AS [2015-16 Science]
      ,stored_grades.SOC_Y1_prev AS [2015-16 Social Studies]
      ,attendance.n_mem_cur AS [16-17 Days Enrolled]
      ,attendance.n_abs_cur AS [16-17 Days Absent]
      ,attendance.n_mem_prev AS [15-16 Days Enrolled]
      ,attendance.n_abs_prev AS [15-16 Days Absent]
      ,parcc.ELA_scale_prev2 AS [14-15 PARCC Language Arts Score]
      ,parcc.MATH_scale_prev2 AS [14-15 PARCC Math Score]
      ,parcc.ELA_scale_prev1 AS [15-16 PARCC Language Arts Score]
      ,parcc.MATH_scale_prev1 AS [15-16 PARCC Math Score]
      ,CASE 
        WHEN co.SPEDLEP LIKE '%SPED%' THEN 'Y' 
        ELSE 'N'
       END AS IEP
      ,co.SPED_code AS [IEP Program]
FROM KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK)
LEFT OUTER JOIN curr_grades WITH(NOLOCK)
  ON co.student_number = curr_grades.student_number
LEFT OUTER JOIN stored_grades WITH(NOLOCK)
  ON co.studentid = stored_grades.studentid
LEFT OUTER JOIN attendance WITH(NOLOCK)
  ON co.studentid = attendance.STUDENTID
LEFT OUTER JOIN parcc WITH(NOLOCK)
  ON co.student_number = parcc.student_number
WHERE co.year = KIPP_NJ.dbo.fn_Global_Academic_Year()
  AND co.enroll_status = 0
  AND co.grade_level >= 5
  AND co.rn = 1
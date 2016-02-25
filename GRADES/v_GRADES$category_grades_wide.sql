USE KIPP_NJ
GO

ALTER VIEW GRADES$category_grades_wide AS

WITH course_order AS (
  SELECT student_number
        ,academic_year
        ,course_number
        ,credittype
        ,ROW_NUMBER() OVER(
           PARTITION BY student_number, academic_year
             ORDER BY CASE
                       WHEN credittype = 'ENG' THEN 01
                       WHEN credittype = 'RHET' THEN 02
                       WHEN credittype = 'MATH' THEN 03
                       WHEN credittype = 'SCI' THEN 04
                       WHEN credittype = 'SOC' THEN 05
                       WHEN credittype = 'WLANG' THEN 11
                       WHEN credittype = 'PHYSED' THEN 12
                       WHEN credittype = 'ART' THEN 13
                       WHEN credittype = 'STUDY' THEN 21
                       WHEN credittype = 'COCUR' THEN 22
                       WHEN credittype = 'ELEC' THEN 22
                       WHEN credittype = 'LOG' THEN 22
                      END
                     ,course_number) AS class_rn      
  FROM
      (
       SELECT DISTINCT
              student_number      
             ,academic_year            
             ,course_number      
             ,credittype      
       FROM KIPP_NJ..GRADES$final_grades_long#static WITH(NOLOCK)
       WHERE academic_year = KIPP_NJ.dbo.fn_Global_Academic_Year()
         AND credittype NOT IN ('LOG')
         AND course_number NOT IN ('')
      ) sub
 )

,grades_long AS (
  SELECT cat.student_number
        ,cat.SCHOOLID
        ,cat.academic_year
        ,cat.CREDITTYPE
        ,cat.COURSE_NUMBER
        ,cat.sectionid
        ,cat.teacher_name
        ,cat.reporting_term
        ,cat.rt
        ,cat.grade_category
        ,cat.grade_category_pct
        ,o.class_rn
  FROM KIPP_NJ..GRADES$category_grades_long#static cat WITH(NOLOCK)
  JOIN course_order o
    ON cat.student_number = o.student_number
   AND cat.academic_year = o.academic_year
   AND cat.COURSE_NUMBER = o.course_number
  WHERE cat.academic_year = KIPP_NJ.dbo.fn_Global_Academic_Year()

  UNION ALL

  SELECT cat.student_number
        ,cat.SCHOOLID
        ,cat.academic_year
        ,'ALL' AS CREDITTYPE
        ,'ALL' AS COURSE_NUMBER
        ,NULL AS sectionid
        ,NULL AS teacher_name
        ,cat.reporting_term      
        ,cat.rt
        ,cat.grade_category
        ,ROUND(AVG(cat.grade_category_pct),0)
        ,NULL AS class_rn
  FROM KIPP_NJ..GRADES$category_grades_long#static cat WITH(NOLOCK)     
  WHERE cat.academic_year = KIPP_NJ.dbo.fn_Global_Academic_Year()
  GROUP BY cat.student_number
          ,cat.SCHOOLID
          ,cat.academic_year
          ,cat.reporting_term      
          ,cat.rt
          ,cat.grade_category

  UNION ALL

  SELECT cat.student_number
        ,cat.SCHOOLID
        ,cat.academic_year
        ,cat.CREDITTYPE
        ,cat.COURSE_NUMBER
        ,cat.sectionid
        ,cat.teacher_name
        ,cat.reporting_term
        ,'CUR' AS rt
        ,cat.grade_category
        ,cat.grade_category_pct
        ,o.class_rn
  FROM KIPP_NJ..GRADES$category_grades_long#static cat WITH(NOLOCK)
  JOIN course_order o
    ON cat.student_number = o.student_number
   AND cat.academic_year = o.academic_year
   AND cat.COURSE_NUMBER = o.course_number
  WHERE cat.academic_year = KIPP_NJ.dbo.fn_Global_Academic_Year()

  UNION ALL

  SELECT cat.student_number
        ,cat.SCHOOLID
        ,cat.academic_year
        ,'ALL' AS CREDITTYPE
        ,'ALL' AS COURSE_NUMBER
        ,NULL AS sectionid
        ,NULL AS teacher_name
        ,cat.reporting_term
        ,'CUR' AS rt
        ,cat.grade_category
        ,ROUND(AVG(cat.grade_category_pct),0)
        ,NULL AS class_rn
  FROM KIPP_NJ..GRADES$category_grades_long#static cat WITH(NOLOCK)     
  WHERE cat.academic_year = KIPP_NJ.dbo.fn_Global_Academic_Year()
  GROUP BY cat.student_number
          ,cat.SCHOOLID
          ,cat.academic_year
          ,cat.reporting_term      
          ,cat.grade_category
 )

SELECT student_number
      ,SCHOOLID
      ,academic_year
      ,CREDITTYPE
      ,COURSE_NUMBER
      ,class_rn
      ,sectionid
      ,teacher_name
      ,reporting_term      
      ,[A_CUR] /* assessments */
      ,[C_CUR] /* classwork */      
      ,[H_CUR] /* homework */
      ,[P_CUR] /* class performance */
      ,[S_CUR] /* summative assessments */
      ,CASE WHEN schoolid = 73253 THEN NULL ELSE [E_CUR] END AS E_CUR /* homework quality */      
      
      ,ROUND(AVG([A_CUR]) OVER(PARTITION BY student_number, academic_year, course_number ORDER BY reporting_term ASC),0) AS A_Y1 
      ,ROUND(AVG([C_CUR]) OVER(PARTITION BY student_number, academic_year, course_number ORDER BY reporting_term ASC),0) AS C_Y1      
      ,ROUND(AVG([H_CUR]) OVER(PARTITION BY student_number, academic_year, course_number ORDER BY reporting_term ASC),0) AS H_Y1      
      ,ROUND(AVG([P_CUR]) OVER(PARTITION BY student_number, academic_year, course_number ORDER BY reporting_term ASC),0) AS P_Y1
      ,ROUND(AVG([S_CUR]) OVER(PARTITION BY student_number, academic_year, course_number ORDER BY reporting_term ASC),0) AS S_Y1
      ,CASE WHEN schoolid = 73253 THEN NULL ELSE ROUND(AVG([E_CUR]) OVER(PARTITION BY student_number, academic_year, course_number ORDER BY reporting_term ASC),0) END AS E_Y1

      ,MAX([A_RT1]) OVER(PARTITION BY student_number, academic_year, course_number ORDER BY reporting_term ASC) AS [A_RT1]
      ,MAX([A_RT2]) OVER(PARTITION BY student_number, academic_year, course_number ORDER BY reporting_term ASC) AS [A_RT2]
      ,MAX([A_RT3]) OVER(PARTITION BY student_number, academic_year, course_number ORDER BY reporting_term ASC) AS [A_RT3]
      ,MAX([A_RT4]) OVER(PARTITION BY student_number, academic_year, course_number ORDER BY reporting_term ASC) AS [A_RT4]
      ,MAX([C_RT1]) OVER(PARTITION BY student_number, academic_year, course_number ORDER BY reporting_term ASC) AS [C_RT1]
      ,MAX([C_RT2]) OVER(PARTITION BY student_number, academic_year, course_number ORDER BY reporting_term ASC) AS [C_RT2]
      ,MAX([C_RT3]) OVER(PARTITION BY student_number, academic_year, course_number ORDER BY reporting_term ASC) AS [C_RT3]
      ,MAX([C_RT4]) OVER(PARTITION BY student_number, academic_year, course_number ORDER BY reporting_term ASC) AS [C_RT4]
      ,MAX([E_RT1]) OVER(PARTITION BY student_number, academic_year, course_number ORDER BY reporting_term ASC) AS [E_RT1]
      ,MAX([E_RT2]) OVER(PARTITION BY student_number, academic_year, course_number ORDER BY reporting_term ASC) AS [E_RT2]
      ,MAX([E_RT3]) OVER(PARTITION BY student_number, academic_year, course_number ORDER BY reporting_term ASC) AS [E_RT3]
      ,MAX([E_RT4]) OVER(PARTITION BY student_number, academic_year, course_number ORDER BY reporting_term ASC) AS [E_RT4]
      ,MAX([H_RT1]) OVER(PARTITION BY student_number, academic_year, course_number ORDER BY reporting_term ASC) AS [H_RT1]
      ,MAX([H_RT2]) OVER(PARTITION BY student_number, academic_year, course_number ORDER BY reporting_term ASC) AS [H_RT2]
      ,MAX([H_RT3]) OVER(PARTITION BY student_number, academic_year, course_number ORDER BY reporting_term ASC) AS [H_RT3]
      ,MAX([H_RT4]) OVER(PARTITION BY student_number, academic_year, course_number ORDER BY reporting_term ASC) AS [H_RT4]
      ,MAX([P_RT1]) OVER(PARTITION BY student_number, academic_year, course_number ORDER BY reporting_term ASC) AS [P_RT1]
      ,MAX([P_RT2]) OVER(PARTITION BY student_number, academic_year, course_number ORDER BY reporting_term ASC) AS [P_RT2]
      ,MAX([P_RT3]) OVER(PARTITION BY student_number, academic_year, course_number ORDER BY reporting_term ASC) AS [P_RT3]
      ,MAX([P_RT4]) OVER(PARTITION BY student_number, academic_year, course_number ORDER BY reporting_term ASC) AS [P_RT4]
      ,MAX([S_RT1]) OVER(PARTITION BY student_number, academic_year, course_number ORDER BY reporting_term ASC) AS [S_RT1]
      ,MAX([S_RT2]) OVER(PARTITION BY student_number, academic_year, course_number ORDER BY reporting_term ASC) AS [S_RT2]
      ,MAX([S_RT3]) OVER(PARTITION BY student_number, academic_year, course_number ORDER BY reporting_term ASC) AS [S_RT3]
      ,MAX([S_RT4]) OVER(PARTITION BY student_number, academic_year, course_number ORDER BY reporting_term ASC) AS [S_RT4]

      ,ROW_NUMBER() OVER(
         PARTITION BY student_number, academic_year, reporting_term, credittype
           ORDER BY course_number) AS rn_credittype
FROM
    (
     SELECT student_number
           ,schoolid
           ,academic_year
           ,credittype
           ,course_number
           ,class_rn
           ,sectionid
           ,teacher_name
           ,reporting_term           
           ,CONCAT(grade_category, '_', rt) AS pivot_field
           ,grade_category_pct           
     FROM grades_long
    ) sub
PIVOT(
  MAX(grade_category_pct)
  FOR pivot_field IN ([A_CUR]
                     ,[A_RT1]
                     ,[A_RT2]
                     ,[A_RT3]
                     ,[A_RT4]
                     ,[C_CUR]
                     ,[C_RT1]
                     ,[C_RT2]
                     ,[C_RT3]
                     ,[C_RT4]
                     ,[E_CUR]
                     ,[E_RT1]
                     ,[E_RT2]
                     ,[E_RT3]
                     ,[E_RT4]
                     ,[H_CUR]
                     ,[H_RT1]
                     ,[H_RT2]
                     ,[H_RT3]
                     ,[H_RT4]
                     ,[P_CUR]
                     ,[P_RT1]
                     ,[P_RT2]
                     ,[P_RT3]
                     ,[P_RT4]
                     ,[S_CUR]
                     ,[S_RT1]
                     ,[S_RT2]
                     ,[S_RT3]
                     ,[S_RT4])
 ) p
USE KIPP_NJ
GO

ALTER VIEW GRADES$elements_long AS 

SELECT studentid
      ,yearid
      ,course_number
      ,pgf_type      
      ,CASE
        WHEN term = 'simple_avg' THEN 'Y1'
        WHEN schoolid = 73253 THEN 'Q' + CONVERT(VARCHAR,RIGHT(term, 1))
        ELSE 'T' + CONVERT(VARCHAR,RIGHT(term, 1))
       END AS term
      ,grade
FROM GRADES$elements WITH(NOLOCK)
UNPIVOT(
  grade
  FOR term IN (grade_1
              ,grade_2
              ,grade_3
              ,grade_4
              ,simple_avg)
 ) u
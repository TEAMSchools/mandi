USE KIPP_NJ
GO

ALTER VIEW GRADES$time_series_wide AS

SELECT student_number
      ,date
      ,COALESCE([A4],[A3],[A2],[A1]) AS A_term
      ,[AY]
      ,COALESCE([C4],[C3],[C2],[C1]) AS C_term
      ,[CY]
      ,COALESCE([E4],[E3],[E2],[E1]) AS E_term
      ,[EY]
      ,COALESCE([H4],[H3],[H2],[H1]) AS H_term
      ,[HY]
      ,COALESCE([P4],[P3],[P2],[P1]) AS P_term
      ,[PY]
      ,COALESCE([S4],[S3],[S2],[S1]) AS S_term
      ,[SY]
      ,COALESCE([Q4],[Q3],[Q2],[Q1]) AS Q_term
      ,[Y1]
FROM
    (
     SELECT student_number
           ,date
           ,finalgradename
           ,ROUND(AVG(moving_average),0) AS moving_avg
     FROM KIPP_NJ..GRADES$time_series ts WITH(NOLOCK)
     WHERE ts.academic_year = KIPP_NJ.dbo.fn_Global_Academic_Year()
       AND ts.moving_average IS NOT NULL       
     GROUP BY student_number
             ,date
             ,finalgradename
    ) sub
PIVOT(
  MAX(moving_avg)
  FOR finalgradename IN ([A1]
                        ,[A2]
                        ,[A3]
                        ,[A4]
                        ,[AY]
                        ,[C1]
                        ,[C2]
                        ,[C3]
                        ,[C4]
                        ,[CY]
                        ,[E1]
                        ,[E2]
                        ,[E3]
                        ,[E4]
                        ,[EY]
                        ,[H1]
                        ,[H2]
                        ,[H3]
                        ,[H4]
                        ,[HY]
                        ,[P1]
                        ,[P2]
                        ,[P3]
                        ,[P4]
                        ,[PY]
                        ,[S1]
                        ,[S2]
                        ,[S3]
                        ,[S4]
                        ,[SY]
                        ,[Q1]
                        ,[Q2]
                        ,[Q3]
                        ,[Q4]                        
                        ,[Y1])
 ) p
USE KIPP_NJ
GO

ALTER VIEW DL$reading_levels#extract AS

SELECT student_number
      ,academic_year
      ,test_round
      ,CASE 
        WHEN end_date <= CONVERT(DATE,GETDATE()) THEN read_lvl        
        WHEN is_new_test = 1 THEN read_lvl
        ELSE prev_read_lvl
       END AS read_lvl
      ,goal_lvl
      ,CASE 
        WHEN end_date <= CONVERT(DATE,GETDATE()) THEN lvl_num
        WHEN is_new_test = 1 THEN lvl_num
        ELSE prev_lvl_num
       END AS read_lvl_num
      ,goal_num AS goal_lvl_num
      ,met_goal      
FROM KIPP_NJ..LIT$achieved_by_round#static WITH(NOLOCK)
WHERE academic_year = KIPP_NJ.dbo.fn_Global_Academic_Year()
SELECT student_number
      ,academic_year
      ,test_round
      ,read_lvl      
      ,goal_lvl
      ,lvl_num AS read_lvl_num
      ,goal_num AS goal_lvl_num
      ,met_goal      
FROM KIPP_NJ..LIT$achieved_by_round#static WITH(NOLOCK)
WHERE academic_year = 2015 --KIPP_NJ.dbo.fn_Global_Academic_Year()
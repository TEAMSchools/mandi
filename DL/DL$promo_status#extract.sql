SELECT student_number
      ,academic_year
      ,term
      ,promo_status_overall
      ,promo_status_attendance
      ,promo_status_lit
      ,promo_status_grades      
      ,promo_status_credits     

      ,GPA_term
      ,GPA_Y1
      ,GPA_cum
      ,GPA_term_status
      ,GPA_Y1_status
      ,GPA_cum_status
      
      ,projected_credits_earned
      ,credits_enrolled

      ,HWQ_Y1
      ,lvls_grown_yr AS reading_lvl_growth_y1
FROM KIPP_NJ..PROMO$promo_status WITH(NOLOCK)
WHERE academic_year = 2015 --KIPP_NJ.dbo.fn_Global_Academic_Year()
USE KIPP_NJ
GO

ALTER VIEW GPA$detail#MS AS

SELECT STUDENTID
      ,STUDENT_NUMBER
      ,SCHOOLID
      ,GPA_t1_all
      ,GPA_t2_all
      ,GPA_t3_all
      ,GPA_y1_all
      ,GPA_t1_core
      ,GPA_t2_core
      ,GPA_t3_core
      ,GPA_y1_core      
      ,elements_all
      ,elements_core
      ,failing_all
      ,failing_core
      ,n_failing_all
      ,n_failing_core
      ,RANK() OVER(PARTITION BY schoolid ORDER BY GPA_t1_all DESC) AS rank_school_t1_all
      ,RANK() OVER(PARTITION BY schoolid ORDER BY GPA_t2_all DESC) AS rank_school_t2_all
      ,RANK() OVER(PARTITION BY schoolid ORDER BY GPA_t3_all DESC) AS rank_school_t3_all
      ,RANK() OVER(PARTITION BY schoolid ORDER BY GPA_y1_all DESC) AS rank_school_y1_all
      ,RANK() OVER(PARTITION BY schoolid ORDER BY GPA_t1_core DESC) AS rank_school_t1_core
      ,RANK() OVER(PARTITION BY schoolid ORDER BY GPA_t2_core DESC) AS rank_school_t2_core
      ,RANK() OVER(PARTITION BY schoolid ORDER BY GPA_t3_core DESC) AS rank_school_t3_core
      ,RANK() OVER(PARTITION BY schoolid ORDER BY GPA_y1_core DESC) AS rank_school_y1_core
      ,RANK() OVER(PARTITION BY schoolid, grade_level ORDER BY GPA_t1_all DESC) AS rank_gr_t1_all
      ,RANK() OVER(PARTITION BY schoolid, grade_level ORDER BY GPA_t2_all DESC) AS rank_gr_t2_all
      ,RANK() OVER(PARTITION BY schoolid, grade_level ORDER BY GPA_t3_all DESC) AS rank_gr_t3_all
      ,RANK() OVER(PARTITION BY schoolid, grade_level ORDER BY GPA_y1_all DESC) AS rank_gr_y1_all
      ,RANK() OVER(PARTITION BY schoolid, grade_level ORDER BY GPA_t1_core DESC) AS rank_gr_t1_core
      ,RANK() OVER(PARTITION BY schoolid, grade_level ORDER BY GPA_t2_core DESC) AS rank_gr_t2_core
      ,RANK() OVER(PARTITION BY schoolid, grade_level ORDER BY GPA_t3_core DESC) AS rank_gr_t3_core
      ,RANK() OVER(PARTITION BY schoolid, grade_level ORDER BY GPA_y1_core DESC) AS rank_gr_y1_core
      ,COUNT(studentid) OVER(PARTITION BY schoolid) AS n_school
      ,COUNT(studentid) OVER(PARTITION BY schoolid, grade_level) AS n_gr
FROM 
    (
     SELECT STUDENTID
           ,STUDENT_NUMBER
           ,SCHOOLID
           ,GRADE_LEVEL
           ,CONVERT(FLOAT,ROUND(SUM(weighted_points_t1) / SUM(credit_hours_t1),2)) AS GPA_t1_all
           ,CONVERT(FLOAT,ROUND(SUM(weighted_points_t2) / SUM(credit_hours_t2),2)) AS GPA_t2_all
           ,CONVERT(FLOAT,ROUND(SUM(weighted_points_t3) / SUM(credit_hours_t3),2)) AS GPA_t3_all
           ,CONVERT(FLOAT,ROUND(SUM(weighted_points_y1) / SUM(credit_hours_y1),2)) AS GPA_y1_all
           ,CONVERT(FLOAT,ROUND(SUM(core_weighted_points_t1) / SUM(core_credit_hours_t1),2)) AS GPA_t1_core
           ,CONVERT(FLOAT,ROUND(SUM(core_weighted_points_t2) / SUM(core_credit_hours_t2),2)) AS GPA_t2_core
           ,CONVERT(FLOAT,ROUND(SUM(core_weighted_points_t3) / SUM(core_credit_hours_t3),2)) AS GPA_t3_core
           ,CONVERT(FLOAT,ROUND(SUM(core_weighted_points_y1) / SUM(core_credit_hours_y1),2)) AS GPA_y1_core
           ,dbo.GROUP_CONCAT_D(course_y1, ' | ') AS elements_all
           ,dbo.GROUP_CONCAT_D(core_course_y1, ' | ') AS elements_core
           ,dbo.GROUP_CONCAT_D(FAILING_Y1, ' | ') AS failing_all
           ,dbo.GROUP_CONCAT_D(core_failing_y1, ' | ') AS failing_core
           ,SUM(promo_test) AS n_failing_all
           ,SUM(core_promo_test) AS n_failing_core
     FROM 
         (
          SELECT studentid
                ,student_number
                ,grade_level
                ,schoolid      
                ,credittype      
                ,weighted_points_t1
                ,weighted_points_t2
                ,weighted_points_t3
                ,weighted_points_y1
                ,credit_hours_t1
                ,credit_hours_t2
                ,credit_hours_t3
                ,credit_hours_y1
                ,promo_test
                ,course_y1
                ,failing_y1
                ,CASE WHEN credittype NOT IN ('COCUR','WLANG') THEN weighted_points_t1 ELSE NULL END AS core_weighted_points_t1
                ,CASE WHEN credittype NOT IN ('COCUR','WLANG') THEN weighted_points_t2 ELSE NULL END AS core_weighted_points_t2
                ,CASE WHEN credittype NOT IN ('COCUR','WLANG') THEN weighted_points_t3 ELSE NULL END AS core_weighted_points_t3
                ,CASE WHEN credittype NOT IN ('COCUR','WLANG') THEN weighted_points_y1 ELSE NULL END AS core_weighted_points_y1
                ,CASE WHEN credittype NOT IN ('COCUR','WLANG') THEN credit_hours_t1 ELSE NULL END AS core_credit_hours_t1
                ,CASE WHEN credittype NOT IN ('COCUR','WLANG') THEN credit_hours_t2 ELSE NULL END AS core_credit_hours_t2
                ,CASE WHEN credittype NOT IN ('COCUR','WLANG') THEN credit_hours_t3 ELSE NULL END AS core_credit_hours_t3
                ,CASE WHEN credittype NOT IN ('COCUR','WLANG') THEN credit_hours_y1 ELSE NULL END AS core_credit_hours_y1
                ,CASE WHEN credittype NOT IN ('COCUR','WLANG') THEN promo_test ELSE NULL END AS core_promo_test
                ,CASE WHEN credittype NOT IN ('COCUR','WLANG') THEN course_y1 ELSE NULL END AS core_course_y1
                ,CASE WHEN credittype NOT IN ('COCUR','WLANG') THEN failing_y1 ELSE NULL END AS core_failing_y1           
          FROM GRADES$DETAIL#MS WITH (NOLOCK)
         ) sub
     GROUP BY STUDENTID
             ,STUDENT_NUMBER
             ,SCHOOLID
             ,GRADE_LEVEL
    ) sub1
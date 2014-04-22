USE KIPP_NJ
GO

ALTER VIEW GPA$detail#TEAM AS
SELECT studentid
      ,student_number
      ,schoolid
      ,lastfirst
      ,grade_level
      ,round(sum(weighted_points_T1)/sum(credit_hours_T1),2) as GPA_T1_weighted_all
      ,round(sum(weighted_points_T2)/sum(credit_hours_T2),2) as GPA_T2_weighted_all
      ,round(sum(weighted_points_T3)/sum(credit_hours_T3),2) as GPA_T3_weighted_all
      ,round(sum(weighted_points_Y1)/sum(credit_hours_Y1),2) as GPA_Y1_weighted_all
      ,dbo.GROUP_CONCAT(course_y1) AS elements_all
      ,sum(promo_test) as num_failing_all
      ,dbo.GROUP_CONCAT(failing_y1) AS elements_failing_all
      ,round(sum(core_weighted_points_T1)/sum(core_credit_hours_T1),2) as GPA_T1_weighted_core
      ,round(sum(core_weighted_points_T2)/sum(core_credit_hours_T2),2) as GPA_T2_weighted_core
      ,round(sum(core_weighted_points_T3)/sum(core_credit_hours_T3),2) as GPA_T3_weighted_core
      ,round(sum(core_weighted_points_Y1)/sum(core_credit_hours_Y1),2) as GPA_Y1_weighted_core
      ,dbo.GROUP_CONCAT(core_course_y1) AS elements_core
      ,dbo.GROUP_CONCAT(core_failing_y1) AS elements_failing_core
      ,sum(core_promo_test) as num_failing_core
FROM      
     (
      SELECT studentid
            ,student_number
            ,schoolid
            ,lastfirst
            ,grade_level
            ,course_y1
            ,credittype
            ,weighted_points_T1
            ,weighted_points_T2
            ,weighted_points_T3
            ,weighted_points_Y1
            ,credit_hours_t1
            ,credit_hours_t2
            ,credit_hours_t3
            ,credit_hours_y1
            ,promo_test
            ,failing_y1
            ,case when credittype NOT IN ('COCUR','WLANG') then weighted_points_t1 else null end as core_weighted_points_t1
            ,case when credittype NOT IN ('COCUR','WLANG') then weighted_points_t2 else null end as core_weighted_points_t2
            ,case when credittype NOT IN ('COCUR','WLANG') then weighted_points_t3 else null end as core_weighted_points_t3
            ,case when credittype NOT IN ('COCUR','WLANG') then weighted_points_y1 else null end as core_weighted_points_y1
            ,case when credittype NOT IN ('COCUR','WLANG') then credit_hours_t1 else null end as core_credit_hours_t1
            ,case when credittype NOT IN ('COCUR','WLANG') then credit_hours_t2 else null end as core_credit_hours_t2
            ,case when credittype NOT IN ('COCUR','WLANG') then credit_hours_t3 else null end as core_credit_hours_t3
            ,case when credittype NOT IN ('COCUR','WLANG') then credit_hours_y1 else null end as core_credit_hours_y1
            ,case when credittype NOT IN ('COCUR','WLANG') then course_y1 else null end as core_course_y1
            ,case when credittype NOT IN ('COCUR','WLANG') then failing_y1 else null end as core_failing_y1
            ,case when credittype NOT IN ('COCUR','WLANG') then promo_test else null end as core_promo_test
      FROM GRADES$DETAIL#MS WITH (NOLOCK)
     ) sub1
GROUP BY studentid, student_number, schoolid, lastfirst, grade_level
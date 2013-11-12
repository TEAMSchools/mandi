--NCA Blue

USE KIPP_NJ
GO

ALTER VIEW REPORTING$progress_tracker#NCA AS
WITH roster AS
     (
      SELECT s.student_number
            ,s.id AS studentid
            ,s.lastfirst
            ,s.first_name
            ,s.last_name                        
            ,s.gender
            ,CONVERT(DATE,s.dob) AS dob
            ,s.student_web_id
            ,s.student_web_password
            ,s.home_phone
            ,cs.mother_cell
            ,cs.father_cell
            ,c.grade_level AS grade_level
            ,s.classof
            ,cs.guardianemail
            ,cs.advisor
            ,cs.SPEDLEP AS SPED
            ,ROW_NUMBER() OVER(
                PARTITION BY s.grade_level
                    ORDER BY s.id) AS peer_count
      FROM KIPP_NJ..COHORT$comprehensive_long#static c WITH (NOLOCK)
      JOIN KIPP_NJ..STUDENTS s WITH (NOLOCK)
        ON c.studentid = s.id
       AND s.enroll_status = 0
      LEFT OUTER JOIN KIPP_NJ..CUSTOM_STUDENTS cs WITH (NOLOCK)
        ON cs.studentid = s.id
      WHERE year = 2013
        AND c.rn = 1        
        AND c.schoolid = 73253
     )

SELECT ROW_NUMBER() OVER(          
           ORDER BY lastfirst) AS rn
      ,student_number
      ,studentid
      ,lastfirst
      ,first_name
      ,last_name                        
      ,gender
      ,dob
      ,student_web_id
      ,student_web_password
      ,home_phone
      ,mother_cell
      ,father_cell
      ,grade_level
      ,classof
      ,guardianemail
      ,advisor
      ,SPED
      ,att_pct_counts_yr
      ,att_pct_yr
      ,att_counts_yr
      ,on_time_pct      
      ,inv_tardy_pct_yr
      ,tardy_count_yr
      ,suspensions
      ,gpa_ytd      
      ,gpa_cum
      ,earned_credits_cum
      ,AY_all     
      ,HY_all     
      ,PY_all
      --,CY_all
      ,E1_all
      ,E2_all
      ,num_failing
      ,courses AS courses_failing
      ,points_goal_yr
      ,points_yr
      ,map_sci_pct      
      ,map_math_pct
      ,map_read_pct
      ,map_sci_rit      
      ,map_math_rit
      ,map_read_rit
      ,lexile_cur
      ,lexile_min
      ,lexile_max
      ,merits_yr      
      ,merits_curr
      ,demerits_yr
      ,demerits_curr
      ,subtype AS recent_merit
      ,entry_date AS merit_date
      ,in_grade_denom
      ,CASE
        WHEN gpa_ytd IS NOT NULL THEN
         ROW_NUMBER() OVER(
         PARTITION BY grade_level
             ORDER BY gpa_ytd DESC) 
        ELSE NULL
       END AS gpa_rank_ytd
      ,CASE
        WHEN gpa_cum IS NOT NULL THEN
         ROW_NUMBER() OVER(
         PARTITION BY grade_level
             ORDER BY gpa_cum DESC) 
        ELSE NULL
       END AS gpa_rank_cum
      ,rc1_course_name
      ,rc1_Y1
      ,rc2_course_name
      ,rc2_Y1
      ,rc3_course_name
      ,rc3_Y1
      ,rc4_course_name
      ,rc4_Y1
      ,rc5_course_name
      ,rc5_Y1
      ,rc6_course_name
      ,rc6_Y1
      ,rc7_course_name
      ,rc7_Y1
      ,rc8_course_name
      ,rc8_Y1
      ,rc9_course_name
      ,rc9_Y1
      ,rc10_course_name
      ,rc10_Y1
--PROFICIENCY METRICS      
      ,CASE
        WHEN att_pct_yr >= 95 THEN 4
        WHEN att_pct_yr >= 93 AND att_pct_yr < 95 THEN 3
        WHEN att_pct_yr >= 90 AND att_pct_yr < 93 THEN 2
        WHEN att_pct_yr < 90 THEN 1
       END AS att_pct_counts_yr_prof
      ,CASE
        WHEN inv_tardy_pct_yr >= 98 THEN 4
        WHEN inv_tardy_pct_yr >= 95 AND inv_tardy_pct_yr < 98 THEN 3
        WHEN inv_tardy_pct_yr >= 90 AND inv_tardy_pct_yr < 95 THEN 2
        WHEN inv_tardy_pct_yr <  90 THEN 1
       END AS on_time_pct_prof      
      ,CASE
        WHEN suspensions =  0 THEN 3
        WHEN suspensions >= 1 THEN 1
       END AS suspensions_prof      
      ,CASE
        WHEN gpa_ytd >= 3.0 THEN 4
        WHEN gpa_ytd >= 2.5 AND gpa_ytd < 3.0 THEN 3
        WHEN gpa_ytd >= 2.0 AND gpa_ytd < 2.5 THEN 2
        WHEN gpa_ytd <  2.0 THEN 1
       END AS gpa_ytd_prof
      ,CASE
        WHEN gpa_cum >= 3.0 THEN 4
        WHEN gpa_cum >= 2.5 AND gpa_cum < 3.0 THEN 3
        WHEN gpa_cum >= 2.0 AND gpa_cum < 2.5 THEN 2
        WHEN gpa_cum <  2.0 THEN 1
       END AS gpa_cum_prof
      ,CASE        
        WHEN grade_level = 10 AND earned_credits_cum >  30 THEN 4
        WHEN grade_level = 10 AND earned_credits_cum =  30 THEN 3
        WHEN grade_level = 10 AND earned_credits_cum >= 25 AND earned_credits_cum < 30 THEN 2
        WHEN grade_level = 10 AND earned_credits_cum <  25 THEN 1
        WHEN grade_level = 11 AND earned_credits_cum >  60 THEN 4
        WHEN grade_level = 11 AND earned_credits_cum =  60 THEN 3
        WHEN grade_level = 11 AND earned_credits_cum >= 55 AND earned_credits_cum < 60 THEN 2
        WHEN grade_level = 11 AND earned_credits_cum <  55 THEN 1
        WHEN grade_level = 12 AND earned_credits_cum >  90 THEN 4
        WHEN grade_level = 12 AND earned_credits_cum =  90 THEN 3
        WHEN grade_level = 12 AND earned_credits_cum >= 85 AND earned_credits_cum < 90 THEN 2
        WHEN grade_level = 12 AND earned_credits_cum <  85 THEN 1
       END AS earned_credits_cum_prof
      ,CASE
        WHEN AY_all >= 87 THEN 4
        WHEN AY_all <  87 AND AY_all >= 80  THEN 3
        WHEN AY_all <  80 AND AY_all >= 70  THEN 2
        WHEN AY_all <  70  THEN 1
       END AS AY_all_prof
      ,CASE
        WHEN HY_all >= 90 THEN 4
        WHEN HY_all <  90 AND HY_all >= 83  THEN 3
        WHEN HY_all <  83 AND HY_all >= 75  THEN 2
        WHEN HY_all <  75  THEN 1
       END AS HY_all_prof
      ,CASE
        WHEN PY_all >= 87 THEN 4
        WHEN PY_all <  87 AND PY_all >= 83  THEN 3
        WHEN PY_all <  83 AND PY_all >= 75  THEN 2
        WHEN PY_all <  75  THEN 1
       END AS PY_all_prof
      ,CASE
        WHEN E1_all >= 87 THEN 4
        WHEN E1_all <  87 AND E1_all >= 80  THEN 3
        WHEN E1_all <  80 AND E1_all >= 70  THEN 2
        WHEN E1_all <  70  THEN 1
       END AS E1_all_prof            
      ,CASE
        WHEN E2_all >= 87 THEN 4
        WHEN E2_all <  87 AND E2_all >= 80  THEN 3
        WHEN E2_all <  80 AND E2_all >= 70  THEN 2
        WHEN E2_all <  70  THEN 1
       END AS E2_all_prof      
      ,CASE
        WHEN num_failing = 0 THEN 3
        WHEN num_failing = 1 THEN 2
        WHEN num_failing > 1 THEN 1
       END AS num_failing_prof
      --,points_goal_yr,points_yr -- prof is relative to goal
      ,CASE
        WHEN map_sci_pct >= 75 THEN 4
        WHEN map_sci_pct <  75 AND map_sci_pct >= 62 THEN 3
        WHEN map_sci_pct <  62 AND map_sci_pct >= 50 THEN 2
        WHEN map_sci_pct <  50 THEN 1
       END AS map_sci_pct_prof
      ,CASE
        WHEN map_math_pct >= 75 THEN 4
        WHEN map_math_pct <  75 AND map_math_pct >= 62 THEN 3
        WHEN map_math_pct <  62 AND map_math_pct >= 50 THEN 2
        WHEN map_math_pct <  50 THEN 1
       END AS map_math_pct_prof
      ,CASE
        WHEN map_read_pct >= 75 THEN 4
        WHEN map_read_pct <  75 AND map_read_pct >= 62 THEN 3
        WHEN map_read_pct <  62 AND map_read_pct >= 50 THEN 2
        WHEN map_read_pct <  50 THEN 1
       END AS map_read_pct_prof                        
      ,CASE
        WHEN merits_curr >= 25 THEN 4
        WHEN merits_curr <  25 AND merits_curr >= 15 THEN 3
        WHEN merits_curr <  15 AND merits_curr >= 10 THEN 2
        WHEN merits_curr <  10 THEN 1
       END AS merits_curr_prof      
      ,CASE
        WHEN demerits_curr >  12 THEN 1
        WHEN demerits_curr <= 12 AND demerits_curr >= 7 THEN 2
        WHEN demerits_curr <=  6 AND demerits_curr >= 4 THEN 3
        WHEN demerits_curr <=  3 THEN 4
       END AS demerits_curr_prof
      ,NULL AS lexile_cur_prof
FROM
     (SELECT roster.*                 
            ,dem.in_grade_denom
     --Attendance
     --ATT_MEM$attendance_percentages
     --ATT_MEM$attendance_counts
           --year
           ,ROUND(att_pct.Y1_att_pct_total,0) AS att_pct_yr
           ,ROUND(att_counts.absences_total,0) AS att_counts_yr
           ,CONVERT(VARCHAR,ROUND(att_pct.Y1_att_pct_total,0))
              + '% ('
              + CONVERT(VARCHAR,CONVERT(FLOAT,att_counts.absences_total))
              + ')'                                     
               AS att_pct_counts_yr
           ,CONVERT(VARCHAR,(100 - ROUND(att_pct.Y1_tardy_pct_total,0)))
              + '% ('
              + CONVERT(VARCHAR,CONVERT(FLOAT,att_counts.tardies_total))
              + ')'                                     
               AS on_time_pct
           ,(100 - ROUND(att_pct.Y1_tardy_pct_total,0)) AS inv_tardy_pct_yr
           ,ROUND(att_counts.tardies_total,0)           AS tardy_count_yr
           ,ROUND(att_counts.OSS,0)                     AS suspensions
           
     --GPA
     --GPA$detail#nca
     --GPA$cumulative#NCA
           --current SY
           ,nca_gpa.gpa_Y1 AS gpa_ytd      
           --cumulative (all years)
           ,gpa_cumulative.cumulative_Y1_gpa AS gpa_cum
           ,earned_credits_cum
           
     --Course Grades
     --GRADES$wide_all     
           ,gr_wide.AY_all     
           ,gr_wide.HY_all     
           ,gr_wide.PY_all
           --,gr_wide.CY_all
           ,gr_wide.E1_all
           ,gr_wide.E2_all
           ,gr_wide.rc1_course_name
           ,gr_wide.rc1_Y1
           ,gr_wide.rc2_course_name
           ,gr_wide.rc2_Y1
           ,gr_wide.rc3_course_name
           ,gr_wide.rc3_Y1
           ,gr_wide.rc4_course_name
           ,gr_wide.rc4_Y1
           ,gr_wide.rc5_course_name
           ,gr_wide.rc5_Y1
           ,gr_wide.rc6_course_name
           ,gr_wide.rc6_Y1
           ,gr_wide.rc7_course_name
           ,gr_wide.rc7_Y1
           ,gr_wide.rc8_course_name
           ,gr_wide.rc8_Y1
           ,gr_wide.rc9_course_name
           ,gr_wide.rc9_Y1
           ,gr_wide.rc10_course_name
           ,gr_wide.rc10_Y1
           
           --On-track?
           ,fail.courses
           ,CASE
             WHEN fail.num_failing IS NULL THEN 0
             ELSE fail.num_failing
            END AS num_failing
           
     --Ed Tech
     --AR$progress_to_goals_long#static

           --Accelerated Reader      
           --AR year      
           ,ar_yr.points_goal AS points_goal_yr
           ,ROUND(ar_yr.points,0) AS points_yr

     --MAP & Lexile scores -- update academic year in JOIN
     --MAP$comprehensive#identifiers
           ,map_sci_cur.testpercentile AS map_sci_pct
           ,map_sci_cur.testritscore AS map_sci_rit
           ,map_math_cur.testpercentile AS map_math_pct
           ,map_math_cur.testritscore AS map_math_rit
           ,map_read_cur.testpercentile AS map_read_pct
           ,map_read_cur.testritscore AS map_read_rit
           ,map_read_cur.rittoreadingscore AS lexile_cur
           ,map_read_cur.rittoreadingmin AS lexile_min
           ,map_read_cur.rittoreadingmax AS lexile_max
         
     --Discipline
     --DISC$merits_demerits_count#NCA
           --Merits
             --year      
           ,merits.total_merits_rt1 
             + merits.total_merits_rt2 
             + merits.total_merits_rt3 
             + merits.total_merits_rt4 AS merits_yr      
             --current            
           ,merits.total_merits_rt1    AS merits_curr   -- update field name for current term
           
           --Demerits
             --year
           ,merits.total_demerits_rt1
             + merits.total_demerits_rt2
             + merits.total_demerits_rt3
             + merits.total_demerits_rt4 AS demerits_yr
             --current
           ,merits.total_demerits_rt1    AS demerits_curr -- update field name for current term
           ,disc.subtype
           ,disc.entry_date
           
     FROM roster WITH (NOLOCK)
      
     --ATTENDANCE
     LEFT OUTER JOIN ATT_MEM$attendance_counts att_counts WITH (NOLOCK)
       ON roster.studentid = att_counts.id
     LEFT OUTER JOIN ATT_MEM$att_percentages att_pct WITH (NOLOCK)
       ON roster.studentid = att_pct.id
       
     --GPA
     LEFT OUTER JOIN GPA$detail#NCA nca_gpa WITH (NOLOCK)
       ON roster.studentid = nca_gpa.studentid      
     LEFT OUTER JOIN GPA$cumulative gpa_cumulative WITH (NOLOCK)
       ON roster.studentid = gpa_cumulative.studentid
      AND gpa_cumulative.schoolid = 73253
       
     --GRADES
     LEFT OUTER JOIN GRADES$wide_all#NCA gr_wide WITH (NOLOCK)
       ON roster.studentid = gr_wide.studentid
     LEFT OUTER JOIN (SELECT studentid
                            ,COUNT(fail.y1) AS num_failing
                            ,dbo.GROUP_CONCAT_DS(fail.course_name, CHAR(10), 1) AS courses
                      FROM GRADES$DETAIL#NCA fail WITH (NOLOCK)
                      WHERE fail.y1 < 70
                      GROUP BY studentid) fail
       ON roster.studentid = fail.studentid
       
     --ED TECH
       --ACCELERATED READER
     LEFT OUTER JOIN AR$progress_to_goals_long#static ar_yr WITH (NOLOCK)
       ON roster.studentid = ar_yr.studentid 
      AND ar_yr.time_period_name = 'Year'
      AND ar_yr.yearid = dbo.fn_Global_Term_Id()
      
     --MAP (LEXILE)
     LEFT OUTER JOIN KIPP_NJ..MAP$comprehensive#identifiers map_read_cur WITH (NOLOCK)
       ON roster.studentid = map_read_cur.ps_studentid
      AND map_read_cur.measurementscale  = 'Reading'
      AND map_read_cur.map_year_academic = 2013 --update yearly
      AND map_read_cur.rn_curr = 1
     LEFT OUTER JOIN KIPP_NJ..MAP$comprehensive#identifiers map_math_cur WITH (NOLOCK)
       ON roster.studentid = map_math_cur.ps_studentid
      AND map_math_cur.measurementscale = 'Mathematics'
      AND map_math_cur.map_year_academic = 2013 --update yearly
      AND map_math_cur.rn_curr = 1
     LEFT OUTER JOIN KIPP_NJ..MAP$comprehensive#identifiers map_sci_cur WITH (NOLOCK)
       ON roster.studentid = map_sci_cur.ps_studentid
      AND map_sci_cur.measurementscale = 'Science - General Science'
      AND map_sci_cur.map_year_academic = 2013 --update yearly
      AND map_sci_cur.rn_curr = 1

     --MERITS & DEMERITS
     LEFT OUTER JOIN DISC$merits_demerits_count#NCA merits WITH (NOLOCK)
       ON roster.studentid = merits.studentid
     LEFT OUTER JOIN DISC$log#static disc WITH (NOLOCK)
       ON roster.studentid = disc.studentid
      AND disc.rn = 1
      AND disc.logtypeid = 3023      
       
     LEFT OUTER JOIN (SELECT grade_level
                            ,MAX(peer_count) AS in_grade_denom
                      FROM roster WITH (NOLOCK)
                      GROUP BY grade_level) dem
       ON roster.grade_level = dem.grade_level       
    ) sub_1
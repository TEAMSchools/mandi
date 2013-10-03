USE KIPP_NJ
GO

--ALTER VIEW REPORTING$progress_tracker#NCA AS
WITH roster AS
     (SELECT s.student_number
            ,s.id AS studentid
            ,s.lastfirst
            ,s.first_name
            ,s.last_name
            ,c.grade_level AS grade_level
            ,cs.advisor
            ,cs.SPEDLEP AS SPED
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

SELECT student_number
      ,studentid
      ,lastfirst
      ,first_name
      ,last_name
      ,grade_level
      ,advisor
      ,SPED
      ,att_pct_counts_yr
      ,on_time_pct      
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
      ,points_goal_yr
      ,points_yr
      ,map_sci_pctile_cur
      ,map_math_pctile_cur
      ,map_read_pctile_cur
      ,lexile_cur
      ,total_merits_yr      
      ,total_merits_curr
      ,total_demerits_yr
      ,total_demerits_curr

--PROFICIENCY METRICS      
      ,CASE
        WHEN att_pct_yr >= 95 THEN 1
        WHEN att_pct_yr >= 93 AND att_pct_yr < 95 THEN 2
        WHEN att_pct_yr >= 90 AND att_pct_yr < 93 THEN 3
        WHEN att_pct_yr < 90 THEN 4
       END AS att_pct_prof
      ,CASE
        WHEN inv_tardy_pct_yr >= 98 THEN 1
        WHEN inv_tardy_pct_yr >= 95 AND inv_tardy_pct_yr < 98 THEN 2
        WHEN inv_tardy_pct_yr >= 90 AND inv_tardy_pct_yr < 95 THEN 3
        WHEN inv_tardy_pct_yr <  90 THEN 4
       END AS on_time_pct_prof      
      ,CASE
        WHEN suspensions =  0 THEN 2
        WHEN suspensions >= 1 THEN 4
       END AS suspensions_prof
      /*
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
      ,points_goal_yr
      ,points_yr
      ,map_sci_pctile_cur
      ,map_math_pctile_cur
      ,map_read_pctile_cur
      ,lexile_cur
      ,total_merits_yr      
      ,total_merits_curr
      ,total_demerits_yr
      ,total_demerits_curr
      */
FROM
     (SELECT roster.*                 
     --Attendance
     --ATT_MEM$attendance_percentages
     --ATT_MEM$attendance_counts
           --year
           ,ROUND(att_pct.Y1_att_pct_total,0) AS att_pct_yr
           ,att_counts.absences_total AS att_counts_yr
           ,CONVERT(VARCHAR,ROUND(att_pct.Y1_att_pct_total,0))
              + '% ('
              + CONVERT(VARCHAR,att_counts.absences_total)
              + ')'                                     AS att_pct_counts_yr
           ,CONVERT(VARCHAR,(100 - ROUND(att_pct.Y1_tardy_pct_total,0)))
              + '% ('
              + CONVERT(VARCHAR,att_counts.tardies_total)
              + ')'                                     AS on_time_pct
           ,(100 - ROUND(att_pct.Y1_tardy_pct_total,0)) AS inv_tardy_pct_yr
           ,att_counts.tardies_total                    AS tardy_count_yr
           ,att_counts.OSS                              AS suspensions
           
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
           
           --On-track?
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
           ,map_sci_cur.testpercentile AS map_sci_pctile_cur
           ,map_math_cur.testpercentile AS map_math_pctile_cur
           ,map_read_cur.testpercentile AS map_read_pctile_cur
           ,map_read_cur.rittoreadingscore AS lexile_cur
         
     --Discipline
     --DISC$merits_demerits_count#NCA
           --Merits
             --year      
           ,merits.total_merits_rt1 
             + merits.total_merits_rt2 
             + merits.total_merits_rt3 
             + merits.total_merits_rt4 AS total_merits_yr      
             --current            
           ,merits.total_merits_rt1    AS total_merits_curr   -- update field name for current term
           
           --Demerits
             --year
           ,merits.total_demerits_rt1
             + merits.total_demerits_rt2
             + merits.total_demerits_rt3
             + merits.total_demerits_rt4 AS total_demerits_yr
             --current -- update field name for current term
           ,merits.total_demerits        AS total_demerits_curr -- update field name for current term
           
     FROM roster
      
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
       
     --GRADES
     LEFT OUTER JOIN GRADES$wide_all#NCA gr_wide WITH (NOLOCK)
       ON roster.studentid = gr_wide.studentid
     LEFT OUTER JOIN (SELECT studentid
                            ,COUNT(fail.y1) AS num_failing
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
    ) sub_1
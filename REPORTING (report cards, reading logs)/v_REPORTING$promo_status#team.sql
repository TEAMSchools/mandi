USE KIPP_NJ
GO

--ALTER VIEW REPORTING$promo_status#TEAM AS
SELECT 
         studentid
        ,student_number
        ,promo_status_grades
        ,attendance_points
        ,y1_att_pts_pct
        ,att_string
        ,promo_status_att         
        ,case 
                       when promo_status_grades  + promo_status_att  like 'On TrackOn Track' then 'On Track'
                       when promo_status_grades  + promo_status_att  like 'On TrackOn Track' then 'On Track'
                       when promo_status_grades  + promo_status_att  like '%Promotion In Doubt%' then 'Promotion In Doubt'
                       when promo_status_grades  + promo_status_att  like '%Off Track%' then 'Promotion In Doubt'
                       when promo_status_grades  + promo_status_att  like '%Warning%' then 'Promotion In Doubt'
                       else 'Satisfactory' 
         end as promo_status_overall
         
FROM(
      SELECT
                     studentid
                    ,student_number
                    ,promo_status_grades
                    ,attendance_points
                    ,y1_att_pts_pct
                    ,att_string
                    ,case 
                             when y1_att_pts_pct < 90 then 'Off Track' --redundant
                             when y1_att_pts_pct < 92 then 'Off Track'
                             when y1_att_pts_pct >= 98 then 'On Track' --redundant
                             else 'On Track' 
                   end as promo_status_att   
      FROM             
      (select s.id as studentid
            ,s.student_number
      
            ,case when ((gr_wide.rc1_y1 < 70 and gr_wide.rc1_credittype != 'COCUR') OR
                        (gr_wide.rc2_y1 < 70 and gr_wide.rc2_credittype != 'COCUR') OR 
                        (gr_wide.rc3_y1 < 70 and gr_wide.rc3_credittype != 'COCUR') OR
                        (gr_wide.rc4_y1 < 70 and gr_wide.rc4_credittype != 'COCUR') OR
                        (gr_wide.rc5_y1 < 70 and gr_wide.rc5_credittype != 'COCUR') OR
                        (gr_wide.rc6_y1 < 70 and gr_wide.rc6_credittype != 'COCUR') OR
                        (gr_wide.rc7_y1 < 70 and gr_wide.rc7_credittype != 'COCUR') OR
                        (gr_wide.rc8_y1 < 70 and gr_wide.rc8_credittype != 'COCUR') 
                        ) then 'Promotion In Doubt'
                  else 'On Track' end as promo_status_grades 
      
            ,CAST(mem.mem AS VARCHAR) + '-(' + CAST(ac.absences_total AS VARCHAR) + '+(' + CAST(ac.tardies_total AS VARCHAR) + '/3))' + '/' + CAST(mem.mem AS VARCHAR) as att_string
            ,ac.absences_total + floor(ac.tardies_total/3) as attendance_points
            ,round(
                      ((mem.mem - (ac.absences_total + floor(ac.tardies_total/3))) / mem.mem) * 100
                  ,2) as y1_att_pts_pct
      
        from STUDENTS s
        left outer join GRADES$wide_all#MS gr_wide on s.id = gr_wide.studentid
        left outer join GPA$detail#TEAM team_GPA on s.id = TEAM_GPA.studentid
        left outer join ATT_MEM$attendance_counts ac on s.id = ac.id
        left outer join ATT_MEM$membership_counts mem on s.id = mem.id
        --only used for Rise
        --left outer join GRADES$elements team_hw on s.id = team_hw.studentid 
        --            AND team_hw.pgf_type = 'H'
        where s.schoolid = 133570965 and s.enroll_status = 0
        )sub
 )sub1
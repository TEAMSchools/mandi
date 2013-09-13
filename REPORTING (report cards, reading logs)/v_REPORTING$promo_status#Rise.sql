USE KIPP_NJ
GO

--ALTER VIEW REPORTING$promo_status#Rise AS
select studentid
      ,student_number
      ,attendance_points
      ,y1_att_pts_pct
      ,att_string
      ,GPA_Promo_Status_Grades
      ,promo_status_att
      ,promo_status_hw
      ,case 
         when GPA_Promo_Status_Grades  + promo_status_att + promo_status_hw like 'HonorsHonorsHonors' then 'Honors'
         when GPA_Promo_Status_Grades  + promo_status_att + promo_status_hw like 'High HonorsHonorsHonors' then 'Honors'
         when GPA_Promo_Status_Grades  + promo_status_att + promo_status_hw like '%Off Track%' then 'Off Track'
         when GPA_Promo_Status_Grades  + promo_status_att + promo_status_hw like '%Warning%' then 'Warning'
         else 'Satisfactory' 
      end as promo_status_overall
from
      (select studentid
            ,student_number
            ,attendance_points
            ,y1_att_pts_pct
            ,att_string
            ,promo_status_grades
            ,case 
               when y1_att_pts_pct < 90 then 'Off Track'
               when y1_att_pts_pct < 92 then 'Warning'
               when y1_att_pts_pct >= 98 then 'Honors'
               else 'Satisfactory' 
             end as promo_status_att
            ,case 
               when simple_avg < 65 then 'Off Track'
               when simple_avg < 70 then 'Warning'
               when simple_avg >= 90 then 'Honors'
               else 'Satisfactory' 
             end as promo_status_hw
            ,case 
               when GPA >= 3   and GPA <3.5 and promo_status_grades not like '%Warning%' then 'Honors' 
               when GPA >= 3.5 and promo_status_grades not like '%Warning%' then 'High Honors' 
               else promo_status_grades 
             end as GPA_Promo_Status_Grades
      from
           (select s.id as studentid
                  ,s.student_number
                  ,case 
                     when (gr_wide.rc1_y1 < 65 or
                           gr_wide.rc2_y1 < 65 or
                           gr_wide.rc3_y1 < 65 or
                           gr_wide.rc4_y1 < 65 or
                           gr_wide.rc5_y1 < 65 or
                           gr_wide.rc6_y1 < 65 or
                           gr_wide.rc7_y1 < 65 or
                           gr_wide.rc8_y1 < 65) 
                     then 'Off Track'
                     when (gr_wide.rc1_y1 < 70 or
                           gr_wide.rc2_y1 < 70 or
                           gr_wide.rc3_y1 < 70 or
                           gr_wide.rc4_y1 < 70 or
                           gr_wide.rc5_y1 < 70 or
                           gr_wide.rc6_y1 < 70 or
                           gr_wide.rc7_y1 < 70 or
                           gr_wide.rc8_y1 < 70) 
                     then 'Warning'
--                        when (nvl(gr_wide.rc1_y1,100) >= 85 and
--                              nvl(gr_wide.rc2_y1,100) >= 85 and
--                              nvl(gr_wide.rc3_y1,100) >= 85 and
--                              nvl(gr_wide.rc4_y1,100) >= 85 and 
--                              nvl(gr_wide.rc5_y1,100) >= 85 and
--                              nvl(gr_wide.rc6_y1,100) >= 85 and
--                              nvl(gr_wide.rc7_y1,100) >= 85 and
--                              nvl(gr_wide.rc8_y1,100) >= 85) then 'Honors'      
                     else 'Satisfactory' 
                   end as promo_status_grades
                  ,Rise_GPA.GPA_Y1 as GPA
                  ,CAST(mem.mem AS VARCHAR) + '-(' + CAST(ac.absences_total AS VARCHAR) + '+(' + CAST(ac.tardies_total AS VARCHAR) + '/3))' + '/' + CAST(mem.mem AS VARCHAR) as att_string
                  ,ac.absences_total + floor(ac.tardies_total/3) as attendance_points
                  ,round(
                            ((mem.mem - (ac.absences_total + floor(ac.tardies_total/3))) / mem.mem) * 100
                        ,2) as y1_att_pts_pct
                  ,rise_hw.simple_avg
            from STUDENTS s
            left outer join GRADES$wide_all#MS gr_wide on s.id = gr_wide.studentid
            left outer join GPA$detail#Rise Rise_GPA on s.id = Rise_GPA.studentid
            left outer join ATT_MEM$attendance_counts ac on s.id = ac.id
            left outer join ATT_MEM$membership_counts mem on s.id = mem.id
            left outer join GRADES$elements rise_hw
                         ON s.id = rise_hw.studentid
                        AND rise_hw.pgf_type = 'H'
                        AND rise_hw.course_number = 'all_courses'
            where s.schoolid = 73252 and s.enroll_status = 0              
            )sub
 )sub1
/*
PURPOSE:
  Sum counts of merits (NCA feedback to students for positive actions) for each student
  
MAINTENANCE:
  Dependent on DISC$MERITS#NCA
  
MAJOR STRUCTURAL REVISIONS OR CHANGES:
  Changed perfect week to +3 (previously 2) 2013-09-12
  
CREATED BY: AM2
  
ORIGIN DATE: Fall 2011
  
*/

USE KIPP_NJ
GO

SELECT studentid
      ,student_number
      --teacher merits
      ,teacher_merits
      ,teacher_merits_rt1
      ,teacher_merits_rt2
      ,teacher_merits_rt3
      ,teacher_merits_rt4
      --perfect weeks
      ,perfect_week_merits
      ,perfect_week_merits_rt1
      ,perfect_week_merits_rt2
      ,perfect_week_merits_rt3
      ,perfect_week_merits_rt4            
      --total merits
      ,teacher_merits + perfect_week_merits AS total_merits
      ,teacher_merits_rt1 + perfect_week_merits_rt1 AS total_merits_rt1
      ,teacher_merits_rt2 + perfect_week_merits_rt2 AS total_merits_rt2
      ,teacher_merits_rt3 + perfect_week_merits_rt3 AS total_merits_rt3
      ,teacher_merits_rt4 + perfect_week_merits_rt4 AS total_merits_rt4
      
FROM
      (SELECT s.id AS studentid
             ,s.student_number
             --teacher merits
             ,COUNT(merits.rn) AS teacher_merits
             ,SUM(CASE WHEN merits.rt = 'RT1' THEN 1 ELSE 0 END) AS teacher_merits_rt1
             ,SUM(CASE WHEN merits.rt = 'RT2' THEN 1 ELSE 0 END) AS teacher_merits_rt2
             ,SUM(CASE WHEN merits.rt = 'RT3' THEN 1 ELSE 0 END) AS teacher_merits_rt3
             ,SUM(CASE WHEN merits.rt = 'RT4' THEN 1 ELSE 0 END) AS teacher_merits_rt4
             --perfect weeks
             ,(perfect.perfect_weeks * 3) AS perfect_week_merits
             ,(perfect.perfect_weeks_rt1 * 3) AS perfect_week_merits_rt1
             ,(perfect.perfect_weeks_rt2 * 3) AS perfect_week_merits_rt2
             ,(perfect.perfect_weeks_rt3 * 3) AS perfect_week_merits_rt3
             ,(perfect.perfect_weeks_rt4 * 3) AS perfect_week_merits_rt4            
       FROM STUDENTS s
       LEFT OUTER JOIN DISC$log merits
         ON s.id = merits.studentid
        AND logtypeid = 3023
       LEFT OUTER JOIN disc$perfect_weeks#NCA perfect
         ON s.id = perfect_studentid
       WHERE s.schoolid = 73253 and s.enroll_status = 0
       GROUP BY s.id, s.student_number, perfect.perfect_weeks,perfect.perfect_weeks_rt1, perfect.perfect_weeks_rt2
                 ,perfect.perfect_weeks_rt3, perfect.perfect_weeks_rt4
      ) sub
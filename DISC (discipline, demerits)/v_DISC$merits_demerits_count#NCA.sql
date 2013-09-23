/*
PURPOSE:
  Sum counts of merits and demerits (NCA feedback to students for positive/negative actions) for each student
  
MAINTENANCE:
  Dependent on DISC$log
  
MAJOR STRUCTURAL REVISIONS OR CHANGES:
  Changed perfect week to +3 (previously 2) 2013-09-12
  JOINED with demerits
  
CREATED BY: AM2
  
ORIGIN DATE: Fall 2011
*/

USE KIPP_NJ
GO

--ALTER VIEW DISC$merits_demerits_count#NCA AS
SELECT s.id AS studentid
      ,s.student_number
      
      --MERITS
      --teacher merits
      ,ISNULL(teacher_merits,0) AS teacher_merits
      ,ISNULL(teacher_merits_rt1,0) AS teacher_merits_rt1
      ,ISNULL(teacher_merits_rt2,0) AS teacher_merits_rt2
      ,ISNULL(teacher_merits_rt3,0) AS teacher_merits_rt3
      ,ISNULL(teacher_merits_rt4,0) AS teacher_merits_rt4
      --perfect weeks
      ,ISNULL(perfect_week_merits,0) AS perfect_week_merits
      ,ISNULL(perfect_week_merits_rt1,0) AS perfect_week_merits_rt1
      ,ISNULL(perfect_week_merits_rt2,0) AS perfect_week_merits_rt2
      ,ISNULL(perfect_week_merits_rt3,0) AS perfect_week_merits_rt3
      ,ISNULL(perfect_week_merits_rt4,0)    AS perfect_week_merits_rt4
      --total merits
      ,ISNULL(teacher_merits + perfect_week_merits,0) AS total_merits
      ,ISNULL(teacher_merits_rt1 + perfect_week_merits_rt1,0) AS total_merits_rt1
      ,ISNULL(teacher_merits_rt2 + perfect_week_merits_rt2,0) AS total_merits_rt2
      ,ISNULL(teacher_merits_rt3 + perfect_week_merits_rt3,0) AS total_merits_rt3
      ,ISNULL(teacher_merits_rt4 + perfect_week_merits_rt4,0) AS total_merits_rt4

      --DEMERITS
      ,ISNULL(total_demerits,0) AS total_demerits
      --by reporting term
      ,ISNULL(total_demerits_rt1,0) AS total_demerits_rt1
      ,ISNULL(total_demerits_rt2,0) AS total_demerits_rt2
      ,ISNULL(total_demerits_rt3,0) AS total_demerits_rt3
      ,ISNULL(total_demerits_rt4,0) AS total_demerits_rt4
      --by tier
      ,ISNULL(total_tier1_demerits,0) AS total_tier1_demerits
      ,ISNULL(total_tier2_demerits,0) AS total_tier2_demerits
      ,ISNULL(total_tier3_demerits,0) AS total_tier3_demerits
      --tier by reporting term
      ,ISNULL(tier1_demerits_rt1,0) AS tier1_demerits_rt1
      ,ISNULL(tier1_demerits_rt2,0) AS tier1_demerits_rt2
      ,ISNULL(tier1_demerits_rt3,0) AS tier1_demerits_rt3
      ,ISNULL(tier1_demerits_rt4,0) AS tier1_demerits_rt4
      ,ISNULL(tier2_demerits_rt1,0) AS tier2_demerits_rt1
      ,ISNULL(tier2_demerits_rt2,0) AS tier2_demerits_rt2
      ,ISNULL(tier2_demerits_rt3,0) AS tier2_demerits_rt3
      ,ISNULL(tier2_demerits_rt4,0) AS tier2_demerits_rt4
      ,ISNULL(tier3_demerits_rt1,0) AS tier3_demerits_rt1
      ,ISNULL(tier3_demerits_rt2,0) AS tier3_demerits_rt2
      ,ISNULL(tier3_demerits_rt3,0) AS tier3_demerits_rt3
      ,ISNULL(tier3_demerits_rt4,0) AS tier3_demerits_rt4

FROM STUDENTS s

--Merits
LEFT OUTER JOIN (SELECT studentid             
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
                 FROM DISC$log merits        
                 LEFT OUTER JOIN disc$perfect_weeks#NCA perfect
                   ON studentid = perfect_studentid
                 WHERE logtypeid = 3023
                 GROUP BY studentid, perfect.perfect_weeks, perfect.perfect_weeks_rt1, perfect.perfect_weeks_rt2,perfect.perfect_weeks_rt3, perfect.perfect_weeks_rt4
                ) merits
  ON s.id = merits.studentid

--Demerits
LEFT OUTER JOIN (SELECT studentid                       
                       ,COUNT(demerits.rn) AS total_demerits                       
                       --by reporting term
                       ,SUM(CASE when demerits.rt = 'RT1' THEN 1 ELSE 0 END) AS total_demerits_rt1
                       ,SUM(CASE when demerits.rt = 'RT2' THEN 1 ELSE 0 END) AS total_demerits_rt2
                       ,SUM(CASE when demerits.rt = 'RT3' THEN 1 ELSE 0 END) AS total_demerits_rt3
                       ,SUM(CASE when demerits.rt = 'RT4' THEN 1 ELSE 0 END) AS total_demerits_rt4                       
                       --by tier
                       ,SUM(CASE when demerits.tier = 'Tier 1' THEN 1 ELSE 0 END) AS total_tier1_demerits
                       ,SUM(CASE when demerits.tier = 'Tier 2' THEN 1 ELSE 0 END) AS total_tier2_demerits
                       ,SUM(CASE when demerits.tier = 'Tier 3' THEN 1 ELSE 0 END) AS total_tier3_demerits                       
                       --tier by reporting term
                       ,SUM(CASE when demerits.rt = 'RT1' and demerits.tier = 'Tier 1' THEN 1 ELSE 0 END) AS tier1_demerits_rt1
                       ,SUM(CASE when demerits.rt = 'RT2' and demerits.tier = 'Tier 1' THEN 1 ELSE 0 END) AS tier1_demerits_rt2
                       ,SUM(CASE when demerits.rt = 'RT3' and demerits.tier = 'Tier 1' THEN 1 ELSE 0 END) AS tier1_demerits_rt3
                       ,SUM(CASE when demerits.rt = 'RT4' and demerits.tier = 'Tier 1' THEN 1 ELSE 0 END) AS tier1_demerits_rt4                       
                       ,SUM(CASE when demerits.rt = 'RT1' and demerits.tier = 'Tier 2' THEN 1 ELSE 0 END) AS tier2_demerits_rt1
                       ,SUM(CASE when demerits.rt = 'RT2' and demerits.tier = 'Tier 2' THEN 1 ELSE 0 END) AS tier2_demerits_rt2
                       ,SUM(CASE when demerits.rt = 'RT3' and demerits.tier = 'Tier 2' THEN 1 ELSE 0 END) AS tier2_demerits_rt3
                       ,SUM(CASE when demerits.rt = 'RT4' and demerits.tier = 'Tier 2' THEN 1 ELSE 0 END) AS tier2_demerits_rt4                       
                       ,SUM(CASE when demerits.rt = 'RT1' and demerits.tier = 'Tier 3' THEN 1 ELSE 0 END) AS tier3_demerits_rt1
                       ,SUM(CASE when demerits.rt = 'RT2' and demerits.tier = 'Tier 3' THEN 1 ELSE 0 END) AS tier3_demerits_rt2
                       ,SUM(CASE when demerits.rt = 'RT3' and demerits.tier = 'Tier 3' THEN 1 ELSE 0 END) AS tier3_demerits_rt3
                       ,SUM(CASE when demerits.rt = 'RT4' and demerits.tier = 'Tier 3' THEN 1 ELSE 0 END) AS tier3_demerits_rt4                             
                 FROM DISC$log demerits                   
                 WHERE logtypeid = 3223                 
                 GROUP BY studentid
                ) demerits
  ON s.id = demerits.studentid

WHERE s.schoolid = 73253
  AND s.enroll_status = 0
  AND s.id = 3551
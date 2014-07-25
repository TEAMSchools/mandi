/*
PURPOSE:
  Sum counts for demerits (NCA discipline) for each student
  
MAINTENANCE:
  Dependent on MV Demerits
  
MAJOR STRUCTURAL REVISIONS OR CHANGES:
  None
  
CREATED BY: AM2
  
ORIGIN DATE: Fall 2011
  
*/

USE KIPP_NJ
GO

SELECT s.id AS studentid
      ,s.student_number
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
      
      --reporting term by tier
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
            
FROM STUDENTS s
LEFT OUTER JOIN DISC$log demerits
  ON s.id = demerits.studentid
 AND logtypeid = 3223
WHERE s.schoolid = 73253
  AND s.enroll_status = 0
GROUP BY s.id, s.student_number
USE KIPP_NJ
GO

ALTER VIEW COMPLIANCE$civil_rights_data_collection AS 

WITH pt1_roster AS (
  SELECT co.studentid
        ,co.STUDENT_NUMBER
        ,CASE 
          WHEN co.grade_level = 0 THEN 'KG'
          ELSE 'G' + RIGHT('0' + CONVERT(VARCHAR,co.grade_level), 2)
         END AS grade_level
        ,s.GENDER
        ,CASE
          WHEN s.ETHNICITY = 'B' THEN 'BL'
          WHEN s.ETHNICITY = 'H' THEN 'HI'
          WHEN s.ETHNICITY = 'T' THEN 'TR'
          WHEN s.ETHNICITY = 'W' THEN 'WH'
         END AS ethnicity
        ,CASE WHEN cs.SPEDLEP LIKE '%SPED%' THEN 'IDEA' ELSE NULL END AS IDEA
        ,CASE WHEN cs.SPEDLEP = 'LEP' THEN 'LEP' ELSE NULL END AS LEP
        ,CASE WHEN cs.STATUS_504 = 1 THEN '504' ELSE NULL END AS [504_status]
  FROM COHORT$comprehensive_long#static co WITH(NOLOCK)
  JOIN STUDENTS s WITH(NOLOCK)
    ON co.studentid = s.id
  JOIN CUSTOM_STUDENTS cs WITH(NOLOCK)
    ON co.studentid = cs.STUDENTID  
  WHERE co.year = 2013
    AND co.grade_level < 99
    AND co.entrydate <= '2013-10-15'
    AND co.exitdate >= '2013-10-15'
 )

,pt2_roster AS (
  SELECT co.studentid
        ,co.STUDENT_NUMBER
        ,CASE 
          WHEN co.grade_level = 0 THEN 'KG'
          ELSE 'G' + RIGHT('0' + CONVERT(VARCHAR,co.grade_level), 2)
         END AS grade_level        
        ,s.GENDER
        ,CASE
          WHEN s.ETHNICITY = 'B' THEN 'BL'
          WHEN s.ETHNICITY = 'H' THEN 'HI'
          WHEN s.ETHNICITY = 'T' THEN 'TR'
          WHEN s.ETHNICITY = 'W' THEN 'WH'
         END AS ethnicity
        ,CASE WHEN cs.SPEDLEP LIKE '%SPED%' THEN 'IDEA' ELSE NULL END AS IDEA
        ,CASE WHEN cs.SPEDLEP = 'LEP' THEN 'LEP' ELSE NULL END AS LEP
        ,CASE WHEN cs.STATUS_504 = 1 THEN '504' ELSE NULL END AS [504_status]        
        ,CASE 
          WHEN co.grade_level < next_yr.grade_level THEN 0
          WHEN co.grade_level = next_yr.grade_level THEN 1          
          WHEN blobs.transfercomment LIKE '%Retained%' THEN 1 
          ELSE 0 
         END AS is_retained
  FROM COHORT$comprehensive_long#static co WITH(NOLOCK)
  LEFT OUTER JOIN COHORT$comprehensive_long#static next_yr WITH(NOLOCK)
    ON co.year = (next_yr.year - 1)
   AND co.studentid = next_yr.studentid
   AND next_yr.rn = 1
  JOIN STUDENTS s WITH(NOLOCK)
    ON co.studentid = s.id
  JOIN CUSTOM_STUDENTS cs WITH(NOLOCK)
    ON co.studentid = cs.STUDENTID
  LEFT OUTER JOIN PS$student_BLObs#static blobs WITH(NOLOCK)
    ON co.studentid = blobs.studentid
  WHERE co.year = 2013
    AND co.grade_level < 99    
    AND co.rn = 1
 )

,abs_count AS (
  SELECT r.*
        ,COUNT(mem.CALENDARDATE) AS abs_count
  FROM pt2_roster r WITH(NOLOCK)
  LEFT OUTER JOIN KIPP_NJ..ATT_MEM$MEMBERSHIP mem WITH(NOLOCK)
    ON r.studentid = mem.STUDENTID
   AND mem.academic_year = 2013
   AND mem.MEMBERSHIPVALUE = 1
   AND mem.ATTENDANCEVALUE = 0
  GROUP BY r.studentid
          ,r.STUDENT_NUMBER
          ,r.grade_level
          ,r.GENDER
          ,r.ethnicity
          ,r.IDEA
          ,r.LEP
          ,r.[504_status]
          ,r.is_retained
 )

,suspension_count AS (
  SELECT r.*
        ,SUM(CASE WHEN att.att_code = 'S' THEN 1 ELSE 0 END) AS ISS
        ,ISNULL(oss.OSS,0) AS OSS
  FROM pt2_roster r WITH(NOLOCK)
  LEFT OUTER JOIN ATT_MEM$ATTENDANCE att WITH(NOLOCK)
    ON r.studentid = att.STUDENTID
   AND att.academic_year = 2013
   AND att.att_code = 'S'
  LEFT OUTER JOIN (
                   SELECT studentid
                         ,COUNT(streak_id) AS OSS
                   FROM ATT_MEM$attendance_streak WITH(NOLOCK)
                   WHERE academic_year = 2013
                     AND att_code = 'OS'
                   GROUP BY studentid
                  ) oss
    ON r.studentid = oss.studentid
  GROUP BY r.studentid
          ,r.student_number
          ,r.grade_level
          ,r.gender
          ,r.ethnicity
          ,r.IDEA
          ,r.LEP
          ,r.[504_status]
          ,r.is_retained
          ,oss.OSS
 )

--Overall Student Enrollment
SELECT 'SCH_ENR_' + ethnicity + '_' + GENDER AS field_name
      ,COUNT(studentid) AS N
FROM pt1_roster WITH(NOLOCK)
GROUP BY ethnicity
        ,GENDER

UNION ALL

SELECT 'SCH_ENR_' + IDEA + '_' + GENDER AS field_name
      ,COUNT(*) AS N
FROM pt1_roster WITH(NOLOCK)
WHERE IDEA = 'IDEA'
GROUP BY IDEA
        ,GENDER

UNION ALL

SELECT 'SCH_ENR_' + [504_status] + '_' + GENDER AS field_name
      ,COUNT(*) AS N
FROM pt1_roster WITH(NOLOCK)
WHERE [504_status] = '504'
GROUP BY [504_status]
        ,GENDER

UNION ALL

SELECT 'SCH_ENR_' +  LEP + '_' + GENDER AS field_name
      ,COUNT(*) AS N
FROM pt1_roster WITH(NOLOCK)
WHERE LEP = 'LEP'
GROUP BY LEP
        ,GENDER

UNION ALL

--Enrollment of Students who are Limited English Proficient (LEP) 
/* SKIPPED - All should be 0 */

--Students Enrolled in LEP Programs
/* SKIPPED - All should be 0 */

-- Students with disabilities served under IDEA
SELECT 'SCH_IDEAENR_' + ethnicity + '_' + GENDER AS field_name
      ,COUNT(studentid) AS N
FROM pt1_roster WITH(NOLOCK)
WHERE IDEA = 'IDEA'
GROUP BY ethnicity
        ,GENDER

UNION ALL

SELECT 'SCH_IDEAENR_' +  LEP + '_' + GENDER AS field_name
      ,COUNT(*) AS N
FROM pt1_roster WITH(NOLOCK)
WHERE IDEA = 'IDEA'
  AND LEP = 'LEP'
GROUP BY LEP
        ,GENDER

UNION ALL

-- Students with disabilities served under Section 504 of the Rehabilitation Act of 1973, but not served  under IDEA
SELECT 'SCH_504ENR_' + ethnicity + '_' + GENDER AS field_name
      ,COUNT(studentid) AS N
FROM pt1_roster WITH(NOLOCK)
WHERE [504_status] = '504'
GROUP BY ethnicity
        ,GENDER

UNION ALL

SELECT 'SCH_504ENR_' +  LEP + '_' + GENDER AS field_name
      ,COUNT(*) AS N
FROM pt1_roster WITH(NOLOCK)
WHERE [504_status] = '504'
  AND LEP = 'LEP'
GROUP BY LEP
        ,GENDER

UNION ALL

-- Students who were retained in Grade X
SELECT 'SCH_RET_' + grade_level + '_' + ethnicity + '_' + GENDER AS field_name
      ,COUNT(studentid) AS N
FROM pt2_roster WITH(NOLOCK)
WHERE is_retained = 1
GROUP BY ethnicity
        ,GENDER
        ,grade_level

UNION ALL

SELECT 'SCH_RET_' + grade_level + '_' + IDEA + '_' + GENDER AS field_name
      ,COUNT(*) AS N
FROM pt2_roster WITH(NOLOCK)
WHERE IDEA = 'IDEA'
  AND is_retained = 1
GROUP BY IDEA
        ,GENDER
        ,grade_level

UNION ALL

SELECT 'SCH_RET_' + grade_level + '_' + [504_status] + '_' + GENDER AS field_name
      ,COUNT(*) AS N
FROM pt2_roster WITH(NOLOCK)
WHERE [504_status] = '504'
  AND is_retained = 1
GROUP BY [504_status]
        ,GENDER
        ,grade_level

UNION ALL

SELECT 'SCH_RET_' + grade_level + '_' +  LEP + '_' + GENDER AS field_name
      ,COUNT(*) AS N
FROM pt2_roster WITH(NOLOCK)
WHERE LEP = 'LEP'
  AND is_retained = 1
GROUP BY LEP
        ,GENDER
        ,grade_level

UNION ALL

-- Student Retention Indicator (1 = Yes, 0 = No)
SELECT 'SCH_RET_' + grade_level + '_IND' AS field_name
      ,CASE WHEN COUNT(studentid) > 0 THEN 1 ELSE 0 END AS N
FROM pt2_roster WITH(NOLOCK)
WHERE is_retained = 1
GROUP BY grade_level

UNION ALL

-- Chronic Student Absenteeism - Students absent 15 or more school days during school year
SELECT 'SCH_ABSENT_' + ethnicity + '_' + GENDER AS field_name
      ,COUNT(studentid) AS N
FROM abs_count WITH(NOLOCK)
WHERE abs_count >= 15
GROUP BY ethnicity
        ,GENDER        

UNION ALL

SELECT 'SCH_ABSENT_' + IDEA + '_' + GENDER AS field_name
      ,COUNT(*) AS N
FROM abs_count WITH(NOLOCK)
WHERE IDEA = 'IDEA'
  AND abs_count >= 15
GROUP BY IDEA
        ,GENDER        

UNION ALL

SELECT 'SCH_ABSENT_' + [504_status] + '_' + GENDER AS field_name
      ,COUNT(*) AS N
FROM abs_count WITH(NOLOCK)
WHERE [504_status] = '504'
  AND abs_count >= 15
GROUP BY [504_status]
        ,GENDER        

UNION ALL

SELECT 'SCH_ABSENT_' +  LEP + '_' + GENDER AS field_name
      ,COUNT(*) AS N
FROM abs_count WITH(NOLOCK)
WHERE LEP = 'LEP'
  AND abs_count >= 15
GROUP BY LEP
        ,GENDER

UNION ALL

-- Students without disabilities who received one or more in-school suspensions
SELECT 'SCH_DISCWODIS_ISS_' + ethnicity + '_' + GENDER AS field_name
      ,COUNT(studentid) AS N
FROM suspension_count WITH(NOLOCK)
WHERE ISS >= 1
  AND IDEA IS NULL
  AND [504_status] IS NULL
GROUP BY ethnicity
        ,GENDER        

UNION ALL

SELECT 'SCH_DISCWODIS_ISS_' +  LEP + '_' + GENDER AS field_name
      ,COUNT(*) AS N
FROM suspension_count WITH(NOLOCK)
WHERE ISS >= 1
  AND IDEA IS NULL
  AND [504_status] IS NULL
  AND LEP = 'LEP'  
GROUP BY LEP
        ,GENDER

UNION ALL

-- Students without disabilities who received only one out-of-school suspension
SELECT 'SCH_DISCWODIS_SINGOOS_' + ethnicity + '_' + GENDER AS field_name
      ,COUNT(studentid) AS N
FROM suspension_count WITH(NOLOCK)
WHERE OSS = 1
  AND IDEA IS NULL
  AND [504_status] IS NULL
GROUP BY ethnicity
        ,GENDER        

UNION ALL

SELECT 'SCH_DISCWODIS_SINGOOS_' +  LEP + '_' + GENDER AS field_name
      ,COUNT(*) AS N
FROM suspension_count WITH(NOLOCK)
WHERE OSS = 1
  AND IDEA IS NULL
  AND [504_status] IS NULL
  AND LEP = 'LEP'  
GROUP BY LEP
        ,GENDER

UNION ALL

-- Students without disabilities who received more than one out-of-school suspension
SELECT 'SCH_DISCWODIS_MULTIOOS_' + ethnicity + '_' + GENDER AS field_name
      ,COUNT(studentid) AS N
FROM suspension_count WITH(NOLOCK)
WHERE OSS > 1
  AND IDEA IS NULL
  AND [504_status] IS NULL
GROUP BY ethnicity
        ,GENDER        

UNION ALL

SELECT 'SCH_DISCWODIS_MULTIOOS_' +  LEP + '_' + GENDER AS field_name
      ,COUNT(*) AS N
FROM suspension_count WITH(NOLOCK)
WHERE OSS > 1
  AND IDEA IS NULL
  AND [504_status] IS NULL
  AND LEP = 'LEP'  
GROUP BY LEP
        ,GENDER

UNION ALL

-- Students WITH disabilities who received one or more in-school suspensions
SELECT 'SCH_DISCWDIS_ISS_IDEA_' + ethnicity + '_' + GENDER AS field_name
      ,COUNT(studentid) AS N
FROM suspension_count WITH(NOLOCK)
WHERE ISS >= 1
  AND IDEA = 'IDEA'
GROUP BY ethnicity
        ,GENDER        

UNION ALL

SELECT 'SCH_DISCWDIS_ISS_' +  LEP + '_' + GENDER AS field_name
      ,COUNT(*) AS N
FROM suspension_count WITH(NOLOCK)
WHERE ISS >= 1
  AND IDEA = 'IDEA'
  AND LEP = 'LEP'  
GROUP BY LEP
        ,GENDER

UNION ALL

SELECT 'SCH_DISCWDIS_ISS_' + [504_status] + '_' + GENDER AS field_name
      ,COUNT(studentid) AS N
FROM suspension_count WITH(NOLOCK)
WHERE ISS >= 1
  AND [504_status] = '504'
GROUP BY GENDER        
        ,[504_status]

UNION ALL

-- Students WITH disabilities who received only one out-of-school suspension
SELECT 'SCH_DISCWDIS_SINGOOS_IDEA_' + ethnicity + '_' + GENDER AS field_name
      ,COUNT(studentid) AS N
FROM suspension_count WITH(NOLOCK)
WHERE OSS = 1
  AND IDEA = 'IDEA'
GROUP BY ethnicity
        ,GENDER        

UNION ALL

SELECT 'SCH_DISCWDIS_SINGOOS_' +  LEP + '_' + GENDER AS field_name
      ,COUNT(*) AS N
FROM suspension_count WITH(NOLOCK)
WHERE OSS = 1
  AND IDEA = 'IDEA'
  AND LEP = 'LEP'  
GROUP BY LEP
        ,GENDER

UNION ALL

SELECT 'SCH_DISCWDIS_SINGOOS_' + [504_status] + '_' + GENDER AS field_name
      ,COUNT(studentid) AS N
FROM suspension_count WITH(NOLOCK)
WHERE OSS = 1
  AND [504_status] = '504'
GROUP BY GENDER   
        ,[504_status]     

UNION ALL

-- Students WITH disabilities who received more than one out-of-school suspension
SELECT 'SCH_DISCWDIS_MULTOOS_IDEA_' + ethnicity + '_' + GENDER AS field_name
      ,COUNT(studentid) AS N
FROM suspension_count WITH(NOLOCK)
WHERE OSS > 1
  AND IDEA = 'IDEA'
GROUP BY ethnicity
        ,GENDER        

UNION ALL

SELECT 'SCH_DISCWDIS_MULTOOS_' +  LEP + '_' + GENDER AS field_name
      ,COUNT(*) AS N
FROM suspension_count WITH(NOLOCK)
WHERE OSS > 1
  AND IDEA = 'IDEA'
  AND LEP = 'LEP'  
GROUP BY LEP
        ,GENDER

UNION ALL

SELECT 'SCH_DISCWDIS_MULTOOS_' + [504_status] + '_' + GENDER AS field_name
      ,COUNT(studentid) AS N
FROM suspension_count WITH(NOLOCK)
WHERE OSS > 1
  AND [504_status] = '504'
GROUP BY GENDER       
        ,[504_status]
USE KIPP_NJ
GO

ALTER VIEW COMPLIANCE$civil_rights_data_collection AS 

WITH pt1_roster AS (
  /* only 10/15 students */
  SELECT co.studentid
        ,co.STUDENT_NUMBER
        ,CASE 
          WHEN co.grade_level = 0 THEN 'KG'
          ELSE 'G' + RIGHT('0' + CONVERT(VARCHAR,co.grade_level), 2)
         END AS grade_level
        ,co.GENDER        
        ,CASE
          WHEN co.ETHNICITY = 'B' THEN 'BL'
          WHEN co.ETHNICITY = 'H' THEN 'HI'
          WHEN co.ETHNICITY = 'T' THEN 'TR'
          WHEN co.ETHNICITY = 'W' THEN 'WH'
         END AS ethnicity
        ,CASE WHEN co.SPEDLEP LIKE '%SPED%' THEN 'IDEA' ELSE NULL END AS IDEA
        ,CASE WHEN co.SPEDLEP = 'LEP' THEN 'LEP' ELSE NULL END AS LEP
        ,CASE WHEN co.STATUS_504 = 1 THEN '504' ELSE NULL END AS [504_status]
        ,co.retained_yr_flag AS is_retained
  FROM KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK)
  WHERE co.year = 2013
    AND co.grade_level < 99
    AND co.entrydate <= '2013-10-15'
    AND co.exitdate >= '2013-10-15'
 )

,pt2_roster AS (
  /* only 10/15 students */
  SELECT co.studentid
        ,co.STUDENT_NUMBER
        ,CASE 
          WHEN co.grade_level = 0 THEN 'KG'
          ELSE 'G' + RIGHT('0' + CONVERT(VARCHAR,co.grade_level), 2)
         END AS grade_level        
        ,co.GENDER
        ,CASE
          WHEN co.ETHNICITY = 'B' THEN 'BL'
          WHEN co.ETHNICITY = 'H' THEN 'HI'
          WHEN co.ETHNICITY = 'T' THEN 'TR'
          WHEN co.ETHNICITY = 'W' THEN 'WH'
         END AS ethnicity
        ,CASE WHEN co.SPEDLEP LIKE '%SPED%' THEN 'IDEA' ELSE NULL END AS IDEA
        ,CASE WHEN co.SPEDLEP = 'LEP' THEN 'LEP' ELSE NULL END AS LEP
        ,CASE WHEN co.STATUS_504 = 1 THEN '504' ELSE NULL END AS [504_status]        
        ,co.retained_yr_flag AS is_retained
  FROM KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK)  
  WHERE co.year = 2013
    AND co.grade_level < 99    
    AND co.rn = 1
 )

,abs_count AS (
  SELECT r.*
        ,COUNT(mem.studentid) AS abs_count
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

,enrollments AS (
  SELECT STUDENTID      
        ,termid
        ,CASE WHEN CREDITTYPE NOT IN ('MATH','SCI') THEN 'OTH' ELSE CREDITTYPE END AS credittype
        ,COURSE_NUMBER
        ,COURSE_NAME
        ,CASE
          WHEN COURSE_NUMBER IN ('M310','M400','M405','M415','MATH10') THEN 'ALG'
          WHEN COURSE_NUMBER IN ('MATH20','MATH22','MATH25','MATH73') THEN 'GEOM'
          WHEN COURSE_NUMBER IN ('MATH32','MATH35') THEN 'ALG2'        
          WHEN COURSE_NUMBER IN ('MATH40','MATH44','MATH45') THEN 'ADVM'
          WHEN COURSE_NUMBER IN ('MATH42') THEN 'CALC'        
          WHEN COURSE_NUMBER IN ('SCI20','SCI25') THEN 'BIOL'
          WHEN COURSE_NUMBER IN ('SCI30','SCI35') THEN 'CHEM'        
          WHEN COURSE_NUMBER IN ('SCI31','SCI36') THEN 'PHYS'                    
         END AS course_shorthand
        ,CASE WHEN COURSE_NUMBER IN ('MATH45','ENG45','FREN45','HIST25','HIST35') THEN 1 ELSE 0 END AS is_AP
        ,ROW_NUMBER() OVER(
          PARTITION BY studentid, course_number
            ORDER BY dateleft DESC) AS rn_dupes
  FROM KIPP_NJ..PS$course_enrollments#static enr WITH(NOLOCK)
  WHERE enr.academic_year = 2013
    AND drop_flags = 0
    AND COURSE_NUMBER IN ('ENG45','FREN45','HIST25','HIST35','M310','M400','M405','M415','MATH10','MATH20','MATH22','MATH25'
                         ,'MATH32','MATH35','MATH40','MATH42','MATH44','MATH45','MATH73','SCI20','SCI25','SCI30','SCI31'
                         ,'SCI35','SCI36','SCI40','SCI41','SCI43')
 )

/* Overall Student Enrollment */
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

/* Students with disabilities served under IDEA */
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

/* Students with disabilities served under Section 504 of the Rehabilitation Act of 1973, but not served  under IDEA */
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

/* Students who were retained in Grade X */
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

/* Student Retention Indicator (1 = Yes, 0 = No) */
SELECT 'SCH_RET_' + grade_level + '_IND' AS field_name
      ,CASE WHEN COUNT(studentid) > 0 THEN 1 ELSE 0 END AS N
FROM pt2_roster WITH(NOLOCK)
WHERE is_retained = 1
GROUP BY grade_level

UNION ALL

/* Chronic Student Absenteeism - Students absent 15 or more school days during school year */
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

/* Students without disabilities who received one or more in-school suspensions */
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

/* Students without disabilities who received only one out-of-school suspension */
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

/* Students without disabilities who received more than one out-of-school suspension */
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

/* Students WITH disabilities who received one or more in-school suspensions */
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

/* Students WITH disabilities who received only one out-of-school suspension */
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

/* Students WITH disabilities who received more than one out-of-school suspension */
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
        
UNION ALL

/* Students who passed Algebra I in grade... */
-- by ethnicity
SELECT 'SCH_ALGPASS_'
         + CASE
            WHEN r.grade_level IN ('G07','G08') THEN 'GS0708'
            WHEN r.grade_level IN ('G09','G10') THEN 'GS0910'
            WHEN r.grade_level IN ('G11','G12') THEN 'GS1112'
           END + '_'
         + r.ethnicity + '_'
         + r.GENDER AS field_name
      ,COUNT(gr.studentid) AS N
FROM KIPP_NJ..GRADES$STOREDGRADES#static gr WITH(NOLOCK)
JOIN pt2_roster r
  ON gr.STUDENTID = r.studentid
WHERE gr.academic_year = 2013
  AND gr.COURSE_NUMBER IN ('MATH10','MATH15','M400','M310','M405','M415')
  AND gr.STORECODE = 'Y1'
  AND GRADE NOT LIKE 'F%'
GROUP BY CASE
          WHEN r.grade_level IN ('G07','G08') THEN 'GS0708'
          WHEN r.grade_level IN ('G09','G10') THEN 'GS0910'
          WHEN r.grade_level IN ('G11','G12') THEN 'GS1112'
         END 
        ,r.ethnicity
        ,r.gender
UNION ALL
-- by SPED
SELECT 'SCH_ALGPASS_'
         + CASE
            WHEN r.grade_level IN ('G07','G08') THEN 'GS0708'
            WHEN r.grade_level IN ('G09','G10') THEN 'GS0910'
            WHEN r.grade_level IN ('G11','G12') THEN 'GS1112'
           END + '_'
         + r.IDEA + '_'
         + r.GENDER AS field_name
      ,COUNT(gr.studentid) AS N
FROM KIPP_NJ..GRADES$STOREDGRADES#static gr WITH(NOLOCK)
JOIN pt2_roster r
  ON gr.STUDENTID = r.studentid
 AND r.IDEA = 'IDEA'
WHERE gr.academic_year = 2013
  AND gr.COURSE_NUMBER IN ('MATH10','MATH15','M400','M310','M405','M415')
  AND gr.STORECODE = 'Y1'
  AND GRADE NOT LIKE 'F%'
GROUP BY CASE
          WHEN r.grade_level IN ('G07','G08') THEN 'GS0708'
          WHEN r.grade_level IN ('G09','G10') THEN 'GS0910'
          WHEN r.grade_level IN ('G11','G12') THEN 'GS1112'
         END 
        ,r.IDEA
        ,r.gender
UNION ALL
-- by LEP
SELECT 'SCH_ALGPASS_'
         + CASE
            WHEN r.grade_level IN ('G07','G08') THEN 'GS0708'
            WHEN r.grade_level IN ('G09','G10') THEN 'GS0910'
            WHEN r.grade_level IN ('G11','G12') THEN 'GS1112'
           END + '_'
         + r.LEP + '_'
         + r.GENDER AS field_name
      ,COUNT(gr.studentid) AS N
FROM KIPP_NJ..GRADES$STOREDGRADES#static gr WITH(NOLOCK)
JOIN pt2_roster r
  ON gr.STUDENTID = r.studentid
 AND r.LEP = 'LEP'
WHERE gr.academic_year = 2013
  AND gr.COURSE_NUMBER IN ('MATH10','MATH15','M400','M310','M405','M415')
  AND gr.STORECODE = 'Y1'
  AND GRADE NOT LIKE 'F%'
GROUP BY CASE
          WHEN r.grade_level IN ('G07','G08') THEN 'GS0708'
          WHEN r.grade_level IN ('G09','G10') THEN 'GS0910'
          WHEN r.grade_level IN ('G11','G12') THEN 'GS1112'
         END 
        ,r.LEP
        ,r.gender

UNION ALL

/* Students enrolled in Algebra I in grade... */
-- by ethnicity
SELECT 'SCH_ALGENR_'
         + CASE
            WHEN r.grade_level IN ('G07','G08') THEN 'GS0708'
            WHEN r.grade_level IN ('G09','G10') THEN 'GS0910'
            WHEN r.grade_level IN ('G11','G12') THEN 'GS1112'
           END + '_'
         + r.ethnicity + '_'
         + r.GENDER AS field_name
      ,COUNT(enr.studentid) AS N
FROM enrollments enr WITH(NOLOCK)
JOIN pt2_roster r
  ON enr.STUDENTID = r.studentid
WHERE enr.rn_dupes = 1
  AND enr.course_shorthand = 'ALG'
GROUP BY CASE
          WHEN r.grade_level IN ('G07','G08') THEN 'GS0708'
          WHEN r.grade_level IN ('G09','G10') THEN 'GS0910'
          WHEN r.grade_level IN ('G11','G12') THEN 'GS1112'
         END 
        ,r.ethnicity
        ,r.gender
UNION ALL
-- by SPED
SELECT 'SCH_ALGENR_'
         + CASE
            WHEN r.grade_level IN ('G07','G08') THEN 'GS0708'
            WHEN r.grade_level IN ('G09','G10') THEN 'GS0910'
            WHEN r.grade_level IN ('G11','G12') THEN 'GS1112'
           END + '_'
         + r.IDEA + '_'
         + r.GENDER AS field_name
      ,COUNT(enr.studentid) AS N
FROM enrollments enr WITH(NOLOCK)
JOIN pt2_roster r
  ON enr.STUDENTID = r.studentid
 AND r.IDEA = 'IDEA'
WHERE enr.rn_dupes = 1
  AND enr.course_shorthand = 'ALG'  
GROUP BY CASE
          WHEN r.grade_level IN ('G07','G08') THEN 'GS0708'
          WHEN r.grade_level IN ('G09','G10') THEN 'GS0910'
          WHEN r.grade_level IN ('G11','G12') THEN 'GS1112'
         END 
        ,r.IDEA
        ,r.gender
UNION ALL
-- by LEP
SELECT 'SCH_ALGENR_'
         + CASE
            WHEN r.grade_level IN ('G07','G08') THEN 'GS0708'
            WHEN r.grade_level IN ('G09','G10') THEN 'GS0910'
            WHEN r.grade_level IN ('G11','G12') THEN 'GS1112'
           END + '_'
         + r.LEP + '_'
         + r.GENDER AS field_name
      ,COUNT(enr.studentid) AS N
FROM enrollments enr WITH(NOLOCK)
JOIN pt2_roster r
  ON enr.STUDENTID = r.studentid
 AND r.LEP = 'LEP'
WHERE enr.rn_dupes = 1
  AND enr.course_shorthand = 'ALG'  
GROUP BY CASE
          WHEN r.grade_level IN ('G07','G08') THEN 'GS0708'
          WHEN r.grade_level IN ('G09','G10') THEN 'GS0910'
          WHEN r.grade_level IN ('G11','G12') THEN 'GS1112'
         END 
        ,r.LEP
        ,r.gender

UNION ALL

/* Students enrolled in at least one AP course */
-- by ethnicity
SELECT 'SCH_APENR_'
         + r.ethnicity + '_'
         + r.GENDER AS field_name
      ,COUNT(DISTINCT enr.studentid) AS N
FROM enrollments enr WITH(NOLOCK)
JOIN pt2_roster r
  ON enr.STUDENTID = r.studentid
WHERE enr.rn_dupes = 1
  AND enr.is_AP = 1
GROUP BY r.ethnicity
        ,r.gender        
UNION ALL
-- by SPED
SELECT 'SCH_APENR_'
         + r.IDEA + '_'
         + r.GENDER AS field_name
      ,COUNT(DISTINCT enr.studentid) AS N
FROM enrollments enr WITH(NOLOCK)
JOIN pt2_roster r
  ON enr.STUDENTID = r.studentid
 AND r.IDEA = 'IDEA'
WHERE enr.rn_dupes = 1
  AND enr.is_AP = 1
GROUP BY r.IDEA
        ,r.gender        
UNION ALL
-- by LEP
SELECT 'SCH_APENR_'
         + r.LEP + '_'
         + r.GENDER AS field_name
      ,COUNT(DISTINCT enr.studentid) AS N
FROM enrollments enr WITH(NOLOCK)
JOIN pt2_roster r
  ON enr.STUDENTID = r.studentid
 AND r.LEP = 'LEP'
WHERE enr.rn_dupes = 1
  AND enr.is_AP = 1
GROUP BY r.LEP
        ,r.gender        

UNION ALL

/* Students enrolled AP courses by subject */
-- by ethnicity
SELECT 'SCH_AP' + enr.credittype + 'ENR_'
         + r.ethnicity + '_'
         + r.GENDER AS field_name
      ,COUNT(enr.studentid) AS N
FROM enrollments enr WITH(NOLOCK)
JOIN pt2_roster r
  ON enr.STUDENTID = r.studentid
WHERE enr.rn_dupes = 1
  AND enr.is_AP = 1
GROUP BY r.ethnicity
        ,r.gender
        ,enr.credittype
UNION ALL
-- by SPED
SELECT 'SCH_AP' + enr.credittype + 'ENR_'
         + r.IDEA + '_'
         + r.GENDER AS field_name
      ,COUNT(enr.studentid) AS N
FROM enrollments enr WITH(NOLOCK)
JOIN pt2_roster r
  ON enr.STUDENTID = r.studentid
 AND r.IDEA = 'IDEA'
WHERE enr.rn_dupes = 1
  AND enr.is_AP = 1
GROUP BY r.IDEA
        ,r.gender
        ,enr.credittype
UNION ALL
-- by LEP
SELECT 'SCH_AP' + enr.credittype + 'ENR_'
         + r.LEP + '_'
         + r.GENDER AS field_name
      ,COUNT(enr.studentid) AS N
FROM enrollments enr WITH(NOLOCK)
JOIN pt2_roster r
  ON enr.STUDENTID = r.studentid
 AND r.LEP = 'LEP'
WHERE enr.rn_dupes = 1
  AND enr.is_AP = 1
GROUP BY r.LEP
        ,r.gender
        ,enr.credittype

UNION ALL

/* Students enrolled in... */
-- by ethnicity
SELECT 'SCH_' 
         + CASE 
            WHEN enr.course_shorthand = 'GEOM' THEN 'GEOMENR_GS0712_'
            ELSE enr.credittype + 'ENR_' + enr.course_shorthand + '_'
           END
         + r.ethnicity + '_'
         + r.GENDER AS field_name
      ,COUNT(enr.studentid) AS N
FROM enrollments enr WITH(NOLOCK)
JOIN pt2_roster r
  ON enr.STUDENTID = r.studentid
WHERE enr.rn_dupes = 1  
  AND enr.course_shorthand IS NOT NULL
GROUP BY r.ethnicity
        ,r.gender        
        ,enr.course_shorthand
        ,enr.credittype
UNION ALL
-- by SPED
SELECT 'SCH_' 
         + CASE 
            WHEN enr.course_shorthand = 'GEOM' THEN 'GEOMENR_GS0712_'
            ELSE enr.credittype + 'ENR_' + enr.course_shorthand + '_'
           END
         + r.IDEA + '_'
         + r.GENDER AS field_name
      ,COUNT(enr.studentid) AS N
FROM enrollments enr WITH(NOLOCK)
JOIN pt2_roster r
  ON enr.STUDENTID = r.studentid
 AND r.IDEA = 'IDEA'
WHERE enr.rn_dupes = 1  
  AND enr.course_shorthand IS NOT NULL
GROUP BY r.IDEA
        ,r.gender        
        ,enr.course_shorthand
        ,enr.credittype
UNION ALL
-- by LEP
SELECT 'SCH_' 
         + CASE 
            WHEN enr.course_shorthand = 'GEOM' THEN 'GEOMENR_GS0712_'
            ELSE enr.credittype + 'ENR_' + enr.course_shorthand + '_'
           END
         + r.LEP + '_'
         + r.GENDER AS field_name
      ,COUNT(enr.studentid) AS N
FROM enrollments enr WITH(NOLOCK)
JOIN pt2_roster r
  ON enr.STUDENTID = r.studentid
 AND r.LEP = 'LEP'
WHERE enr.rn_dupes = 1  
  AND enr.course_shorthand IS NOT NULL
GROUP BY r.LEP
        ,r.gender        
        ,enr.course_shorthand
        ,enr.credittype

UNION ALL

/* Student Participation in the SAT Reasoning Test or ACT  */
-- by ethnicity
SELECT CONCAT('SCH_SATACT_', r.ethnicity, '_', r.GENDER) AS field_name
      ,COUNT(DISTINCT satact.student_number) AS N
FROM pt2_roster r
JOIN KIPP_NJ..AAA_DELETE$SAT_ACT_participation_20132014 satact WITH(NOLOCK)
  ON r.student_number = satact.student_number
 AND (satact.SAT_taken = 'Yes' OR satact.ACT_taken = 'Yes')
GROUP BY r.ethnicity
        ,r.GENDER
UNION ALL
-- by IDEA
SELECT CONCAT('SCH_SATACT_', r.IDEA, '_', r.GENDER) AS field_name
      ,COUNT(DISTINCT satact.student_number) AS N
FROM pt2_roster r
JOIN KIPP_NJ..AAA_DELETE$SAT_ACT_participation_20132014 satact WITH(NOLOCK)
  ON r.student_number = satact.student_number
 AND (satact.SAT_taken = 'Yes' OR satact.ACT_taken = 'Yes')
WHERE r.IDEA = 'IDEA'
GROUP BY r.IDEA
        ,r.GENDER
UNION ALL
-- by IDEA
SELECT CONCAT('SCH_SATACT_', r.LEP, '_', r.GENDER) AS field_name
      ,COUNT(DISTINCT satact.student_number) AS N
FROM pt2_roster r
JOIN KIPP_NJ..AAA_DELETE$SAT_ACT_participation_20132014 satact WITH(NOLOCK)
  ON r.student_number = satact.student_number
 AND (satact.SAT_taken = 'Yes' OR satact.ACT_taken = 'Yes')
WHERE r.LEP = 'LEP'
GROUP BY r.LEP
        ,r.GENDER

UNION ALL

/*
Students who did not receive a qualifying score on any AP exams for the one or more AP courses enrolled in
Students who received a qualifying score on one or more AP exams for one or more AP courses enrolled in
*/
-- by ethnicity
SELECT field_name
      ,COUNT(DISTINCT student_number) AS N
FROM
    (
     SELECT r.student_number
           ,CONCAT('SCH_APPASS_'
                  ,CASE WHEN MAX(ap.score) OVER(PARTITION BY r.student_number) >= 3 THEN 'ONEORMORE' ELSE 'NONE' END, '_'
                  ,r.ethnicity, '_'
                  ,r.gender) AS field_name
           
     FROM pt2_roster r
     JOIN KIPP_NJ..AAA_DELETE$AP_scores_20132014 ap WITH(NOLOCK)
       ON r.student_number = ap.student_number
    ) sub
GROUP BY field_name
UNION ALL
-- by IDEA
SELECT field_name
      ,COUNT(DISTINCT student_number) AS N
FROM
    (
     SELECT r.student_number
           ,CONCAT('SCH_APPASS_'
                  ,CASE WHEN MAX(ap.score) OVER(PARTITION BY r.student_number) >= 3 THEN 'ONEORMORE' ELSE 'NONE' END, '_'
                  ,r.IDEA, '_'
                  ,r.gender) AS field_name
           
     FROM pt2_roster r
     JOIN KIPP_NJ..AAA_DELETE$AP_scores_20132014 ap WITH(NOLOCK)
       ON r.student_number = ap.student_number
     WHERE r.IDEA = 'IDEA'
    ) sub
GROUP BY field_name
UNION ALL
-- by IDEA
SELECT field_name
      ,COUNT(DISTINCT student_number) AS N
FROM
    (
     SELECT r.student_number
           ,CONCAT('SCH_APPASS_'
                  ,CASE WHEN MAX(ap.score) OVER(PARTITION BY r.student_number) >= 3 THEN 'ONEORMORE' ELSE 'NONE' END, '_'
                  ,r.LEP, '_'
                  ,r.gender) AS field_name
           
     FROM pt2_roster r
     JOIN KIPP_NJ..AAA_DELETE$AP_scores_20132014 ap WITH(NOLOCK)
       ON r.student_number = ap.student_number
     WHERE r.LEP = 'LEP'
    ) sub
GROUP BY field_name

UNION ALL

/*
Students who took one or more AP exams for one or more AP courses enrolled in
Students who were enrolled in one or more AP courses but who did not take any AP exams
*/
-- by ethnicity
SELECT field_name
      ,COUNT(DISTINCT studentid) AS N
FROM
    (
     SELECT enr.STUDENTID
           ,CONCAT('SCH_APEXAM_'
                  ,CASE WHEN SUM(CASE WHEN ap.student_number IS NOT NULL THEN 1 ELSE 0 END) OVER(PARTITION BY enr.studentid) > 0 THEN 'ONEORMORE_' ELSE 'NONE_' END
                  ,r.ethnicity, '_'
                  ,r.GENDER) AS field_name
     FROM enrollments enr WITH(NOLOCK)
     JOIN pt2_roster r
       ON enr.STUDENTID = r.studentid
     LEFT OUTER JOIN KIPP_NJ..AAA_DELETE$AP_scores_20132014 ap WITH(NOLOCK)
       ON r.student_number = ap.student_number 
     WHERE enr.rn_dupes = 1
       AND enr.is_AP = 1
    ) sub
GROUP BY field_name
UNION ALL
-- by IDEA
SELECT field_name
      ,COUNT(DISTINCT studentid) AS N
FROM
    (
     SELECT enr.STUDENTID
           ,CONCAT('SCH_APEXAM_'
                  ,CASE WHEN SUM(CASE WHEN ap.student_number IS NOT NULL THEN 1 ELSE 0 END) OVER(PARTITION BY enr.studentid) > 0 THEN 'ONEORMORE_' ELSE 'NONE_' END
                  ,r.IDEA, '_'
                  ,r.GENDER) AS field_name
     FROM enrollments enr WITH(NOLOCK)
     JOIN pt2_roster r
       ON enr.STUDENTID = r.studentid
      AND r.IDEA = 'IDEA'
     LEFT OUTER JOIN KIPP_NJ..AAA_DELETE$AP_scores_20132014 ap WITH(NOLOCK)
       ON r.student_number = ap.student_number 
     WHERE enr.rn_dupes = 1
       AND enr.is_AP = 1
    ) sub
GROUP BY field_name
UNION ALL
-- by LEP
SELECT field_name
      ,COUNT(DISTINCT studentid) AS N
FROM
    (
     SELECT enr.STUDENTID
           ,CONCAT('SCH_APEXAM_'
                  ,CASE WHEN SUM(CASE WHEN ap.student_number IS NOT NULL THEN 1 ELSE 0 END) OVER(PARTITION BY enr.studentid) > 0 THEN 'ONEORMORE_' ELSE 'NONE_' END
                  ,r.LEP, '_'
                  ,r.GENDER) AS field_name
     FROM enrollments enr WITH(NOLOCK)
     JOIN pt2_roster r
       ON enr.STUDENTID = r.studentid
      AND r.LEP = 'LEP'
     LEFT OUTER JOIN KIPP_NJ..AAA_DELETE$AP_scores_20132014 ap WITH(NOLOCK)
       ON r.student_number = ap.student_number 
     WHERE enr.rn_dupes = 1
       AND enr.is_AP = 1
    ) sub
GROUP BY field_name
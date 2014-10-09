WITH roster AS (
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

--Overall Student Enrollment
SELECT 'SCH_ENR_' + ethnicity + '_' + GENDER AS field_name
      ,COUNT(studentid) AS N
FROM roster
GROUP BY ethnicity
        ,GENDER

UNION ALL

SELECT 'SCH_ENR_' + IDEA + '_' + GENDER AS field_name
      ,COUNT(*) AS N
FROM roster
WHERE IDEA = 'IDEA'
GROUP BY IDEA
        ,GENDER

UNION ALL

SELECT 'SCH_ENR_' + [504_status] + '_' + GENDER AS field_name
      ,COUNT(*) AS N
FROM roster
WHERE [504_status] = '504'
GROUP BY [504_status]
        ,GENDER

UNION ALL

SELECT 'SCH_ENR_' +  LEP + '_' + GENDER AS field_name
      ,COUNT(*) AS N
FROM roster
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
FROM roster
WHERE IDEA = 'IDEA'
GROUP BY ethnicity
        ,GENDER

UNION ALL

SELECT 'SCH_IDEAENR_' +  LEP + '_' + GENDER AS field_name
      ,COUNT(*) AS N
FROM roster
WHERE IDEA = 'IDEA'
  AND LEP = 'LEP'
GROUP BY LEP
        ,GENDER

UNION ALL

-- Students with disabilities served under Section 504 of the Rehabilitation Act of 1973, but not served  under IDEA
SELECT 'SCH_504ENR_' + ethnicity + '_' + GENDER AS field_name
      ,COUNT(studentid) AS N
FROM roster
WHERE [504_status] = '504'
GROUP BY ethnicity
        ,GENDER

UNION ALL

SELECT 'SCH_504ENR_' +  LEP + '_' + GENDER AS field_name
      ,COUNT(*) AS N
FROM roster
WHERE [504_status] = '504'
  AND LEP = 'LEP'
GROUP BY LEP
        ,GENDER
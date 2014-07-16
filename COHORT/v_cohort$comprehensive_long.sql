USE KIPP_NJ
GO

ALTER VIEW COHORT$comprehensive_long AS

-- RE-ENROLLMENTS
WITH reenrollments AS (  
  SELECT reenrollments.*
  FROM
      --reenrollments (ALL completed school years -- majority of the query)
      (
       SELECT re_base.studentid
             ,re_base.grade_level
             ,re_base.schoolid
             ,re_base.entrycode
             ,re_base.exitcode
             ,re_base.entrydate
             ,re_base.exitdate
             ,terms.abbreviation
             ,terms.yearid
             ,ROW_NUMBER() OVER(
                 PARTITION BY re_base.studentid, terms.yearid
                     ORDER BY re_base.exitdate DESC) AS rn
       FROM OPENQUERY(PS_TEAM,'
         SELECT re.studentid AS studentid
               ,re.schoolid AS schoolid
               ,re.grade_level AS grade_level
               ,re.entrydate
               ,re.exitdate
               ,re.entrycode
               ,re.exitcode
         FROM reenrollments re
         WHERE (re.exitdate - re.entrydate) > 0
       ') re_base
       LEFT OUTER JOIN TERMS WITH(NOLOCK)
         ON re_base.schoolid = terms.schoolid       
        AND re_base.entrydate >= terms.firstday
        AND re_base.exitdate <= DATEADD(DAY, 1, terms.lastday)
        AND terms.portion = 1
      ) reenrollments
  WHERE reenrollments.rn = 1 --only last reenrollment for any year
    --AND reenrollments.yearid < LEFT(dbo.fn_Global_Term_Id(), 2) -- no reenrollments from this year    
 )

--STUDENTS (midyear transfers)
,transfers_out AS (  
  SELECT s_1.studentid
        ,s_1.grade_level
        ,s_1.schoolid
        ,s_1.entrycode
        ,s_1.exitcode
        ,s_1.entrydate
        ,s_1.exitdate
        ,terms.abbreviation
        ,terms.yearid
        ,ROW_NUMBER() OVER(
            PARTITION BY s_1.studentid, terms.yearid
                ORDER BY s_1.exitdate DESC) AS rn
  FROM
      (
       SELECT s.id AS studentid
             ,s.schoolid AS schoolid
             ,s.grade_level AS grade_level
             ,s.entrydate
             ,s.exitdate
             ,s.entrycode
             ,s.exitcode
       FROM students s WITH(NOLOCK)
       WHERE s.enroll_status > 0
         AND s.schoolid != 999999
         AND DATEDIFF(DAY, s.entrydate, s.exitdate) > 1
      ) s_1
  LEFT OUTER JOIN terms WITH(NOLOCK)
    ON s_1.schoolid = terms.schoolid 
   AND s_1.entrydate >= terms.firstday
   AND s_1.exitdate <= DATEADD(DAY, 1, terms.lastday)
   AND terms.portion = 1
 )

--STUDENTS (current year enrollment)
,current_enroll AS (
  SELECT s_2.studentid
        ,s_2.grade_level
        ,s_2.schoolid
        ,s_2.entrycode
        ,NULL AS exitcode
        ,s_2.entrydate
        ,s_2.exitdate
        ,terms.abbreviation
        ,terms.yearid
        ,ROW_NUMBER() OVER(
            PARTITION BY s_2.studentid,terms.yearid 
                ORDER BY s_2.exitdate DESC) AS rn
  FROM
      (
       SELECT s.id AS studentid
             ,s.schoolid AS schoolid
             ,s.grade_level AS grade_level
             ,s.entrydate
             ,s.entrycode
             ,s.exitdate           
       FROM students s WITH(NOLOCK)
       WHERE s.enroll_status = 0 
         AND s.schoolid != 999999
         AND DATEDIFF(DAY, s.entrydate, s.exitdate) > 1
      ) s_2
  LEFT OUTER JOIN terms WITH(NOLOCK)
    ON s_2.schoolid = terms.schoolid      
   AND s_2.entrydate >= terms.firstday
   AND s_2.exitdate <= DATEADD(DAY, 1, terms.lastday)
   AND terms.portion = 1
 )
 

--GRADUATED STUDENTS
,graduates AS (
  SELECT s_3.studentid
        ,s_3.grade_level
        ,s_3.schoolid
        ,NULL AS entrycode
        ,NULL AS exitcode
        ,NULL AS entrydate
        ,NULL AS exitdate
        ,terms.abbreviation
        ,terms.yearid
        ,ROW_NUMBER() OVER(
            PARTITION BY s_3.studentid, terms.yearid 
                ORDER BY s_3.exitdate DESC) AS rn
  FROM
      (
       SELECT s.id AS studentid
             ,s.schoolid AS schoolid
             ,s.grade_level AS grade_level
             ,s.entrydate
             ,s.exitdate
       FROM students s WITH(NOLOCK)
       WHERE s.enroll_status = 3
      ) s_3
  LEFT OUTER JOIN terms WITH(NOLOCK)
    ON s_3.schoolid = terms.schoolid
   AND s_3.entrydate < terms.firstday
   AND terms.portion = 1
 )

,unioned_tables AS (
  SELECT * FROM reenrollments
  UNION ALL
  SELECT * FROM transfers_out
  UNION ALL
  SELECT * FROM current_enroll
  UNION ALL
  SELECT * FROM graduates
 )

SELECT unioned_tables.studentid
      ,s.STUDENT_NUMBER
      ,s.lastfirst
      ,s.grade_level AS highest_achieved
      ,unioned_tables.grade_level
      ,unioned_tables.schoolid
      ,unioned_tables.abbreviation
      ,(unioned_tables.yearid + 1990) AS year
      ,CASE 
        WHEN unioned_tables.grade_level > 12 THEN NULL
        ELSE unioned_tables.yearid
              + 2003
              + (-1 * unioned_tables.grade_level)
       END AS cohort
      ,unioned_tables.entrycode
      ,unioned_tables.exitcode
      ,unioned_tables.entrydate
      ,unioned_tables.exitdate
      ,ROW_NUMBER() OVER(
          PARTITION BY unioned_tables.studentid, unioned_tables.yearid
              ORDER BY unioned_tables.exitdate DESC) AS rn
      ,ROW_NUMBER() OVER(
          PARTITION BY unioned_tables.studentid
              ORDER BY unioned_tables.yearid ASC) AS year_in_network
FROM unioned_tables
LEFT OUTER JOIN students s
  ON unioned_tables.studentid = s.id
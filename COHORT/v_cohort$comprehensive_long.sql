USE KIPP_NJ
GO

ALTER VIEW COHORT$comprehensive_long AS

WITH reenrollments AS (  
  SELECT sub.studentid
        ,sub.grade_level
        ,sub.schoolid
        ,sub.entrycode
        ,sub.exitcode
        ,sub.entrydate
        ,sub.exitdate
        ,sub.yearid
        ,sub.rn
  FROM
      (
       SELECT re.studentid
             ,re.grade_level
             ,re.schoolid
             ,re.entrycode
             ,re.exitcode
             ,re.entrydate
             ,re.exitdate             
             ,terms.yearid
             ,ROW_NUMBER() OVER(
                PARTITION BY re.studentid, terms.yearid
                  ORDER BY re.exitdate DESC) AS rn
       FROM KIPP_NJ..PS$REENROLLMENTS#static re WITH(NOLOCK)       
       LEFT OUTER JOIN KIPP_NJ..PS$TERMS#static terms WITH(NOLOCK)
         ON re.schoolid = terms.schoolid       
        AND re.entrydate >= terms.firstday
        AND re.exitdate <= DATEADD(DAY, 1, terms.lastday)
        AND terms.portion = 1
       WHERE DATEDIFF(DAY,re.ENTRYDATE, re.EXITDATE) > 0
      ) sub
  WHERE sub.rn = 1 -- only last reenrollment for any year
 )

,transfers_out AS (  
  SELECT s.id AS studentid
        ,s.grade_level
        ,s.schoolid
        ,s.entrycode
        ,s.exitcode
        ,s.entrydate
        ,s.exitdate
        ,terms.yearid
        ,ROW_NUMBER() OVER(
            PARTITION BY s.id, terms.yearid
                ORDER BY s.exitdate DESC) AS rn
  FROM KIPP_NJ..PS$STUDENTS#static s WITH(NOLOCK)
  LEFT OUTER JOIN KIPP_NJ..PS$TERMS#static terms WITH(NOLOCK)
    ON s.schoolid = terms.schoolid 
   AND s.entrydate >= terms.firstday
   AND s.exitdate <= DATEADD(DAY, 1, terms.lastday)
   AND terms.portion = 1
  WHERE s.enroll_status = 2
    AND DATEDIFF(DAY, s.entrydate, s.exitdate) > 1
 )

,current_enroll AS (
  SELECT s.id AS studentid
        ,s.grade_level
        ,s.schoolid
        ,s.entrycode
        ,NULL AS exitcode
        ,s.entrydate
        ,s.exitdate        
        ,terms.yearid
        ,ROW_NUMBER() OVER(
           PARTITION BY s.id, terms.yearid 
             ORDER BY s.exitdate DESC) AS rn
  FROM KIPP_NJ..PS$STUDENTS#static s WITH(NOLOCK)
  LEFT OUTER JOIN KIPP_NJ..PS$terms#static terms WITH(NOLOCK)
    ON s.schoolid = terms.schoolid      
   AND s.entrydate >= terms.firstday
   AND s.exitdate <= DATEADD(DAY, 1, terms.lastday)
   AND terms.portion = 1
  WHERE s.enroll_status = 0 
    AND s.schoolid != 999999
    AND DATEDIFF(DAY, s.entrydate, s.exitdate) > 1 
 )

,graduates AS (
  SELECT s.id AS studentid
        ,s.grade_level
        ,s.schoolid
        ,NULL AS entrycode
        ,NULL AS exitcode
        ,NULL AS entrydate
        ,NULL AS exitdate        
        ,terms.yearid
        ,ROW_NUMBER() OVER(
            PARTITION BY s.id, terms.yearid 
                ORDER BY s.exitdate DESC) AS rn
  FROM KIPP_NJ..PS$STUDENTS#static s WITH(NOLOCK)
  LEFT OUTER JOIN KIPP_NJ..PS$terms#static terms WITH(NOLOCK)
    ON s.schoolid = terms.schoolid
   AND s.entrydate < terms.firstday
   AND terms.portion = 1
  WHERE s.enroll_status = 3
    AND s.id NOT IN (171, 141, 45) /* 3 students back in the Dark Ages graduated 8th, didn't go to NCA in 9th, but came back and graduated from NCA with a different student record these are their stories */
 )

SELECT sub.studentid
      ,s.STUDENT_NUMBER
      ,s.lastfirst
      ,s.grade_level AS highest_achieved
      ,sub.grade_level
      ,sub.schoolid
      ,NULL AS abbreviation
      ,(sub.yearid + 1990) AS year
      ,CASE 
        WHEN sub.grade_level > 12 THEN NULL
        ELSE sub.yearid + 2003 + (-1 * sub.grade_level)
       END AS cohort
      ,sub.entrycode
      ,sub.exitcode
      ,CONVERT(DATE,sub.entrydate) AS entrydate
      ,CONVERT(DATE,sub.exitdate) AS exitdate
      ,ROW_NUMBER() OVER(
         PARTITION BY sub.studentid, sub.yearid
           ORDER BY sub.exitdate DESC) AS rn
      ,ROW_NUMBER() OVER(
         PARTITION BY sub.studentid
           ORDER BY sub.yearid ASC) AS year_in_network
FROM
    (
     SELECT studentid
           ,grade_level
           ,schoolid
           ,entrycode
           ,exitcode
           ,entrydate
           ,exitdate        
           ,yearid
           ,rn
     FROM reenrollments
     UNION ALL
     SELECT studentid
           ,grade_level
           ,schoolid
           ,entrycode
           ,exitcode
           ,entrydate
           ,exitdate        
           ,yearid
           ,rn
     FROM transfers_out
     UNION ALL
     SELECT studentid
           ,grade_level
           ,schoolid
           ,entrycode
           ,exitcode
           ,entrydate
           ,exitdate        
           ,yearid
           ,rn
     FROM current_enroll
     UNION ALL
     SELECT studentid
           ,grade_level
           ,schoolid
           ,entrycode
           ,exitcode
           ,entrydate
           ,exitdate        
           ,yearid
           ,rn
     FROM graduates
    ) sub
LEFT OUTER JOIN KIPP_NJ..PS$STUDENTS#static s WITH(NOLOCK)
  ON sub.studentid = s.id
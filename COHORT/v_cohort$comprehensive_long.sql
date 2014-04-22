USE KIPP_NJ
GO

ALTER VIEW COHORT$comprehensive_long AS

SELECT *
FROM OPENQUERY(PS_TEAM,'
  SELECT unioned_tables.studentid
        ,s.lastfirst
        ,s.grade_level AS highest_achieved
        ,unioned_tables.grade_level
        ,unioned_tables.schoolid
        ,unioned_tables.abbreviation
        ,(unioned_tables.yearid + 1990) AS year
        ,unioned_tables.yearid 
           + 2003 
           + (-1 * CASE
                    WHEN unioned_tables.grade_level > 12 THEN NULL
                    ELSE unioned_tables.grade_level
                   END) 
           AS cohort
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
  FROM
      --THIS LEVEL UNIONS FOUR TABLES: REENROLLMENTS (who completed the year)
      -- STUDENTS (midyear transfers)
      -- STUDENTS (current year enrollment)
      -- GRADUATED STUDENTS
      (
       SELECT *
       FROM
           (
           -- RE-ENROLLMENTS
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
                 FROM
                     (
                      SELECT re.studentid AS studentid
                            ,re.schoolid AS schoolid
                            ,re.grade_level AS grade_level
                            ,re.entrydate
                            ,re.exitdate
                            ,re.entrycode
                            ,re.exitcode
                      FROM reenrollments re
                      WHERE (re.exitdate - re.entrydate) > 0
                     ) re_base
                 LEFT OUTER JOIN terms 
                   ON re_base.schoolid = terms.schoolid       
                  AND re_base.entrydate >= terms.firstday
                  AND re_base.exitdate <= (terms.lastday + 1)
                  AND terms.portion = 1
                ) reenrollments
            WHERE reenrollments.rn = 1 --only last reenrollment for any year
            AND reenrollments.yearid < 2200 -- no reenrollments FROM this year
           )
           
          UNION ALL         
           
           (
           --STUDENTS (midyear transfers)
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
                 FROM students s
                 WHERE s.enroll_status > 0
                   AND s.schoolid != 999999
                   AND (s.exitdate - s.entrydate) > 1
                ) s_1
            LEFT OUTER JOIN terms 
              ON s_1.schoolid = terms.schoolid 
             AND s_1.entrydate >= terms.firstday
             AND s_1.exitdate <= (terms.lastday + 1)
             AND terms.portion = 1
           )

          UNION ALL         
           
           (
           --STUDENTS (current year enrollment)
            SELECT s_2.studentid
                  ,s_2.grade_level
                  ,s_2.schoolid
                  ,s_2.entrycode
                  ,NULL AS exitcode
                  ,s_2.entrydate
                  ,s_2.exitdate
                  ,terms.abbreviation
                  ,terms.yearid
                  ,ROW_NUMBER() OVER (PARTITION BY s_2.studentid,terms.yearid ORDER BY s_2.exitdate DESC) AS rn
            FROM
                (
                 SELECT s.id AS studentid
                       ,s.schoolid AS schoolid
                       ,s.grade_level AS grade_level
                       ,s.entrydate
                       ,s.entrycode
                       ,s.exitdate
                 FROM students s
                 WHERE s.enroll_status = 0 
                   AND s.schoolid != 999999
                   AND (s.exitdate - s.entrydate) > 1
                ) s_2
            LEFT OUTER JOIN terms 
              ON s_2.schoolid = terms.schoolid      
             AND s_2.entrydate >= terms.firstday
             AND s_2.exitdate <= (terms.lastday + 1)
             AND terms.portion = 1
           )

          UNION ALL        
           
           (    
           --GRADUATED STUDENTS
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
                FROM students s
                WHERE s.enroll_status = 3
               ) s_3
           LEFT OUTER JOIN terms
             ON s_3.schoolid = terms.schoolid
            AND s_3.entrydate < terms.firstday
            AND terms.portion = 1
          )        
      ) unioned_tables
  LEFT OUTER JOIN students s 
    ON unioned_tables.studentid = s.id
')
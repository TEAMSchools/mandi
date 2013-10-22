USE KIPP_NJ
GO

ALTER VIEW LIT$FP_test_events_long#identifiers AS
SELECT sub.*
--/*
      ,CASE
        WHEN sub.status = 'Achieved'
        THEN sub.GLEQ - base.GLEQ
        ELSE NULL
       END AS GLEQ_growth_ytd
      ,CASE
        WHEN sub.status = 'Achieved'
        THEN sub.level_number - base.level_number
        ELSE NULL
       END AS level_growth_ytd
--*/
      ,CASE
        WHEN sub.status = 'Achieved'
        THEN sub.GLEQ - prev.GLEQ
        ELSE NULL
       END AS GLEQ_growth_prev
      ,CASE
        WHEN sub.status = 'Achieved'
        THEN sub.level_number - prev.level_number
        ELSE NULL
       END AS level_growth_prev
--*/
--/*
      ,CASE
        WHEN sub.status = 'Achieved'
        THEN sub.GLEQ - tri.GLEQ
        ELSE NULL
       END AS GLEQ_growth_tri
      ,CASE
        WHEN sub.status = 'Achieved'
        THEN sub.level_number - tri.level_number
        ELSE NULL
       END AS level_growth_tri
--*/
FROM

--ALL TEST EVENTS
     (SELECT rs.testid 
            ,cohort.schoolid
            ,cohort.grade_level
            ,cohort.year
            ,cohort.abbreviation            
            ,s.id AS studentid      
            ,s.student_number
            ,s.lastfirst      
            ,rs.test_date
            ,dates.time_per_name
            ,rs.step_ltr_level AS letter_level
            ,rs.status           
            ,rs.fp_wpmrate                  
            ,rs.fp_fluency
            ,rs.fp_accuracy
            ,rs.fp_comp_within
            ,rs.fp_comp_beyond
            ,rs.fp_comp_about
            ,rs.fp_comp_prof            
            ,rs.fp_keylever
            ,rs.genre
            ,CASE
              WHEN step_ltr_level = 'AA' THEN 0.0
              WHEN step_ltr_level = 'A' THEN 0.3
              WHEN step_ltr_level = 'B' THEN 0.5
              WHEN step_ltr_level = 'C' THEN 0.7
              WHEN step_ltr_level = 'D' THEN 1.0
              WHEN step_ltr_level = 'E' THEN 1.2
              WHEN step_ltr_level = 'F' THEN 1.4
              WHEN step_ltr_level = 'G' THEN 1.6
              WHEN step_ltr_level = 'H' THEN 1.8
              WHEN step_ltr_level = 'I' THEN 2.0
              WHEN step_ltr_level = 'J' THEN 2.2
              WHEN step_ltr_level = 'K' THEN 2.4
              WHEN step_ltr_level = 'L' THEN 2.6
              WHEN step_ltr_level = 'M' THEN 2.8
              WHEN step_ltr_level = 'N' THEN 3.0
              WHEN step_ltr_level = 'O' THEN 3.5
              WHEN step_ltr_level = 'P' THEN 3.8
              WHEN step_ltr_level = 'Q' THEN 4.0
              WHEN step_ltr_level = 'R' THEN 4.5
              WHEN step_ltr_level = 'S' THEN 4.8
              WHEN step_ltr_level = 'T' THEN 5.0
              WHEN step_ltr_level = 'U' THEN 5.5
              WHEN step_ltr_level = 'V' THEN 6.0
              WHEN step_ltr_level = 'W' THEN 6.3
              WHEN step_ltr_level = 'X' THEN 6.7
              WHEN step_ltr_level = 'Y' THEN 7.0
              WHEN step_ltr_level = 'Z' THEN 7.5
              WHEN step_ltr_level = 'Z+' THEN 8.0
              ELSE NULL
             END AS GLEQ
            ,CASE
              WHEN step_ltr_level = 'AA' THEN 0
              WHEN step_ltr_level = 'A' THEN 1
              WHEN step_ltr_level = 'B' THEN 2
              WHEN step_ltr_level = 'C' THEN 3
              WHEN step_ltr_level = 'D' THEN 4
              WHEN step_ltr_level = 'E' THEN 5
              WHEN step_ltr_level = 'F' THEN 6
              WHEN step_ltr_level = 'G' THEN 7
              WHEN step_ltr_level = 'H' THEN 8
              WHEN step_ltr_level = 'I' THEN 9
              WHEN step_ltr_level = 'J' THEN 10
              WHEN step_ltr_level = 'K' THEN 11
              WHEN step_ltr_level = 'L' THEN 12
              WHEN step_ltr_level = 'M' THEN 13
              WHEN step_ltr_level = 'N' THEN 14
              WHEN step_ltr_level = 'O' THEN 15
              WHEN step_ltr_level = 'P' THEN 16
              WHEN step_ltr_level = 'Q' THEN 17
              WHEN step_ltr_level = 'R' THEN 18
              WHEN step_ltr_level = 'S' THEN 19
              WHEN step_ltr_level = 'T' THEN 20
              WHEN step_ltr_level = 'U' THEN 21
              WHEN step_ltr_level = 'V' THEN 22
              WHEN step_ltr_level = 'W' THEN 23
              WHEN step_ltr_level = 'X' THEN 24
              WHEN step_ltr_level = 'Y' THEN 25
              WHEN step_ltr_level = 'Z' THEN 26
              WHEN step_ltr_level = 'Z+' THEN 27
              ELSE NULL
             END AS level_number             
            ,CASE
              WHEN status = 'Achieved' THEN
               ROW_NUMBER() OVER
                 (PARTITION BY rs.studentid, cohort.year, rs.status
                      ORDER BY rs.test_date ASC, step_ltr_level ASC)
              ELSE NULL
             END AS achv_base
            ,CASE
              WHEN status = 'Achieved' THEN
               ROW_NUMBER() OVER
                 (PARTITION BY rs.studentid, cohort.year, rs.status
                      ORDER BY rs.test_date DESC, step_ltr_level DESC)
              ELSE NULL
             END AS achv_curr
            ,CASE
              WHEN status = 'Did Not Achieve' THEN
               ROW_NUMBER() OVER
                 (PARTITION BY rs.studentid, cohort.year, rs.status
                      ORDER BY rs.test_date ASC, step_ltr_level DESC)
              ELSE NULL
             END AS dna_base
            ,CASE
              WHEN status = 'Did Not Achieve' THEN
               ROW_NUMBER() OVER
                 (PARTITION BY rs.studentid, cohort.year, rs.status
                      ORDER BY rs.test_date DESC, step_ltr_level ASC)
              ELSE NULL
             END AS dna_curr
            ,CASE
              WHEN status = 'Achieved' THEN
               ROW_NUMBER() OVER
                 (PARTITION BY rs.studentid, rs.status
                      ORDER BY rs.test_date ASC, step_ltr_level ASC)
              ELSE NULL
             END AS achv_base_all
            ,CASE
              WHEN status = 'Achieved' THEN
               ROW_NUMBER() OVER
                 (PARTITION BY rs.studentid, rs.status
                      ORDER BY rs.test_date DESC, step_ltr_level DESC)
              ELSE NULL
             END AS achv_curr_all
            ,CASE
              WHEN status = 'Achieved' THEN
               ROW_NUMBER() OVER
                 (PARTITION BY rs.studentid, cohort.year, dates.time_per_name, rs.status
                      ORDER BY rs.test_date ASC, step_ltr_level ASC)
              ELSE NULL
             END AS achv_base_tri
            ,CASE
              WHEN status = 'Achieved' THEN
               ROW_NUMBER() OVER
                 (PARTITION BY rs.studentid, cohort.year, dates.time_per_name, rs.status
                      ORDER BY rs.test_date DESC, step_ltr_level DESC)
              ELSE NULL
             END AS achv_curr_tri
            ,CASE
              WHEN status = 'Did Not Achieve' THEN
               ROW_NUMBER() OVER
                 (PARTITION BY rs.studentid, cohort.year, dates.time_per_name, rs.status
                      ORDER BY rs.test_date ASC, step_ltr_level DESC)
              ELSE NULL
             END AS dna_base_tri
            ,CASE
              WHEN status = 'Did Not Achieve' THEN
               ROW_NUMBER() OVER
                 (PARTITION BY rs.studentid, cohort.year, dates.time_per_name, rs.status
                      ORDER BY rs.test_date DESC, step_ltr_level ASC)
              ELSE NULL
             END AS dna_curr_tri
      FROM READINGSCORES rs
      JOIN STUDENTS s
        ON rs.studentid = s.id
      LEFT OUTER JOIN COHORT$comprehensive_long#static cohort
        ON rs.studentid = cohort.studentid
       AND rs.test_date >= CONVERT(DATE,CONVERT(VARCHAR,DATEPART(YYYY,cohort.entrydate)) + '-07-01')
       AND rs.test_date <= CONVERT(DATE,CONVERT(VARCHAR,DATEPART(YYYY,cohort.exitdate)) + '-06-30')
       AND cohort.rn = 1
      LEFT OUTER JOIN REPORTING$dates dates
        ON rs.test_date >= dates.start_date
       AND rs.test_date <= dates.end_date
       AND dates.identifier = 'LIT'
      WHERE testid = 3273      
     ) sub

--BASE ACHIEVED TEST FOR YEAR
LEFT OUTER JOIN 
     (SELECT *
      FROM
           (SELECT rs.studentid
                  ,cohort.year            
                  ,CASE
                    WHEN step_ltr_level = 'AA' THEN 0.0
                    WHEN step_ltr_level = 'A' THEN 0.3
                    WHEN step_ltr_level = 'B' THEN 0.5
                    WHEN step_ltr_level = 'C' THEN 0.7
                    WHEN step_ltr_level = 'D' THEN 1.0
                    WHEN step_ltr_level = 'E' THEN 1.2
                    WHEN step_ltr_level = 'F' THEN 1.4
                    WHEN step_ltr_level = 'G' THEN 1.6
                    WHEN step_ltr_level = 'H' THEN 1.8
                    WHEN step_ltr_level = 'I' THEN 2.0
                    WHEN step_ltr_level = 'J' THEN 2.2
                    WHEN step_ltr_level = 'K' THEN 2.4
                    WHEN step_ltr_level = 'L' THEN 2.6
                    WHEN step_ltr_level = 'M' THEN 2.8
                    WHEN step_ltr_level = 'N' THEN 3.0
                    WHEN step_ltr_level = 'O' THEN 3.5
                    WHEN step_ltr_level = 'P' THEN 3.8
                    WHEN step_ltr_level = 'Q' THEN 4.0
                    WHEN step_ltr_level = 'R' THEN 4.5
                    WHEN step_ltr_level = 'S' THEN 4.8
                    WHEN step_ltr_level = 'T' THEN 5.0
                    WHEN step_ltr_level = 'U' THEN 5.5
                    WHEN step_ltr_level = 'V' THEN 6.0
                    WHEN step_ltr_level = 'W' THEN 6.3
                    WHEN step_ltr_level = 'X' THEN 6.7
                    WHEN step_ltr_level = 'Y' THEN 7.0
                    WHEN step_ltr_level = 'Z' THEN 7.5
                    WHEN step_ltr_level = 'Z+' THEN 8.0
                    ELSE NULL
                   END AS GLEQ
                  ,CASE
                    WHEN step_ltr_level = 'AA' THEN 0
                    WHEN step_ltr_level = 'A' THEN 1
                    WHEN step_ltr_level = 'B' THEN 2
                    WHEN step_ltr_level = 'C' THEN 3
                    WHEN step_ltr_level = 'D' THEN 4
                    WHEN step_ltr_level = 'E' THEN 5
                    WHEN step_ltr_level = 'F' THEN 6
                    WHEN step_ltr_level = 'G' THEN 7
                    WHEN step_ltr_level = 'H' THEN 8
                    WHEN step_ltr_level = 'I' THEN 9
                    WHEN step_ltr_level = 'J' THEN 10
                    WHEN step_ltr_level = 'K' THEN 11
                    WHEN step_ltr_level = 'L' THEN 12
                    WHEN step_ltr_level = 'M' THEN 13
                    WHEN step_ltr_level = 'N' THEN 14
                    WHEN step_ltr_level = 'O' THEN 15
                    WHEN step_ltr_level = 'P' THEN 16
                    WHEN step_ltr_level = 'Q' THEN 17
                    WHEN step_ltr_level = 'R' THEN 18
                    WHEN step_ltr_level = 'S' THEN 19
                    WHEN step_ltr_level = 'T' THEN 20
                    WHEN step_ltr_level = 'U' THEN 21
                    WHEN step_ltr_level = 'V' THEN 22
                    WHEN step_ltr_level = 'W' THEN 23
                    WHEN step_ltr_level = 'X' THEN 24
                    WHEN step_ltr_level = 'Y' THEN 25
                    WHEN step_ltr_level = 'Z' THEN 26
                    WHEN step_ltr_level = 'Z+' THEN 27
                    ELSE NULL
                   END AS level_number            
                  ,CASE
                    WHEN status = 'Achieved' THEN
                     ROW_NUMBER() OVER
                       (PARTITION BY rs.studentid, cohort.year, rs.status
                            ORDER BY rs.test_date ASC, step_ltr_level ASC)
                    ELSE NULL
                   END AS achv_base
            FROM READINGSCORES rs      
            LEFT OUTER JOIN COHORT$comprehensive_long#static cohort
              ON rs.studentid = cohort.studentid
             AND rs.test_date >= CONVERT(DATE,CONVERT(VARCHAR,DATEPART(YYYY,cohort.entrydate)) + '-07-01')
             AND rs.test_date <= CONVERT(DATE,CONVERT(VARCHAR,DATEPART(YYYY,cohort.exitdate)) + '-06-30')
             AND cohort.rn = 1
            WHERE testid = 3273
           ) sq_1
      WHERE sq_1.achv_base = 1
     ) base
  ON sub.studentid = base.studentid
 AND sub.year = base.year

--PREVIOUSLY ACHIEVED TEST
LEFT OUTER JOIN 
     (SELECT *
      FROM
           (SELECT rs.studentid
                  ,cohort.year            
                  ,CASE
                    WHEN step_ltr_level = 'AA' THEN 0.0
                    WHEN step_ltr_level = 'A' THEN 0.3
                    WHEN step_ltr_level = 'B' THEN 0.5
                    WHEN step_ltr_level = 'C' THEN 0.7
                    WHEN step_ltr_level = 'D' THEN 1.0
                    WHEN step_ltr_level = 'E' THEN 1.2
                    WHEN step_ltr_level = 'F' THEN 1.4
                    WHEN step_ltr_level = 'G' THEN 1.6
                    WHEN step_ltr_level = 'H' THEN 1.8
                    WHEN step_ltr_level = 'I' THEN 2.0
                    WHEN step_ltr_level = 'J' THEN 2.2
                    WHEN step_ltr_level = 'K' THEN 2.4
                    WHEN step_ltr_level = 'L' THEN 2.6
                    WHEN step_ltr_level = 'M' THEN 2.8
                    WHEN step_ltr_level = 'N' THEN 3.0
                    WHEN step_ltr_level = 'O' THEN 3.5
                    WHEN step_ltr_level = 'P' THEN 3.8
                    WHEN step_ltr_level = 'Q' THEN 4.0
                    WHEN step_ltr_level = 'R' THEN 4.5
                    WHEN step_ltr_level = 'S' THEN 4.8
                    WHEN step_ltr_level = 'T' THEN 5.0
                    WHEN step_ltr_level = 'U' THEN 5.5
                    WHEN step_ltr_level = 'V' THEN 6.0
                    WHEN step_ltr_level = 'W' THEN 6.3
                    WHEN step_ltr_level = 'X' THEN 6.7
                    WHEN step_ltr_level = 'Y' THEN 7.0
                    WHEN step_ltr_level = 'Z' THEN 7.5
                    WHEN step_ltr_level = 'Z+' THEN 8.0
                    ELSE NULL
                   END AS GLEQ
                  ,CASE
                    WHEN step_ltr_level = 'AA' THEN 0
                    WHEN step_ltr_level = 'A' THEN 1
                    WHEN step_ltr_level = 'B' THEN 2
                    WHEN step_ltr_level = 'C' THEN 3
                    WHEN step_ltr_level = 'D' THEN 4
                    WHEN step_ltr_level = 'E' THEN 5
                    WHEN step_ltr_level = 'F' THEN 6
                    WHEN step_ltr_level = 'G' THEN 7
                    WHEN step_ltr_level = 'H' THEN 8
                    WHEN step_ltr_level = 'I' THEN 9
                    WHEN step_ltr_level = 'J' THEN 10
                    WHEN step_ltr_level = 'K' THEN 11
                    WHEN step_ltr_level = 'L' THEN 12
                    WHEN step_ltr_level = 'M' THEN 13
                    WHEN step_ltr_level = 'N' THEN 14
                    WHEN step_ltr_level = 'O' THEN 15
                    WHEN step_ltr_level = 'P' THEN 16
                    WHEN step_ltr_level = 'Q' THEN 17
                    WHEN step_ltr_level = 'R' THEN 18
                    WHEN step_ltr_level = 'S' THEN 19
                    WHEN step_ltr_level = 'T' THEN 20
                    WHEN step_ltr_level = 'U' THEN 21
                    WHEN step_ltr_level = 'V' THEN 22
                    WHEN step_ltr_level = 'W' THEN 23
                    WHEN step_ltr_level = 'X' THEN 24
                    WHEN step_ltr_level = 'Y' THEN 25
                    WHEN step_ltr_level = 'Z' THEN 26
                    WHEN step_ltr_level = 'Z+' THEN 27
                    ELSE NULL
                   END AS level_number            
                  ,CASE
                    WHEN status = 'Achieved' THEN
                     ROW_NUMBER() OVER
                       (PARTITION BY rs.studentid, rs.status
                            ORDER BY rs.test_date DESC, step_ltr_level DESC)
                    ELSE NULL
                   END AS achv_curr_all
            FROM READINGSCORES rs      
            LEFT OUTER JOIN COHORT$comprehensive_long#static cohort
              ON rs.studentid = cohort.studentid
             AND rs.test_date >= CONVERT(DATE,CONVERT(VARCHAR,DATEPART(YYYY,cohort.entrydate)) + '-07-01')
             AND rs.test_date <= CONVERT(DATE,CONVERT(VARCHAR,DATEPART(YYYY,cohort.exitdate)) + '-06-30')
             AND cohort.rn = 1
            WHERE testid = 3273
           ) sq_2
      --WHERE sq_2.achv_curr > 1
     ) prev
  ON sub.studentid = prev.studentid
 AND sub.achv_curr_all = (prev.achv_curr_all - 1)
 
--BASE TEST ACHIEVED FOR TRIMESTER
LEFT OUTER JOIN 
     (SELECT *
      FROM
           (SELECT rs.studentid
                  ,cohort.year            
                  ,CASE
                    WHEN dates.time_per_name = 'Diagnostic' THEN 'T1'
                    WHEN dates.time_per_name = 'T1' THEN 'T2'
                    WHEN dates.time_per_name = 'T2' THEN 'T3'
                   END AS time_per_name
                  ,CASE
                    WHEN step_ltr_level = 'AA' THEN 0.0
                    WHEN step_ltr_level = 'A' THEN 0.3
                    WHEN step_ltr_level = 'B' THEN 0.5
                    WHEN step_ltr_level = 'C' THEN 0.7
                    WHEN step_ltr_level = 'D' THEN 1.0
                    WHEN step_ltr_level = 'E' THEN 1.2
                    WHEN step_ltr_level = 'F' THEN 1.4
                    WHEN step_ltr_level = 'G' THEN 1.6
                    WHEN step_ltr_level = 'H' THEN 1.8
                    WHEN step_ltr_level = 'I' THEN 2.0
                    WHEN step_ltr_level = 'J' THEN 2.2
                    WHEN step_ltr_level = 'K' THEN 2.4
                    WHEN step_ltr_level = 'L' THEN 2.6
                    WHEN step_ltr_level = 'M' THEN 2.8
                    WHEN step_ltr_level = 'N' THEN 3.0
                    WHEN step_ltr_level = 'O' THEN 3.5
                    WHEN step_ltr_level = 'P' THEN 3.8
                    WHEN step_ltr_level = 'Q' THEN 4.0
                    WHEN step_ltr_level = 'R' THEN 4.5
                    WHEN step_ltr_level = 'S' THEN 4.8
                    WHEN step_ltr_level = 'T' THEN 5.0
                    WHEN step_ltr_level = 'U' THEN 5.5
                    WHEN step_ltr_level = 'V' THEN 6.0
                    WHEN step_ltr_level = 'W' THEN 6.3
                    WHEN step_ltr_level = 'X' THEN 6.7
                    WHEN step_ltr_level = 'Y' THEN 7.0
                    WHEN step_ltr_level = 'Z' THEN 7.5
                    WHEN step_ltr_level = 'Z+' THEN 8.0
                    ELSE NULL
                   END AS GLEQ
                  ,CASE
                    WHEN step_ltr_level = 'AA' THEN 0
                    WHEN step_ltr_level = 'A' THEN 1
                    WHEN step_ltr_level = 'B' THEN 2
                    WHEN step_ltr_level = 'C' THEN 3
                    WHEN step_ltr_level = 'D' THEN 4
                    WHEN step_ltr_level = 'E' THEN 5
                    WHEN step_ltr_level = 'F' THEN 6
                    WHEN step_ltr_level = 'G' THEN 7
                    WHEN step_ltr_level = 'H' THEN 8
                    WHEN step_ltr_level = 'I' THEN 9
                    WHEN step_ltr_level = 'J' THEN 10
                    WHEN step_ltr_level = 'K' THEN 11
                    WHEN step_ltr_level = 'L' THEN 12
                    WHEN step_ltr_level = 'M' THEN 13
                    WHEN step_ltr_level = 'N' THEN 14
                    WHEN step_ltr_level = 'O' THEN 15
                    WHEN step_ltr_level = 'P' THEN 16
                    WHEN step_ltr_level = 'Q' THEN 17
                    WHEN step_ltr_level = 'R' THEN 18
                    WHEN step_ltr_level = 'S' THEN 19
                    WHEN step_ltr_level = 'T' THEN 20
                    WHEN step_ltr_level = 'U' THEN 21
                    WHEN step_ltr_level = 'V' THEN 22
                    WHEN step_ltr_level = 'W' THEN 23
                    WHEN step_ltr_level = 'X' THEN 24
                    WHEN step_ltr_level = 'Y' THEN 25
                    WHEN step_ltr_level = 'Z' THEN 26
                    WHEN step_ltr_level = 'Z+' THEN 27
                    ELSE NULL
                   END AS level_number            
                  ,CASE
                    WHEN status = 'Achieved' THEN
                     ROW_NUMBER() OVER
                       (PARTITION BY rs.studentid, cohort.year, dates.time_per_name, rs.status
                            ORDER BY rs.test_date DESC, step_ltr_level DESC)
                    ELSE NULL
                   END AS achv_curr_tri
            FROM READINGSCORES rs      
            LEFT OUTER JOIN COHORT$comprehensive_long#static cohort
              ON rs.studentid = cohort.studentid
             AND rs.test_date >= CONVERT(DATE,CONVERT(VARCHAR,DATEPART(YYYY,cohort.entrydate)) + '-07-01')
             AND rs.test_date <= CONVERT(DATE,CONVERT(VARCHAR,DATEPART(YYYY,cohort.exitdate)) + '-06-30')
             AND cohort.rn = 1
            LEFT OUTER JOIN REPORTING$dates dates
              ON rs.test_date >= dates.start_date
             AND rs.test_date <= dates.end_date
             AND dates.identifier = 'LIT'
            WHERE testid = 3273
           ) sq_3
      WHERE sq_3.achv_curr_tri = 1
        AND sq_3.time_per_name IS NOT NULL
     ) tri
  ON sub.studentid = tri.studentid
 AND sub.year = tri.year
 AND sub.time_per_name = tri.time_per_name
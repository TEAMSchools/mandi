USE [KIPP_NJ]
GO

ALTER VIEW LIT$STEP_test_events_long#identifiers AS
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
     (SELECT rs.testid 
            ,cohort.schoolid
            ,cohort.grade_level      
            ,cohort.year
            ,cohort.abbreviation
            ,s.id AS studentid
		          ,s.student_number
		          ,s.lastfirst 
		          ,dates.time_per_name
		          ,rs.test_date		          
		          ,rs.step_ltr_level AS step_level
		          ,rs.status
		          ,rs.color
		          ,rs.instruct_lvl
		          ,rs.indep_lvl
		          ,rs.name_ass
		          ,rs.ltr_nameid
		          ,rs.ltr_soundid
		          ,rs.pa_rhymingwds
		          ,rs.cp_orient
		          ,rs.cp_121match
		          ,rs.cp_slw
		          ,rs.pa_mfs
		          ,rs.devsp_first
		          ,rs.devsp_svs
		          ,rs.devsp_final
		          ,rs.rr_121match
		          ,rs.rr_holdspattern
		          ,rs.rr_understanding
		          ,rs.pa_segmentation
		          ,rs.accuracy_1a
		          ,rs.accuracy_2b		        
		          ,rs.cc_factual
		          ,rs.cc_infer
		          ,rs.cc_other
		          ,rs.accuracy
		          ,rs.cc_ct
		          ,rs.total_vwlattmpt
		          ,rs.ra_errors
		          ,rs.reading_rate
		          ,rs.fluency
		          ,rs.devsp_ifbd
		          ,rs.ocomp_factual
		          ,rs.ocomp_ct
		          ,rs.scomp_factual
		          ,rs.scomp_infer
		          ,rs.scomp_ct
		          ,rs.devsp_longvp
		          ,rs.devsp_rcontv
		          ,rs.ocomp_infer
		          ,rs.devsp_vcelvp
		          ,rs.devsp_vowldig
		          ,rs.devsp_cmplxb
		          ,rs.wcomp_fact
		          ,rs.wcomp_infer
		          ,rs.retelling
		          ,rs.wcomp_ct
		          ,rs.devsp_eding
		          ,rs.devsp_doubsylj
		          ,rs.devsp_longv2sw
		          ,rs.devsp_rcont2sw
		          ,rs.cc_prof1
            ,rs.cc_prof2
            ,rs.cp_prof
            ,rs.devsp_prof1
            ,rs.devsp_prof2
            ,rs.ocomp_prof1
            ,rs.ocomp_prof2
            ,rs.rr_prof
            ,rs.scomp_prof
            ,rs.wcomp_prof
		          ,rs.genre
            ,CASE
              WHEN step_ltr_level = 'Pre' THEN 0.0
              WHEN step_ltr_level = '1'   THEN 0.0
              WHEN step_ltr_level = '2'   THEN 0.3
              WHEN step_ltr_level = '3'   THEN 0.7
              WHEN step_ltr_level = '4'   THEN 1.2
              WHEN step_ltr_level = '5'   THEN 1.6
              WHEN step_ltr_level = '6'   THEN 2.0
              WHEN step_ltr_level = '7'   THEN 2.4
              WHEN step_ltr_level = '8'   THEN 2.6
              WHEN step_ltr_level = '9'   THEN 2.8
              WHEN step_ltr_level = '10'  THEN 3.0
              WHEN step_ltr_level = '11'  THEN 3.5
              WHEN step_ltr_level = '12'  THEN 3.8        
              ELSE NULL
             END AS GLEQ
            ,CASE
              WHEN step_ltr_level = 'Pre' THEN 0        
              ELSE CONVERT(INT,step_ltr_level)
             END AS level_number                        
            ,CASE
              WHEN status = 'Achieved' THEN
               ROW_NUMBER() OVER
                 (PARTITION BY rs.studentid, cohort.year, rs.status
                      ORDER BY rs.test_date ASC, CONVERT(INT,CASE WHEN step_ltr_level = 'Pre' THEN 0 ELSE step_ltr_level END) ASC)
              ELSE NULL
             END AS achv_base
            ,CASE
              WHEN status = 'Achieved' THEN
               ROW_NUMBER() OVER
                 (PARTITION BY rs.studentid, cohort.year, rs.status
                      ORDER BY rs.test_date DESC, CONVERT(INT,CASE WHEN step_ltr_level = 'Pre' THEN 0 ELSE step_ltr_level END) DESC)
              ELSE NULL
             END AS achv_curr
            ,CASE
              WHEN status = 'Did Not Achieve' THEN
               ROW_NUMBER() OVER
                 (PARTITION BY rs.studentid, cohort.year, rs.status
                      ORDER BY rs.test_date ASC, CONVERT(INT,CASE WHEN step_ltr_level = 'Pre' THEN 0 ELSE step_ltr_level END) DESC)
              ELSE NULL
             END AS dna_base
            ,CASE
              WHEN status = 'Did Not Achieve' THEN
               ROW_NUMBER() OVER
                 (PARTITION BY rs.studentid, cohort.year, rs.status
                      ORDER BY rs.test_date DESC, CONVERT(INT,CASE WHEN step_ltr_level = 'Pre' THEN 0 ELSE step_ltr_level END) ASC)
              ELSE NULL
             END AS dna_curr
            ,CASE
              WHEN status = 'Achieved' THEN
               ROW_NUMBER() OVER
                 (PARTITION BY rs.studentid, rs.status
                      ORDER BY rs.test_date ASC, CONVERT(INT,CASE WHEN step_ltr_level = 'Pre' THEN 0 ELSE step_ltr_level END) ASC)
              ELSE NULL
             END AS achv_base_all
            ,CASE
              WHEN status = 'Achieved' THEN
               ROW_NUMBER() OVER
                 (PARTITION BY rs.studentid, rs.status
                      ORDER BY rs.test_date DESC, CONVERT(INT,CASE WHEN step_ltr_level = 'Pre' THEN 0 ELSE step_ltr_level END) DESC)
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
      WHERE testid != 3273
     ) sub
--/*
--BASE TEST ACHIEVED FOR EACH SCHOOL YEAR
LEFT OUTER JOIN
     (SELECT *
      FROM
           (SELECT cohort.year            
                 ,rs.studentid
                 ,CASE
                   WHEN step_ltr_level = 'Pre' THEN 0.0
                   WHEN step_ltr_level = '1' THEN 0.0
                   WHEN step_ltr_level = '2' THEN 0.3
                   WHEN step_ltr_level = '3' THEN 0.7
                   WHEN step_ltr_level = '4' THEN 1.2
                   WHEN step_ltr_level = '5' THEN 1.6
                   WHEN step_ltr_level = '6' THEN 2.0
                   WHEN step_ltr_level = '7' THEN 2.4
                   WHEN step_ltr_level = '8' THEN 2.6
                   WHEN step_ltr_level = '9' THEN 2.8
                   WHEN step_ltr_level = '10' THEN 3.0
                   WHEN step_ltr_level = '11' THEN 3.5
                   WHEN step_ltr_level = '12' THEN 3.8        
                   ELSE NULL
                  END AS GLEQ
                 ,CASE
                   WHEN step_ltr_level = 'Pre' THEN 0        
                   ELSE CONVERT(INT,step_ltr_level)
                  END AS level_number
                 --helps to determine first test event FOR a student IN a year
                 ,CASE
                   WHEN status = 'Achieved' THEN
                    ROW_NUMBER() OVER
                      (PARTITION BY rs.studentid, cohort.year, rs.status
                           ORDER BY rs.test_date ASC, CONVERT(INT,CASE WHEN step_ltr_level = 'Pre' THEN 0 ELSE step_ltr_level END) ASC)
                   ELSE NULL
                  END AS achv_base
                 --helps to determine last test event FOR a student IN a year          
           FROM READINGSCORES rs      
           LEFT OUTER JOIN COHORT$comprehensive_long#static cohort
             ON rs.studentid = cohort.studentid
            AND rs.test_date >= CONVERT(DATE,CONVERT(VARCHAR,DATEPART(YYYY,cohort.entrydate)) + '-07-01')
            AND rs.test_date <= CONVERT(DATE,CONVERT(VARCHAR,DATEPART(YYYY,cohort.exitdate)) + '-06-30')
            AND cohort.rn = 1
           WHERE testid != 3273
          )sq1
    WHERE sq1.achv_base = 1      
   ) base
  ON sub.studentid = base.studentid
 AND sub.year = base.year 
--*/
--/*
--PREVIOUS TEST ACHIEVED IN SAME SCHOOL YEAR
LEFT OUTER JOIN 
     (SELECT *
      FROM
           (SELECT cohort.year            
                 ,rs.studentid
                 ,CASE
                   WHEN step_ltr_level = 'Pre' THEN 0.0
                   WHEN step_ltr_level = '1' THEN 0.0
                   WHEN step_ltr_level = '2' THEN 0.3
                   WHEN step_ltr_level = '3' THEN 0.7
                   WHEN step_ltr_level = '4' THEN 1.2
                   WHEN step_ltr_level = '5' THEN 1.6
                   WHEN step_ltr_level = '6' THEN 2.0
                   WHEN step_ltr_level = '7' THEN 2.4
                   WHEN step_ltr_level = '8' THEN 2.6
                   WHEN step_ltr_level = '9' THEN 2.8
                   WHEN step_ltr_level = '10' THEN 3.0
                   WHEN step_ltr_level = '11' THEN 3.5
                   WHEN step_ltr_level = '12' THEN 3.8        
                   ELSE NULL
                  END AS GLEQ
                 ,CASE
                   WHEN step_ltr_level = 'Pre' THEN 0        
                   ELSE CONVERT(INT,step_ltr_level)
                  END AS level_number            
                 ,CASE
                   WHEN status = 'Achieved' THEN
                    ROW_NUMBER() OVER
                      (PARTITION BY rs.studentid, rs.status
                           ORDER BY rs.test_date DESC, CONVERT(INT,CASE WHEN step_ltr_level = 'Pre' THEN 0 ELSE step_ltr_level END) DESC)
                   ELSE NULL
             END AS achv_curr_all
           FROM READINGSCORES rs      
           LEFT OUTER JOIN COHORT$comprehensive_long#static cohort
             ON rs.studentid = cohort.studentid
            AND rs.test_date >= CONVERT(DATE,CONVERT(VARCHAR,DATEPART(YYYY,cohort.entrydate)) + '-07-01')
            AND rs.test_date <= CONVERT(DATE,CONVERT(VARCHAR,DATEPART(YYYY,cohort.exitdate)) + '-06-30')
            AND cohort.rn = 1
           WHERE testid != 3273
          ) sq_3
      --WHERE sq_3.achv_curr > 1
     ) prev
  ON sub.studentid = prev.studentid
 AND sub.achv_curr_all = (prev.achv_curr_all - 1) 
--*/
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
                   WHEN step_ltr_level = 'Pre' THEN 0.0
                   WHEN step_ltr_level = '1' THEN 0.0
                   WHEN step_ltr_level = '2' THEN 0.3
                   WHEN step_ltr_level = '3' THEN 0.7
                   WHEN step_ltr_level = '4' THEN 1.2
                   WHEN step_ltr_level = '5' THEN 1.6
                   WHEN step_ltr_level = '6' THEN 2.0
                   WHEN step_ltr_level = '7' THEN 2.4
                   WHEN step_ltr_level = '8' THEN 2.6
                   WHEN step_ltr_level = '9' THEN 2.8
                   WHEN step_ltr_level = '10' THEN 3.0
                   WHEN step_ltr_level = '11' THEN 3.5
                   WHEN step_ltr_level = '12' THEN 3.8        
                   ELSE NULL
                  END AS GLEQ
                 ,CASE
                   WHEN step_ltr_level = 'Pre' THEN 0        
                   ELSE CONVERT(INT,step_ltr_level)
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
            WHERE testid != 3273
           ) sq_3
      WHERE sq_3.achv_curr_tri = 1
        AND sq_3.time_per_name IS NOT NULL
     ) tri
  ON sub.studentid = tri.studentid
 AND sub.year = tri.year
 AND sub.time_per_name = tri.time_per_name
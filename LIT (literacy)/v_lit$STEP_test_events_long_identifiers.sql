USE [KIPP_NJ]
GO

ALTER VIEW LIT$STEP_test_events_long#identifiers AS
SELECT s.id AS studentid
      ,s.student_number
      ,cohort.schoolid
      ,cohort.grade_level
      ,cohort.abbreviation
      ,cohort.year    
      ,scores.test_date
      ,scores.step_ltr_level AS step_level
      ,scores.testid
      ,scores.status           
      ,scores.color
		    ,scores.instruct_lvl
		    ,scores.indep_lvl
		    ,scores.name_ass
		    ,scores.ltr_nameid
		    ,scores.ltr_soundid
		    ,scores.pa_rhymingwds
		    ,scores.cp_orient
		    ,scores.cp_121match
		    ,scores.cp_slw
		    ,scores.pa_mfs
		    ,scores.devsp_first
		    ,scores.devsp_svs
		    ,scores.devsp_final
		    ,scores.rr_121match
		    ,scores.rr_holdspattern
		    ,scores.rr_understanding
		    ,scores.pa_segmentation
		    ,scores.accuracy_1a
		    ,scores.accuracy_2b
		    ,scores.read_teacher
		    ,scores.cc_factual
		    ,scores.cc_infer
		    ,scores.cc_other
		    ,scores.accuracy
		    ,scores.cc_ct
		    ,scores.total_vwlattmpt
		    ,scores.ra_errors
		    ,scores.reading_rate
		    ,scores.fluency
		    ,scores.devsp_ifbd
		    ,scores.ocomp_factual
		    ,scores.ocomp_ct
		    ,scores.scomp_factual
		    ,scores.scomp_infer
		    ,scores.scomp_ct
		    ,scores.devsp_longvp
		    ,scores.devsp_rcontv
		    ,scores.ocomp_infer
		    ,scores.devsp_vcelvp
		    ,scores.devsp_vowldig
		    ,scores.devsp_cmplxb
		    ,scores.wcomp_fact
		    ,scores.wcomp_infer
		    ,scores.retelling
		    ,scores.wcomp_ct
		    ,scores.devsp_eding
		    ,scores.devsp_doubsylj
		    ,scores.devsp_longv2sw
		    ,scores.devsp_rcont2sw       
      ,ROW_NUMBER() OVER(
          PARTITION BY scores.studentid, cohort.year
              ORDER BY scores.test_date ASC) AS rn_asc       
      ,ROW_NUMBER() OVER(
          PARTITION BY scores.studentid, cohort.year
              ORDER BY scores.test_date DESC) AS rn_desc
      ,CASE
        WHEN scores.status = 'Did Not Achieve' THEN NULL
        ELSE ROW_NUMBER() OVER(
             PARTITION BY scores.studentid, cohort.year, scores.status
                 ORDER BY scores.test_date ASC)
       END AS achv_base
       --helps to determine last test event FOR a student IN a year
      ,CASE
        WHEN scores.status = 'Did Not Achieve' THEN NULL
        ELSE ROW_NUMBER() OVER(
             PARTITION BY scores.studentid, cohort.year, scores.status
                 ORDER BY scores.test_date DESC)
       END AS achv_curr
FROM STUDENTS s
JOIN READINGSCORES scores
  ON s.id = scores.studentid
LEFT OUTER JOIN COHORT$comprehensive_long#static cohort
  ON scores.studentid = cohort.studentid
 AND scores.test_date >= cohort.entrydate
 AND scores.test_date <= cohort.exitdate
 AND cohort.rn = 1
WHERE scores.testid > 3273 -- STEP DATA ONLY
  AND s.enroll_status = 0
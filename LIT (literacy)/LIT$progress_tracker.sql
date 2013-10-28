USE KIPP_NJ
GO

--ALTER VIEW LIT$progress_tracker AS
SELECT

--STUDENT IDENTIFIERS
       scores.testid
      ,scores.year        --from COHORT
      ,scores.schoolid    --from COHORT
      ,scores.grade_level --from COHORT
      ,s.schoolid AS curr_school
      ,s.grade_level AS curr_grade
      ,s.team AS curr_team
      ,cs.advisor AS curr_advisor
      ,NULL AS read_teacher
      ,scores.studentid
      ,scores.student_number
      ,scores.lastfirst      
      
--TEST IDENTIFIERS      
      ,scores.time_per_name AS test_round
      ,scores.test_date
      ,scores.fp_keylever      
      ,scores.color
      ,scores.genre
      ,scores.status
      ,CASE
        WHEN scores.testid = 3273 THEN scores.letter_level
        ELSE scores.step_level
       END AS reading_level
      ,scores.GLEQ
      ,scores.level_number            

--RAW SCORES (TEST SPECIFIC)
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
      ,scores.fp_wpmrate
      ,scores.fp_fluency
      ,scores.fp_accuracy
      ,scores.fp_comp_within
      ,scores.fp_comp_beyond
      ,scores.fp_comp_about      
      ,scores.fp_comp_prof AS fp_comp_prof_agg
      ,scores.cc_prof1 AS cc_prof1_agg
      ,scores.cc_prof2 AS cc_prof2_agg
      ,scores.cp_prof AS cp_prof_agg
      ,scores.devsp_prof1 AS devsp_prof1_agg
      ,scores.devsp_prof2 AS devsp_prof2_agg
      ,scores.ocomp_prof1 AS ocomp_prof1_agg
      ,scores.ocomp_prof2 AS ocomp_prof2_agg
      ,scores.rr_prof AS rr_prof_agg
      ,scores.scomp_prof AS scomp_prof_agg
      ,scores.wcomp_prof AS wcomp_prof_agg

--PROFICIENCY MEASURES (BOOLEAN)
  --FUNDAMENTALS
      ,CASE
        WHEN prof.name_ass IS NOT NULL AND scores.name_ass >= prof.name_ass THEN 1 
        WHEN prof.name_ass IS NOT NULL AND scores.name_ass < prof.name_ass THEN 0 
        ELSE NULL 
       END AS name_ass_prof
      ,CASE
        WHEN prof.ltr_nameid IS NOT NULL AND scores.ltr_nameid >= prof.ltr_nameid THEN 1 
        WHEN prof.ltr_nameid IS NOT NULL AND scores.ltr_nameid < prof.ltr_nameid THEN 0 
        ELSE NULL 
       END AS ltr_nameid_prof
      ,CASE
        WHEN prof.ltr_soundid IS NOT NULL AND scores.ltr_soundid >= prof.ltr_soundid THEN 1 
        WHEN prof.ltr_soundid IS NOT NULL AND scores.ltr_soundid < prof.ltr_soundid THEN 0
        ELSE NULL 
       END AS ltr_soundid_prof
      ,CASE 
        WHEN prof.cp_prof IS NOT NULL AND scores.cp_prof >= prof.cp_prof THEN 1 
        WHEN prof.cp_prof IS NOT NULL AND scores.cp_prof < prof.cp_prof THEN 0 
        ELSE NULL 
       END AS cp_prof
      
  --PHONEMIC AWARENESS
      ,CASE
        WHEN prof.pa_rhymingwds IS NOT NULL AND scores.pa_rhymingwds >= prof.pa_rhymingwds THEN 1 
        WHEN prof.pa_rhymingwds IS NOT NULL AND scores.pa_rhymingwds < prof.pa_rhymingwds THEN 0 
        ELSE NULL 
       END AS pa_rhymingwds_prof      
      ,CASE
        WHEN prof.pa_mfs IS NOT NULL AND scores.pa_mfs >= prof.pa_mfs THEN 1 
        WHEN prof.pa_mfs IS NOT NULL AND scores.pa_mfs < prof.pa_mfs THEN 0 
        ELSE NULL 
       END AS pa_mfs_prof      
      ,CASE
        WHEN prof.pa_segmentation IS NOT NULL AND scores.pa_segmentation >= prof.pa_segmentation THEN 1 
        WHEN prof.pa_segmentation IS NOT NULL AND scores.pa_segmentation < prof.pa_segmentation THEN 0 
        ELSE NULL 
       END AS pa_segmentation_prof      
      
  --ACCURACY, et al
      --these go against the logical flow, fewer errors = higher proficiency
      ,CASE
        WHEN prof.accuracy_1a IS NOT NULL AND scores.accuracy_1a < prof.accuracy_1a THEN 1 
        WHEN prof.accuracy_1a IS NOT NULL AND scores.accuracy_1a >= prof.accuracy_1a THEN 0 
        ELSE NULL 
       END AS accuracy_1a_prof
      ,CASE 
        WHEN prof.accuracy_2b IS NOT NULL AND scores.accuracy_2b < prof.accuracy_2b THEN 1 
        WHEN prof.accuracy_2b IS NOT NULL AND scores.accuracy_2b >= prof.accuracy_2b THEN 0 
        ELSE NULL 
       END AS accuracy_2b_prof
      ,CASE
        WHEN scores.accuracy IS NOT NULL AND scores.accuracy IN ('Above','Target') THEN 1 
        WHEN scores.accuracy IS NOT NULL AND scores.accuracy = 'Below' THEN 0 
        ELSE NULL 
       END AS accuracy_prof
      ,CASE 
        WHEN prof.fluency IS NOT NULL AND scores.fluency >= prof.fluency THEN 1 
        WHEN prof.fluency IS NOT NULL AND scores.fluency < prof.fluency THEN 0 
        ELSE NULL 
       END AS fluency_prof
      ,CASE 
        WHEN prof.retelling IS NOT NULL AND scores.retelling >= prof.retelling THEN 1 
        WHEN prof.retelling IS NOT NULL AND scores.retelling < prof.retelling THEN 0 
        ELSE NULL 
       END AS retelling_prof
      ,CASE
        WHEN scores.reading_rate IS NOT NULL AND scores.reading_rate IN ('Above','Target') THEN 1 
        WHEN scores.reading_rate IS NOT NULL AND scores.reading_rate = 'Below' THEN 0 
        ELSE NULL 
       END AS reading_rate_prof
      ,CASE
        WHEN prof.rr_prof IS NOT NULL AND scores.rr_prof >= prof.rr_prof THEN 1 
        WHEN prof.rr_prof IS NOT NULL AND scores.rr_prof < prof.rr_prof THEN 0 
        ELSE NULL 
       END AS rr_prof

  --DEVELOPMENTAL SPELLING
        --STEPs 1 - 3
      ,CASE
        WHEN prof.devsp_prof1 IS NOT NULL AND scores.devsp_prof1 >= prof.devsp_prof1 THEN 1 
        WHEN prof.devsp_prof1 IS NOT NULL AND scores.devsp_prof1 < prof.devsp_prof1 THEN 0 
        ELSE NULL 
       END AS devsp_prof1_prof
        --STEPs 4 -5
      ,CASE
        WHEN prof.devsp_prof2 IS NOT NULL AND scores.devsp_prof2 >= prof.devsp_prof2 THEN 1 
        WHEN prof.devsp_prof2 IS NOT NULL AND scores.devsp_prof2 < prof.devsp_prof2 THEN 0 
        ELSE NULL 
       END AS devsp_prof2_prof
      --for STEPs 6-12, DevSpell proficiencies are compound, meaning a student must be proficient in ALL
      --of the components in order to be proficient for the section
        --STEP 6
      ,CASE
        WHEN prof.devsp_longvp IS NOT NULL AND scores.devsp_longvp >= prof.devsp_longvp 
         AND prof.devsp_rcontv IS NOT NULL AND scores.devsp_rcontv >= prof.devsp_rcontv THEN 1
        WHEN prof.devsp_longvp IS NOT NULL AND scores.devsp_longvp < prof.devsp_longvp THEN 0
        WHEN prof.devsp_rcontv IS NOT NULL AND scores.devsp_rcontv < prof.devsp_rcontv THEN 0 
        ELSE NULL 
       END AS devsp_prof_06      
        --STEP 7
      ,CASE
        WHEN prof.devsp_longvp IS NOT NULL AND scores.devsp_longvp >= prof.devsp_longvp
         AND prof.devsp_vcelvp IS NOT NULL AND scores.devsp_vcelvp >= prof.devsp_vcelvp THEN 1 
        WHEN prof.devsp_vcelvp IS NOT NULL AND scores.devsp_vcelvp < prof.devsp_vcelvp THEN 0
        WHEN prof.devsp_longvp IS NOT NULL AND scores.devsp_longvp < prof.devsp_longvp THEN 0 
        ELSE NULL 
       END AS devsp_prof_07
        --STEPs 8 - 10
      ,CASE 
        WHEN prof.devsp_vowldig IS NOT NULL AND scores.devsp_vowldig >= prof.devsp_vowldig
         AND prof.devsp_longvp IS NOT NULL AND scores.devsp_longvp >= prof.devsp_longvp 
         AND prof.devsp_rcontv IS NOT NULL AND scores.devsp_rcontv >= prof.devsp_rcontv
         AND prof.devsp_cmplxb IS NOT NULL AND scores.devsp_cmplxb >= prof.devsp_cmplxb THEN 1
        WHEN prof.devsp_cmplxb IS NOT NULL AND scores.devsp_cmplxb < prof.devsp_cmplxb THEN 0 
        WHEN prof.devsp_vowldig IS NOT NULL AND scores.devsp_vowldig < prof.devsp_vowldig THEN 0
        WHEN prof.devsp_rcontv IS NOT NULL AND scores.devsp_rcontv < prof.devsp_rcontv THEN 0
        WHEN prof.devsp_longvp IS NOT NULL AND scores.devsp_longvp < prof.devsp_longvp THEN 0
        ELSE NULL
       END AS devsp_prof_8_10
        --STEPs 11 - 12
      ,CASE
        WHEN prof.devsp_eding IS NOT NULL AND scores.devsp_eding >= prof.devsp_eding
         AND prof.devsp_doubsylj IS NOT NULL AND scores.devsp_doubsylj >= prof.devsp_doubsylj
         AND prof.devsp_longv2sw IS NOT NULL AND scores.devsp_longv2sw >= prof.devsp_longv2sw
         AND prof.devsp_rcont2sw IS NOT NULL AND scores.devsp_rcont2sw >= prof.devsp_rcont2sw THEN 1
        WHEN prof.devsp_rcont2sw IS NOT NULL AND scores.devsp_rcont2sw < prof.devsp_rcont2sw THEN 0
        WHEN prof.devsp_eding IS NOT NULL AND scores.devsp_eding < prof.devsp_eding THEN 0
        WHEN prof.devsp_doubsylj IS NOT NULL AND scores.devsp_doubsylj < prof.devsp_doubsylj THEN 0
        WHEN prof.devsp_longv2sw IS NOT NULL AND scores.devsp_longv2sw < prof.devsp_longv2sw THEN 0
        ELSE NULL 
       END AS devsp_prof_11_12
       
  --COMPREHENSION      
      ,CASE
        WHEN prof.cc_prof1 IS NOT NULL AND scores.cc_prof1 >= prof.cc_prof1 THEN 1 
        WHEN prof.cc_prof1 IS NOT NULL AND scores.cc_prof1 < prof.cc_prof1 THEN 0 
        ELSE NULL 
       END AS cc_prof1
      ,CASE
        WHEN prof.cc_prof2 IS NOT NULL AND scores.cc_prof2 >= prof.cc_prof2 THEN 1 
        WHEN prof.cc_prof2 IS NOT NULL AND scores.cc_prof2 < prof.cc_prof2 THEN 0 
        ELSE NULL 
       END AS cc_prof2
      ,CASE
        WHEN prof.ocomp_prof1 IS NOT NULL AND scores.ocomp_prof1 >= prof.ocomp_prof1 THEN 1 
        WHEN prof.ocomp_prof1 IS NOT NULL AND scores.ocomp_prof1 < prof.ocomp_prof1 THEN 0 
        ELSE NULL
       END AS ocomp_prof1
      ,CASE
        WHEN prof.ocomp_prof2 IS NOT NULL AND scores.ocomp_prof2 >= prof.ocomp_prof2 THEN 1 
        WHEN prof.ocomp_prof2 IS NOT NULL AND scores.ocomp_prof2 < prof.ocomp_prof2 THEN 0 
        ELSE NULL 
       END AS ocomp_prof2
      ,CASE
        WHEN prof.scomp_prof IS NOT NULL AND scores.scomp_prof >= prof.scomp_prof THEN 1 
        WHEN prof.scomp_prof IS NOT NULL AND scores.scomp_prof < prof.scomp_prof THEN 0 
        ELSE NULL 
       END AS scomp_prof
      ,CASE
        WHEN prof.wcomp_prof IS NOT NULL AND scores.wcomp_prof >= prof.wcomp_prof THEN 1 
        WHEN prof.wcomp_prof IS NOT NULL AND scores.wcomp_prof < prof.wcomp_prof THEN 0 
        ELSE NULL 
       END AS wcomp_prof
      
  --F&P PROFICIENCIES      
      ,CASE
        WHEN prof.fp_wpmrate IS NOT NULL AND scores.fp_wpmrate >= prof.fp_wpmrate THEN 1 
        WHEN prof.fp_wpmrate IS NOT NULL AND scores.fp_wpmrate < prof.fp_wpmrate THEN 0 
        ELSE NULL 
       END AS fp_wpmrate_prof
      ,CASE
        WHEN prof.fp_fluency IS NOT NULL AND scores.fp_fluency >= prof.fp_fluency THEN 1 
        WHEN prof.fp_fluency IS NOT NULL AND scores.fp_fluency < prof.fp_fluency THEN 0 
        ELSE NULL 
       END AS fp_fluency_prof
      ,CASE
        WHEN prof.fp_accuracy IS NOT NULL AND scores.fp_accuracy >= prof.fp_accuracy THEN 1 
        WHEN prof.fp_accuracy IS NOT NULL AND scores.fp_accuracy < prof.fp_accuracy THEN 0 
        ELSE NULL 
       END AS fp_accuracy_prof      
      ,CASE 
        WHEN prof.fp_comp_prof IS NOT NULL AND scores.fp_comp_prof >= prof.fp_comp_prof THEN 1 
        WHEN prof.fp_comp_prof IS NOT NULL AND scores.fp_comp_prof < prof.fp_comp_prof THEN 0 
        ELSE NULL 
       END AS fp_comp_prof

--PROFICIENCY BENCHMARKS
      ,prof.name_ass AS name_ass_bench
      ,prof.ltr_nameid AS ltr_nameid_bench
      ,prof.ltr_soundid AS ltr_soundid_bench
      ,prof.pa_rhymingwds AS pa_rhymingwds_bench
      ,prof.pa_mfs AS pa_mfs_bench
      ,prof.pa_segmentation AS pa_segmentation_bench
      ,prof.accuracy_1a AS accuracy_1a_bench
      ,prof.accuracy_2b AS accuracy_2b_bench
      ,prof.fluency AS fluency_bench
      ,prof.devsp_longvp AS devsp_longvp_bench
      ,prof.devsp_rcontv AS devsp_rcontv_bench
      ,prof.devsp_vcelvp AS devsp_vcelvp_bench
      ,prof.devsp_vowldig AS devsp_vowldig_bench
      ,prof.devsp_cmplxb AS devsp_cmplxb_bench
      ,prof.retelling AS retelling_bench
      ,prof.devsp_eding AS devsp_eding_bench
      ,prof.devsp_doubsylj AS devsp_doubsylj_bench
      ,prof.devsp_longv2sw AS devsp_longv2sw_bench
      ,prof.devsp_rcont2sw AS devsp_rcont2sw_bench
      ,prof.fp_wpmrate AS fp_wpmrate_bench
      ,prof.fp_fluency AS fp_fluency_bench
      ,prof.fp_accuracy AS fp_accuracy_bench
      ,prof.fp_comp_prof AS fp_comp_prof_bench
      ,prof.cc_prof1 AS cc_prof1_bench
      ,prof.cc_prof2 AS cc_prof2_bench
      ,prof.cp_prof AS cp_prof_bench
      ,prof.devsp_prof1 AS devsp_prof1_bench
      ,prof.devsp_prof2 AS devsp_prof2_bench
      ,prof.ocomp_prof1 AS ocomp_prof1_bench
      ,prof.ocomp_prof2 AS ocomp_prof2_bench
      ,prof.rr_prof AS rr_prof_bench
      ,prof.scomp_prof AS scomp_prof_bench
      ,prof.wcomp_prof AS wcomp_prof_bench

--MARGIN ABOVE/BELOW PROFICIENT
      ,scores.name_ass - prof.name_ass AS name_ass_margin
      ,scores.ltr_nameid - prof.ltr_nameid AS ltr_nameid_margin
      ,scores.ltr_soundid - prof.ltr_soundid AS ltr_soundid_margin
      ,scores.cp_prof - prof.cp_prof AS cp_prof_margin
      
      ,scores.pa_rhymingwds - prof.pa_rhymingwds AS pa_rhymingwds_margin      
      ,scores.pa_mfs - prof.pa_mfs AS pa_mfs_margin      
      ,scores.pa_segmentation - prof.pa_segmentation AS pa_segmentation_margin
      
      ,scores.accuracy_1a - prof.accuracy_1a AS accuracy_1a_margin
      ,scores.accuracy_2b - prof.accuracy_2b AS accuracy_2b_margin      
      ,scores.fluency - prof.fluency AS fluency_margin      
      ,scores.retelling - prof.retelling AS retelling_margin      
      ,scores.rr_prof - prof.rr_prof AS rr_prof_margin
            
      ,scores.devsp_longvp - prof.devsp_longvp AS devsp_longvp_margin
      ,scores.devsp_rcontv - prof.devsp_rcontv AS devsp_rcontv_margin      
      ,scores.devsp_vcelvp - prof.devsp_vcelvp AS devsp_vcelvp_margin
      ,scores.devsp_vowldig - prof.devsp_vowldig AS devsp_vowldig_margin
      ,scores.devsp_cmplxb - prof.devsp_cmplxb AS devsp_cmplxb_margin      
      ,scores.devsp_eding - prof.devsp_eding AS devsp_eding_margin
      ,scores.devsp_doubsylj - prof.devsp_doubsylj AS devsp_doubsylj_margin
      ,scores.devsp_longv2sw - prof.devsp_longv2sw AS devsp_longv2sw_margin
      ,scores.devsp_rcont2sw - prof.devsp_rcont2sw AS devsp_rcont2sw_margin
      ,scores.devsp_prof1 - prof.devsp_prof1 AS devsp_prof1_margin
      ,scores.devsp_prof2 - prof.devsp_prof2 AS devsp_prof2_margin
      
      ,scores.cc_prof1 - prof.cc_prof1 AS cc_prof1_margin
      ,scores.cc_prof2 - prof.cc_prof2 AS cc_prof2_margin      
      ,scores.ocomp_prof1 - prof.ocomp_prof1 AS ocomp_prof1_margin
      ,scores.ocomp_prof2 - prof.ocomp_prof2 AS ocomp_prof2_margin
      ,scores.scomp_prof - prof.scomp_prof AS scomp_prof_margin
      ,scores.wcomp_prof - prof.wcomp_prof AS wcomp_prof_margin
      
      ,scores.fp_wpmrate - prof.fp_wpmrate AS fp_wpmrate_margin
      ,scores.fp_fluency - prof.fp_fluency AS fp_fluency_margin
      ,scores.fp_accuracy - prof.fp_accuracy AS fp_accuracy_margin      
      ,scores.fp_comp_prof - prof.fp_comp_prof AS fp_comp_prof_margin

--GROWTH MEASURES
      ,scores.achv_base     --first level achieved for academic year
      ,scores.achv_curr     --most recent level achieved for academic year
      ,scores.dna_base      --first DNA for academic year
      ,scores.dna_curr      --most recent DNA for academic year
      ,scores.achv_base_all --first level achieved all time
      ,scores.achv_curr_all --most recent level achieved all time
      ,scores.achv_base_tri --first level achieved for academic year
      ,scores.achv_curr_tri --most recent level achieved for academic year
      ,scores.dna_base_tri  --first DNA for academic year
      ,scores.dna_curr_tri  --most recent DNA for academic year
      ,scores.GLEQ_growth_ytd
      ,scores.level_growth_ytd
      ,scores.GLEQ_growth_prev
      ,scores.level_growth_prev
      ,scores.GLEQ_growth_tri
      ,scores.level_growth_tri
      
--MAP LEXILE
--scores from MAP reading test taken within a 16-week range of the FP/STEP test
      ,map.testritscore AS map_reading_rit
      ,map.testpercentile AS map_reading_pct
      ,map.rittoreadingscore AS lexile
      ,map.rittoreadingmax AS lexile_max
      ,map.rittoreadingmin AS lexile_min      
      
--REPORTING HASHES
      ,CASE
        WHEN status = 'Achieved' THEN CONVERT(VARCHAR,scores.student_number) + '_'
                                       + CONVERT(VARCHAR,time_per_name) + '_' 
                                       + CONVERT(VARCHAR,status) + '_' 
                                       + CONVERT(VARCHAR,year) + '_' 
                                       + CONVERT(VARCHAR,achv_base_tri)
        WHEN status = 'Did Not Achieve' THEN CONVERT(VARCHAR,scores.student_number) + '_'
                                              + CONVERT(VARCHAR,time_per_name) + '_' 
                                              + CONVERT(VARCHAR,status) + '_' 
                                              + CONVERT(VARCHAR,year) + '_' 
                                              + CONVERT(VARCHAR,dna_base_tri)
        ELSE NULL
       END AS reporting_hash
      
FROM
     (SELECT testid
            ,schoolid
            ,grade_level
            ,year       
            ,studentid
            ,student_number
            ,lastfirst
            ,test_date
            ,letter_level
            ,status
            ,NULL AS step_level
            ,NULL AS color
            ,NULL AS instruct_lvl
            ,NULL AS indep_lvl       
            ,NULL AS name_ass
            ,NULL AS ltr_nameid
            ,NULL AS ltr_soundid
            ,NULL AS pa_rhymingwds
            ,NULL AS cp_orient
            ,NULL AS cp_121match
            ,NULL AS cp_slw
            ,NULL AS pa_mfs
            ,NULL AS devsp_first
            ,NULL AS devsp_svs
            ,NULL AS devsp_final
            ,NULL AS rr_121match
            ,NULL AS rr_holdspattern
            ,NULL AS rr_understanding
            ,NULL AS pa_segmentation
            ,NULL AS accuracy_1a
            ,NULL AS accuracy_2b
            ,NULL AS cc_factual
            ,NULL AS cc_infer
            ,NULL AS cc_other
            ,NULL AS accuracy
            ,NULL AS cc_ct
            ,NULL AS total_vwlattmpt
            ,NULL AS ra_errors
            ,NULL AS reading_rate
            ,NULL AS fluency
            ,NULL AS devsp_ifbd
            ,NULL AS ocomp_factual
            ,NULL AS ocomp_ct
            ,NULL AS scomp_factual
            ,NULL AS scomp_infer
            ,NULL AS scomp_ct
            ,NULL AS devsp_longvp
            ,NULL AS devsp_rcontv
            ,NULL AS ocomp_infer
            ,NULL AS devsp_vcelvp
            ,NULL AS devsp_vowldig
            ,NULL AS devsp_cmplxb
            ,NULL AS wcomp_fact
            ,NULL AS wcomp_infer
            ,NULL AS retelling
            ,NULL AS wcomp_ct
            ,NULL AS devsp_eding
            ,NULL AS devsp_doubsylj
            ,NULL AS devsp_longv2sw
            ,NULL AS devsp_rcont2sw
            ,NULL AS cc_prof1
            ,NULL AS cc_prof2
            ,NULL AS cp_prof
            ,NULL AS devsp_prof1
            ,NULL AS devsp_prof2
            ,NULL AS ocomp_prof1
            ,NULL AS ocomp_prof2
            ,NULL AS rr_prof
            ,NULL AS scomp_prof
            ,NULL AS wcomp_prof
            ,fp_wpmrate
            ,fp_fluency
            ,fp_accuracy
            ,fp_comp_within
            ,fp_comp_beyond
            ,fp_comp_about
            ,fp_comp_prof
            ,fp_keylever
            ,genre
            ,GLEQ
            ,level_number
            ,achv_base
            ,achv_curr
            ,dna_base
            ,dna_curr
            ,achv_base_all
            ,achv_curr_all
            ,achv_base_tri
            ,achv_curr_tri
            ,dna_base_tri
            ,dna_curr_tri
            ,GLEQ_growth_ytd
            ,level_growth_ytd
            ,GLEQ_growth_prev
            ,level_growth_prev
            ,GLEQ_growth_tri
            ,level_growth_tri
            ,time_per_name
      FROM LIT$FP_test_events_long#identifiers#static

      UNION ALL

      SELECT testid
            ,schoolid
            ,grade_level
            ,year       
            ,studentid
            ,student_number
            ,lastfirst
            ,test_date
            ,NULL AS letter_level
            ,status       
            ,step_level
            ,color
            ,instruct_lvl
            ,indep_lvl
            ,name_ass
            ,ltr_nameid
            ,ltr_soundid
            ,pa_rhymingwds
            ,cp_orient
            ,cp_121match
            ,cp_slw
            ,pa_mfs
            ,devsp_first
            ,devsp_svs
            ,devsp_final
            ,rr_121match
            ,rr_holdspattern
            ,rr_understanding
            ,pa_segmentation
            ,accuracy_1a
            ,accuracy_2b
            ,cc_factual
            ,cc_infer
            ,cc_other
            ,accuracy
            ,cc_ct
            ,total_vwlattmpt
            ,ra_errors
            ,reading_rate
            ,fluency
            ,devsp_ifbd
            ,ocomp_factual
            ,ocomp_ct
            ,scomp_factual
            ,scomp_infer
            ,scomp_ct
            ,devsp_longvp
            ,devsp_rcontv
            ,ocomp_infer
            ,devsp_vcelvp
            ,devsp_vowldig
            ,devsp_cmplxb
            ,wcomp_fact
            ,wcomp_infer
            ,retelling
            ,wcomp_ct
            ,devsp_eding
            ,devsp_doubsylj
            ,devsp_longv2sw
            ,devsp_rcont2sw
		          ,cc_prof1
            ,cc_prof2
            ,cp_prof
            ,devsp_prof1
            ,devsp_prof2
            ,ocomp_prof1
            ,ocomp_prof2
            ,rr_prof
            ,scomp_prof
            ,wcomp_prof
            ,NULL AS fp_wpmrate
            ,NULL AS fp_fluency
            ,NULL AS fp_accuracy
            ,NULL AS fp_comp_within
            ,NULL AS fp_comp_beyond
            ,NULL AS fp_comp_about
            ,NULL AS fp_comp_prof
            ,NULL AS fp_keylever
            ,genre
            ,GLEQ
            ,level_number
            ,achv_base
            ,achv_curr
            ,dna_base
            ,dna_curr
            ,achv_base_all
            ,achv_curr_all
            ,achv_base_tri
            ,achv_curr_tri
            ,dna_base_tri
            ,dna_curr_tri
            ,GLEQ_growth_ytd
            ,level_growth_ytd
            ,GLEQ_growth_prev
            ,level_growth_prev
            ,GLEQ_growth_tri
            ,level_growth_tri
            ,time_per_name
      FROM LIT$STEP_test_events_long#identifiers
     ) scores
JOIN LIT$proficiency prof
  ON scores.testid = prof.testid
JOIN STUDENTS s
  ON scores.studentid = s.id
LEFT OUTER JOIN CUSTOM_STUDENTS cs
  ON scores.studentid = cs.studentid
LEFT OUTER JOIN MAP$comprehensive#identifiers map
  ON scores.studentid = map.ps_studentid
 AND scores.test_date >= DATEADD(WK,-8,map.teststartdate)
 AND scores.test_date <= DATEADD(WK,8,map.teststartdate)
 AND map.measurementscale = 'Reading'
 AND map.rn = 1
WHERE s.enroll_status = 0
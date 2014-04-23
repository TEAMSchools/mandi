USE KIPP_NJ
GO

ALTER VIEW LIT$readingscores_long AS

WITH long_scores AS (
  SELECT unique_id      
        ,testid
        ,studentid
        ,step_ltr_level AS read_lvl
        ,status
        ,field
        ,score
  FROM
      (
       SELECT unique_id      
             ,testid
             ,studentid
             ,step_ltr_level
             ,status
             ,CONVERT(VARCHAR,name_ass) AS name_ass
             ,CONVERT(VARCHAR,ltr_nameid) AS ltr_nameid
             ,CONVERT(VARCHAR,ltr_soundid) AS ltr_soundid
             ,CONVERT(VARCHAR,pa_rhymingwds) AS pa_rhymingwds
             ,CONVERT(VARCHAR,pa_mfs) AS pa_mfs
             ,CONVERT(VARCHAR,pa_segmentation) AS pa_segmentation
             ,CONVERT(VARCHAR,cp_orient) AS cp_orient
             ,CONVERT(VARCHAR,cp_121match) AS cp_121match
             ,CONVERT(VARCHAR,cp_slw) AS cp_slw
             ,CONVERT(VARCHAR,devsp_first) AS devsp_first
             ,CONVERT(VARCHAR,devsp_svs) AS devsp_svs
             ,CONVERT(VARCHAR,devsp_final) AS devsp_final
             ,CONVERT(VARCHAR,devsp_init_bd) AS devsp_init_bd
             ,CONVERT(VARCHAR,devsp_fin_bd) AS devsp_fin_bd
             ,CONVERT(VARCHAR,devsp_ifbd) AS devsp_ifbd
             ,CONVERT(VARCHAR,devsp_longvp) AS devsp_longvp
             ,CONVERT(VARCHAR,devsp_rcontv) AS devsp_rcontv
             ,CONVERT(VARCHAR,devsp_vce) AS devsp_vce
             ,CONVERT(VARCHAR,devsp_long_vwl) AS devsp_long_vwl
             ,CONVERT(VARCHAR,devsp_vcelvp) AS devsp_vcelvp
             ,CONVERT(VARCHAR,devsp_vowldig) AS devsp_vowldig
             ,CONVERT(VARCHAR,devsp_cmplxb) AS devsp_cmplxb
             ,CONVERT(VARCHAR,devsp_eding) AS devsp_eding
             ,CONVERT(VARCHAR,devsp_doubsylj) AS devsp_doubsylj
             ,CONVERT(VARCHAR,devsp_longv2sw) AS devsp_longv2sw
             ,CONVERT(VARCHAR,devsp_rcont2sw) AS devsp_rcont2sw
             ,CONVERT(VARCHAR,rr_121match) AS rr_121match
             ,CONVERT(VARCHAR,rr_holdspattern) AS rr_holdspattern
             ,CONVERT(VARCHAR,rr_understanding) AS rr_understanding
             ,CONVERT(VARCHAR,
               CASE
                WHEN accuracy = 'Above' THEN 2
                WHEN accuracy = 'Target' THEN 1
                WHEN accuracy = 'Below' THEN 0
                ELSE NULL
               END) AS accuracy
             ,CONVERT(VARCHAR,accuracy_1a) AS accuracy_1a
             ,CONVERT(VARCHAR,accuracy_2b) AS accuracy_2b
             ,CONVERT(VARCHAR,ra_errors) AS ra_errors
             ,CONVERT(VARCHAR,cc_factual) AS cc_factual
             ,CONVERT(VARCHAR,cc_infer) AS cc_infer
             ,CONVERT(VARCHAR,cc_other) AS cc_other
             ,CONVERT(VARCHAR,cc_ct) AS cc_ct
             ,CONVERT(VARCHAR,ocomp_factual) AS ocomp_factual
             ,CONVERT(VARCHAR,ocomp_ct) AS ocomp_ct
             ,CONVERT(VARCHAR,ocomp_infer) AS ocomp_infer
             ,CONVERT(VARCHAR,scomp_factual) AS scomp_factual
             ,CONVERT(VARCHAR,scomp_infer) AS scomp_infer
             ,CONVERT(VARCHAR,scomp_ct) AS scomp_ct
             ,CONVERT(VARCHAR,wcomp_fact) AS wcomp_fact
             ,CONVERT(VARCHAR,wcomp_infer) AS wcomp_infer
             ,CONVERT(VARCHAR,wcomp_ct) AS wcomp_ct
             ,CONVERT(VARCHAR,retelling) AS retelling
             ,CONVERT(VARCHAR,total_vwlattmpt) AS total_vwlattmpt
             ,CONVERT(VARCHAR,
                CASE
                 WHEN accuracy = 'Above' THEN 2
                 WHEN accuracy = 'Target' THEN 1
                 WHEN accuracy = 'Below' THEN 0
                 ELSE NULL
                END) AS reading_rate
             ,CONVERT(VARCHAR,reading_time) AS reading_time
             ,CONVERT(VARCHAR,fluency) AS fluency
             ,CONVERT(VARCHAR,ROUND(fp_wpmrate,0)) AS fp_wpmrate
             ,CONVERT(VARCHAR,fp_fluency) AS fp_fluency
             ,CONVERT(VARCHAR,fp_accuracy) AS fp_accuracy
             ,CONVERT(VARCHAR,fp_comp_within) AS fp_comp_within
             ,CONVERT(VARCHAR,fp_comp_beyond) AS fp_comp_beyond
             ,CONVERT(VARCHAR,fp_comp_about) AS fp_comp_about           
             ,CONVERT(VARCHAR,cc_prof) AS cc_prof
             ,CONVERT(VARCHAR,ocomp_prof) AS ocomp_prof
             ,CONVERT(VARCHAR,scomp_prof) AS scomp_prof
             ,CONVERT(VARCHAR,wcomp_prof) AS wcomp_prof
             ,CONVERT(VARCHAR,fp_comp_prof) AS fp_comp_prof
             ,CONVERT(VARCHAR,cp_prof) AS cp_prof
             ,CONVERT(VARCHAR,rr_prof) AS rr_prof
             ,CONVERT(VARCHAR,devsp_prof) AS devsp_prof
             ,CONVERT(VARCHAR,devsp_blend_prof) AS devsp_blend_prof
             ,CONVERT(VARCHAR,devsp_vce_longvwl_prof) AS devsp_vce_longvwl_prof
       FROM READINGSCORES WITH(NOLOCK)
      ) sub

  UNPIVOT (
    score
    FOR field IN (name_ass
                       ,ltr_nameid
                       ,ltr_soundid
                       ,pa_rhymingwds
                       ,pa_mfs
                       ,pa_segmentation
                       ,cp_orient
                       ,cp_121match
                       ,cp_slw
                       ,devsp_first
                       ,devsp_svs
                       ,devsp_final
                       ,devsp_init_bd
                       ,devsp_fin_bd
                       ,devsp_ifbd
                       ,devsp_longvp
                       ,devsp_rcontv
                       ,devsp_vce
                       ,devsp_long_vwl
                       ,devsp_vcelvp
                       ,devsp_vowldig
                       ,devsp_cmplxb
                       ,devsp_eding
                       ,devsp_doubsylj
                       ,devsp_longv2sw
                       ,devsp_rcont2sw
                       ,rr_121match
                       ,rr_holdspattern
                       ,rr_understanding
                       ,accuracy
                       ,accuracy_1a
                       ,accuracy_2b
                       ,ra_errors
                       ,cc_factual
                       ,cc_infer
                       ,cc_other
                       ,cc_ct
                       ,ocomp_factual
                       ,ocomp_ct
                       ,ocomp_infer
                       ,scomp_factual
                       ,scomp_infer
                       ,scomp_ct
                       ,wcomp_fact
                       ,wcomp_infer
                       ,wcomp_ct
                       ,retelling
                       ,total_vwlattmpt
                       ,reading_rate
                       ,reading_time
                       ,fluency
                       ,fp_wpmrate
                       ,fp_fluency
                       ,fp_accuracy
                       ,fp_comp_within
                       ,fp_comp_beyond
                       ,fp_comp_about                     
                       ,cc_prof
                       ,ocomp_prof
                       ,scomp_prof
                       ,wcomp_prof
                       ,fp_comp_prof
                       ,cp_prof
                       ,rr_prof
                       ,devsp_prof
                       ,devsp_blend_prof)
   ) unpiv
 )


SELECT sub.unique_id
      ,sub.testid
      ,sub.studentid
      ,sub.read_lvl
      ,sub.status
      ,sub.domain
      ,sub.field
      ,sub.score
      ,sub.benchmark
      ,sub.is_prof
      ,CASE WHEN sub.is_prof = 0 THEN sub.domain ELSE NULL END AS dna_reason
FROM 
    (
     SELECT rs.unique_id
           ,rs.testid
           ,rs.studentid
           ,rs.read_lvl
           ,rs.status
           ,prof.domain
           ,rs.field
           ,rs.score
           ,prof.benchmark
           ,CASE 
             WHEN rs.field NOT IN ('accuracy_1a','accuracy_2b') AND rs.score >= prof.benchmark THEN 1
             WHEN rs.field IN ('accuracy_1a','accuracy_2b') AND rs.score <= prof.benchmark THEN 1
             ELSE 0
            END AS is_prof
     FROM long_scores rs
     JOIN LIT$prof_long prof
       ON rs.testid = prof.testid
      AND rs.field = prof.field
    ) sub
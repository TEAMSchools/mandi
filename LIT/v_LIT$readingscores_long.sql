USE KIPP_NJ
GO

ALTER VIEW LIT$readingscores_long AS

WITH ps_scores_long AS (
  SELECT unique_id      
        ,testid
        ,studentid
        ,read_lvl
        ,status
        ,field
        ,score
  FROM
      (
       SELECT unique_id      
             ,testid
             ,studentid       
             ,CASE WHEN academic_year = 2015 AND testid = 3273 THEN instruct_lvl ELSE read_lvl END AS read_lvl
             ,ISNULL(status,'Did Not Achieve') AS status
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
             ,CONVERT(VARCHAR,devsp_ifbd) AS devsp_ifbd
             ,CONVERT(VARCHAR,devsp_longvowel) AS devsp_longvowel
             ,CONVERT(VARCHAR,devsp_rcontrol) AS devsp_rcontrol                          
             ,CONVERT(VARCHAR,devsp_vowldig) AS devsp_vowldig
             ,CONVERT(VARCHAR,devsp_cmplxb) AS devsp_cmplxb
             ,CONVERT(VARCHAR,devsp_eding) AS devsp_eding
             ,CONVERT(VARCHAR,devsp_doubsylj) AS devsp_doubsylj             
             ,CONVERT(VARCHAR,rr_121match) AS rr_121match
             ,CONVERT(VARCHAR,rr_holdspattern) AS rr_holdspattern
             ,CONVERT(VARCHAR,rr_understanding) AS rr_understanding             
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
             ,CONVERT(VARCHAR,
                CASE
                 WHEN testid = 3397 AND reading_rate IN ('Above','Target') THEN 30
                 WHEN testid IN (3411,3425) AND reading_rate IN ('Above','Target') THEN 40
                 WHEN testid IN (3442,3458,3474) AND reading_rate IN ('Above','Target') THEN 50
                 WHEN testid IN (3493,3511,3527) AND reading_rate IN ('Above','Target') THEN 75        
                END) AS reading_rate             
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
       FROM KIPP_NJ..LIT$readingscores#static WITH(NOLOCK)
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
                 ,devsp_ifbd
                 ,devsp_longvowel
                 ,devsp_rcontrol                       
                 ,devsp_vowldig
                 ,devsp_cmplxb
                 ,devsp_eding
                 ,devsp_doubsylj                       
                 ,rr_121match
                 ,rr_holdspattern
                 ,rr_understanding                       
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
                 ,reading_rate                       
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
                 ,devsp_prof)
   ) unpiv
 )

,uc_scores_long AS (
  SELECT CONCAT('UC',step.[index]) AS unique_id
        ,s.id AS studentid
        ,CASE               
          WHEN CONVERT(INT,step.step) = 0 THEN 3280
          WHEN CONVERT(INT,step.step) = 1 THEN 3281
          WHEN CONVERT(INT,step.step) = 2 THEN 3282
          WHEN CONVERT(INT,step.step) = 3 THEN 3380
          WHEN CONVERT(INT,step.step) = 4 THEN 3397
          WHEN CONVERT(INT,step.step) = 5 THEN 3411
          WHEN CONVERT(INT,step.step) = 6 THEN 3425
          WHEN CONVERT(INT,step.step) = 7 THEN 3441
          WHEN CONVERT(INT,step.step) = 8 THEN 3458
          WHEN CONVERT(INT,step.step) = 9 THEN 3474
          WHEN CONVERT(INT,step.step) = 10 THEN 3493
          WHEN CONVERT(INT,step.step) = 11 THEN 3511
          WHEN CONVERT(INT,step.step) = 12 THEN 3527
         END AS testid      
        ,CASE 
          WHEN step.passed = 1 THEN 'Achieved'
          WHEN step.passed = 0 THEN 'Did Not Achieve'
         END AS status
        ,CASE        
          WHEN step.component IN ('Comprehension Conversation') THEN 'cc_prof'
          WHEN step.component IN ('Comprehension Conversation: Critical Thinking') THEN 'cc_ct'
          WHEN step.component IN ('Comprehension Conversation: Factual') THEN 'cc_factual'
          WHEN step.component IN ('Comprehension Conversation: Inferential') THEN 'cc_infer'
          WHEN step.component IN ('Comprehension Conversation: Other') THEN 'cc_other'
        
          WHEN step.component IN ('Concepts about Print') THEN 'cp_prof'
          WHEN step.component IN ('Concepts about Print: One-to-One Matching') THEN 'cp_121match'
          WHEN step.component IN ('Concepts about Print: Orientation') THEN 'cp_orient'
          WHEN step.component IN ('Concepts about Print: Sense of Letter vs. Word') THEN 'cp_slw'
        
          WHEN step.component IN ('Developmental Spelling: Long-Vowel Pattern','Developmental Spelling: Long-Vowel 2-Syllable Words','Developmental Spelling: V-C-e + Long-Vowel Pattern') THEN 'devsp_longvowel'
          WHEN step.component IN ('Developmental Spelling: Initial + Final Blend/Digraph','Developmental Spelling: Initial + Final Blend/Digraphs') THEN 'devsp_ifbd'
          WHEN step.component IN ('Developmental Spelling: R-Controlled 2-Syllable Words','Developmental Spelling: R-Controlled Vowel') THEN 'devsp_rcontrol'        
          WHEN step.component IN ('Developmental Spelling') THEN 'devsp_prof'
          WHEN step.component IN ('Developmental Spelling: Complex Blend') THEN 'devsp_cmplxb'
          WHEN step.component IN ('Developmental Spelling: Doubling at Syllable Juncture') THEN 'devsp_doubsylj'
          WHEN step.component IN ('Developmental Spelling: -ed/-ing Endings') THEN 'devsp_eding'
          WHEN step.component IN ('Developmental Spelling: Final Sound') THEN 'devsp_final'
          WHEN step.component IN ('Developmental Spelling: First Sound') THEN 'devsp_first'
          WHEN step.component IN ('Developmental Spelling: Short-Vowel Sound') THEN 'devsp_svs'
          WHEN step.component IN ('Developmental Spelling: Vowel Digraphs') THEN 'devsp_vowldig'
        
          WHEN step.component IN ('Fluency') THEN 'fluency'
        
          WHEN step.component IN ('Letter-Name Identification') THEN 'ltr_nameid'
        
          WHEN step.component IN ('Letter-Sound Identification') THEN 'ltr_soundid'
        
          WHEN step.component IN ('Name Assessment') THEN 'name_ass'
        
          WHEN step.component IN ('Oral Comprehension') THEN 'ocomp_prof'
          WHEN step.component IN ('Oral Comprehension: Critical Thinking') THEN 'ocomp_ct'
          WHEN step.component IN ('Oral Comprehension: Factual') THEN 'ocomp_factual'
          WHEN step.component IN ('Oral Comprehension: Inferential') THEN 'ocomp_infer'
        
          WHEN step.component IN ('Phonemic Awareness: Matching First Sounds') THEN 'pa_mfs'
          WHEN step.component IN ('Phonemic Awareness: Rhyming Words') THEN 'pa_rhymingwds'
          WHEN step.component IN ('Phonemic Awareness: Segmentation') THEN 'pa_segmentation'
        
          WHEN step.component IN ('Reading Rate') THEN 'reading_rate'
        
          WHEN step.component IN ('Reading Record') THEN 'rr_prof'
          WHEN step.component IN ('Reading Record: Holds Pattern') THEN 'rr_holdspattern'
          WHEN step.component IN ('Reading Record: One-to-One Matching') THEN 'rr_121match'
          WHEN step.component IN ('Reading Record: Understanding') THEN 'rr_understanding'
        
          WHEN step.component IN ('Retelling') THEN 'retelling'
        
          WHEN step.component IN ('Silent Comprehension') THEN 'scomp_prof'
          WHEN step.component IN ('Silent Comprehension: Critical Thinking') THEN 'scomp_ct'
          WHEN step.component IN ('Silent Comprehension: Factual') THEN 'scomp_factual'
          WHEN step.component IN ('Silent Comprehension: Inferential') THEN 'scomp_infer'
        
          WHEN step.component IN ('Written Comprehension') THEN 'wcomp_prof'
          WHEN step.component IN ('Written Comprehension: Critical Thinking') THEN 'wcomp_ct'
          WHEN step.component IN ('Written Comprehension: Factual') THEN 'wcomp_fact'
          WHEN step.component IN ('Written Comprehension: Inferential') THEN 'wcomp_infer'
          ELSE step.component
         END AS field
        ,step.score
        ,CASE WHEN step.step = 0 THEN 'Pre' ELSE CONVERT(VARCHAR,step.step) END AS read_lvl
        ,step.step AS lvl_num
  FROM KIPP_NJ..AUTOLOAD$STEP_Level_Assessment_Data_long step WITH(NOLOCK)
  LEFT OUTER JOIN KIPP_NJ..PS$STUDENTS#static s WITH(NOLOCK)
    ON step.studentid = s.student_number
 )

,illuminate_fp AS (
  SELECT unique_id
        ,studentid           
        ,testid
        ,status
        ,field
        ,score           
        ,read_lvl
        ,lvl_num           
  FROM
      (
       SELECT rs.unique_id
             ,rs.studentid           
             ,3273 AS testid
             ,rs.status      
             ,CASE WHEN rs.status = 'Did Not Achieve' THEN rs.instructional_level_tested ELSE rs.achieved_independent_level END AS read_lvl
             ,CASE WHEN rs.status = 'Did Not Achieve' THEN rs.instr_lvl_num ELSE rs.indep_lvl_num END AS lvl_num
             ,rs.about_the_text AS fp_comp_about   
             ,rs.beyond_the_text AS fp_comp_beyond
             ,rs.within_the_text AS fp_comp_within
             ,rs.accuracy AS fp_accuracy
             ,rs.fluency AS fp_fluency
             ,rs.reading_rate_wpm AS fp_wpmrate    
             ,rs.comp_overall AS fp_comp_prof
       FROM KIPP_NJ..LIT$ILLUMINATE_test_events#identifiers#static rs WITH(NOLOCK)
       LEFT OUTER JOIN KIPP_NJ..PS$STUDENTS#static s WITH(NOLOCK)
         ON rs.studentid = s.student_number
      ) sub
  UNPIVOT(
    score
    FOR field IN (fp_wpmrate
                 ,fp_fluency
                 ,fp_accuracy
                 ,fp_comp_within
                 ,fp_comp_beyond
                 ,fp_comp_about
                 ,fp_comp_prof)
   ) u
 )

,all_scores AS (
  SELECT rs.unique_id
        ,rs.studentid           
        ,rs.testid
        ,rs.status
        ,rs.field
        ,rs.score
           
        ,gleq.read_lvl
        ,gleq.fp_lvl_num AS lvl_num           
  FROM ps_scores_long rs
  LEFT OUTER JOIN KIPP_NJ..AUTOLOAD$GDOCS_LIT_gleq gleq WITH(NOLOCK)
    ON rs.read_lvl = gleq.read_lvl
  WHERE rs.testid = 3273

  UNION ALL

  SELECT rs.unique_id
        ,rs.studentid           
        ,rs.testid
        ,rs.status
        ,rs.field
        ,rs.score
           
        ,gleq.read_lvl
        ,gleq.lvl_num           
  FROM ps_scores_long rs
  LEFT OUTER JOIN KIPP_NJ..AUTOLOAD$GDOCS_LIT_gleq gleq WITH(NOLOCK)
    ON rs.testid = gleq.testid 
   AND gleq.lvl_num != -1
  WHERE rs.testid != 3273

  UNION ALL

  SELECT rs.unique_id
        ,rs.studentid           
        ,rs.testid
        ,rs.status
        ,rs.field
        ,rs.score           
        ,rs.read_lvl
        ,rs.lvl_num           
  FROM uc_scores_long rs     

  UNION ALL

  SELECT rs.unique_id
        ,rs.studentid           
        ,rs.testid
        ,rs.status
        ,rs.field
        ,rs.score           
        ,rs.read_lvl
        ,rs.lvl_num           
  FROM illuminate_fp rs     
 )

SELECT sub.unique_id
      ,sub.testid
      ,sub.studentid
      ,sub.read_lvl
      ,sub.lvl_num
      ,sub.status
      ,sub.domain
      ,sub.subdomain
      ,sub.strand
      ,sub.label
      ,sub.specific_label
      ,sub.field
      ,sub.score
      ,sub.benchmark
      ,sub.is_prof
      ,sub.is_dna
      ,CASE
        WHEN sub.label LIKE '%errors%' THEN sub.benchmark - sub.score
        ELSE sub.score - sub.benchmark 
       END AS margin      
      ,CASE 
        WHEN sub.testid != 3273 AND sub.is_prof = 0 THEN 1
        WHEN sub.testid = 3273 AND sub.domain != 'Comprehension' AND sub.is_prof = 0 THEN 1
        WHEN sub.testid = 3273 AND sub.domain = 'Comprehension' AND MIN(sub.is_prof) OVER(PARTITION BY sub.unique_id, sub.domain) = 0 AND sub.score_order = 1 THEN 1
        ELSE 0        
       END AS dna_filter
      ,CASE 
        WHEN sub.testid != 3273 AND sub.is_prof = 0 THEN sub.domain 
        WHEN sub.testid = 3273 AND sub.domain != 'Comprehension' AND sub.is_prof = 0 THEN sub.domain
        WHEN sub.testid = 3273 AND sub.domain = 'Comprehension' AND MIN(sub.is_prof) OVER(PARTITION BY sub.unique_id, sub.domain) = 0 AND sub.score_order = 1 THEN sub.strand
        ELSE NULL 
       END AS dna_reason
FROM 
    (
     SELECT rs.unique_id           
           ,rs.testid
           ,rs.studentid
           ,rs.read_lvl
           ,rs.lvl_num
           ,rs.status                                 
           ,rs.field
           ,rs.score
           ,prof.domain
           ,prof.subdomain
           ,prof.strand           
           ,CONVERT(FLOAT,prof.score) AS benchmark
           ,CASE
             WHEN prof.strand LIKE '%overall%' THEN ISNULL(prof.domain + ': ', '') + prof.strand
             ELSE ISNULL(prof.subdomain + ': ', '') + prof.strand 
            END AS label
           ,CASE
             WHEN prof.strand LIKE '%overall%' AND prof.subdomain IS NOT NULL THEN ISNULL(prof.domain + ' (', '') + ISNULL(prof.subdomain + '): ', '') + prof.strand
             WHEN prof.strand LIKE '%overall%' AND prof.subdomain IS NULL THEN ISNULL(prof.domain + ': ', '') + prof.strand
             ELSE ISNULL(prof.subdomain + ': ', '') + prof.strand 
            END AS specific_label
           ,CASE 
             WHEN prof.score IS NULL THEN NULL
             WHEN prof.field_name NOT IN ('ra_errors','accuracy_1a','accuracy_2b') AND rs.score >= CONVERT(FLOAT,prof.score) THEN 1
             WHEN prof.field_name IN ('ra_errors','accuracy_1a','accuracy_2b') AND rs.score <= CONVERT(FLOAT,prof.score) THEN 1
             ELSE 0
            END AS is_prof
           ,CASE 
             WHEN prof.score IS NULL THEN NULL
             WHEN prof.field_name NOT IN ('ra_errors','accuracy_1a','accuracy_2b') AND rs.score < CONVERT(FLOAT,prof.score) THEN 1
             WHEN prof.field_name IN ('ra_errors','accuracy_1a','accuracy_2b') AND rs.score > CONVERT(FLOAT,prof.score) THEN 1
             ELSE 0
            END AS is_dna
           ,ROW_NUMBER() OVER(
              PARTITION BY rs.unique_id, prof.domain
                ORDER BY rs.score ASC, prof.strand DESC) AS score_order
     FROM all_scores rs
     LEFT OUTER JOIN KIPP_NJ..AUTOLOAD$GDOCS_LIT_proficiency_long prof WITH(NOLOCK)
       ON rs.testid = prof.testid
      AND rs.field = prof.field_name
      AND CASE WHEN rs.testid = 3273 THEN rs.lvl_num ELSE prof.lvl_num END = prof.lvl_num
    ) sub
--CREATE OR REPLACE VIEW KIPP_NWK$STEP_TEST_EVENTS AS
SELECT
      lastfirst || '_' || student_number AS "Student Number"
      ,grade_level AS "Grade Level"
      ,team
      --,read_teacher AS "Guided Reading Teacher"
      -- STEP ROUND NEEDS TO BE MORE DYNAMIC, ANOTHER TABLE TO DEFINE DATES?
      ,CASE
        WHEN test_date LIKE '%AUG%' OR test_date LIKE '%SEP%' THEN 'Diagnostic'
        WHEN test_date LIKE '%OCT%' OR test_date LIKE '%DEC%' THEN 'T1'
        WHEN test_date LIKE '%JAN%' OR test_date LIKE '%MAR%' THEN 'T2'
        WHEN test_date LIKE '%APR%' OR test_date LIKE '%JUN%' THEN 'T3'
      END AS "Step Round"
      ,color AS "Test Type"      
      ,CASE
        WHEN step_level =  'PreDNA' THEN 'Pre_DNA'
        ELSE step_level
      END AS "Step Level"
      ,status
      ,indep_lvl AS "Independent Level"
      ,instruct_lvl AS "Instructional Level"
      
      -- STEP PRE:  NAME ASSOCIATION     
      ,CASE
        --testid 3280, STEP Pre
        WHEN testid = 3280 AND name_ass <  4 THEN 'Below_' || name_ass
        WHEN testid = 3280 AND name_ass >= 4 THEN 'Meets_' || name_ass
      END AS "Pre _ Name"
      
      -- STEP PRE:          PHONICS AWARENESS - RHYMING WORDS
      ,CASE
        --testid 3280, STEP Pre
        WHEN testid = 3280 AND pa_rhymingwds <  6 THEN 'Below_' || pa_rhymingwds
        WHEN testid = 3280 AND pa_rhymingwds >= 6 THEN 'Meets_' || pa_rhymingwds
      END AS "Pre _ Ph. Aw.-Rhyme"
      
      -- STEPS PRE to 01:    CONCEPTS ABOUT PRINT (AGGREGATED)
      ,CASE
        --testid 3280, STEP Pre
        WHEN testid = 3280 AND cp_prof <  6 THEN 'Below_' || cp_prof
        WHEN testid = 3280 AND cp_prof >= 6 THEN 'Meets_' || cp_prof
        
        --testid 3281, STEP 01
        WHEN testid = 3281 AND cp_prof <  10 THEN 'Below_' || cp_prof
        WHEN testid = 3281 AND cp_prof >= 10 THEN 'Meets_' || cp_prof
      END AS "Pre - 1 _ Concepts about Print"
      
      -- STEPS PRE to 02:    LETTER ID - NAME
      ,CASE
        --testid 3280, STEP Pre
        WHEN testid = 3280 AND ltr_nameid <  15 THEN /*'Below_' ||*/ ltr_nameid
        WHEN testid = 3280 AND ltr_nameid >= 15 THEN /*--'Meets_' ||*/ ltr_nameid
        
        --testid 3281, STEP 01
        WHEN testid = 3281 AND ltr_nameid <  35 THEN /*'Below_' ||*/ ltr_nameid
        WHEN testid = 3281 AND ltr_nameid >= 35 THEN /*--'Meets_' ||*/ ltr_nameid
        
        --testid 3282, STEP 02
        WHEN testid = 3282 AND ltr_nameid <  50 THEN /*'Below_' ||*/ ltr_nameid
        WHEN testid = 3282 AND ltr_nameid >= 50 THEN /*--'Meets_' ||*/ ltr_nameid
      END AS "Pre - 2 _ LID Name"
      
      -- STEPS 01 to 03:      LETTER ID - SOUND
      ,CASE
        --testid 3281, STEP 01
        WHEN testid = 3281 AND ltr_soundid <  8 THEN /*'Below_' ||*/ ltr_soundid
        WHEN testid = 3281 AND ltr_soundid >= 8 THEN /*--'Meets_' ||*/ ltr_soundid
        
        --testid 3282, STEP 02
        WHEN testid = 3282 AND ltr_soundid <  18 THEN /*'Below_' ||*/ ltr_soundid
        WHEN testid = 3282 AND ltr_soundid >= 18 THEN /*--'Meets_' ||*/ ltr_soundid
        
        --testid 3380, STEP 03
        WHEN testid = 3380 AND ltr_soundid <  24 THEN /*'Below_' ||*/ ltr_soundid
        WHEN testid = 3380 AND ltr_soundid >= 24 THEN /*--'Meets_' ||*/ ltr_soundid
      END AS "Pre - 3 _ LID Sound"
      
      -- STEP 01:             PHONEMIC AWARENESS - MATCHING FIRST SOUNDS
      ,CASE
        --testid 3281, STEP 01
        WHEN testid = 3281 AND pa_mfs <  6 THEN 'Below_' || pa_mfs
        WHEN testid = 3281 AND pa_mfs >= 6 THEN 'Meets_' || pa_mfs
      END AS "STEP 1 _ PA-1st"
      
      -- STEP 01:             READING RECORD
      ,CASE
        --testid 3281, STEP 01
        WHEN testid = 3281 AND rr_prof <  5 THEN 'Below_' || rr_prof
        WHEN testid = 3281 AND rr_prof >= 5 THEN 'Meets_' || rr_prof
      END AS "STEP 1 _ Reading Record"
      
      -- STEPS 01 to 03:      DEVELOPMENTAL SPELLING (AGGREGATE)
      ,CASE
        --testid 3281, STEP 01
        WHEN testid = 3281 AND devsp_prof1 <  5 THEN 'Below'
        WHEN testid = 3281 AND devsp_prof1 >= 5 THEN 'Meets'
        
        --testid 3282, STEP 02
        WHEN testid = 3282 AND devsp_prof1 <  12 THEN 'Below'
        WHEN testid = 3282 AND devsp_prof1 >= 12 THEN 'Meets'
        
        --testid 3380, STEP 03
        WHEN testid = 3380 AND devsp_prof1 <  18 THEN 'Below'
        WHEN testid = 3380 AND devsp_prof1 >= 18 THEN 'Meets'
      END AS "STEP 1 - 3 _ Dev. Spell"
      
      -- STEP 02:             READING RECORD: BOOK 1 ACCURACY
      ,CASE
        --testid 3282, STEP 02
        WHEN testid = 3282 AND accuracy_1a >= 3 THEN 'Below_Below 90%'
        WHEN testid = 3282 AND accuracy_1a =  2 THEN 'Below_90-94%'
        WHEN testid = 3282 AND accuracy_1a =  1 THEN 'Meets_95-97%'
        WHEN testid = 3282 AND accuracy_1a =  0 THEN 'Meets_98-100%'
      END AS "STEP 2_Reading Record: Bk1 Acc" --MODIFIED, ORIGINAL MORE THAN 30 CHARACTERS
      
      -- STEP 02:             READING RECORD: BOOK 2 ACCURACY
      ,CASE
        --testid 3282, STEP 02
        WHEN testid = 3282 AND accuracy_2b >= 3 THEN 'Below_Below 90%'
        WHEN testid = 3282 AND accuracy_2b =  2 THEN 'Below_90-94%'
        WHEN testid = 3282 AND accuracy_2b =  1 THEN 'Meets_95-97%'
        WHEN testid = 3282 AND accuracy_2b =  0 THEN 'Meets_98-100%'
      END AS "STEP 2_Reading Record: Bk2 Acc" --MODIFIED, ORIGINAL MORE THAN 30 CHARACTERS
      
      -- STEPS 02 to 03:      PHONEMIC AWARENESS: SEGMENTATION
      ,CASE
        --testid 3282, STEP 02 & testid 3380, STEP 03
        WHEN testid IN (3282,3380) AND pa_segmentation <  4 THEN /*'Below_' ||*/ pa_segmentation
        WHEN testid IN (3282,3380) AND pa_segmentation >= 4 THEN /*--'Meets_' ||*/ pa_segmentation
      END AS "STEP 2 - 3 _ PA - seg"
      
      -- STEPS 2 to 3:        COMPREHENSION (AGGREGATED)
      -- DIFFERENT AGGREGATE COMP FIELDS, WE NEED TO FIX THIS FOR V2
      ,CASE
        --testid 3282, STEP 02
        WHEN testid = 3282 AND cc_prof1 <  4 THEN 'Below_' || cc_prof1
        WHEN testid = 3282 AND cc_prof1 >= 4 THEN 'Meets_' || cc_prof1
        
        --testid 3380, STEP 03
        WHEN testid = 3380 AND cc_prof2 <  4 THEN 'Below_' || cc_prof2
        WHEN testid = 3380 AND cc_prof2 >= 4 THEN 'Meets_' || cc_prof2
      END AS "STEP 2 - 3 _ Comprehension"
            
      -- STEPS 03 to 12:      ACCURACY      
      ,CASE
        --testids 3380, 3397, 3411, 3425, 3441, 3458, 3474, 3493, 3511, 3527, STEPS 03 - 12
        WHEN testid IN (3380,3397,3411,3425,3441,3458,3474,3493,3511,3527) AND accuracy = 'Above'   THEN 'Meets_98-100%'
        WHEN testid IN (3380,3397,3411,3425,3441,3458,3474,3493,3511,3527) AND accuracy = 'Target'  THEN 'Meets_95-97%'
        WHEN testid IN (3380,3397,3411,3425,3441,3458,3474,3493,3511,3527) AND accuracy = 'Below'   THEN 'Below_90%'
      END AS "STEP 3 - 12 _ Acurracy"
            
      -- IF FIELD SHOULD BE ra_errors & IF SAME PROFICIENCY LEVELS AS STEP 02...
      /*
      ,CASE
        --testids 3380, 3397, 3411, 3425, 3441, 3458, 3474, 3493, 3511, 3527, STEPS 03 - 12
        WHEN testid IN (3380,3397,3411,3425,3441,3458,3474,3493,3511,3527) AND ra_errors >= 3 THEN 'Below_Below 90%'
        WHEN testid IN (3380,3397,3411,3425,3441,3458,3474,3493,3511,3527) AND ra_errors =  2 THEN 'Below_90-94%'
        WHEN testid IN (3380,3397,3411,3425,3441,3458,3474,3493,3511,3527) AND ra_errors =  1 THEN 'Meets_95-97%'
        WHEN testid IN (3380,3397,3411,3425,3441,3458,3474,3493,3511,3527) AND ra_errors =  0 THEN 'Meets_98-100%'
      END AS "STEP 3 - 12 _ Acurracy"
      */
              
      -- STEPS 04 to 12:      FLUENCY
      ,CASE
        --testids 3397, 3411, 3425, 3441, 3458, 3474, 3493, 3511, 3527, STEPS 04 - 12
        WHEN testid IN (3397,3411,3425,3441,3458,3474,3493,3511,3527) AND fluency <= 3 THEN 'Below_' || fluency
        WHEN testid IN (3397,3411,3425,3441,3458,3474,3493,3511,3527) AND fluency >  3 THEN 'Meets_' || fluency
      END AS "STEP 4 - 12 _ Fluency"
      
       -- STEPS 04 to 05:     COMPREHENSION (AGGREGATED)
      ,CASE
        --testid 3397, STEP 04 & testid 3411, STEP 05
        WHEN testid IN (3397,3411) AND cc_prof2 <  5 THEN 'Below_' || cc_prof2
        WHEN testid IN (3397,3411) AND cc_prof2 >= 5 THEN 'Meets_' || cc_prof2
      END AS "STEP 4 - 5 _ Comprehension"
      
      -- STEPS 4 to 5:        DEVELOPMENTAL SPELLING (AGGREGATED)
      ,CASE
        --testid 3397, STEP 04
        WHEN testid = 3397 AND devsp_prof2 <  8 THEN 'Below'
        WHEN testid = 3397 AND devsp_prof2 >= 8 THEN 'Meets'
        
        --testid 3411, STEP 05
        WHEN testid = 3411 AND devsp_prof2 <  12 THEN 'Below_' || devsp_prof2
        WHEN testid = 3411 AND devsp_prof2 >= 12 THEN 'Meets_' || devsp_prof2
      END AS "STEP 4 - 5 _ Dev. Spell"
            
      -- STEPS 04 to 12:      READING RATE
      ,CASE
        --testids 3397, 3411, 3425, 3441, 3458, 3474, 3493, 3511, 3527, STEPS 04 - 12
        WHEN testid IN (3397,3411,3425,3441,3458,3474,3493,3511,3527) AND reading_rate IN ('Above','Target') THEN 'Meets'
        WHEN testid IN (3397,3411,3425,3441,3458,3474,3493,3511,3527) AND reading_rate = 'Below' THEN 'Below'
      END AS "STEP 4 - 12 _ Rate"

      -- STEPS 06 to 07:      COMPREHENSION
      ,CASE
        --testid 3425, STEP 06
        WHEN testid = 3425 AND ocomp_prof1 >= 3 AND scomp_prof >= 3 THEN 'Meets'
        WHEN testid = 3425 AND ocomp_prof1 >= 3 AND scomp_prof <  3 THEN 'Below_Silent'
        WHEN testid = 3425 AND ocomp_prof1 <  3 AND scomp_prof >= 3 THEN 'Below_Oral'
        WHEN testid = 3425 AND ocomp_prof1 <  3 AND scomp_prof <  3 THEN 'Below_Oral/Silent'
        
        --testid 3441, STEP 07
        WHEN testid = 3441 AND ocomp_prof2 >= 3 AND scomp_prof >= 3 THEN 'Meets'
        WHEN testid = 3441 AND ocomp_prof2 >= 3 AND scomp_prof <  3 THEN 'Below_Silent'
        WHEN testid = 3441 AND ocomp_prof2 <  3 AND scomp_prof >= 3 THEN 'Below_Oral'
        WHEN testid = 3441 AND ocomp_prof2 <  3 AND scomp_prof <  3 THEN 'Below_Oral/Silent'
      END AS "STEP 6 - 7 _ Comprehension"

      -- STEPS 06 to 07:      DEVELOPMENTAL SPELLING
      ,CASE
        --testid 3425, STEP 06
        WHEN testid = 3425 AND devsp_longvp >= 4 AND devsp_rcontv >= 2 THEN 'Meets'
        WHEN testid = 3425 AND devsp_longvp >= 4 AND devsp_rcontv <  2 THEN 'Below'
        WHEN testid = 3425 AND devsp_longvp <  4 AND devsp_rcontv >= 2 THEN 'Below'
        WHEN testid = 3425 AND devsp_longvp <  4 AND devsp_rcontv <  2 THEN 'Below'
                
        --testid 3441, STEP 07
        WHEN testid = 3441 AND devsp_vcelvp >= 2 AND devsp_rcontv >= 2 THEN 'Meets'
        WHEN testid = 3441 AND devsp_vcelvp >= 2 AND devsp_rcontv <  2 THEN 'Below'
        WHEN testid = 3441 AND devsp_vcelvp <  2 AND devsp_rcontv >= 2 THEN 'Below'
        WHEN testid = 3441 AND devsp_vcelvp <  2 AND devsp_rcontv <  2 THEN 'Below'
      END AS "STEP 6 - 7 _ Dev. Spell"
      
      -- STEP 08:             COMPREHENSION
      -- PROFICIENCY FIELD IS AGGREGATED, OUTPUT IS DISAGGREGATED, SOMETHING NEEDS TO BE CHANGED HERE :(
      ,CASE
        --testid 3458, STEP 08
        WHEN testid = 3458 AND cc_prof2 >= 6 THEN 'Meets'
        WHEN testid = 3458 AND cc_prof2 <  6 THEN 'Below_Oral/Written' --CAN'T DIFFERENTIATE BECAUSE FIELD IS AGGREGATED
      END AS "STEP 8  _ Comprehension"
      
      -- STEPS 08 to 12:      RETELLING
      ,CASE
        --testids 3458, 3474, 3493, 3511, 3527, STEPS 08 - 12
        WHEN testid IN (3458,3474,3493,3511,3527) AND retelling >= 3 THEN 'Meets_' || retelling
        WHEN testid IN (3458,3474,3493,3511,3527) AND retelling <  3 THEN 'Below_' || retelling
      END AS "STEP 8 - 12 _ Retell"

      -- STEPS 08 to 10:      DEVELOPMENTAL SPELLING      
      ,CASE
        --testid 3458, STEP 08
        WHEN testid = 3458 AND devsp_cmplxb  >= 2 AND devsp_longvp >= 2 AND devsp_rcontv >= 2 AND devsp_vowldig >= 2 THEN 'Meets'
        WHEN testid = 3458 AND devsp_cmplxb  <  2 THEN 'Below'
        WHEN testid = 3458 AND devsp_longvp  <  2 THEN 'Below'
        WHEN testid = 3458 AND devsp_rcontv  <  2 THEN 'Below' 
        WHEN testid = 3458 AND devsp_vowldig <  2 THEN 'Below'
                
        --testid 3474, STEP 09
        WHEN testid = 3474 AND devsp_cmplxb  >= 3 AND devsp_longvp >= 3 AND devsp_rcontv >= 3 AND devsp_vowldig >= 3 THEN 'Meets'
        WHEN testid = 3474 AND devsp_cmplxb  <  3 THEN 'Below'
        WHEN testid = 3474 AND devsp_longvp  <  3 THEN 'Below'
        WHEN testid = 3474 AND devsp_rcontv  <  3 THEN 'Below' 
        WHEN testid = 3474 AND devsp_vowldig <  3 THEN 'Below'
                
        --testid 3493, STEP 10
        WHEN testid = 3493 AND devsp_cmplxb  >= 4 AND devsp_longvp >= 4 AND devsp_rcontv >= 2 AND devsp_vowldig >= 4 THEN 'Meets'
        WHEN testid = 3493 AND devsp_cmplxb  <  4 THEN 'Below'
        WHEN testid = 3493 AND devsp_longvp  <  4 THEN 'Below'
        WHEN testid = 3493 AND devsp_rcontv  <  2 THEN 'Below' 
        WHEN testid = 3493 AND devsp_vowldig <  4 THEN 'Below'
        
        --all contained testids
        --ELSE 'Below'                
      END AS "STEP 8 - 10 _ Dev. Spell"
      
      -- STEPS 09 to 12:      COMPREHENSION
      ,CASE
        --testid 3474, STEP 09
        WHEN testid = 3474 AND ocomp_prof2 >= 4 AND wcomp_prof1 >= 2 THEN 'Meets'
        WHEN testid = 3474 AND ocomp_prof2 >= 4 AND wcomp_prof1 <  2 THEN 'Below_Written'
        WHEN testid = 3474 AND ocomp_prof2 <  4 AND wcomp_prof1 >= 2 THEN 'Below_Oral'
        WHEN testid = 3474 AND ocomp_prof2 <  4 AND wcomp_prof1 <  2 THEN 'Below_Oral/Written'
        
        --testid 3493, STEP 10 & testid 3511, STEP 11
        WHEN testid = 3493 AND ocomp_prof3 >= 4 AND wcomp_prof2 >= 2 THEN 'Meets'
        WHEN testid = 3493 AND ocomp_prof3 >= 4 AND wcomp_prof2 <  2 THEN 'Below_Written'
        WHEN testid = 3493 AND ocomp_prof3 <  4 AND wcomp_prof2 >= 2 THEN 'Below_Oral'
        WHEN testid = 3493 AND ocomp_prof3 <  4 AND wcomp_prof2 <  2 THEN 'Below_Oral/Written'
        
        --testid 3527, STEP 12
        WHEN testid = 3527 AND ocomp_prof2 >= 4 AND wcomp_prof2 >= 2 THEN 'Meets'
        WHEN testid = 3527 AND ocomp_prof2 >= 4 AND wcomp_prof2 <  2 THEN 'Below_Written'
        WHEN testid = 3527 AND ocomp_prof2 <  4 AND wcomp_prof2 >= 2 THEN 'Below_Oral'
        WHEN testid = 3527 AND ocomp_prof2 <  4 AND wcomp_prof2 <  2 THEN 'Below_Oral/Written'
      END AS "STEP 9 - 12 _ Comprehension"

      -- STEPS 11 to 12:      DEVELOPMENTAL SPELLING
      ,CASE
        --testid 3511, STEP 11
        WHEN testid = 3511 AND devsp_doubsylj >= 2 AND devsp_eding >= 2 AND devsp_longv2sw >= 1 AND devsp_rcont2sw >= 1 THEN 'Meets'
        WHEN testid = 3458 AND devsp_doubsylj < 2 THEN 'Below'
        WHEN testid = 3458 AND devsp_eding < 2 THEN 'Below'
        WHEN testid = 3458 AND devsp_longv2sw < 1 THEN 'Below'
        WHEN testid = 3458 AND devsp_rcont2sw < 1 THEN 'Below'
                
        --testid 3527, STEP 12
        WHEN testid = 3527 AND devsp_doubsylj >= 3 AND devsp_eding >= 4 AND devsp_longv2sw >= 2 AND devsp_rcont2sw >= 2 THEN 'Meets'
        WHEN testid = 3474 AND devsp_doubsylj < 3 THEN 'Below'
        WHEN testid = 3474 AND devsp_eding < 4 THEN 'Below'
        WHEN testid = 3474 AND devsp_longv2sw < 2 THEN 'Below'
        WHEN testid = 3474 AND devsp_rcont2sw < 2 THEN 'Below'
        
        --all contained testids
        --ELSE 'Below'
      END AS "STEP 11 - 12 _ Dev. Spell"
      
      -- FOR UNION ALL
      ,NULL AS "FP_L-Z_Rate"
      ,NULL AS "FP_L-Z_Fluency"
      ,NULL AS "FP_L-Z_Accuracy"      
      ,NULL AS "FP_L-Z_Comprehension"

FROM
     (SELECT studentid
            ,lastfirst
            ,student_number
            ,grade_level
            ,team
            ,test_date
            ,step_level
            ,testid
            ,status
            ,read_teacher
            ,accuracy
            ,accuracy_1a
            ,accuracy_2b
            ,cc_ct
            ,cc_factual
            ,cc_infer
            ,cc_other
            ,color
            ,cp_121match
            ,cp_orient
            ,cp_slw
            ,devsp_final
            ,devsp_first
            ,devsp_ifbd
            ,devsp_svs
            ,indep_lvl
            ,instruct_lvl
            ,ocomp_ct
            ,ocomp_factual
            ,ocomp_infer
            ,ra_errors
            ,reading_rate
            ,rr_121match
            ,rr_holdspattern
            ,rr_understanding
            ,scomp_ct
            ,scomp_factual
            ,scomp_infer
            ,wcomp_ct
            ,wcomp_fact
            ,wcomp_infer
            ,devsp_cmplxb
            ,devsp_doubsylj
            ,devsp_eding
            ,devsp_longv2sw
            ,devsp_longvp
            ,devsp_rcont2sw
            ,devsp_rcontv
            ,devsp_vcelvp
            ,devsp_vowldig
            ,fluency
            ,ltr_nameid
            ,ltr_soundid
            ,name_ass
            ,pa_mfs
            ,pa_rhymingwds
            ,pa_segmentation
            ,retelling
            ,total_vwlattmpt            
            ,cc_factual + cc_other + cc_infer AS cc_prof1                 --proficiency critera for STEP(s) 2
            ,cc_factual + cc_infer + cc_ct AS cc_prof2                    --proficiency critera for STEP(s) 3-5,8
            ,cp_orient + cp_121match + cp_slw AS cp_prof                  --proficiency critera for STEP(s) Pre-1
            ,devsp_first + devsp_svs + devsp_final AS devsp_prof1         --proficiency critera for STEP(s) 1-3
            ,devsp_svs + devsp_ifbd AS devsp_prof2                        --proficiency critera for STEP(s) 4-5
            ,ocomp_factual + ocomp_ct AS ocomp_prof1                      --proficiency critera for STEP(s) 6
            ,ocomp_factual + ocomp_ct + ocomp_infer AS ocomp_prof2        --proficiency critera for STEP(s) 7,9,12
            ,ocomp_ct + ocomp_infer AS ocomp_prof3                        --proficiency critera for STEP(s) 10-11
            ,rr_121match + rr_holdspattern + rr_understanding AS rr_prof  --proficiency critera for STEP(s) 1
            ,scomp_factual + scomp_infer + scomp_ct AS scomp_prof         --proficiency critera for STEP(s) 6-7
            ,wcomp_fact + wcomp_infer AS wcomp_prof1                      --proficiency critera for STEP(s) 9
            ,wcomp_fact + wcomp_infer + wcomp_ct AS wcomp_prof2           --proficiency critera for STEP(s) 10-12
      FROM           
           (SELECT s.id AS studentid                                    
                  ,s.lastfirst
                  ,s.student_number
                  ,s.grade_level
                  ,s.team
                  ,user_defined_date AS test_date
                  ,user_defined_text AS step_level
                  ,foreignkey_alpha AS testid
                  ,user_defined_text2 AS status
                  ,PS_CUSTOMFIELDS.GETCF('readingScores',scores.unique_id,'Field1')  AS color
                  ,PS_CUSTOMFIELDS.GETCF('readingScores',scores.unique_id,'Field2')  AS instruct_lvl
                  ,PS_CUSTOMFIELDS.GETCF('readingScores',scores.unique_id,'Field3')  AS indep_lvl
                  ,PS_CUSTOMFIELDS.GETCF('readingScores',scores.unique_id,'Field4')  AS name_ass
                  ,PS_CUSTOMFIELDS.GETCF('readingScores',scores.unique_id,'Field5')  AS ltr_nameid
                  ,PS_CUSTOMFIELDS.GETCF('readingScores',scores.unique_id,'Field6')  AS ltr_soundid
                  ,PS_CUSTOMFIELDS.GETCF('readingScores',scores.unique_id,'Field7')  AS pa_rhymingwds
                  ,PS_CUSTOMFIELDS.GETCF('readingScores',scores.unique_id,'Field8')  AS cp_orient
                  ,PS_CUSTOMFIELDS.GETCF('readingScores',scores.unique_id,'Field9')  AS cp_121match
                  ,PS_CUSTOMFIELDS.GETCF('readingScores',scores.unique_id,'Field10') AS cp_slw
                  ,PS_CUSTOMFIELDS.GETCF('readingScores',scores.unique_id,'Field11') AS pa_mfs
                  ,PS_CUSTOMFIELDS.GETCF('readingScores',scores.unique_id,'Field12') AS devsp_first
                  ,PS_CUSTOMFIELDS.GETCF('readingScores',scores.unique_id,'Field13') AS devsp_svs
                  ,PS_CUSTOMFIELDS.GETCF('readingScores',scores.unique_id,'Field14') AS devsp_final
                  ,PS_CUSTOMFIELDS.GETCF('readingScores',scores.unique_id,'Field15') AS rr_121match
                  ,PS_CUSTOMFIELDS.GETCF('readingScores',scores.unique_id,'Field16') AS rr_holdspattern
                  ,PS_CUSTOMFIELDS.GETCF('readingScores',scores.unique_id,'Field17') AS rr_understanding
                  ,PS_CUSTOMFIELDS.GETCF('readingScores',scores.unique_id,'Field18') AS pa_segmentation
                  ,PS_CUSTOMFIELDS.GETCF('readingScores',scores.unique_id,'Field19') AS accuracy_1a
                  ,PS_CUSTOMFIELDS.GETCF('readingScores',scores.unique_id,'Field20') AS accuracy_2b
                  ,PS_CUSTOMFIELDS.GETCF('readingScores',scores.unique_id,'Field21') AS read_teacher
                  ,PS_CUSTOMFIELDS.GETCF('readingScores',scores.unique_id,'Field22') AS cc_factual
                  ,PS_CUSTOMFIELDS.GETCF('readingScores',scores.unique_id,'Field23') AS cc_infer
                  ,PS_CUSTOMFIELDS.GETCF('readingScores',scores.unique_id,'Field24') AS cc_other
                  ,PS_CUSTOMFIELDS.GETCF('readingScores',scores.unique_id,'Field25') AS accuracy
                  ,PS_CUSTOMFIELDS.GETCF('readingScores',scores.unique_id,'Field26') AS cc_ct
                  ,PS_CUSTOMFIELDS.GETCF('readingScores',scores.unique_id,'Field27') AS total_vwlattmpt
                  ,PS_CUSTOMFIELDS.GETCF('readingScores',scores.unique_id,'Field28') AS ra_errors
                  ,PS_CUSTOMFIELDS.GETCF('readingScores',scores.unique_id,'Field29') AS reading_rate
                  ,PS_CUSTOMFIELDS.GETCF('readingScores',scores.unique_id,'Field30') AS fluency
                  ,PS_CUSTOMFIELDS.GETCF('readingScores',scores.unique_id,'Field31') AS devsp_ifbd
                  ,PS_CUSTOMFIELDS.GETCF('readingScores',scores.unique_id,'Field32') AS ocomp_factual
                  ,PS_CUSTOMFIELDS.GETCF('readingScores',scores.unique_id,'Field33') AS ocomp_ct
                  ,PS_CUSTOMFIELDS.GETCF('readingScores',scores.unique_id,'Field34') AS scomp_factual
                  ,PS_CUSTOMFIELDS.GETCF('readingScores',scores.unique_id,'Field35') AS scomp_infer
                  ,PS_CUSTOMFIELDS.GETCF('readingScores',scores.unique_id,'Field36') AS scomp_ct
                  ,PS_CUSTOMFIELDS.GETCF('readingScores',scores.unique_id,'Field37') AS devsp_longvp
                  ,PS_CUSTOMFIELDS.GETCF('readingScores',scores.unique_id,'Field38') AS devsp_rcontv
                  ,PS_CUSTOMFIELDS.GETCF('readingScores',scores.unique_id,'Field39') AS ocomp_infer
                  ,PS_CUSTOMFIELDS.GETCF('readingScores',scores.unique_id,'Field40') AS devsp_vcelvp
                  ,PS_CUSTOMFIELDS.GETCF('readingScores',scores.unique_id,'Field41') AS devsp_vowldig
                  ,PS_CUSTOMFIELDS.GETCF('readingScores',scores.unique_id,'Field42') AS devsp_cmplxb
                  ,PS_CUSTOMFIELDS.GETCF('readingScores',scores.unique_id,'Field43') AS wcomp_fact
                  ,PS_CUSTOMFIELDS.GETCF('readingScores',scores.unique_id,'Field44') AS wcomp_infer
                  ,PS_CUSTOMFIELDS.GETCF('readingScores',scores.unique_id,'Field45') AS retelling
                  ,PS_CUSTOMFIELDS.GETCF('readingScores',scores.unique_id,'Field46') AS wcomp_ct
                  ,PS_CUSTOMFIELDS.GETCF('readingScores',scores.unique_id,'Field47') AS devsp_eding
                  ,PS_CUSTOMFIELDS.GETCF('readingScores',scores.unique_id,'Field48') AS devsp_doubsylj
                  ,PS_CUSTOMFIELDS.GETCF('readingScores',scores.unique_id,'Field49') AS devsp_longv2sw
                  ,PS_CUSTOMFIELDS.GETCF('readingScores',scores.unique_id,'Field50') AS devsp_rcont2sw
            FROM virtualtablesdata3 scores
            JOIN students s ON s.id = scores.foreignKey 
             AND s.id = 3904
            WHERE scores.related_to_table = 'readingScores' 
              AND user_defined_text IS NOT NULL
              AND foreignkey_alpha > 3273 
            ORDER BY scores.schoolid
                    ,s.grade_level
                    ,s.team
                    ,s.lastfirst
                    ,scores.user_defined_date DESC
            ) sub_1
      ) sub_2
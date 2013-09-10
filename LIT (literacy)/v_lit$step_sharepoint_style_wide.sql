USE KIPP_NJ
GO

ALTER VIEW LIT$tracker_sharepoint_style_wide AS

SELECT sub_2.schoolid
	  ,sub_2.lastfirst + '_' + sub_2.student_number AS "Student Number"
      ,grade_level AS "Grade Level"
      ,s.TEAM
      --,read_teacher AS "Guided Reading Teacher"
      ,test_date AS "Step Round"          
      ,color AS "Test Type" 
      ,CASE
        WHEN step_level IN ('PreDNA','Pre DNA') THEN 'Pre_DNA'
        WHEN step_level = 'Pre' AND status = 'Did Not Achieve' THEN 'Pre_DNA'
        ELSE step_level
      END AS "Step Level"
      ,CASE
		WHEN STEP_LEVEL = 'Pre' THEN 'Achieved'
		ELSE STATUS
	  END AS status
      ,indep_lvl AS "Independent Level"
      ,instruct_lvl AS "Instructional Level"

      -- STEP PRE:  NAME ASSOCIATION     
      ,CASE
        --testid 3280, STEP Pre
        WHEN testid = 3280 AND name_ass <  4 THEN 'Below_' + CAST(name_ass AS VARCHAR(20))
        WHEN testid = 3280 AND name_ass >= 4 THEN 'Meets_' + CAST(name_ass AS VARCHAR(20))
      END AS "Pre _ Name"
      
      -- STEP PRE:          PHONICS AWARENESS - RHYMING WORDS
      ,CASE
        --testid 3280, STEP Pre
        WHEN testid = 3280 AND pa_rhymingwds <  6 THEN 'Below_' + CAST(pa_rhymingwds AS VARCHAR(20))
        WHEN testid = 3280 AND pa_rhymingwds >= 6 THEN 'Meets_' + CAST(pa_rhymingwds AS VARCHAR(20))
      END AS "Pre _ Ph. Aw.-Rhyme"

      -- STEPS PRE to 01:    CONCEPTS ABOUT PRINT (AGGREGATED)
      ,CASE
        --testid 3280, STEP Pre
        WHEN testid = 3280 AND cp_prof <  6 THEN 'Below_' + CAST(cp_prof AS VARCHAR(20))
        WHEN testid = 3280 AND cp_prof >= 6 THEN 'Meets_' + CAST(cp_prof AS VARCHAR(20))
        
        --testid 3281, STEP 01
        WHEN testid = 3281 AND cp_prof <  10 THEN 'Below_' + CAST(cp_prof AS VARCHAR(20))
        WHEN testid = 3281 AND cp_prof >= 10 THEN 'Meets_' + CAST(cp_prof AS VARCHAR(20))
      END AS "Pre - 1 _ Concepts about Print"
      
      -- STEPS PRE to 02:    LETTER ID - NAME
      ,CASE
        --testid 3280, STEP Pre
        WHEN testid = 3280 AND ltr_nameid <  15 THEN /*'Below_' +*/ ltr_nameid
        WHEN testid = 3280 AND ltr_nameid >= 15 THEN /*--'Meets_' +*/ ltr_nameid
        
        --testid 3281, STEP 01
        WHEN testid = 3281 AND ltr_nameid <  35 THEN /*'Below_' +*/ ltr_nameid
        WHEN testid = 3281 AND ltr_nameid >= 35 THEN /*--'Meets_' +*/ ltr_nameid
        
        --testid 3282, STEP 02
        WHEN testid = 3282 AND ltr_nameid <  50 THEN /*'Below_' +*/ ltr_nameid
        WHEN testid = 3282 AND ltr_nameid >= 50 THEN /*--'Meets_' +*/ ltr_nameid
      END AS "Pre - 2 _ LID Name"
      
      -- STEPS 01 to 03:      LETTER ID - SOUND
      ,CASE
        --testid 3281, STEP 01
        WHEN testid = 3281 AND ltr_soundid <  8 THEN /*'Below_' +*/ ltr_soundid
        WHEN testid = 3281 AND ltr_soundid >= 8 THEN /*--'Meets_' +*/ ltr_soundid
        
        --testid 3282, STEP 02
        WHEN testid = 3282 AND ltr_soundid <  18 THEN /*'Below_' +*/ ltr_soundid
        WHEN testid = 3282 AND ltr_soundid >= 18 THEN /*--'Meets_' +*/ ltr_soundid
        
        --testid 3380, STEP 03
        WHEN testid = 3380 AND ltr_soundid <  24 THEN /*'Below_' +*/ ltr_soundid
        WHEN testid = 3380 AND ltr_soundid >= 24 THEN /*--'Meets_' +*/ ltr_soundid
      END AS "Pre - 3 _ LID Sound"

      -- STEP 01:             PHONEMIC AWARENESS - MATCHING FIRST SOUNDS
      ,CASE
        --testid 3281, STEP 01
        WHEN testid = 3281 AND pa_mfs <  6 THEN 'Below_' + CAST(pa_mfs AS VARCHAR(20))
        WHEN testid = 3281 AND pa_mfs >= 6 THEN 'Meets_' + CAST(pa_mfs AS VARCHAR(20))
      END AS "STEP 1 _ PA-1st"
      
      -- STEP 01:             READING RECORD
      ,CASE
        --testid 3281, STEP 01
        WHEN testid = 3281 AND rr_prof <  5 THEN 'Below_' + CAST(rr_prof AS VARCHAR(20))
        WHEN testid = 3281 AND rr_prof >= 5 THEN 'Meets_' + CAST(rr_prof AS VARCHAR(20))
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
        WHEN testid IN (3282,3380) AND pa_segmentation <  4 THEN /*'Below_' +*/ pa_segmentation
        WHEN testid IN (3282,3380) AND pa_segmentation >= 4 THEN /*--'Meets_' +*/ pa_segmentation
      END AS "STEP 2 - 3 _ PA - seg"
      
      -- STEPS 2 to 3:        COMPREHENSION (AGGREGATED)
      -- DIFFERENT AGGREGATE COMP FIELDS, WE NEED TO FIX THIS FOR V2
      ,CASE
        --testid 3282, STEP 02
        WHEN testid = 3282 AND cc_prof1 <  4 THEN 'Below_' + CAST(cc_prof1 AS VARCHAR(20))
        WHEN testid = 3282 AND cc_prof1 >= 4 THEN 'Meets_' + CAST(cc_prof1 AS VARCHAR(20))
        
        --testid 3380, STEP 03
        WHEN testid = 3380 AND cc_prof2 <  4 THEN 'Below_' + CAST(cc_prof2 AS VARCHAR(20))
        WHEN testid = 3380 AND cc_prof2 >= 4 THEN 'Meets_' + CAST(cc_prof2 AS VARCHAR(20))
      END AS "STEP 2 - 3 _ Comprehension"

      -- STEPS 03 to 12:      ACCURACY      
      ,CASE
        --testids 3380, 3397, 3411, 3425, 3441, 3458, 3474, 3493, 3511, 3527, STEPS 03 - 12
        WHEN testid IN (3380,3397,3411,3425,3441,3458,3474,3493,3511,3527) AND accuracy = 'Above'   THEN 'Meets_98-100%'
        WHEN testid IN (3380,3397,3411,3425,3441,3458,3474,3493,3511,3527) AND accuracy = 'Target'  THEN 'Meets_95-97%'
        WHEN testid IN (3380,3397,3411,3425,3441,3458,3474,3493,3511,3527) AND accuracy = 'Below'   THEN 'Below_90%'
      END AS "STEP 3 - 12 _ Acurracy"
            
      /*
      -- IF FIELD SHOULD BE ra_errors & IF SAME PROFICIENCY LEVELS AS STEP 02...
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
        WHEN testid IN (3397,3411,3425,3441,3458,3474,3493,3511,3527) AND fluency <= 3 THEN 'Below_' + CAST(fluency AS VARCHAR(20))
        WHEN testid IN (3397,3411,3425,3441,3458,3474,3493,3511,3527) AND fluency >  3 THEN 'Meets_' + CAST(fluency AS VARCHAR(20))
      END AS "STEP 4 - 12 _ Fluency"
      
       -- STEPS 04 to 05:     COMPREHENSION (AGGREGATED)
      ,CASE
        --testid 3397, STEP 04 & testid 3411, STEP 05
        WHEN testid IN (3397,3411) AND cc_prof2 <  5 THEN 'Below_' + CAST(cc_prof2 AS VARCHAR(20))
        WHEN testid IN (3397,3411) AND cc_prof2 >= 5 THEN 'Meets_' + CAST(cc_prof2 AS VARCHAR(20))
      END AS "STEP 4 - 5 _ Comprehension"

      -- STEPS 4 to 5:        DEVELOPMENTAL SPELLING (AGGREGATED)
      ,CASE
        --testid 3397, STEP 04
        WHEN testid = 3397 AND devsp_prof2 <  8 THEN 'Below'
        WHEN testid = 3397 AND devsp_prof2 >= 8 THEN 'Meets'
        
        --testid 3411, STEP 05
        WHEN testid = 3411 AND devsp_prof2 <  12 THEN 'Below'
        WHEN testid = 3411 AND devsp_prof2 >= 12 THEN 'Meets'
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
      -- PROFICIENCY FIELD IS AGGREGATED, OUTPUT IS DISAGGREGATED, SOMETHING NEEDS TO BE CHANGED MOVING FORWARD
      ,CASE
        --testid 3458, STEP 08
        WHEN testid = 3458 AND cc_prof2 >= 6 THEN 'Meets'
        WHEN testid = 3458 AND cc_prof2 <  6 THEN 'Below_Oral/Written' --CAN'T DIFFERENTIATE BECAUSE FIELD IS AGGREGATED
      END AS "STEP 8  _ Comprehension"

      -- STEPS 08 to 12:      RETELLING
      ,CASE
        --testids 3458, 3474, 3493, 3511, 3527, STEPS 08 - 12
        WHEN testid IN (3458,3474,3493,3511,3527) AND retelling >= 3 THEN 'Meets_' + CAST(retelling AS VARCHAR(20))
        WHEN testid IN (3458,3474,3493,3511,3527) AND retelling <  3 THEN 'Below_' + CAST(retelling AS VARCHAR(20))
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
      END AS "STEP 8 - 10 _ Dev. Spell"
      
      -- STEPS 09 to 12:      COMPREHENSION
      ,CASE
        --testid 3474, STEP 09
        WHEN testid = 3474 AND ocomp_prof2 >= 4 AND wcomp_prof >= 2 THEN 'Meets'
        WHEN testid = 3474 AND ocomp_prof2 >= 4 AND wcomp_prof <  2 THEN 'Below_Written'
        WHEN testid = 3474 AND ocomp_prof2 <  4 AND wcomp_prof >= 2 THEN 'Below_Oral'
        WHEN testid = 3474 AND ocomp_prof2 <  4 AND wcomp_prof <  2 THEN 'Below_Oral/Written'
        
        --testid 3493, STEP 10 & testid 3511, STEP 11
        WHEN testid = 3493 AND ocomp_prof2 >= 4 AND wcomp_prof >= 2 THEN 'Meets'
        WHEN testid = 3493 AND ocomp_prof2 >= 4 AND wcomp_prof <  2 THEN 'Below_Written'
        WHEN testid = 3493 AND ocomp_prof2 <  4 AND wcomp_prof >= 2 THEN 'Below_Oral'
        WHEN testid = 3493 AND ocomp_prof2 <  4 AND wcomp_prof <  2 THEN 'Below_Oral/Written'
        
        --testid 3527, STEP 12
        WHEN testid = 3527 AND ocomp_prof2 >= 4 AND wcomp_prof >= 2 THEN 'Meets'
        WHEN testid = 3527 AND ocomp_prof2 >= 4 AND wcomp_prof <  2 THEN 'Below_Written'
        WHEN testid = 3527 AND ocomp_prof2 <  4 AND wcomp_prof >= 2 THEN 'Below_Oral'
        WHEN testid = 3527 AND ocomp_prof2 <  4 AND wcomp_prof <  2 THEN 'Below_Oral/Written'
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
                
      END AS "STEP 11 - 12 _ Dev. Spell"
      
      -- NULL COLUMNS FOR UNION ALL WITH F&P DATA
      ,NULL AS "FP_L-Z_Accuracy"
      ,NULL AS "FP_L-Z_Rate"
      ,NULL AS "FP_L-Z_Fluency"            
      ,NULL AS "FP_L-Z_Comprehension"
FROM
     (SELECT schoolid
			,studentid
            ,lastfirst
            ,student_number            
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
            ,SUM(cc_factual + cc_other + cc_infer) AS cc_prof1                 --proficiency critera for STEP(s) 2
            ,SUM(cc_factual + cc_infer + cc_ct) AS cc_prof2                    --proficiency critera for STEP(s) 3-5,8
            ,SUM(cp_orient + cp_121match + cp_slw) AS cp_prof                  --proficiency critera for STEP(s) Pre-1
            ,SUM(devsp_first + devsp_svs + devsp_final) AS devsp_prof1         --proficiency critera for STEP(s) 1-3
            ,SUM(devsp_svs + devsp_ifbd) AS devsp_prof2                        --proficiency critera for STEP(s) 4-5
            ,SUM(ocomp_factual + ocomp_ct) AS ocomp_prof1                      --proficiency critera for STEP(s) 6
            ,SUM(ocomp_ct + ocomp_infer + ocomp_factual) AS ocomp_prof2        --proficiency critera for STEP(s) 7,9-12
            ,SUM(rr_121match + rr_holdspattern + rr_understanding) AS rr_prof  --proficiency critera for STEP(s) 1
            ,SUM(scomp_factual + scomp_infer + scomp_ct) AS scomp_prof         --proficiency critera for STEP(s) 6-7
            ,SUM(wcomp_fact + wcomp_infer + wcomp_ct) AS wcomp_prof            --proficiency critera for STEP(s) 9-12
      FROM           
           (SELECT step.*				  
			FROM LIT$step_test_events_long#identifiers step						
			) sub_1
	  GROUP BY schoolid, studentid, lastfirst, student_number, test_date, step_level, testid, status, read_teacher
			  ,accuracy, accuracy_1a, accuracy_2b, cc_ct, cc_factual, cc_infer, cc_other, color, cp_121match
			  ,cp_orient, cp_slw, devsp_final, devsp_first, devsp_ifbd, devsp_svs, indep_lvl, instruct_lvl
			  ,ocomp_ct, ocomp_factual, ocomp_infer, ra_errors, reading_rate, rr_121match, rr_holdspattern
              ,rr_understanding, scomp_ct, scomp_factual, scomp_infer, wcomp_ct, wcomp_fact, wcomp_infer
              ,devsp_cmplxb, devsp_doubsylj, devsp_eding, devsp_longv2sw, devsp_longvp, devsp_rcont2sw         ,devsp_rcontv
              ,devsp_vcelvp, devsp_vowldig, fluency, ltr_nameid, ltr_soundid, name_ass, pa_mfs, pa_rhymingwds
              ,pa_segmentation, retelling, total_vwlattmpt
) sub_2
JOIN students s
  ON s.id = studentid
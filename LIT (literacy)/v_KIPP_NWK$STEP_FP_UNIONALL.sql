SELECT *
FROM PS.KIPP_NWK$STEP_TEST_EVENTS

UNION ALL

-- F&P DATA
SELECT 
      lastfirst || '_' || student_number AS "Student Number"
      ,grade_level AS "Grade Level"
      ,team
      --,read_teacher AS "Guided Reading Teacher"      
      ,CASE
        WHEN test_date LIKE '%AUG%' OR test_date LIKE '%SEP%' THEN 'Diagnostic'
        WHEN test_date LIKE '%OCT%' OR test_date LIKE '%DEC%' THEN 'T1'
        WHEN test_date LIKE '%JAN%' OR test_date LIKE '%MAR%' THEN 'T2'
        WHEN test_date LIKE '%APR%' OR test_date LIKE '%JUN%' THEN 'T3'
      END AS "Step Round"
      ,NULL AS "Test Type"      
      ,CASE
        WHEN step_level =  'Pre DNA' THEN 'Pre_DNA'
        ELSE step_level
      END AS "Step Level"
      ,status
      ,NULL AS "Independent Level"
      ,NULL AS "Instructional Level"
      ,NULL AS "Pre _ Name"
      ,NULL AS "Pre _ Ph. Aw.-Rhyme"
      ,NULL AS "Pre - 1 _ Concepts about Print"
      ,NULL AS "Pre - 2 _ LID Name"
      ,NULL AS "Pre - 3 _ LID Sound"
      ,NULL AS "STEP 1 _ PA-1st"
      ,NULL AS "STEP 1 _ Reading Record"
      ,NULL AS "STEP 1 - 3 _ Dev. Spell"
      ,NULL AS "STEP 2_Reading Record: Bk1 Acc"
      ,NULL AS "STEP 2_Reading Record: Bk2 Acc"
      ,NULL AS "STEP 2 - 3 _ PA - seg"
      ,NULL AS "STEP 2 - 3 _ Comprehension"
      ,NULL AS "STEP 3 - 12 _ Acurracy"
      ,NULL AS "STEP 4 - 12 _ Fluency"
      ,NULL AS "STEP 4 - 5 _ Comprehension"
      ,NULL AS "STEP 4 - 5 _ Dev. Spell"
      ,NULL AS "STEP 4 - 12 _ Rate"
      ,NULL AS "STEP 6 - 7 _ Comprehension"
      ,NULL AS "STEP 6 - 7 _ Dev. Spell"
      ,NULL AS "STEP 8  _ Comprehension"
      ,NULL AS "STEP 8 - 12 _ Retell"
      ,NULL AS "STEP 8 - 10 _ Dev. Spell"
      ,NULL AS "STEP 9 - 12 _ Comprehension"
      ,NULL AS "STEP 11 - 12 _ Dev. Spell"
      ,fp_accuracy AS "FP_L-Z_Accuracy"
      ,fp_wpmrate AS "FP_L-Z_Rate"
      ,fp_fluency AS "FP_L-Z_Fluency"
      ,fp_comp_within + fp_comp_beyond + fp_comp_about AS "FP_L-Z_Comprehension"
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
            ,PS_CUSTOMFIELDS.GETCF('readingScores',scores.unique_id,'Field1')  AS fp_wpmrate                  
            ,PS_CUSTOMFIELDS.GETCF('readingScores',scores.unique_id,'Field2')  AS fp_fluency
            ,PS_CUSTOMFIELDS.GETCF('readingScores',scores.unique_id,'Field3')  AS fp_accuracy
            ,PS_CUSTOMFIELDS.GETCF('readingScores',scores.unique_id,'Field4')  AS fp_comp_within
            ,PS_CUSTOMFIELDS.GETCF('readingScores',scores.unique_id,'Field5')  AS fp_comp_beyond
            ,PS_CUSTOMFIELDS.GETCF('readingScores',scores.unique_id,'Field6')  AS fp_comp_about
            ,PS_CUSTOMFIELDS.GETCF('readingScores',scores.unique_id,'Field7')  AS fp_keylever
      FROM virtualtablesdata3 scores
      JOIN students s on s.id = scores.foreignKey 
      WHERE scores.related_to_table = 'readingScores' 
        AND user_defined_text is not null 
        AND foreignkey_alpha = '3273'
        AND s.id = 3904
        --AND scores.schoolid = 73252
        --AND scores.user_defined_date LIKE '%AUG-13'
      ) sub_1    

;


SELECT "Student Number"
      ,"Grade Level"
      ,Team
      ,"Step Round"
FROM PS.KIPP_NWK$STEP_TEST_EVENTS

UNION ALL

SELECT NULL
      ,NULL
      ,NULL
      ,NULL
FROM DUAL

SELECT NULL AS "Student Number"
      ,NULL AS "Grade Level"
FROM DUAL
;



;
  ORDER BY scores.schoolid
          ,s.grade_level
          ,s.team
          ,s.lastfirst
          ,scores.user_defined_date DESC
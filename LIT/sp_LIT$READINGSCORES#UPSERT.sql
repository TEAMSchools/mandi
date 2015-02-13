USE KIPP_NJ
GO

ALTER PROCEDURE sp_LIT$READINGSCORES#UPSERT AS

BEGIN

  WITH rs_update AS (
    SELECT UNIQUE_ID
          ,STUDENTID
          ,SCHOOLID
          ,TEST_DATE
          ,TESTID
          ,STEP_LTR_LEVEL
          ,STATUS
          ,ACADEMIC_YEAR
          ,TEST_ROUND
          ,COLOR
          ,INSTRUCT_LVL
          ,INDEP_LVL
          ,GENRE
          ,NAME_ASS
          ,LTR_NAMEID
          ,LTR_SOUNDID
          ,PA_RHYMINGWDS
          ,PA_MFS
          ,PA_SEGMENTATION
          ,CP_ORIENT
          ,CP_121MATCH
          ,CP_SLW
          ,DEVSP_FIRST
          ,DEVSP_SVS
          ,DEVSP_FINAL
          ,DEVSP_IFBD
          ,DEVSP_LONGVOWEL
          ,DEVSP_RCONTROL
          ,DEVSP_VOWLDIG
          ,DEVSP_CMPLXB
          ,DEVSP_EDING
          ,DEVSP_DOUBSYLJ
          ,RR_121MATCH
          ,RR_HOLDSPATTERN
          ,RR_UNDERSTANDING
          ,ACCURACY_1A
          ,ACCURACY_2B
          ,RA_ERRORS
          ,CC_FACTUAL
          ,CC_INFER
          ,CC_OTHER
          ,CC_CT
          ,OCOMP_FACTUAL
          ,OCOMP_CT
          ,OCOMP_INFER
          ,SCOMP_FACTUAL
          ,SCOMP_INFER
          ,SCOMP_CT
          ,WCOMP_FACT
          ,WCOMP_INFER
          ,WCOMP_CT
          ,RETELLING
          ,READING_RATE
          ,FLUENCY
          ,FP_WPMRATE
          ,FP_FLUENCY
          ,FP_ACCURACY
          ,FP_COMP_WITHIN
          ,FP_COMP_BEYOND
          ,FP_COMP_ABOUT
          ,FP_KEYLEVER
    FROM OPENQUERY(PS_TEAM,'
    SELECT unique_id
          ,foreignKey AS studentid
          ,schoolid
          ,user_defined_date AS test_date
          ,foreignkey_alpha AS testid
          ,user_defined_text AS step_ltr_level            
          ,user_defined_text2 AS status
          ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field50'') AS academic_year
          ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field49'') AS test_round
          ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field1'') AS color
          ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field2'') AS instruct_lvl
          ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field3'') AS indep_lvl
          ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field21'') AS genre
          ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field4'') AS name_ass
          ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field5'') AS ltr_nameid
          ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field6'') AS ltr_soundid
          ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field7'') AS pa_rhymingwds
          ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field11'') AS pa_mfs
          ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field18'') AS pa_segmentation
          ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field8'') AS cp_orient
          ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field9'') AS cp_121match
          ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field10'') AS cp_slw
          ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field12'') AS devsp_first
          ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field13'') AS devsp_svs
          ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field14'') AS devsp_final
          ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field31'') AS devsp_ifbd
          ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field37'') AS devsp_longvowel
          ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field38'') AS devsp_rcontrol   
          ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field41'') AS devsp_vowldig
          ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field42'') AS devsp_cmplxb
          ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field47'') AS devsp_eding
          ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field48'') AS devsp_doubsylj      
          ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field15'') AS rr_121match
          ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field16'') AS rr_holdspattern
          ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field17'') AS rr_understanding      
          ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field19'') AS accuracy_1a
          ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field20'') AS accuracy_2b
          ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field28'') AS ra_errors
          ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field22'') AS cc_factual
          ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field23'') AS cc_infer
          ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field24'') AS cc_other
          ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field26'') AS cc_ct
          ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field32'') AS ocomp_factual
          ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field33'') AS ocomp_ct
          ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field39'') AS ocomp_infer
          ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field34'') AS scomp_factual
          ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field35'') AS scomp_infer
          ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field36'') AS scomp_ct
          ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field43'') AS wcomp_fact
          ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field44'') AS wcomp_infer
          ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field46'') AS wcomp_ct
          ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field45'') AS retelling      
          ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field29'') AS reading_rate
          ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field30'') AS fluency
          ,NULL AS fp_wpmrate
          ,NULL AS fp_fluency
          ,NULL AS fp_accuracy
          ,NULL AS fp_comp_within
          ,NULL AS fp_comp_beyond
          ,NULL AS fp_comp_about
          ,NULL AS fp_keylever
    FROM virtualtablesdata3 scores
    WHERE foreignkey_alpha > 3273
      AND related_to_table = ''readingScores''
      AND (created_on >= TRUNC(SYSDATE - 1) OR last_modified >= TRUNC(SYSDATE - 1))
    UNION ALL
    SELECT unique_id
          ,foreignKey AS studentid
          ,schoolid
          ,user_defined_date AS test_date
          ,foreignkey_alpha AS testid
          ,user_defined_text AS step_ltr_level
          ,user_defined_text2 AS status
          ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field50'') AS academic_year
          ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field49'') AS test_round
          ,NULL AS color
          ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field48'') AS instruct_lvl
          ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field47'') AS indep_lvl
          ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field21'') AS genre
          ,NULL AS name_ass
          ,NULL AS ltr_nameid
          ,NULL AS ltr_soundid
          ,NULL AS pa_rhymingwds
          ,NULL AS pa_mfs
          ,NULL AS pa_segmentation
          ,NULL AS cp_orient
          ,NULL AS cp_121match
          ,NULL AS cp_slw
          ,NULL AS devsp_first
          ,NULL AS devsp_svs
          ,NULL AS devsp_final
          ,NULL AS devsp_ifbd
          ,NULL AS devsp_longvp
          ,NULL AS devsp_rcontv
          ,NULL AS devsp_vowldig
          ,NULL AS devsp_cmplxb
          ,NULL AS devsp_eding
          ,NULL AS devsp_doubsylj      
          ,NULL AS rr_121match
          ,NULL AS rr_holdspattern
          ,NULL AS rr_understanding      
          ,NULL AS accuracy_1a
          ,NULL AS accuracy_2b
          ,NULL AS ra_errors
          ,NULL AS cc_factual
          ,NULL AS cc_infer
          ,NULL AS cc_other
          ,NULL AS cc_ct
          ,NULL AS ocomp_factual
          ,NULL AS ocomp_ct
          ,NULL AS ocomp_infer
          ,NULL AS scomp_factual
          ,NULL AS scomp_infer
          ,NULL AS scomp_ct
          ,NULL AS wcomp_fact
          ,NULL AS wcomp_infer
          ,NULL AS wcomp_ct
          ,NULL AS retelling      
          ,NULL AS reading_rate
          ,NULL AS fluency
          ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field1'') AS fp_wpmrate
          ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field2'') AS fp_fluency
          ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field3'') AS fp_accuracy
          ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field4'') AS fp_comp_within
          ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field5'') AS fp_comp_beyond
          ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field6'') AS fp_comp_about
          ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field7'') AS fp_keylever
    FROM virtualtablesdata3 scores
    WHERE foreignkey_alpha = 3273
      AND related_to_table = ''readingScores''
      AND (created_on >= TRUNC(SYSDATE - 1) OR last_modified >= TRUNC(SYSDATE - 1))
    ')
   )

  MERGE KIPP_NJ..LIT$READINGSCORES#STAGING AS TARGET
    USING rs_update AS SOURCE
       ON TARGET.unique_id = SOURCE.unique_id
    WHEN MATCHED THEN
     UPDATE
      SET TARGET.TEST_DATE = SOURCE.TEST_DATE       
         ,TARGET.STEP_LTR_LEVEL = SOURCE.STEP_LTR_LEVEL
         ,TARGET.STATUS = SOURCE.STATUS
         ,TARGET.ACADEMIC_YEAR = SOURCE.ACADEMIC_YEAR
         ,TARGET.TEST_ROUND = SOURCE.TEST_ROUND
         ,TARGET.COLOR = SOURCE.COLOR
         ,TARGET.INSTRUCT_LVL = SOURCE.INSTRUCT_LVL
         ,TARGET.INDEP_LVL = SOURCE.INDEP_LVL
         ,TARGET.GENRE = SOURCE.GENRE
         ,TARGET.NAME_ASS = SOURCE.NAME_ASS
         ,TARGET.LTR_NAMEID = SOURCE.LTR_NAMEID
         ,TARGET.LTR_SOUNDID = SOURCE.LTR_SOUNDID
         ,TARGET.PA_RHYMINGWDS = SOURCE.PA_RHYMINGWDS
         ,TARGET.PA_MFS = SOURCE.PA_MFS
         ,TARGET.PA_SEGMENTATION = SOURCE.PA_SEGMENTATION
         ,TARGET.CP_ORIENT = SOURCE.CP_ORIENT
         ,TARGET.CP_121MATCH = SOURCE.CP_121MATCH
         ,TARGET.CP_SLW = SOURCE.CP_SLW
         ,TARGET.DEVSP_FIRST = SOURCE.DEVSP_FIRST
         ,TARGET.DEVSP_SVS = SOURCE.DEVSP_SVS
         ,TARGET.DEVSP_FINAL = SOURCE.DEVSP_FINAL
         ,TARGET.DEVSP_IFBD = SOURCE.DEVSP_IFBD
         ,TARGET.DEVSP_LONGVOWEL = SOURCE.DEVSP_LONGVOWEL
         ,TARGET.DEVSP_RCONTROL = SOURCE.DEVSP_RCONTROL
         ,TARGET.DEVSP_VOWLDIG = SOURCE.DEVSP_VOWLDIG
         ,TARGET.DEVSP_CMPLXB = SOURCE.DEVSP_CMPLXB
         ,TARGET.DEVSP_EDING = SOURCE.DEVSP_EDING
         ,TARGET.DEVSP_DOUBSYLJ = SOURCE.DEVSP_DOUBSYLJ
         ,TARGET.RR_121MATCH = SOURCE.RR_121MATCH
         ,TARGET.RR_HOLDSPATTERN = SOURCE.RR_HOLDSPATTERN
         ,TARGET.RR_UNDERSTANDING = SOURCE.RR_UNDERSTANDING
         ,TARGET.ACCURACY_1A = SOURCE.ACCURACY_1A
         ,TARGET.ACCURACY_2B = SOURCE.ACCURACY_2B
         ,TARGET.RA_ERRORS = SOURCE.RA_ERRORS
         ,TARGET.CC_FACTUAL = SOURCE.CC_FACTUAL
         ,TARGET.CC_INFER = SOURCE.CC_INFER
         ,TARGET.CC_OTHER = SOURCE.CC_OTHER
         ,TARGET.CC_CT = SOURCE.CC_CT
         ,TARGET.OCOMP_FACTUAL = SOURCE.OCOMP_FACTUAL
         ,TARGET.OCOMP_CT = SOURCE.OCOMP_CT
         ,TARGET.OCOMP_INFER = SOURCE.OCOMP_INFER
         ,TARGET.SCOMP_FACTUAL = SOURCE.SCOMP_FACTUAL
         ,TARGET.SCOMP_INFER = SOURCE.SCOMP_INFER
         ,TARGET.SCOMP_CT = SOURCE.SCOMP_CT
         ,TARGET.WCOMP_FACT = SOURCE.WCOMP_FACT
         ,TARGET.WCOMP_INFER = SOURCE.WCOMP_INFER
         ,TARGET.WCOMP_CT = SOURCE.WCOMP_CT
         ,TARGET.RETELLING = SOURCE.RETELLING
         ,TARGET.READING_RATE = SOURCE.READING_RATE
         ,TARGET.FLUENCY = SOURCE.FLUENCY
         ,TARGET.FP_WPMRATE = SOURCE.FP_WPMRATE
         ,TARGET.FP_FLUENCY = SOURCE.FP_FLUENCY
         ,TARGET.FP_ACCURACY = SOURCE.FP_ACCURACY
         ,TARGET.FP_COMP_WITHIN = SOURCE.FP_COMP_WITHIN
         ,TARGET.FP_COMP_BEYOND = SOURCE.FP_COMP_BEYOND
         ,TARGET.FP_COMP_ABOUT = SOURCE.FP_COMP_ABOUT
         ,TARGET.FP_KEYLEVER = SOURCE.FP_KEYLEVER
    WHEN NOT MATCHED THEN
     INSERT
      (UNIQUE_ID
      ,STUDENTID
      ,SCHOOLID
      ,TEST_DATE
      ,TESTID
      ,STEP_LTR_LEVEL
      ,STATUS
      ,ACADEMIC_YEAR
      ,TEST_ROUND
      ,COLOR
      ,INSTRUCT_LVL
      ,INDEP_LVL
      ,GENRE
      ,NAME_ASS
      ,LTR_NAMEID
      ,LTR_SOUNDID
      ,PA_RHYMINGWDS
      ,PA_MFS
      ,PA_SEGMENTATION
      ,CP_ORIENT
      ,CP_121MATCH
      ,CP_SLW
      ,DEVSP_FIRST
      ,DEVSP_SVS
      ,DEVSP_FINAL
      ,DEVSP_IFBD
      ,DEVSP_LONGVOWEL
      ,DEVSP_RCONTROL
      ,DEVSP_VOWLDIG
      ,DEVSP_CMPLXB
      ,DEVSP_EDING
      ,DEVSP_DOUBSYLJ
      ,RR_121MATCH
      ,RR_HOLDSPATTERN
      ,RR_UNDERSTANDING
      ,ACCURACY_1A
      ,ACCURACY_2B
      ,RA_ERRORS
      ,CC_FACTUAL
      ,CC_INFER
      ,CC_OTHER
      ,CC_CT
      ,OCOMP_FACTUAL
      ,OCOMP_CT
      ,OCOMP_INFER
      ,SCOMP_FACTUAL
      ,SCOMP_INFER
      ,SCOMP_CT
      ,WCOMP_FACT
      ,WCOMP_INFER
      ,WCOMP_CT
      ,RETELLING
      ,READING_RATE
      ,FLUENCY
      ,FP_WPMRATE
      ,FP_FLUENCY
      ,FP_ACCURACY
      ,FP_COMP_WITHIN
      ,FP_COMP_BEYOND
      ,FP_COMP_ABOUT
      ,FP_KEYLEVER)
     VALUES
      (SOURCE.UNIQUE_ID
      ,SOURCE.STUDENTID
      ,SOURCE.SCHOOLID
      ,SOURCE.TEST_DATE
      ,SOURCE.TESTID
      ,SOURCE.STEP_LTR_LEVEL
      ,SOURCE.STATUS
      ,SOURCE.ACADEMIC_YEAR
      ,SOURCE.TEST_ROUND
      ,SOURCE.COLOR
      ,SOURCE.INSTRUCT_LVL
      ,SOURCE.INDEP_LVL
      ,SOURCE.GENRE
      ,SOURCE.NAME_ASS
      ,SOURCE.LTR_NAMEID
      ,SOURCE.LTR_SOUNDID
      ,SOURCE.PA_RHYMINGWDS
      ,SOURCE.PA_MFS
      ,SOURCE.PA_SEGMENTATION
      ,SOURCE.CP_ORIENT
      ,SOURCE.CP_121MATCH
      ,SOURCE.CP_SLW
      ,SOURCE.DEVSP_FIRST
      ,SOURCE.DEVSP_SVS
      ,SOURCE.DEVSP_FINAL
      ,SOURCE.DEVSP_IFBD
      ,SOURCE.DEVSP_LONGVOWEL
      ,SOURCE.DEVSP_RCONTROL
      ,SOURCE.DEVSP_VOWLDIG
      ,SOURCE.DEVSP_CMPLXB
      ,SOURCE.DEVSP_EDING
      ,SOURCE.DEVSP_DOUBSYLJ
      ,SOURCE.RR_121MATCH
      ,SOURCE.RR_HOLDSPATTERN
      ,SOURCE.RR_UNDERSTANDING
      ,SOURCE.ACCURACY_1A
      ,SOURCE.ACCURACY_2B
      ,SOURCE.RA_ERRORS
      ,SOURCE.CC_FACTUAL
      ,SOURCE.CC_INFER
      ,SOURCE.CC_OTHER
      ,SOURCE.CC_CT
      ,SOURCE.OCOMP_FACTUAL
      ,SOURCE.OCOMP_CT
      ,SOURCE.OCOMP_INFER
      ,SOURCE.SCOMP_FACTUAL
      ,SOURCE.SCOMP_INFER
      ,SOURCE.SCOMP_CT
      ,SOURCE.WCOMP_FACT
      ,SOURCE.WCOMP_INFER
      ,SOURCE.WCOMP_CT
      ,SOURCE.RETELLING
      ,SOURCE.READING_RATE
      ,SOURCE.FLUENCY
      ,SOURCE.FP_WPMRATE
      ,SOURCE.FP_FLUENCY
      ,SOURCE.FP_ACCURACY
      ,SOURCE.FP_COMP_WITHIN
      ,SOURCE.FP_COMP_BEYOND
      ,SOURCE.FP_COMP_ABOUT
      ,SOURCE.FP_KEYLEVER);

END

GO
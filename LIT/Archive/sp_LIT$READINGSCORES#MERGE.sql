USE KIPP_NJ
GO

ALTER PROCEDURE sp_LIT$READINGSCORES#MERGE AS

BEGIN
  
  /* CHECK IF TEMP TABLES EXIST */
  IF OBJECT_ID(N'tempdb..#rs_update') IS NOT NULL
		BEGIN
						DROP TABLE #rs_update
		END
  IF OBJECT_ID(N'tempdb..#delete_tests') IS NOT NULL
		BEGIN
						DROP TABLE #delete_tests
		END;

  /* GET RECENT READINGSCORES ENTRIES */
  WITH rs_update AS (
    SELECT unique_id
          ,studentid
          ,schoolid
          ,test_date
          ,testid
          ,read_lvl
          ,status
          ,CASE WHEN testid = 3273 THEN NULL ELSE field1 END AS color
          ,CASE WHEN testid = 3273 THEN field48 ELSE field2 END AS instruct_lvl
          ,CASE WHEN testid = 3273 THEN field47 ELSE field3 END AS indep_lvl
          ,CASE WHEN testid = 3273 THEN NULL ELSE field4 END AS name_ass
          ,CASE WHEN testid = 3273 THEN NULL ELSE field5 END AS ltr_nameid
          ,CASE WHEN testid = 3273 THEN NULL ELSE field6 END AS ltr_soundid
          ,CASE WHEN testid = 3273 THEN NULL ELSE field7 END AS pa_rhymingwds
          ,field8 AS cp_orient
          ,field9 AS cp_121match
          ,field10 AS cp_slw
          ,field11 AS pa_mfs
          ,field12 AS devsp_first
          ,field13 AS devsp_svs
          ,field14 AS devsp_final
          ,field15 AS rr_121match
          ,field16 AS rr_holdspattern
          ,field17 AS rr_understanding
          ,field18 AS pa_segmentation
          ,field19 AS accuracy_1a
          ,field20 AS accuracy_2b
          ,field21 AS genre
          ,field22 AS cc_factual
          ,field23 AS cc_infer
          ,field24 AS cc_other
          ,field26 AS cc_ct
          ,field28 AS ra_errors
          ,field29 AS reading_rate
          ,field30 AS fluency
          ,field31 AS devsp_ifbd
          ,field32 AS ocomp_factual
          ,field33 AS ocomp_ct
          ,field34 AS scomp_factual
          ,field35 AS scomp_infer
          ,field36 AS scomp_ct
          ,field37 AS devsp_longvowel
          ,field38 AS devsp_rcontrol
          ,field39 AS ocomp_infer
          ,field41 AS devsp_vowldig
          ,field42 AS devsp_cmplxb
          ,field43 AS wcomp_fact
          ,field44 AS wcomp_infer
          ,field45 AS retelling
          ,field46 AS wcomp_ct
          ,CASE WHEN testid = 3273 THEN NULL ELSE field47 END AS devsp_eding
          ,CASE WHEN testid = 3273 THEN NULL ELSE field48 END AS devsp_doubsylj
          ,field49 AS test_round
          ,field50 AS academic_year
          ,CASE WHEN testid = 3273 THEN field1 ELSE NULL END AS fp_wpmrate
          ,CASE WHEN testid = 3273 THEN field2 ELSE NULL END AS fp_fluency
          ,CASE WHEN testid = 3273 THEN field3 ELSE NULL END AS fp_accuracy
          ,CASE WHEN testid = 3273 THEN field4 ELSE NULL END AS fp_comp_within
          ,CASE WHEN testid = 3273 THEN field5 ELSE NULL END AS fp_comp_beyond
          ,CASE WHEN testid = 3273 THEN field6 ELSE NULL END AS fp_comp_about
          ,CASE WHEN testid = 3273 THEN field7 ELSE NULL END AS fp_keylever
          ,field25 AS coaching_code
    FROM OPENQUERY(PS_TEAM,'
      SELECT unique_id
            ,foreignKey AS studentid
            ,schoolid
            ,user_defined_date AS test_date
            ,foreignkey_alpha AS testid
            ,user_defined_text AS read_lvl            
            ,user_defined_text2 AS status
            ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''field1'') AS field1
            ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''field2'') AS field2
            ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''field3'') AS field3
            ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''field4'') AS field4
            ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''field5'') AS field5
            ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''field6'') AS field6
            ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''field7'') AS field7
            ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''field8'') AS field8
            ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''field9'') AS field9
            ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''field10'') AS field10
            ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''field11'') AS field11
            ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''field12'') AS field12
            ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''field13'') AS field13
            ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''field14'') AS field14
            ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''field15'') AS field15
            ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''field16'') AS field16
            ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''field17'') AS field17
            ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''field18'') AS field18
            ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''field19'') AS field19
            ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''field20'') AS field20
            ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''field21'') AS field21
            ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''field22'') AS field22
            ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''field23'') AS field23
            ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''field24'') AS field24
            ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''field25'') AS field25
            ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''field26'') AS field26
            ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''field27'') AS field27
            ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''field28'') AS field28
            ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''field29'') AS field29
            ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''field30'') AS field30
            ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''field31'') AS field31
            ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''field32'') AS field32
            ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''field33'') AS field33
            ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''field34'') AS field34
            ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''field35'') AS field35
            ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''field36'') AS field36
            ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''field37'') AS field37
            ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''field38'') AS field38
            ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''field39'') AS field39
            ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''field40'') AS field40
            ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''field41'') AS field41
            ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''field42'') AS field42
            ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''field43'') AS field43
            ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''field44'') AS field44
            ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''field45'') AS field45
            ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''field46'') AS field46
            ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''field47'') AS field47
            ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''field48'') AS field48
            ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''field49'') AS field49
            ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''field50'') AS field50
      FROM virtualtablesdata3 scores
      WHERE related_to_table = ''readingScores''        
        AND (created_on >= TRUNC(SYSDATE - 4) OR last_modified >= TRUNC(SYSDATE - 4))        
    ')
   )

  /* LOAD NEW SCORES INTO TEMP TABLE */
  SELECT *
  INTO #rs_update
  FROM rs_update;

  /* MERGE INTO DESTINATION TABLE */
  MERGE KIPP_NJ..LIT$READINGSCORES#STAGING AS TARGET
    USING #rs_update AS SOURCE
       ON TARGET.unique_id = SOURCE.unique_id
    WHEN MATCHED THEN
     UPDATE
      SET TARGET.TEST_DATE = SOURCE.TEST_DATE       
         ,TARGET.READ_LVL = SOURCE.READ_LVL
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
         ,TARGET.COACHING_CODE = SOURCE.COACHING_CODE
    WHEN NOT MATCHED THEN
     INSERT
      (UNIQUE_ID
      ,STUDENTID
      ,SCHOOLID
      ,TEST_DATE
      ,TESTID
      ,READ_LVL
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
      ,COACHING_CODE)
     VALUES
      (SOURCE.UNIQUE_ID
      ,SOURCE.STUDENTID
      ,SOURCE.SCHOOLID
      ,SOURCE.TEST_DATE
      ,SOURCE.TESTID
      ,SOURCE.READ_LVL
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
      ,SOURCE.FP_KEYLEVER
      ,SOURCE.COACHING_CODE);

  /* GET LIST OF ALL VALID UNIQUE_IDS */
  WITH valid_tests AS (
    SELECT unique_id
    FROM OPENQUERY(PS_TEAM,'
      SELECT unique_id
      FROM virtualtablesdata3 scores
      WHERE related_to_table = ''readingScores''
    ')
   ) 

  /* COMPARE TO DESTINATION TABLE AND FIND RECORDS THAT NEED TO BE DELETED */
  ,delete_tests AS (
    SELECT r.UNIQUE_ID      
    FROM KIPP_NJ..LIT$READINGSCORES#STAGING r WITH(NOLOCK)
    LEFT OUTER JOIN valid_tests v
      ON r.UNIQUE_ID = v.unique_id
    WHERE v.unique_id IS NULL
  )

  /* LOAD DELETE UNIQUE_IDS INTO TEMP TABLE */
  SELECT *
  INTO #delete_tests
  FROM delete_tests;

  /* DELETE MATCHING UNIQUE_IDS FROM DESTINATION TABLE */
  DELETE KIPP_NJ..LIT$READINGSCORES#STAGING
  WHERE UNIQUE_ID IN (SELECT UNIQUE_ID FROM #delete_tests);

END

GO
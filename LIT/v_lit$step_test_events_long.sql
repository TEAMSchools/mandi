USE KIPP_NJ
GO

ALTER VIEW LIT$step_test_events_long AS

SELECT *
FROM OPENQUERY(PS_TEAM, '
SELECT s.id AS studentid                                    
      ,s.lastfirst
      ,CAST(s.student_number AS VARCHAR(20)) AS student_number
      ,s.grade_level
      ,s.team
      ,user_defined_date AS test_date
      ,CAST(user_defined_text AS VARCHAR(20)) AS step_level
      ,foreignkey_alpha AS testid
      ,user_defined_text2 AS status
      ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field1'')  AS color
      ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field2'')  AS instruct_lvl
      ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field3'')  AS indep_lvl
      ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field4'')  AS name_ass
      ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field5'')  AS ltr_nameid
      ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field6'')  AS ltr_soundid
      ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field7'')  AS pa_rhymingwds
      ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field8'')  AS cp_orient
      ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field9'')  AS cp_121match
      ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field10'') AS cp_slw
      ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field11'') AS pa_mfs
      ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field12'') AS devsp_first
      ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field13'') AS devsp_svs
      ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field14'') AS devsp_final
      ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field15'') AS rr_121match
      ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field16'') AS rr_holdspattern
      ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field17'') AS rr_understanding
      ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field18'') AS pa_segmentation
      ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field19'') AS accuracy_1a
      ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field20'') AS accuracy_2b
      ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field21'') AS read_teacher
      ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field22'') AS cc_factual
      ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field23'') AS cc_infer
      ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field24'') AS cc_other
      ,CAST(PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field25'') AS VARCHAR(20)) AS accuracy
      ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field26'') AS cc_ct
      ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field27'') AS total_vwlattmpt
      ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field28'') AS ra_errors
      ,CAST(PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field29'') AS VARCHAR(20)) AS reading_rate
      ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field30'') AS fluency
      ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field31'') AS devsp_ifbd
      ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field32'') AS ocomp_factual
      ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field33'') AS ocomp_ct
      ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field34'') AS scomp_factual
      ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field35'') AS scomp_infer
      ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field36'') AS scomp_ct
      ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field37'') AS devsp_longvp
      ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field38'') AS devsp_rcontv
      ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field39'') AS ocomp_infer
      ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field40'') AS devsp_vcelvp
      ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field41'') AS devsp_vowldig
      ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field42'') AS devsp_cmplxb
      ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field43'') AS wcomp_fact
      ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field44'') AS wcomp_infer
      ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field45'') AS retelling
      ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field46'') AS wcomp_ct
      ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field47'') AS devsp_eding
      ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field48'') AS devsp_doubsylj
      ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field49'') AS devsp_longv2sw
      ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field50'') AS devsp_rcont2sw
FROM virtualtablesdata3 scores
JOIN students s ON s.id = scores.foreignKey  
WHERE scores.related_to_table = ''readingScores'' 
  AND user_defined_text IS NOT NULL              
  AND foreignkey_alpha > 3273 -- STEP DATA ONLY              
ORDER BY scores.schoolid, s.grade_level, s.team, s.lastfirst, scores.user_defined_date DESC
')
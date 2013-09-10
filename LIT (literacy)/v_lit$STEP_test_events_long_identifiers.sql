USE [KIPP_NJ]
GO

ALTER VIEW LIT$STEP_test_events_long#identifiers AS

SELECT openq.*
      ,cohort.schoolid
      ,cohort.grade_level
      ,cohort.abbreviation
      ,cohort.year
       --helps to determine first test event FOR a student IN a year
      ,ROW_NUMBER() OVER
         (PARTITION BY openq.studentid
                      ,cohort.year
          ORDER BY openq.test_date ASC) AS rn_asc
       --helps to determine last test event FOR a student IN a year
      ,ROW_NUMBER() OVER
         (PARTITION BY openq.studentid
                      ,cohort.year
          ORDER BY openq.test_date DESC) AS rn_desc
FROM OPENQUERY(PS_TEAM, '
	SELECT s.id AS studentid                                    
		  ,s.lastfirst		  
		  ,CAST(s.student_number AS VARCHAR(20)) AS student_number      
		  ,user_defined_date AS test_date
		  ,CAST(user_defined_text AS VARCHAR(20)) AS step_level
		  ,foreignkey_alpha AS testid
		  ,user_defined_text2 AS status
		  ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field1'')  AS color
		  ,CAST(PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field2'') AS VARCHAR(20)) AS instruct_lvl
		  ,CAST(PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field3'') AS VARCHAR(20)) AS indep_lvl
		  ,CAST(PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field4'') AS INT)  AS name_ass
		  ,CAST(PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field5'') AS INT)  AS ltr_nameid
		  ,CAST(PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field6'') AS INT)  AS ltr_soundid
		  ,CAST(PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field7'') AS INT)  AS pa_rhymingwds
		  ,CAST(PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field8'') AS INT)  AS cp_orient
		  ,CAST(PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field9'') AS INT)  AS cp_121match
		  ,CAST(PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field10'') AS INT) AS cp_slw
		  ,CAST(PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field11'') AS INT) AS pa_mfs
		  ,CAST(PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field12'') AS INT) AS devsp_first
		  ,CAST(PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field13'') AS INT) AS devsp_svs
		  ,CAST(PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field14'') AS INT) AS devsp_final
		  ,CAST(PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field15'') AS INT) AS rr_121match
		  ,CAST(PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field16'') AS INT) AS rr_holdspattern
		  ,CAST(PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field17'') AS INT) AS rr_understanding
		  ,CAST(PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field18'') AS INT) AS pa_segmentation
		  ,CAST(PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field19'') AS INT) AS accuracy_1a
		  ,CAST(PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field20'') AS INT) AS accuracy_2b
		  ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field21'') AS read_teacher
		  ,CAST(PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field22'') AS INT) AS cc_factual
		  ,CAST(PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field23'') AS INT) AS cc_infer
		  ,CAST(PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field24'') AS INT) AS cc_other
		  ,CAST(PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field25'') AS VARCHAR(20)) AS accuracy
		  ,CAST(PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field26'') AS INT) AS cc_ct
		  ,CAST(PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field27'') AS INT) AS total_vwlattmpt
		  ,CAST(PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field28'') AS INT) AS ra_errors
		  ,CAST(PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field29'') AS VARCHAR(20)) AS reading_rate
		  ,CAST(PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field30'') AS INT) AS fluency
		  ,CAST(PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field31'') AS INT) AS devsp_ifbd
		  ,CAST(PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field32'') AS INT) AS ocomp_factual
		  ,CAST(PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field33'') AS INT) AS ocomp_ct
		  ,CAST(PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field34'') AS INT) AS scomp_factual
		  ,CAST(PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field35'') AS INT) AS scomp_infer
		  ,CAST(PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field36'') AS INT) AS scomp_ct
		  ,CAST(PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field37'') AS INT) AS devsp_longvp
		  ,CAST(PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field38'') AS INT) AS devsp_rcontv
		  ,CAST(PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field39'') AS INT) AS ocomp_infer
		  ,CAST(PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field40'') AS INT) AS devsp_vcelvp
		  ,CAST(PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field41'') AS INT) AS devsp_vowldig
		  ,CAST(PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field42'') AS INT) AS devsp_cmplxb
		  ,CAST(PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field43'') AS INT) AS wcomp_fact
		  ,CAST(PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field44'') AS INT) AS wcomp_infer
		  ,CAST(PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field45'') AS INT) AS retelling
		  ,CAST(PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field46'') AS INT) AS wcomp_ct
		  ,CAST(PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field47'') AS INT) AS devsp_eding
		  ,CAST(PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field48'') AS INT) AS devsp_doubsylj
		  ,CAST(PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field49'') AS INT) AS devsp_longv2sw
		  ,CAST(PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field50'') AS INT) AS devsp_rcont2sw
	FROM virtualtablesdata3 scores
	JOIN students s ON s.id = scores.foreignKey  
	WHERE scores.related_to_table = ''readingScores'' 
	  AND user_defined_text IS NOT NULL  
	  AND foreignkey_alpha > 3273 -- STEP DATA ONLY	                
	ORDER BY scores.schoolid, s.grade_level, s.team, s.lastfirst, scores.user_defined_date DESC
	') openq
JOIN COHORT$comprehensive_long cohort
  ON openq.studentid = cohort.studentid
 AND openq.test_date >= cohort.entrydate
 AND openq.test_date <= cohort.exitdate
 AND cohort.rn = 1
USE KIPP_NJ
GO

ALTER VIEW reporting$reading_log AS
WITH roster AS
  (SELECT studentid
         ,s.student_number
         ,c.grade_level
         ,c.schoolid
         ,s.lastfirst
         ,s.FIRST_NAME + ' ' + s.LAST_NAME AS name
         ,sch.abbreviation AS school
   FROM KIPP_NJ..COHORT$comprehensive_long#static c
   JOIN KIPP_NJ..SCHOOLS sch
     ON c.schoolid = sch.school_number
   JOIN KIPP_NJ..STUDENTS s
     ON c.studentid = s.id
    AND s.enroll_status = 0
    
   --AND s.ID = 4772
    --AND c.grade_level = 5
    --AND c.schoolid = 133570965
   WHERE year = 2013
     AND rn = 1
     AND c.schoolid != 999999
     AND c.schoolid IN (73252, 133570965)
  )

  ,enrollments AS
  (SELECT cc.termid AS termid
         ,cc.studentid
         ,sections.id AS sectionid
         ,sections.section_number
         ,courses.course_number
         ,courses.course_name
   FROM cc
   JOIN sections
     ON cc.sectionid = sections.id
    AND cc.termid >= 2300
   JOIN courses
     ON sections.course_number = courses.course_number
    AND courses.credittype LIKE 'ENG'
   WHERE cc.dateenrolled <= GETDATE()
	    AND cc.dateleft >= GETDATE()
  )

  ,sri_lexile AS
    (SELECT *
     FROM OPENQUERY(KIPP_NWK, '
       SELECT *
       FROM sri_testing_history')
    )
    
SELECT roster.*
      ,enr.course_name + '|' + enr.section_number AS enr_hash
      ,gr.course_number
      ,gr.course_name
      ,gr.T1 AS cur_term_rdg_gr
      ,gr.Y1 AS y1_rdg_gr
      ,ele.grade_1 AS cur_term_rdg_hw_avg
      ,ele.simple_avg AS y1_rdg_hw_avg
      ,CASE
        WHEN fp_base.letter_level IS NOT NULL THEN fp_base.letter_level
        WHEN fp_base.letter_level IS NULL AND fp_cur.letter_level IS NOT NULL THEN fp_cur.letter_level
        ELSE fp_dna_base.letter_level
       END AS fp_base_letter
      ,CASE
        WHEN fp_cur.letter_level IS NULL THEN fp_dna_curr.letter_level
        ELSE fp_cur.letter_level
       END AS fp_cur_letter
      ,CASE 
         WHEN map_fall.testritscore > map_spr.testritscore THEN map_fall.TestRITScore
         WHEN map_fall.TestRITScore IS NULL THEN map_spr.TestRITScore
         ELSE map_fall.TestRITScore
       END AS map_baseline
      ,cur_rit.TestRITScore AS cur_RIT
      ,cur_rit.TestPercentile AS cur_RIT_percentile
       --use MAP for lexile      
      ,CASE
         WHEN roster.grade_level = 7 AND roster.school = 'Rise' THEN CAST(sri_lexile.lexile AS NVARCHAR)
         WHEN roster.grade_level = 6 AND roster.school = 'Rise' THEN CAST(sri_lexile.lexile AS NVARCHAR)
         WHEN map_fall.testritscore > map_spr.testritscore THEN map_fall.RITtoReadingScore
         WHEN map_fall.TestRITScore IS NULL THEN map_spr.RITtoReadingScore
         ELSE map_fall.RITtoReadingScore
       END AS lexile_baseline_MAP
       --readlive
      ,rl.wpm AS starting_fluency
      ,rl.wpm AS cur_fluency
 
       --AR cur
      ,replace(convert(varchar,convert(Money, ar_cur.words),1),'.00','') AS hex_words
      ,replace(convert(varchar,convert(Money, ar_cur.words_goal),1),'.00','') AS hex_goal
      ,replace(convert(varchar,convert(Money, CAST(ROUND(ar_cur.ontrack_words,0) AS INT)),1),'.00','') AS hex_needed
      ,ar_cur.stu_status_words AS hex_on_track
      ,ar_cur.rank_words_grade_in_school AS hex_rank_words

       --AR year
      ,replace(convert(varchar,convert(Money, ar_year.words),1),'.00','') AS year_words
      ,replace(convert(varchar,convert(Money, ar_cur.words_goal * 6),1),'.00','') AS year_goal  
      ,100 - ar_year.pct_fiction AS year_pct_nf 
      ,ar_year.rank_words_grade_in_school AS year_rank_words
      --accuracy
      ,ar_year.mastery AS accuracy
      ,ar_year.mastery_fiction AS accuracy_fiction
      ,ar_year.mastery_nonfiction AS accuracy_nonfiction
     
FROM roster
--ENR
LEFT OUTER JOIN enrollments enr
  ON roster.studentid = enr.studentid

--GRADES
LEFT OUTER JOIN KIPP_NJ..GRADES$DETAIL#MS gr
  ON roster.studentid = gr.studentid
 AND gr.credittype LIKE '%ENG%'

--HW
LEFT OUTER JOIN KIPP_NJ..GRADES$elements ele
  ON roster.studentid = ele.studentid
 AND gr.course_number = ele.course_number
 AND ele.pgf_type = 'H'
 AND ele.yearid = 23

--F&P
LEFT OUTER JOIN LIT$FP_test_events_long#identifiers#static fp_cur
  ON roster.STUDENTID = fp_cur.studentid
 AND fp_cur.achv_curr_all = 1
LEFT OUTER JOIN LIT$FP_test_events_long#identifiers#static fp_base
  ON roster.STUDENTID = fp_base.studentid
 AND fp_base.achv_base = 1
 AND fp_base.year = 2013
LEFT OUTER JOIN LIT$FP_test_events_long#identifiers#static fp_dna_base
  ON roster.STUDENTID = fp_dna_base.studentid
 AND fp_dna_base.dna_base = 1
 AND fp_dna_base.year = 2013
LEFT OUTER JOIN LIT$FP_test_events_long#identifiers#static fp_dna_curr
  ON roster.STUDENTID = fp_dna_curr.studentid
 AND fp_dna_curr.dna_curr = 1
 AND fp_dna_curr.year = 2013

--RIT, NWEA LEXILE
LEFT OUTER JOIN KIPP_NJ..[MAP$comprehensive#identifiers] map_fall
  ON roster.studentid = map_fall.ps_studentid
 AND map_fall.measurementscale = 'Reading'
 AND map_fall.map_year_academic = 2013
 AND map_fall.TermName = 'Fall 2013-2014'

LEFT OUTER JOIN KIPP_NJ..[MAP$comprehensive#identifiers] map_spr
  ON roster.studentid = map_spr.ps_studentid
 AND map_spr.measurementscale = 'Reading'
 AND map_spr.map_year_academic = 2012
 AND map_spr.TermName = 'Spring 2012-2013'

--CURRENT NWEA RIT
LEFT OUTER JOIN       
    (SELECT sub_1.*
     FROM
          (SELECT ps_studentid
                 ,[map_year_academic]
                 ,[fallwinterspring]
                 ,[map_year]
                 ,[TermName]
                 ,[MeasurementScale]
                 ,[TestRITScore]
                 ,TestPercentile
                 ,[RITtoReadingScore]
                 ,ROW_NUMBER () 
                    OVER (PARTITION BY ps_studentid 
                          ORDER BY map.teststartdate DESC) AS rn_desc
             FROM KIPP_NJ..MAP$comprehensive#identifiers map
             WHERE MeasurementScale = 'Reading'
               AND map_year_academic = 2013
           ) sub_1
     WHERE rn_desc = 1
     ) cur_rit
  ON roster.studentid = cur_rit.ps_studentid

LEFT OUTER JOIN KIPP_NJ..SRSLY_DIE_READLIVE rl
  ON CAST(roster.studentid AS NVARCHAR) = rl.studentid

--AR current
LEFT OUTER JOIN KIPP_NJ..[AR$progress_to_goals_long#static] ar_cur
  ON roster.studentid = ar_cur.studentid
 AND ar_cur.time_period_name = 'RT2'
 AND ar_cur.yearid = 2300

--AR year
LEFT OUTER JOIN KIPP_NJ..[AR$progress_to_goals_long#static] ar_year
  ON roster.studentid = ar_year.studentid
 AND ar_year.time_period_name = 'Year'
 AND ar_year.yearid = 2300

LEFT OUTER JOIN sri_lexile
  ON CAST(roster.student_number AS NVARCHAR) = sri_lexile.base_student_number
 AND sri_lexile.rn_lifetime = 1
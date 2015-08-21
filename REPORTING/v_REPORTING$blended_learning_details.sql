--this view is used for the core data feed (consiting of roster, MAP info) in Rise/TEAM blended learning google doc dashboards

USE KIPP_NJ
GO

ALTER VIEW REPORTING$blended_learning_details AS

WITH curterm AS (
  SELECT schoolid
        ,alt_name
  FROM KIPP_NJ..REPORTING$dates WITH(NOLOCK)
  WHERE academic_year = KIPP_NJ.dbo.fn_Global_Academic_Year()
    AND identifier = 'RT'
    AND start_date <= CONVERT(DATE,GETDATE())
    AND end_date >= CONVERT(DATE,GETDATE())
    AND school_level = 'MS'
 )

,roster AS (
  SELECT c.student_number	AS base_student_number
        ,c.studentid AS base_studentid
        ,c.lastfirst AS stu_lastfirst
        ,c.first_name AS stu_firstname
        ,c.last_name AS stu_lastname
        ,c.grade_level AS stu_grade_level
			     ,c.team AS travel_group     
			     ,c.spedlep AS SPED
			     ,c.gender			     
        ,c.school_name	AS school
  FROM KIPP_NJ..COHORT$identifiers_long#static c  WITH(NOLOCK)                       
  WHERE c.year = KIPP_NJ.dbo.fn_Global_Academic_Year()
    AND c.rn = 1
    AND c.enroll_status = 0
    AND c.grade_level >= 5
    AND c.grade_level <= 8
 )

,data AS (
  SELECT base_student_number
        ,base_studentid
        ,p.schoolid
        ,term      
        ,MATH_ku
        ,MATH_pctile
        ,MATH_rit
        ,MATH_rr
        ,MATH_sec
        ,MATH_teacher
        ,MATH_y1
        ,READ_ku
        ,READ_pctile
        ,READ_rit
        ,READ_rr
        ,READ_sec
        ,READ_teacher
        ,READ_y1
        ,lang_sec
        ,lang_teacher
        ,lang_y1
        ,lang_rit
        ,lang_pctile
        ,lang_ku
        ,lang_rr
        ,SCI_ku
        ,SCI_pctile
        ,SCI_rit
        ,SCI_rr
        ,SCI_sec
        ,SCI_teacher
        ,SCI_y1
  FROM
      (
       SELECT base_student_number
             ,base_studentid             
             ,schoolid
             ,term
             ,credittype + '_' + field AS pivot_hash
             ,value
       FROM
           (
            SELECT sub.base_student_number
                  ,sub.base_studentid                  
                  ,sub.schoolid 
                  ,sub.credittype      
                  ,sub.term                
                  ,CONVERT(VARCHAR,sub.SECTION_NUMBER) AS sec
                  ,CONVERT(VARCHAR,sub.teacher) AS teacher
                  ,CONVERT(VARCHAR,sub.pct) AS y1
                  ,CONVERT(VARCHAR,map.testritscore) AS rit
                  ,CONVERT(VARCHAR,map.testpercentile) AS pctile
                  ,CONVERT(VARCHAR,rr.keep_up_rit) AS ku
                  ,CONVERT(VARCHAR,rr.rutgers_ready_rit) AS rr
            FROM
                ( 
                 SELECT c.year
                       ,c.student_number	AS base_student_number
                       ,c.studentid AS base_studentid
                       ,c.lastfirst AS stu_lastfirst
                       ,c.first_name AS stu_firstname
                       ,c.last_name AS stu_lastname
                       ,c.grade_level AS stu_grade_level
			                    ,c.team AS travel_group     
			                    ,c.spedlep AS SPED
			                    ,c.gender
			                    ,c.schoolid
                       ,c.school_name	AS school
                       ,CASE
                         WHEN enr.credittype = 'MATH' THEN 'Mathematics'
                         WHEN enr.credittype IN ('ENG','READ') THEN 'Reading'
                         WHEN enr.credittype = 'RHET' THEN 'Language Usage'
                         WHEN enr.credittype = 'SCI' THEN 'Science - General Science'
                        END AS measurementscale
                       ,CASE 
                         WHEN enr.credittype = 'ENG' THEN 'READ'
                         WHEN enr.credittype = 'RHET' THEN 'LANG'
                         ELSE enr.credittype 
                        END AS credittype
                       ,enr.course_number
                       ,ISNULL(sec.term,curterm.alt_name) AS term
                       ,enr.SECTION_NUMBER
                       ,enr.teacher_name AS teacher
                       ,gr.y1_pct AS pct
                 FROM KIPP_NJ..COHORT$identifiers_long#static c WITH(NOLOCK)                       
                 JOIN curterm
                   ON c.schoolid = curterm.schoolid
                 JOIN KIPP_NJ..PS$course_enrollments#static enr WITH(NOLOCK)
                   ON c.studentid = enr.STUDENTID
                  AND c.year = enr.academic_year
                  AND enr.credittype IN ('MATH','ENG','SCI','RHET')                
                 LEFT OUTER JOIN KIPP_NJ..GRADES$sections_by_term#static sec WITH(NOLOCK)
                   ON c.studentid = sec.studentid
                  AND enr.sectionid = sec.sectionid
                 LEFT OUTER JOIN KIPP_NJ..PS$SECTIONS#static sn WITH(NOLOCK)
                   ON sec.sectionid = sn.id
                 LEFT OUTER JOIN KIPP_NJ..GRADES$detail_long gr WITH(NOLOCK)
                   ON c.studentid = gr.studentid
                  AND sec.course_number = gr.course_number
                  AND sec.sectionid = gr.sectionid                
                  AND sec.term = gr.term
                  AND gr.curterm_flag = 1
                 WHERE c.year = KIPP_NJ.dbo.fn_Global_Academic_Year()
                   AND c.rn = 1
                   AND c.enroll_status = 0
     		            AND c.grade_level >= 5
     		            AND c.grade_level <= 8
                ) sub
            LEFT OUTER JOIN MAP$best_baseline#static map WITH(NOLOCK)
              ON sub.base_studentid = map.studentid
	            AND sub.measurementscale = map.measurementscale
             AND sub.year = map.year
            LEFT OUTER JOIN MAP$rutgers_ready_student_goals rr WITH(NOLOCK)
	             ON map.studentid = rr.studentid
	            AND map.year = rr.year
	            AND REPLACE(map.measurementscale,' Usage', '') = rr.measurementscale
           ) sub
       UNPIVOT(
         value
         FOR field IN (sub.sec
                      ,sub.teacher                    
                      ,sub.y1
                      ,sub.rit
                      ,sub.pctile
                      ,sub.ku
                      ,sub.rr)
        ) u
      ) sub
  PIVOT(
    MAX(value)
    FOR pivot_hash IN ([MATH_ku]
                      ,[MATH_pctile]
                      ,[MATH_rit]
                      ,[MATH_rr]
                      ,[MATH_sec]
                      ,[MATH_teacher]
                      ,[MATH_y1]
                      ,[READ_ku]
                      ,[READ_pctile]
                      ,[READ_rit]
                      ,[READ_rr]
                      ,[READ_sec]
                      ,[READ_teacher]
                      ,[READ_y1]
                      ,[lang_sec]
                      ,[lang_teacher]
                      ,[lang_y1]
                      ,[lang_rit]
                      ,[lang_pctile]
                      ,[lang_ku]
                      ,[lang_rr]
                      ,[SCI_ku]
                      ,[SCI_pctile]
                      ,[SCI_rit]
                      ,[SCI_rr]
                      ,[SCI_sec]
                      ,[SCI_teacher]
                      ,[SCI_y1])
   ) p
  JOIN curterm
    ON p.term = curterm.alt_name
   AND p.schoolid = curterm.schoolid
 )

SELECT r.base_student_number AS ID
      ,r.stu_lastfirst AS LastFirst
      ,r.stu_grade_level AS GR
      ,r.SPED
      ,r.travel_group AS Travel
      ,r.GENDER AS MF
      ,math_sec
      ,math_y1
      ,sci_sec
      ,sci_y1
      ,school
      ,math_rit
      ,math_pctile
      ,math_ku
      ,math_rr
      ,sci_rit
      ,sci_pctile
      ,sci_ku
      ,sci_rr
      ,read_rit
      ,read_pctile
      ,read_ku
      ,read_rr
      ,lang_rit
      ,lang_pctile
      ,lang_ku
      ,lang_rr
FROM roster r
LEFT OUTER JOIN data
  ON r.base_student_number = data.base_student_number

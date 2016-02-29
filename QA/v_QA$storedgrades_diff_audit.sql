USE KIPP_NJ
GO

ALTER VIEW QA$storedgrades_diff_audit AS

WITH completed_terms AS (
  SELECT alt_name
  FROM REPORTING$dates WITH(NOLOCK)
  WHERE identifier = 'RT'
    AND academic_year = dbo.fn_Global_Academic_Year()
    AND school_level != 'ES'
    AND end_date < CONVERT(DATE,GETDATE())
 )

,stored AS (
  SELECT SCHOOLID              
        ,STUDENT_NUMBER
        ,credittype
        ,COURSE_NUMBER        
        ,COURSE_NAME
        ,term
        ,term_grade_letter AS term_letter
        ,term_grade_percent AS term_pct
  FROM KIPP_NJ..GRADES$final_grades_long#static WITH(NOLOCK)
  WHERE term IN (SELECT alt_name FROM completed_terms WITH(NOLOCK))
 )

,gradebooks AS (
  SELECT student_number
        ,course_number
        ,gradescaleid
        ,finalgradename
        ,ROUND(pct,0) AS pct
        ,teacher
        ,email_addr
  FROM OPENQUERY(PS_TEAM,'
    SELECT s.lastfirst
          ,s.student_number          
          ,cc.course_number
          ,pgf.finalgradename        
          ,pgf.percent AS pct
          ,t.lastfirst AS teacher
          ,t.email_addr                    
          ,cou.gradescaleid
    FROM ps.students s
    JOIN ps.cc cc
      ON cc.studentid = s.id
     AND ABS(cc.termid) >= 2400
     AND cc.course_number NOT IN (''HR'',''STUDY10'',''CHK'')
    JOIN ps.courses cou
      ON cc.course_number = cou.course_number
    JOIN ps.sections sec
      ON abs(cc.sectionid) = sec.id
     AND sec.termid >= 2400
    JOIN ps.teachers t
      ON sec.teacher = t.id
    JOIN ps.pgfinalgrades pgf
      ON pgf.studentid = s.id
     AND cc.sectionid = pgf.sectionid
     AND pgf.grade != ''--''
     AND (s.schoolid IN (73252, 133570965) AND pgf.finalgradename IN (''T1'',''T2'',''T3'')
            OR s.schoolid = 73253 AND pgf.finalgradename IN (''Q1'',''Q2'',''Q3'',''Q4'',''E1'',''E2''))   
  ') gb /* UPDATE TERMID YEARLY */
 )

SELECT co.schoolid
      ,co.student_number
      ,co.lastfirst
      ,co.grade_level
      ,sub.COURSE_NUMBER
      ,sub.COURSE_NAME
      ,sub.CREDITTYPE
      ,sub.teacher
      ,sub.email_addr
      ,sub.term
      ,sub.stored_pct
      ,sub.stored_letter
      ,sub.stored_gpa_points
      ,sub.gradebook_pct
      ,sub.gradebook_letter
      ,sub.gradebook_gpa_points
      ,sub.spread      
FROM 
    (
     SELECT stored.STUDENT_NUMBER
           ,stored.COURSE_NUMBER
           ,stored.course_name
           ,stored.credittype
           ,gradebooks.teacher
           ,gradebooks.email_addr
           ,stored.term
           ,CONVERT(FLOAT,stored.term_pct) AS stored_pct
           ,stored.term_letter AS stored_letter
           ,CONVERT(FLOAT,stored_scale.grade_points) AS stored_gpa_points
           ,CONVERT(FLOAT,gradebooks.pct) AS gradebook_pct                 
           ,scale.letter_grade AS gradebook_letter
           ,CONVERT(FLOAT,scale.grade_points) AS gradebook_gpa_points
           ,gradebooks.pct - stored.term_pct AS spread
           ,CASE             
             WHEN stored.term_pct = gradebooks.pct THEN 0
             WHEN stored.SCHOOLID = 133570965 AND (stored.term_pct = 55 AND gradebooks.pct < 55) THEN 0
             WHEN stored.SCHOOLID = 73253 AND (stored.term_pct = 50 AND gradebooks.pct < 50) THEN 0             
             ELSE 1
            END AS diff           
     FROM gradebooks WITH(NOLOCK)
     JOIN stored WITH(NOLOCK)
       ON gradebooks.student_number = stored.STUDENT_NUMBER
      AND gradebooks.course_number = stored.COURSE_NUMBER
      AND gradebooks.finalgradename = stored.term 
     JOIN GRADES$grade_scales#static scale WITH(NOLOCK)       
       ON gradebooks.gradescaleid = scale.scale_id
      AND gradebooks.pct >= scale.low_cut
      AND gradebooks.pct < scale.high_cut
     JOIN GRADES$grade_scales#static stored_scale WITH(NOLOCK)       
       ON gradebooks.gradescaleid = stored_scale.scale_id
      AND gradebooks.pct >= stored_scale.low_cut
      AND gradebooks.pct < stored_scale.high_cut
    ) sub
JOIN KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK)
  ON sub.student_number = co.student_number
 AND co.year = KIPP_NJ.dbo.fn_Global_Academic_Year()
 AND co.rn = 1
WHERE sub.diff = 1
  AND (ABS(sub.spread) > 1 OR sub.stored_letter != sub.gradebook_letter OR sub.stored_gpa_points != sub.gradebook_gpa_points)
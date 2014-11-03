USE KIPP_NJ
GO

ALTER VIEW QA$storedgrades_diff_audit AS

WITH completed_terms AS (
  SELECT alt_name
  FROM REPORTING$dates WITH(NOLOCK)
  WHERE identifier = 'RT'
    AND academic_year = dbo.fn_Global_Academic_Year()
    AND school_level != 'ES'
    AND end_date <= GETDATE()
 )

,ms_stored AS (
  SELECT SCHOOLID 
        ,grade_level
        ,LASTFIRST
        ,STUDENT_NUMBER
        ,credittype
        ,COURSE_NUMBER        
        ,COURSE_NAME
        ,finalgradename
        ,pct
  FROM GRADES$DETAIL#MS WITH(NOLOCK)
  UNPIVOT (
     pct
     FOR finalgradename IN ([T1],[T2],[T3])
   ) u
 )

,hs_stored AS (
  SELECT schoolid
        ,grade_level
        ,lastfirst
        ,STUDENT_NUMBER
        ,credittype
        ,COURSE_NUMBER
        ,course_name
        ,finalgradename
        ,pct AS pct
  FROM GRADES$DETAIL#NCA WITH(NOLOCK)
  UNPIVOT (
     pct
     FOR finalgradename IN ([Q1],[Q2],[Q3],[Q4],[E1],[E2])
   ) u
 )

,stored AS (
  SELECT *
  FROM ms_stored
  WHERE finalgradename IN (SELECT alt_name FROM completed_terms WITH(NOLOCK))
  UNION ALL
  SELECT *
  FROM hs_stored
  WHERE finalgradename IN (SELECT alt_name FROM completed_terms WITH(NOLOCK))
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

SELECT SCHOOLID
      ,STUDENT_NUMBER
      ,LASTFIRST
      ,grade_level
      ,COURSE_NUMBER
      ,COURSE_NAME
      ,CREDITTYPE
      ,teacher
      ,email_addr
      ,UPPER(finalgradename) AS finalgradename
      ,stored_pct
      ,gradebook_pct
      ,gradebook_letter
      ,gradebook_gpa_points
      ,spread      
FROM 
    (
     SELECT stored.schoolid
           ,stored.LASTFIRST
           ,stored.grade_level
           ,stored.STUDENT_NUMBER
           ,stored.COURSE_NUMBER
           ,stored.course_name
           ,stored.credittype
           ,gradebooks.teacher
           ,gradebooks.email_addr
           ,stored.finalgradename           
           ,stored.pct AS stored_pct
           ,gradebooks.pct AS gradebook_pct      
           ,scale.grade_points AS gradebook_gpa_points
           ,scale.letter_grade AS gradebook_letter
           ,gradebooks.pct - stored.pct AS spread
           ,CASE
             WHEN stored.SCHOOLID = 133570965 AND stored.pct >= 55 AND gradebooks.pct >= 55 AND gradebooks.pct != stored.pct THEN 1
             WHEN stored.SCHOOLID = 73253 AND stored.pct >= 50 AND gradebooks.pct >= 50 AND gradebooks.pct != stored.pct THEN 1
             WHEN stored.SCHOOLID = 73252 AND gradebooks.pct != stored.pct THEN 1
             ELSE 0
            END AS diff
           
     FROM gradebooks WITH(NOLOCK)
     JOIN stored WITH(NOLOCK)
       ON gradebooks.student_number = stored.STUDENT_NUMBER
      AND gradebooks.course_number = stored.COURSE_NUMBER
      AND gradebooks.finalgradename = stored.finalgradename 
     JOIN GRADES$grade_scales#static scale WITH(NOLOCK)       
       ON gradebooks.gradescaleid = scale.scale_id
      AND gradebooks.pct >= scale.low_cut
      AND gradebooks.pct < scale.high_cut
    ) sub
WHERE diff = 1
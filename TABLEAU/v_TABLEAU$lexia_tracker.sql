USE KIPP_NJ
GO

ALTER VIEW TABLEAU$lexia_tracker AS 

WITH prev_week_time AS (
  SELECT username
        ,KIPP_NJ.dbo.fn_DateToSY(datestamp) AS academic_year
        ,datestamp
        ,week_time
        ,ROW_NUMBER() OVER(
          PARTITION BY username, KIPP_NJ.dbo.fn_DateToSY(datestamp)
            ORDER BY datestamp DESC) AS rn
  FROM KIPP_NJ..LEXIA$units_to_target WITH(NOLOCK)
  WHERE DATEPART(WEEKDAY,datestamp) = 1
 )

SELECT co.student_number
      ,co.lastfirst
      ,co.year
      ,co.reporting_schoolid AS schoolid
      ,co.grade_level
      --,co.student_web_id
      ,co.spedlep
      ,ROW_NUMBER() OVER(
         PARTITION BY co.student_number, co.year
           ORDER BY CONVERT(DATE,lex.activity_timestamp) DESC) AS rn_curr
      
      ,enr.teacher_name
      ,enr.SECTION_NUMBER

      ,g.target_units
      ,g.grade_level_target
      ,g.other_level_target
      
      ,lex.username
      ,lex.Lexia_ID
      ,lex.Predictor
      ,lex.activity_name
      ,lex.activity_end_time
      ,lex.accuracy      
      ,lex.rate
      ,lex.percent_completed
      ,lex.status_flag_complete
      ,lex.duration_minutes
      ,lex.all_ccss_inLR      
      ,lex.grade_level_material
      ,lex.units_to_target
      ,lex.today_mins
      ,lex.today_units
      ,lex.week_time
      ,lex.weekly_target
      ,lex.meeting_target_usage
      /*
      --,lex.district_id
      --,lex.District_name
      --,lex.school_id
      --,lex.school_name
      --,lex.classes
      --,lex.class_names
      
      --,lex.fname
      --,lex.lname
      --,lex.grade_label
      --,lex.Predictor_date
      --,lex.risk_level    
      --,lex.activity_id
      --,lex.activity_type
      --,lex.activity_subject
      --,lex.activity_start_time
      --,lex.activity_timestamp      
      --,lex.practice_indicator
      --,lex.High
      --,lex.Fast
      --,lex.advanced      
      --,lex.standards_type
      --,lex.ccssids
      --,lex.activities_in_level
      --,lex.levelname
      --,lex.studentrefid
      --,lex.schoolrefid
      --,lex.classrefid    
      */     
      
      ,ISNULL(g.target_units,0) - ISNULL(lex.units_to_target,0) AS units_completed
      ,CONVERT(FLOAT,(ISNULL(g.target_units,0.0) - ISNULL(lex.units_to_target,0.0))) / CONVERT(FLOAT,g.target_units) AS pct_to_target

      ,pw.week_time AS prev_week_time
FROM KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK)
LEFT OUTER JOIN KIPP_NJ..PS$course_enrollments#static enr WITH(NOLOCK)
  ON co.student_number = enr.student_number
 AND co.year = enr.academic_year
 AND enr.COURSE_NUMBER = 'HR'
 AND enr.drop_flags = 0
JOIN KIPP_NJ..AUTOLOAD$LEXIA_detail lex WITH(NOLOCK)
  ON co.student_web_id = lex.username
 AND co.year = KIPP_NJ.dbo.fn_DateToSY(lex.activity_timestamp)
LEFT OUTER JOIN KIPP_NJ..LEXIA$goals#static g WITH(NOLOCK)
  ON co.student_number = g.STUDENT_NUMBER
 AND co.year = g.academic_year
LEFT OUTER JOIN prev_week_time pw
  ON co.student_web_id = pw.username
 AND co.year = pw.academic_year
 AND pw.rn = 1
WHERE co.year >= 2015
  AND co.grade_level <= 8
  AND co.rn = 1
  AND co.enroll_status = 0
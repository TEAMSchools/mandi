USE KIPP_NJ
GO

ALTER PROCEDURE sp_PS$course_enrollments#MERGE AS

BEGIN

  /* drop temp table if exists */
  IF OBJECT_ID(N'tempdb..#course_enrollments') IS NOT NULL
    BEGIN
				    DROP TABLE #course_enrollments
    END;

  /* load into temp table */
  SELECT *        
  INTO #course_enrollments
  FROM KIPP_NJ..PS$course_enrollments;

  /* merge into destination table */
  MERGE KIPP_NJ..PS$course_enrollments#static AS TARGET
  USING #course_enrollments AS SOURCE
     ON TARGET.ccid = SOURCE.ccid    
  WHEN MATCHED THEN
   UPDATE
    SET TARGET.ccid = SOURCE.ccid
       ,TARGET.STUDENTID = SOURCE.STUDENTID
       ,TARGET.student_number = SOURCE.student_number
       ,TARGET.SCHOOLID = SOURCE.SCHOOLID
       ,TARGET.grade_level = SOURCE.grade_level
       ,TARGET.academic_year = SOURCE.academic_year
       ,TARGET.termid = SOURCE.termid
       ,TARGET.CREDITTYPE = SOURCE.CREDITTYPE
       ,TARGET.COURSE_NAME = SOURCE.COURSE_NAME
       ,TARGET.COURSE_NUMBER = SOURCE.COURSE_NUMBER
       ,TARGET.sectionid = SOURCE.sectionid
       ,TARGET.SECTION_NUMBER = SOURCE.SECTION_NUMBER
       ,TARGET.period = SOURCE.period
       ,TARGET.dateenrolled = SOURCE.dateenrolled
       ,TARGET.dateleft = SOURCE.dateleft
       ,TARGET.lastgradeupdate = SOURCE.lastgradeupdate
       ,TARGET.sectionsDCID = SOURCE.sectionsDCID
       ,TARGET.TEACHERNUMBER = SOURCE.TEACHERNUMBER
       ,TARGET.teacher_name = SOURCE.teacher_name
       ,TARGET.teacher_coach = SOURCE.teacher_coach
       ,TARGET.TNTP_effectiveness = SOURCE.TNTP_effectiveness
       ,TARGET.CREDIT_HOURS = SOURCE.CREDIT_HOURS
       ,TARGET.GRADESCALEID = SOURCE.GRADESCALEID
       ,TARGET.EXCLUDEFROMGPA = SOURCE.EXCLUDEFROMGPA
       ,TARGET.EXCLUDEFROMSTOREDGRADES = SOURCE.EXCLUDEFROMSTOREDGRADES
       ,TARGET.tier = SOURCE.tier
       ,TARGET.tier_numeric = SOURCE.tier_numeric
       ,TARGET.behavior_tier = SOURCE.behavior_tier
       ,TARGET.behavior_tier_numeric = SOURCE.behavior_tier_numeric
       ,TARGET.drop_flags = SOURCE.drop_flags
       ,TARGET.course_enr_status = SOURCE.course_enr_status
       ,TARGET.illuminate_subject = SOURCE.illuminate_subject
       ,TARGET.measurementscale = SOURCE.measurementscale
       ,TARGET.rn_subject = SOURCE.rn_subject
  WHEN NOT MATCHED BY TARGET THEN
   INSERT
    (ccid
    ,STUDENTID
    ,student_number
    ,SCHOOLID
    ,grade_level
    ,academic_year
    ,termid
    ,CREDITTYPE
    ,COURSE_NAME
    ,COURSE_NUMBER
    ,sectionid
    ,SECTION_NUMBER
    ,period
    ,dateenrolled
    ,dateleft
    ,lastgradeupdate
    ,sectionsDCID
    ,TEACHERNUMBER
    ,teacher_name
    ,teacher_coach
    ,TNTP_effectiveness
    ,CREDIT_HOURS
    ,GRADESCALEID
    ,EXCLUDEFROMGPA
    ,EXCLUDEFROMSTOREDGRADES
    ,tier
    ,tier_numeric
    ,behavior_tier
    ,behavior_tier_numeric
    ,drop_flags
    ,course_enr_status
    ,illuminate_subject
    ,measurementscale
    ,rn_subject)
   VALUES
    (SOURCE.ccid
    ,SOURCE.STUDENTID
    ,SOURCE.student_number
    ,SOURCE.SCHOOLID
    ,SOURCE.grade_level
    ,SOURCE.academic_year
    ,SOURCE.termid
    ,SOURCE.CREDITTYPE
    ,SOURCE.COURSE_NAME
    ,SOURCE.COURSE_NUMBER
    ,SOURCE.sectionid
    ,SOURCE.SECTION_NUMBER
    ,SOURCE.period
    ,SOURCE.dateenrolled
    ,SOURCE.dateleft
    ,SOURCE.lastgradeupdate
    ,SOURCE.sectionsDCID
    ,SOURCE.TEACHERNUMBER
    ,SOURCE.teacher_name
    ,SOURCE.teacher_coach
    ,SOURCE.TNTP_effectiveness
    ,SOURCE.CREDIT_HOURS
    ,SOURCE.GRADESCALEID
    ,SOURCE.EXCLUDEFROMGPA
    ,SOURCE.EXCLUDEFROMSTOREDGRADES
    ,SOURCE.tier
    ,SOURCE.tier_numeric
    ,SOURCE.behavior_tier
    ,SOURCE.behavior_tier_numeric
    ,SOURCE.drop_flags
    ,SOURCE.course_enr_status
    ,SOURCE.illuminate_subject
    ,SOURCE.measurementscale
    ,SOURCE.rn_subject); 

END
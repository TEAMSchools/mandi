USE gabby
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE powerschool.ps_adaadm_daily_ctod#merge AS

DECLARE @academic_year int
  SET @academic_year = gabby.utility.Global_Academic_Year()

BEGIN 
  MERGE gabby.powerschool.ps_adaadm_daily_ctod#static AS TARGET
  USING (
         SELECT studentid
               ,calendardate
               ,schoolid
               ,fteid
               ,attendance_conversion_id
               ,attendancevalue
               ,membershipvalue
               ,grade_level
               ,ontrack
               ,offtrack
               ,student_track
               ,potential_attendancevalue
         FROM gabby.powerschool.ps_adaadm_daily_ctod
         WHERE calendardate >= DATEFROMPARTS(2016, 07, 01)
        ) AS SOURCE
     ON TARGET.studentid = SOURCE.studentid
    AND TARGET.calendardate = SOURCE.calendardate
  WHEN MATCHED THEN
   UPDATE
    SET TARGET.schoolid = SOURCE.schoolid
       ,TARGET.fteid = SOURCE.fteid
       ,TARGET.attendance_conversion_id = SOURCE.attendance_conversion_id
       ,TARGET.attendancevalue = SOURCE.attendancevalue
       ,TARGET.membershipvalue = SOURCE.membershipvalue
       ,TARGET.grade_level = SOURCE.grade_level
       ,TARGET.ontrack = SOURCE.ontrack
       ,TARGET.offtrack = SOURCE.offtrack
       ,TARGET.student_track = SOURCE.student_track
       ,TARGET.potential_attendancevalue = SOURCE.potential_attendancevalue
  WHEN NOT MATCHED BY TARGET THEN
   INSERT
    (schoolid
    ,fteid
    ,attendance_conversion_id
    ,attendancevalue
    ,membershipvalue
    ,grade_level
    ,ontrack
    ,offtrack
    ,student_track
    ,potential_attendancevalue)
   VALUES
    (SOURCE.schoolid
    ,SOURCE.fteid
    ,SOURCE.attendance_conversion_id
    ,SOURCE.attendancevalue
    ,SOURCE.membershipvalue
    ,SOURCE.grade_level
    ,SOURCE.ontrack
    ,SOURCE.offtrack
    ,SOURCE.student_track
    ,SOURCE.potential_attendancevalue)
  WHEN NOT MATCHED BY SOURCE AND TARGET.CALENDARDATE >= DATEFROMPARTS(@academic_year, 07, 01) THEN
    DELETE
  --OUTPUT $ACTION, deleted.*
  ;
END

GO
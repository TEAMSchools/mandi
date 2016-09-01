USE KIPP_NJ
GO

ALTER PROCEDURE sp_ATT_MEM$MEMBERSHIP#MERGE AS

BEGIN 

  WITH mem_update AS (
    SELECT *
          ,KIPP_NJ.dbo.fn_DateToSY(calendardate) AS academic_year  
          ,GETDATE() AS last_updated
    FROM OPENQUERY(PS_TEAM,'
      SELECT ctod.studentid         
            ,ctod.schoolid
            ,ctod.calendardate         
            ,ctod.attendancevalue
            ,ctod.membershipvalue             
            ,ctod.potential_attendancevalue
      FROM ps_adaadm_daily_ctod ctod   
      WHERE calendardate >= TO_DATE(''2016-07-01'',''YYYY-MM-DD'') /* UPDATE ANNUALLY */
        AND calendardate <= TRUNC(SYSDATE)
    ')
   )

  MERGE KIPP_NJ..ATT_MEM$MEMBERSHIP AS TARGET
  USING mem_update AS SOURCE
     ON TARGET.studentid = SOURCE.studentid
    AND TARGET.calendardate = SOURCE.calendardate
  WHEN MATCHED THEN
   UPDATE
    SET TARGET.schoolid = SOURCE.schoolid
       ,TARGET.attendancevalue = SOURCE.attendancevalue
       ,TARGET.membershipvalue = SOURCE.membershipvalue
       ,TARGET.potential_attendancevalue = SOURCE.potential_attendancevalue       
       ,TARGET.academic_year = SOURCE.academic_year
       ,TARGET.last_updated = SOURCE.last_updated
  WHEN NOT MATCHED BY TARGET THEN
   INSERT
    (STUDENTID
    ,SCHOOLID
    ,CALENDARDATE
    ,ATTENDANCEVALUE
    ,MEMBERSHIPVALUE
    ,POTENTIAL_ATTENDANCEVALUE
    ,academic_year
    ,last_updated)
   VALUES
    (SOURCE.STUDENTID
    ,SOURCE.SCHOOLID
    ,SOURCE.CALENDARDATE
    ,SOURCE.ATTENDANCEVALUE
    ,SOURCE.MEMBERSHIPVALUE
    ,SOURCE.POTENTIAL_ATTENDANCEVALUE
    ,SOURCE.academic_year
    ,SOURCE.last_updated)
  WHEN NOT MATCHED BY SOURCE AND TARGET.CALENDARDATE >= '2016-07-01' THEN /* UPDATE ANUALLY */
   DELETE;
  --OUTPUT $ACTION, deleted.*;

END

GO
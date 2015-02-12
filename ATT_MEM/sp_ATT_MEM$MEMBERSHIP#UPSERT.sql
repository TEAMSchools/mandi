USE KIPP_NJ
GO

ALTER PROCEDURE sp_ATT_MEM$MEMBERSHIP#UPSERT AS

BEGIN 

  WITH mem_update AS (
    SELECT *
          ,KIPP_NJ.dbo.fn_DateToSY(calendardate) AS academic_year  
    FROM OPENQUERY(PS_TEAM,'
      SELECT ctod.studentid         
            ,ctod.schoolid
            ,ctod.calendardate         
            ,ctod.attendancevalue
            ,ctod.membershipvalue             
            ,ctod.potential_attendancevalue
      FROM ps_adaadm_daily_ctod ctod   
      WHERE calendardate >= TO_DATE(''2014-08-01'',''YYYY-MM-DD'') 
        AND calendardate <= TRUNC(SYSDATE)
    ')
   )

  MERGE KIPP_NJ..ATT_MEM$MEMBERSHIP AS TARGET
  USING mem_update AS SOURCE
     ON TARGET.studentid = SOURCE.studentid
    AND TARGET.calendardate = SOURCE.calendardate
  WHEN MATCHED THEN
   UPDATE
    SET TARGET.attendancevalue = SOURCE.attendancevalue
       ,TARGET.membershipvalue = SOURCE.membershipvalue
       ,TARGET.potential_attendancevalue = SOURCE.potential_attendancevalue       
  WHEN NOT MATCHED THEN
   INSERT
    (STUDENTID
    ,SCHOOLID
    ,CALENDARDATE
    ,ATTENDANCEVALUE
    ,MEMBERSHIPVALUE
    ,POTENTIAL_ATTENDANCEVALUE
    ,academic_year)
   VALUES
    (SOURCE.STUDENTID
    ,SOURCE.SCHOOLID
    ,SOURCE.CALENDARDATE
    ,SOURCE.ATTENDANCEVALUE
    ,SOURCE.MEMBERSHIPVALUE
    ,SOURCE.POTENTIAL_ATTENDANCEVALUE
    ,SOURCE.academic_year);

END

GO
USE KIPP_NJ
GO

ALTER PROCEDURE sp_ATT_MEM$MEMBERSHIP#MERGE AS

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
      WHERE calendardate >= TO_DATE(''2015-08-01'',''YYYY-MM-DD'') 
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
  WHEN NOT MATCHED BY TARGET THEN
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
    ,SOURCE.academic_year)
  WHEN NOT MATCHED BY SOURCE AND TARGET.CALENDARDATE >= CONVERT(DATE,CONCAT(KIPP_NJ.dbo.fn_Global_Academic_Year(), '-08-01')) THEN
   DELETE;
  --OUTPUT $ACTION, deleted.*;

END

GO
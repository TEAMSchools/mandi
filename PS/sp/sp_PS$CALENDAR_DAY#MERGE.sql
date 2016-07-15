USE KIPP_NJ
GO

ALTER PROCEDURE sp_PS$CALENDAR_DAY#MERGE AS

BEGIN

  IF OBJECT_ID(N'tempdb..#calendar_update') IS NOT NULL
    BEGIN
      DROP TABLE #calendar_update
    END;

  BEGIN
    SELECT *
          ,KIPP_NJ.dbo.fn_DateToSY(date_value) AS academic_year
    INTO #calendar_update
    FROM OPENQUERY(PS_TEAM,'
      SELECT schoolid
            ,date_value
            ,membershipvalue
            ,insession        
            ,type
            ,note
      FROM CALENDAR_DAY
      WHERE date_value >= TO_DATE(''2016-07-01'',''YYYY-MM-DD'') /* UPDATE ANNUALLY */
        AND schoolid NOT IN (999999)
    ');
  END

  BEGIN
    MERGE KIPP_NJ..PS$CALENDAR_DAY AS TARGET
    USING #calendar_update AS SOURCE
       ON TARGET.schoolid = SOURCE.schoolid
      AND TARGET.date_value = SOURCE.date_value
    WHEN MATCHED THEN 
     UPDATE
      SET TARGET.schoolid = SOURCE.schoolid
         ,TARGET.date_value = SOURCE.date_value
         ,TARGET.membershipvalue = SOURCE.membershipvalue
         ,TARGET.insession = SOURCE.insession
         ,TARGET.type = SOURCE.type
         ,TARGET.note = SOURCE.note
         ,TARGET.academic_year = SOURCE.academic_year
    WHEN NOT MATCHED BY TARGET THEN 
     INSERT
       (schoolid
       ,date_value
       ,membershipvalue
       ,insession
       ,type
       ,note
       ,academic_year)
     VALUES
       (SOURCE.schoolid
       ,SOURCE.date_value
       ,SOURCE.membershipvalue
       ,SOURCE.insession
       ,SOURCE.type
       ,SOURCE.note
       ,SOURCE.academic_year)
    WHEN NOT MATCHED BY SOURCE AND TARGET.date_value >= '2016-07-01' THEN /* UPDATE ANNUALLY */
      DELETE
    --OUTPUT $ACTION, DELETED.*
    ;
  END

END
GO
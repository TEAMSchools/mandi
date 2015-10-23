USE KIPP_NJ
GO

ALTER PROCEDURE sp_ATT_MEM$PS_ATTENDANCE_MEETING#MERGE AS

BEGIN

  IF OBJECT_ID(N'tempdb..#meeting_att') IS NOT NULL
    BEGIN
      DROP TABLE #meeting_att;
    END  

  BEGIN
    SELECT schoolid
          ,studentid
          ,sectionid
          ,KIPP_NJ.dbo.fn_DateToSY(CONVERT(DATE,att_date)) AS academic_year
          ,CONVERT(DATE,att_date) AS att_date
          ,att_code      
          ,period_abbreviation
    INTO #meeting_att
    FROM OPENQUERY(PS_TEAM,'
      SELECT att.studentid
            ,att.schoolid
            ,att.att_date
            ,att.att_code
            ,att.sectionid
            ,att.period_abbreviation        
      FROM PS_ATTENDANCE_meeting att
      JOIN terms
        ON att.att_date BETWEEN terms.firstday AND terms.lastday
       AND terms.schoolid = att.schoolid
       AND terms.portion = 1
      WHERE TRUNC(att.att_date) >= TO_DATE(''2015-08-01'',''YYYY-MM-DD'')      
        AND TRUNC(att.att_date) <= TRUNC(SYSDATE)
        AND att.period_abbreviation NOT IN (''HRA'',''HR'',''P0'')
    ');
  END  

  BEGIN  
    MERGE KIPP_NJ..ATT_MEM$PS_ATTENDANCE_MEETING AS TARGET
    USING #meeting_att AS SOURCE
       ON TARGET.studentid = SOURCE.studentid
      AND TARGET.sectionid = SOURCE.sectionid
      AND TARGET.period_abbreviation = SOURCE.period_abbreviation
      AND TARGET.att_date = SOURCE.att_date    
    WHEN MATCHED THEN
     UPDATE
      SET TARGET.schoolid = SOURCE.schoolid       
         ,TARGET.academic_year = SOURCE.academic_year       
         ,TARGET.att_code = SOURCE.att_code
         ,TARGET.period_abbreviation = SOURCE.period_abbreviation
    WHEN NOT MATCHED BY TARGET THEN
     INSERT
      (schoolid
      ,studentid
      ,sectionid
      ,academic_year
      ,att_date
      ,att_code
      ,period_abbreviation)
     VALUES
      (SOURCE.schoolid
      ,SOURCE.studentid
      ,SOURCE.sectionid
      ,SOURCE.academic_year
      ,SOURCE.att_date
      ,SOURCE.att_code
      ,SOURCE.period_abbreviation)
    WHEN NOT MATCHED BY SOURCE AND TARGET.att_date >= '2015-08-01' THEN
     DELETE;     
  END  

END
GO
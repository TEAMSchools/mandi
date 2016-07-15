USE KIPP_NJ
GO

ALTER PROCEDURE sp_PS$PGFINALGRADES#MERGE AS

BEGIN

  IF OBJECT_ID(N'tempdb..#pgf_update') IS NOT NULL
    BEGIN
      DROP TABLE #pgf_update
    END;

  BEGIN
    SELECT *
          ,KIPP_NJ.dbo.fn_DateToSY(STARTDATE) AS academic_year
    INTO #pgf_update
    FROM OPENQUERY(PS_TEAM,'
      SELECT DCID        
            ,ID        
            ,STUDENTID
            ,SECTIONID        
            ,FINALGRADENAME
            ,GRADE
            ,GRADEBOOKTYPE        
            ,OVERRIDEFG
            ,CASE WHEN grade = ''--'' THEN NULL ELSE PERCENT END AS PERCENT
            ,CASE WHEN grade = ''--'' THEN NULL ELSE POINTS END AS POINTS
            ,POINTSPOSSIBLE        
            ,VARCREDIT
            ,CITIZENSHIP
            ,STARTDATE
            ,ENDDATE
            ,LASTGRADEUPDATE        
      FROM PGFINALGRADES
      WHERE LASTGRADEUPDATE >= TO_DATE(''2016-07-01'',''YYYY-MM-DD'') /* UPDATE ANNUALLY */
    ');
  END

  BEGIN
    MERGE KIPP_NJ..PS$PGFINALGRADES AS TARGET
      USING #pgf_update AS SOURCE
         ON TARGET.DCID = SOURCE.DCID      
      WHEN MATCHED THEN
       UPDATE
        SET TARGET.ID = SOURCE.ID
           ,TARGET.STUDENTID = SOURCE.STUDENTID
           ,TARGET.SECTIONID = SOURCE.SECTIONID
           ,TARGET.FINALGRADENAME = SOURCE.FINALGRADENAME
           ,TARGET.GRADE = SOURCE.GRADE
           ,TARGET.GRADEBOOKTYPE = SOURCE.GRADEBOOKTYPE
           ,TARGET.OVERRIDEFG = SOURCE.OVERRIDEFG
           ,TARGET.[PERCENT] = SOURCE.[PERCENT]
           ,TARGET.POINTS = SOURCE.POINTS
           ,TARGET.POINTSPOSSIBLE = SOURCE.POINTSPOSSIBLE
           ,TARGET.VARCREDIT = SOURCE.VARCREDIT
           ,TARGET.CITIZENSHIP = SOURCE.CITIZENSHIP
           ,TARGET.STARTDATE = SOURCE.STARTDATE
           ,TARGET.ENDDATE = SOURCE.ENDDATE
           ,TARGET.LASTGRADEUPDATE = SOURCE.LASTGRADEUPDATE
           ,TARGET.academic_year = SOURCE.academic_year
      WHEN NOT MATCHED BY TARGET THEN
       INSERT
        (DCID
        ,ID
        ,STUDENTID
        ,SECTIONID
        ,FINALGRADENAME
        ,GRADE
        ,GRADEBOOKTYPE
        ,OVERRIDEFG
        ,[PERCENT]
        ,POINTS
        ,POINTSPOSSIBLE
        ,VARCREDIT
        ,CITIZENSHIP
        ,STARTDATE
        ,ENDDATE
        ,LASTGRADEUPDATE
        ,academic_year)
       VALUES
        (SOURCE.DCID
        ,SOURCE.ID
        ,SOURCE.STUDENTID
        ,SOURCE.SECTIONID
        ,SOURCE.FINALGRADENAME
        ,SOURCE.GRADE
        ,SOURCE.GRADEBOOKTYPE
        ,SOURCE.OVERRIDEFG
        ,SOURCE.[PERCENT]
        ,SOURCE.POINTS
        ,SOURCE.POINTSPOSSIBLE
        ,SOURCE.VARCREDIT
        ,SOURCE.CITIZENSHIP
        ,SOURCE.STARTDATE
        ,SOURCE.ENDDATE
        ,SOURCE.LASTGRADEUPDATE
        ,SOURCE.academic_year)
      WHEN NOT MATCHED BY SOURCE AND CONVERT(DATE,TARGET.LASTGRADEUPDATE) >= CONVERT(DATE,CONCAT(KIPP_NJ.dbo.fn_Global_Academic_Year(), '-07-01')) THEN
       DELETE
      --OUTPUT $ACTION, deleted.*
      ;
  END

END

GO
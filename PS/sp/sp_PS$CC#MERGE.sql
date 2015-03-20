USE KIPP_NJ
GO

ALTER PROCEDURE sp_PS$CC#MERGE AS

BEGIN

  WITH cc_update AS (
    SELECT CONVERT(INT,DCID) AS DCID
          ,CONVERT(INT,ID) AS ID
          ,CONVERT(INT,STUDENTID) AS STUDENTID
          ,CONVERT(INT,SECTIONID) AS SECTIONID
          ,DATEENROLLED
          ,DATELEFT
          ,CONVERT(INT,SCHOOLID) AS SCHOOLID
          ,CONVERT(INT,TERMID) AS TERMID
          ,PERIOD_OBSOLETE
          ,CONVERT(INT,ATTENDANCE_TYPE_CODE) AS ATTENDANCE_TYPE_CODE
          ,CONVERT(INT,UNUSED2) AS UNUSED2
          ,CONVERT(INT,CURRENTABSENCES) AS CURRENTABSENCES
          ,CONVERT(INT,CURRENTTARDIES) AS CURRENTTARDIES
          ,ATTENDANCE
          ,CONVERT(INT,TEACHERID) AS TEACHERID
          ,LASTGRADEUPDATE
          ,SECTION_NUMBER
          ,COURSE_NUMBER
          ,CONVERT(INT,ORIGSECTIONID) AS ORIGSECTIONID
          ,CONVERT(INT,UNUSED3) AS UNUSED3
          ,TEACHERCOMMENT
          ,LASTATTMOD
          ,ASMTSCORES
          ,FIRSTATTDATE
          ,FINALGRADES
          ,CONVERT(INT,STUDYEAR) AS STUDYEAR
          ,[LOG]
          ,EXPRESSION
          ,STUDENTSECTENRL_GUID
          ,TEACHERPRIVATENOTE
          ,AB_COURSE_CMP_FUN_FLG
          ,AB_COURSE_CMP_EXT_CRD
          ,AB_COURSE_CMP_MET_CD
          ,AB_COURSE_EVA_PRO_CD
          ,AB_COURSE_CMP_STA_CD
          ,KIPP_NJ.dbo.fn_DateToSY(DATEENROLLED) AS academic_year
          ,KIPP_NJ.dbo.fn_ExprToPeriod(EXPRESSION) AS period
    FROM OPENQUERY(PS_TEAM,'
      SELECT dcid
            ,id
            ,studentid
            ,sectionid
            ,dateenrolled
            ,dateleft
            ,schoolid
            ,termid
            ,period_obsolete
            ,attendance_type_code
            ,unused2
            ,currentabsences
            ,currenttardies
            ,dbms_lob.substr(attendance, 2000) AS attendance
            ,teacherid
            ,lastgradeupdate
            ,section_number
            ,course_number
            ,origsectionid
            ,unused3
            ,dbms_lob.substr(teachercomment, 2000) AS teachercomment
            ,lastattmod
            ,dbms_lob.substr(asmtscores, 2000) AS asmtscores
            ,firstattdate
            ,dbms_lob.substr(finalgrades, 2000) AS finalgrades
            ,studyear
            ,dbms_lob.substr(log, 2000) AS log
            ,expression
            ,studentsectenrl_guid
            ,dbms_lob.substr(teacherprivatenote, 2000) AS teacherprivatenote
            ,ab_course_cmp_fun_flg
            ,ab_course_cmp_ext_crd
            ,ab_course_cmp_met_cd
            ,ab_course_eva_pro_cd
            ,ab_course_cmp_sta_cd
      FROM CC
      WHERE termid >= 2400
    ')
   )

  MERGE KIPP_NJ..PS$CC#static AS TARGET
  USING cc_update AS SOURCE
     ON TARGET.DCID = SOURCE.DCID        
  WHEN MATCHED THEN
   UPDATE
    SET TARGET.ID = SOURCE.ID
       ,TARGET.STUDENTID = SOURCE.STUDENTID
       ,TARGET.SECTIONID = SOURCE.SECTIONID
       ,TARGET.DATEENROLLED = SOURCE.DATEENROLLED
       ,TARGET.DATELEFT = SOURCE.DATELEFT
       ,TARGET.SCHOOLID = SOURCE.SCHOOLID
       ,TARGET.TERMID = SOURCE.TERMID
       ,TARGET.PERIOD_OBSOLETE = SOURCE.PERIOD_OBSOLETE
       ,TARGET.ATTENDANCE_TYPE_CODE = SOURCE.ATTENDANCE_TYPE_CODE
       ,TARGET.UNUSED2 = SOURCE.UNUSED2
       ,TARGET.CURRENTABSENCES = SOURCE.CURRENTABSENCES
       ,TARGET.CURRENTTARDIES = SOURCE.CURRENTTARDIES
       ,TARGET.ATTENDANCE = SOURCE.ATTENDANCE
       ,TARGET.TEACHERID = SOURCE.TEACHERID
       ,TARGET.LASTGRADEUPDATE = SOURCE.LASTGRADEUPDATE
       ,TARGET.SECTION_NUMBER = SOURCE.SECTION_NUMBER
       ,TARGET.COURSE_NUMBER = SOURCE.COURSE_NUMBER
       ,TARGET.ORIGSECTIONID = SOURCE.ORIGSECTIONID
       ,TARGET.UNUSED3 = SOURCE.UNUSED3
       ,TARGET.TEACHERCOMMENT = SOURCE.TEACHERCOMMENT
       ,TARGET.LASTATTMOD = SOURCE.LASTATTMOD
       ,TARGET.ASMTSCORES = SOURCE.ASMTSCORES
       ,TARGET.FIRSTATTDATE = SOURCE.FIRSTATTDATE
       ,TARGET.FINALGRADES = SOURCE.FINALGRADES
       ,TARGET.STUDYEAR = SOURCE.STUDYEAR
       ,TARGET.LOG = SOURCE.LOG
       ,TARGET.EXPRESSION = SOURCE.EXPRESSION
       ,TARGET.STUDENTSECTENRL_GUID = SOURCE.STUDENTSECTENRL_GUID
       ,TARGET.TEACHERPRIVATENOTE = SOURCE.TEACHERPRIVATENOTE
       ,TARGET.AB_COURSE_CMP_FUN_FLG = SOURCE.AB_COURSE_CMP_FUN_FLG
       ,TARGET.AB_COURSE_CMP_EXT_CRD = SOURCE.AB_COURSE_CMP_EXT_CRD
       ,TARGET.AB_COURSE_CMP_MET_CD = SOURCE.AB_COURSE_CMP_MET_CD
       ,TARGET.AB_COURSE_EVA_PRO_CD = SOURCE.AB_COURSE_EVA_PRO_CD
       ,TARGET.AB_COURSE_CMP_STA_CD = SOURCE.AB_COURSE_CMP_STA_CD
       ,TARGET.academic_year = SOURCE.academic_year
       ,TARGET.period = SOURCE.period
  WHEN NOT MATCHED THEN
   INSERT
    (ID
    ,STUDENTID
    ,SECTIONID
    ,DATEENROLLED
    ,DATELEFT
    ,SCHOOLID
    ,TERMID
    ,PERIOD_OBSOLETE
    ,ATTENDANCE_TYPE_CODE
    ,UNUSED2
    ,CURRENTABSENCES
    ,CURRENTTARDIES
    ,ATTENDANCE
    ,TEACHERID
    ,LASTGRADEUPDATE
    ,SECTION_NUMBER
    ,COURSE_NUMBER
    ,ORIGSECTIONID
    ,UNUSED3
    ,TEACHERCOMMENT
    ,LASTATTMOD
    ,ASMTSCORES
    ,FIRSTATTDATE
    ,FINALGRADES
    ,STUDYEAR
    ,LOG
    ,EXPRESSION
    ,STUDENTSECTENRL_GUID
    ,TEACHERPRIVATENOTE
    ,AB_COURSE_CMP_FUN_FLG
    ,AB_COURSE_CMP_EXT_CRD
    ,AB_COURSE_CMP_MET_CD
    ,AB_COURSE_EVA_PRO_CD
    ,AB_COURSE_CMP_STA_CD
    ,academic_year
    ,period)
   VALUES
    (SOURCE.ID
    ,SOURCE.STUDENTID
    ,SOURCE.SECTIONID
    ,SOURCE.DATEENROLLED
    ,SOURCE.DATELEFT
    ,SOURCE.SCHOOLID
    ,SOURCE.TERMID
    ,SOURCE.PERIOD_OBSOLETE
    ,SOURCE.ATTENDANCE_TYPE_CODE
    ,SOURCE.UNUSED2
    ,SOURCE.CURRENTABSENCES
    ,SOURCE.CURRENTTARDIES
    ,SOURCE.ATTENDANCE
    ,SOURCE.TEACHERID
    ,SOURCE.LASTGRADEUPDATE
    ,SOURCE.SECTION_NUMBER
    ,SOURCE.COURSE_NUMBER
    ,SOURCE.ORIGSECTIONID
    ,SOURCE.UNUSED3
    ,SOURCE.TEACHERCOMMENT
    ,SOURCE.LASTATTMOD
    ,SOURCE.ASMTSCORES
    ,SOURCE.FIRSTATTDATE
    ,SOURCE.FINALGRADES
    ,SOURCE.STUDYEAR
    ,SOURCE.LOG
    ,SOURCE.EXPRESSION
    ,SOURCE.STUDENTSECTENRL_GUID
    ,SOURCE.TEACHERPRIVATENOTE
    ,SOURCE.AB_COURSE_CMP_FUN_FLG
    ,SOURCE.AB_COURSE_CMP_EXT_CRD
    ,SOURCE.AB_COURSE_CMP_MET_CD
    ,SOURCE.AB_COURSE_EVA_PRO_CD
    ,SOURCE.AB_COURSE_CMP_STA_CD
    ,SOURCE.academic_year
    ,SOURCE.period);

END

GO
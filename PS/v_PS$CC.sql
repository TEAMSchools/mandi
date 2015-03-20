USE KIPP_NJ
GO

ALTER VIEW PS$CC AS

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
')
USE KIPP_NJ
GO

ALTER VIEW PS$teacher_by_last_enrollment AS

SELECT cc.schoolid
      ,cc.studentid
      ,cc.teacherid
      ,cc.course_number
      ,cc.termid
      ,cc.sectionid
      ,t.last_name
      ,t.first_name
      ,t.lastfirst
      ,ROW_NUMBER() OVER(
          PARTITION BY cc.studentid, cc.course_number
              ORDER BY cc.termid DESC) AS rn
FROM KIPP_NJ..PS$CC#static cc WITH(NOLOCK)
JOIN KIPP_NJ..PS$TEACHERS#static t WITH(NOLOCK)
  ON cc.teacherid = t.id
WHERE cc.termid >= KIPP_NJ.dbo.fn_Global_Term_Id()
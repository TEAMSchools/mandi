USE KIPP_NJ
GO

ALTER VIEW PS$comments AS

SELECT tco.studentid
      ,cc.SCHOOLID
      ,cc.course_number
      ,tco.sectionid
      ,tco.finalgradename AS term
      ,tco.teacher_comment      
FROM OPENQUERY(PS_TEAM,'
  SELECT pgf.studentid            
        ,pgf.sectionid           
        ,pgf.finalgradename             
        ,CAST(SUBSTR(pgf.comment_value,1,4000) AS varchar2(4000)) AS teacher_comment
  FROM pgfinalgrades pgf       
  WHERE pgf.finalgradename LIKE ''Q%''
    AND pgf.startdate >= ''2015-07-01''
    AND pgf.startdate <= TRUNC(SYSDATE)
    AND pgf.comment_value IS NOT NULL         
') tco /* UPDATE DATE ANNUALLY */
LEFT OUTER JOIN KIPP_NJ..PS$CC#static cc WITH(NOLOCK)
  ON tco.studentid = cc.studentid
 AND tco.sectionid = cc.sectionid
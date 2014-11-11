USE KIPP_NJ
GO

ALTER VIEW PS$comments AS

SELECT tco.studentid
      ,cc.SCHOOLID
      ,cc.course_number
      ,tco.sectionid
      ,tco.finalgradename AS term
      ,CASE WHEN cc.course_number IN ('HR','Adv') THEN NULL ELSE tco.teacher_comment END AS teacher_comment
      ,CASE WHEN cc.course_number IN ('HR','Adv') THEN tco.teacher_comment ELSE NULL END AS advisor_comment
FROM OPENQUERY(PS_TEAM,'
  SELECT pgf.studentid            
        ,pgf.sectionid           
        ,pgf.finalgradename             
        ,CAST(SUBSTR(pgf.comment_value,1,4000) AS varchar2(4000)) AS teacher_comment
  FROM pgfinalgrades pgf       
  WHERE (pgf.finalgradename LIKE ''T%'' OR pgf.finalgradename LIKE ''Q%'')       
    AND pgf.startdate >= ''2014-08-01''
    AND pgf.startdate <= TRUNC(SYSDATE)
    AND pgf.comment_value IS NOT NULL         
') tco /* UPDATE DATE ANNUALLY */
LEFT OUTER JOIN CC WITH(NOLOCK)
  ON tco.studentid = cc.studentid
 AND tco.sectionid = cc.sectionid
USE KIPP_NJ
GO

SELECT s.id
      ,cc.course_number
      ,tco.sectionid
      ,tco.finalgradename
      ,tco.teacher_comment
      ,CASE
        WHEN cc.course_number IN ('HR','Adv') THEN tco.teacher_comment
        ELSE NULL
       END AS advisor_comment
FROM STUDENTS s
JOIN OPENQUERY(PS_TEAM,'
       SELECT pgf.studentid            
             ,pgf.sectionid           
             ,pgf.finalgradename             
             ,CAST(SUBSTR(pgf.comment_value,1,4000) AS varchar2(4000)) AS teacher_comment
       FROM pgfinalgrades pgf       
       WHERE (pgf.finalgradename LIKE ''T%'' OR pgf.finalgradename LIKE ''Q%'')       
         AND pgf.startdate >= TO_DATE(CASE
                                       WHEN TO_CHAR(SYSDATE,''MON'') IN (''JAN'',''FEB'',''MAR'',''APR'',''MAY'',''JUN'',''JUL'')
                                       THEN TO_CHAR(TO_CHAR(SYSDATE,''YYYY'') - 1)
                                       ELSE TO_CHAR(SYSDATE,''YYYY'')
                                      END || ''-08-01'',''YYYY-MM-DD'')    
         AND pgf.comment_value IS NOT NULL         
       ') tco
  ON s.id = tco.studentid
LEFT OUTER JOIN CC
  ON s.id = cc.studentid
 AND cc.sectionid = tco.sectionid
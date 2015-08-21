USE KIPP_NJ
GO

ALTER VIEW TABLEAU$AR_dashboard AS

SELECT ar.*
      ,s.first_name
      ,s.last_name
      ,s.first_name + ' ' + s.last_name AS student_name
      ,cs.ADVISOR
      ,eng1.COURSE_NAME AS eng1_course
      ,eng1.SECTION_NUMBER AS eng1_section
      ,CASE        
        WHEN eng1.expression = '1(A)' THEN 'HR'
        WHEN eng1.expression = '2(A)' THEN '1'
        WHEN eng1.expression = '3(A)' THEN '2'
        WHEN eng1.expression = '4(A)' THEN '3'
        WHEN eng1.expression = '5(A)' THEN '4A'
        WHEN eng1.expression = '6(A)' THEN '4B'
        WHEN eng1.expression = '7(A)' THEN '4C'
        WHEN eng1.expression = '8(A)' THEN '4D'
        WHEN eng1.expression = '9(A)' THEN '5A'
        WHEN eng1.expression = '10(A)' THEN '5B'
        WHEN eng1.expression = '11(A)' THEN '5C'
        WHEN eng1.expression = '12(A)' THEN '5D'
        WHEN eng1.expression = '13(A)' THEN '6'
        WHEN eng1.expression = '14(A)' THEN '7'
        ELSE NULL
       END AS eng1_period
      ,eng1.LASTFIRST AS eng1_teacher
      ,eng2.COURSE_NAME AS eng2_course
      ,eng2.SECTION_NUMBER AS eng2_section
      ,CASE        
        WHEN eng2.expression = '1(A)' THEN 'HR'
        WHEN eng2.expression = '2(A)' THEN '1'
        WHEN eng2.expression = '3(A)' THEN '2'
        WHEN eng2.expression = '4(A)' THEN '3'
        WHEN eng2.expression = '5(A)' THEN '4A'
        WHEN eng2.expression = '6(A)' THEN '4B'
        WHEN eng2.expression = '7(A)' THEN '4C'
        WHEN eng2.expression = '8(A)' THEN '4D'
        WHEN eng2.expression = '9(A)' THEN '5A'
        WHEN eng2.expression = '10(A)' THEN '5B'
        WHEN eng2.expression = '11(A)' THEN '5C'
        WHEN eng2.expression = '12(A)' THEN '5D'
        WHEN eng2.expression = '13(A)' THEN '6'
        WHEN eng2.expression = '14(A)' THEN '7'
        ELSE NULL
       END AS eng2_period
      ,eng2.LASTFIRST AS eng2_teacher      
      ,diff.COURSE_NAME AS diff_block_assignment
      ,diff.LASTFIRST AS diff_block_teacher
      ,CASE        
        WHEN diff.expression = '5(A)' THEN '4B'
        WHEN diff.expression = '6(A)' THEN '4A'
        WHEN diff.expression = '7(A)' THEN '4D'
        WHEN diff.expression = '8(A)' THEN '4C'        
        ELSE NULL
       END AS diff_block_period      
FROM AR$progress_to_goals_long#static ar WITH(NOLOCK)
LEFT OUTER JOIN PS$STUDENTS#static s WITH(NOLOCK)
  ON ar.studentid = s.id
LEFT OUTER JOIN PS$CUSTOM_STUDENTS#static cs WITH(NOLOCK)
  ON ar.studentid = cs.STUDENTID
LEFT OUTER JOIN (
                 SELECT cc.STUDENTID
                       ,c.COURSE_NAME
                       ,c.COURSE_NUMBER
                       ,cc.SECTION_NUMBER
                       ,cc.EXPRESSION
                       ,cc.DATEENROLLED
                       ,cc.DATELEFT
                       ,t.LASTFIRST
                       ,ROW_NUMBER() OVER
                          (PARTITION BY cc.studentid
                               ORDER BY c.course_name) AS rn
                 FROM PS$COURSES#static c WITH (NOLOCK)
                 JOIN PS$CC#static cc WITH (NOLOCK)
                   ON c.COURSE_NUMBER = cc.COURSE_NUMBER
                  AND cc.TERMID >= KIPP_NJ.dbo.fn_Global_Term_Id()
                  --AND cc.SCHOOLID = 73253
                 JOIN PS$TEACHERS#static t WITH (NOLOCK)
                   ON cc.TEACHERID = t.ID
                 WHERE c.CREDITTYPE = 'ENG'
                   AND c.COURSE_NUMBER NOT LIKE 'ENG0%'
                ) eng1
  ON ar.studentid = eng1.STUDENTID
 --AND ar.start_date >= eng1.DATEENROLLED
 --AND ar.end_date <= eng1.DATELEFT
 AND eng1.rn = 1
LEFT OUTER JOIN (
                 SELECT cc.STUDENTID
                       ,c.COURSE_NAME
                       ,c.COURSE_NUMBER
                       ,cc.SECTION_NUMBER                       
                       ,cc.EXPRESSION
                       ,cc.DATEENROLLED
                       ,cc.DATELEFT
                       ,t.LASTFIRST
                       ,ROW_NUMBER() OVER
                          (PARTITION BY cc.studentid
                               ORDER BY c.course_name) AS rn
                 FROM PS$COURSES#static c WITH (NOLOCK)
                 JOIN PS$CC#static cc WITH (NOLOCK)
                   ON c.COURSE_NUMBER = cc.COURSE_NUMBER
                  AND cc.TERMID >= dbo.fn_Global_Term_Id()
                  --AND cc.SCHOOLID = 73253
                 JOIN PS$TEACHERS#static t WITH (NOLOCK)
                   ON cc.TEACHERID = t.ID
                 WHERE c.CREDITTYPE = 'ENG'
                   AND c.COURSE_NUMBER NOT LIKE 'ENG0%'
                ) eng2
  ON ar.studentid = eng2.STUDENTID
 --AND ar.start_date >= eng2.DATEENROLLED
 --AND ar.end_date <= eng2.DATELEFT
 AND eng2.rn = 2
LEFT OUTER JOIN (
                 SELECT cc.STUDENTID     
                       ,cc.TERMID                         
                       ,cc.COURSE_NUMBER
                       ,c.COURSE_NAME                       
                       ,cc.SECTION_NUMBER
                       ,cc.DATEENROLLED
                       ,cc.DATELEFT
                       ,t.TEACHERNUMBER
                       ,t.LASTFIRST
                       ,CC.EXPRESSION
                       ,ROW_NUMBER() OVER
                          (PARTITION BY cc.studentid
                               ORDER BY cc.termid DESC) AS rn
                 FROM PS$CC#static cc WITH (NOLOCK)   
                 JOIN PS$COURSES#static c WITH(NOLOCK)
                   ON cc.COURSE_NUMBER = c.COURSE_NUMBER
                 JOIN PS$TEACHERS#static t WITH (NOLOCK)
                   ON cc.TEACHERID = t.ID                  
                 WHERE cc.TERMID >= dbo.fn_Global_Term_Id()
                   --AND cc.SCHOOLID = 73253
                   AND cc.EXPRESSION IN ('5(A)','6(A)','7(A)','8(A)')
                   AND (cc.COURSE_NUMBER LIKE 'ENG0%' OR cc.COURSE_NUMBER LIKE 'MATH0%')
                ) diff
  ON ar.studentid = diff.studentid
 --AND ar.start_date >= diff.DATEENROLLED
 --AND ar.end_date <= diff.DATELEFT
 AND diff.rn = 1
WHERE ar.yearid >= dbo.fn_Global_Term_Id()
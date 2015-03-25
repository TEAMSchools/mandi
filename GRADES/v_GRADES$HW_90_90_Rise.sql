USE KIPP_NJ
GO

ALTER VIEW GRADES$HW_90_90#Rise AS

WITH roster AS (
  SELECT s.id AS studentid
        ,s.lastfirst
        ,s.first_name + ' ' + s.last_name AS stu_name
        ,s.grade_level
        --,cc.course_number
  FROM KIPP_NJ..STUDENTS s WITH(NOLOCK) 
  WHERE s.schoolid = 73252
    AND s.enroll_status = 0
 )

,curterm AS (
  SELECT time_per_name
        ,alt_name
  FROM KIPP_NJ..REPORTING$dates WITH(NOLOCK)
  WHERE start_date <= CONVERT(DATE,GETDATE())
    AND end_date >= CONVERT(DATE,GETDATE())
    AND identifier = 'RT'
    AND schoolid = 73252
 )

,ele_wide AS (
  SELECT studentid        
        ,[yr_h]
        ,[yr_q]
        ,[cur_h]
        ,[cur_q]
  FROM
      (
       SELECT studentid
             ,CASE 
               WHEN term = 'Y1' AND pgf_type = 'H' THEN 'yr_h'
               WHEN term != 'Y1' AND pgf_type = 'H' THEN 'cur_h'
               WHEN term = 'Y1' AND pgf_type = 'Q' THEN 'yr_q'
               WHEN term != 'Y1' AND pgf_type = 'Q' THEN 'cur_q'
              END AS pivot_hash
             ,ROUND(AVG(grade),0) AS grade
             --,COUNT(studentid) AS n
       FROM KIPP_NJ..GRADES$elements_long WITH(NOLOCK)
       WHERE yearid = LEFT(KIPP_NJ.dbo.fn_Global_Term_Id(),2)
         AND pgf_type IN ('H','Q')
         AND term IN ((SELECT alt_name FROM curterm), 'Y1')
       GROUP BY studentid, term, pgf_type
      ) sub
  PIVOT(
    MAX(grade)
    FOR pivot_hash IN ([yr_h]
                      ,[yr_q]
                      ,[cur_h]
                      ,[cur_q])
   ) p
 )

SELECT sub.*
      ,CASE
         WHEN cur_q >= 90 AND cur_h >= 90 THEN 'Above'
         WHEN cur_q < 70 OR cur_h < 70 THEN 'Below'
         WHEN cur_q >= 70 AND cur_h >= 70 THEN 'Middle'
       END AS cur_ninety_ninety_status
      ,CASE
         WHEN yr_q >= 90 AND yr_h >= 90 THEN 'Above'
         WHEN yr_q < 70 OR yr_h < 70 THEN 'Below'
         WHEN yr_q >= 70 AND yr_h >= 70 THEN 'Middle'
       END AS yr_ninety_ninety_status
FROM
    (
     SELECT roster.studentid
           ,roster.lastfirst
           ,roster.stu_name
           ,roster.grade_level           
           ,e.cur_q
           ,e.cur_h
           ,e.yr_q
           ,e.yr_h
           --,e.n
     FROM roster
     LEFT OUTER JOIN ele_wide e
       ON roster.studentid = e.studentid     
    ) sub
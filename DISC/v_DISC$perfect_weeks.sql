USE KIPP_NJ
GO

ALTER VIEW DISC$perfect_weeks AS

WITH roster AS (
  SELECT co.student_number
        ,co.studentid        
        ,co.entrydate        
        ,co.exitdate        
        ,co.year AS academic_year
  FROM KIPP_NJ..COHORT$comprehensive_long#static co WITH(NOLOCK)
  WHERE co.schoolid = 73253
    AND co.rn = 1    
 )

,weeks AS (  
  SELECT academic_year
        ,rt
        ,wk
        ,MIN(calendardate) OVER(PARTITION BY academic_year, wk) AS week_of
        ,calendardate
        ,is_past
  FROM
      (
       SELECT DISTINCT
              CONVERT(DATE,mem.calendardate) AS calendardate
             ,DATEPART(WEEK,mem.calendardate) AS wk
             ,mem.academic_year
             ,dt.time_per_name AS rt             
             ,CASE 
               WHEN CONVERT(INT,CONCAT(DATEPART(YEAR,GETDATE()), DATEPART(WEEK,GETDATE()))) 
                     > CONVERT(INT,CONCAT(DATEPART(YEAR,mem.calendardate), DATEPART(WEEK,mem.calendardate))) THEN 1
               ELSE 0
              END AS is_past        
       FROM KIPP_NJ..ATT_MEM$MEMBERSHIP mem WITH(NOLOCK)
       JOIN KIPP_NJ..REPORTING$dates dt WITH(NOLOCK)
         ON mem.schoolid = dt.schoolid
        AND mem.academic_year = dt.academic_year
        AND mem.calendardate >= dt.start_date
        AND mem.calendardate <= dt.end_date 
        AND dt.identifier = 'RT'        
       WHERE mem.schoolid = 73253         
      ) sub 
 )

,curterm AS (
  SELECT academic_year
        ,time_per_name
  FROM REPORTING$dates WITH(NOLOCK)
  WHERE identifier = 'RT' 
    AND start_date <= CONVERT(DATE,GETDATE())
    AND end_date >= CONVERT(DATE,GETDATE())
    AND schoolid = 73253
 )

,demerits AS (
  SELECT demerits.studentid        
        ,demerits.academic_year
        ,DATEPART(WEEK,demerits.entry_date) AS wk
        ,CASE WHEN COUNT(studentid) > 0 THEN 0 ELSE 1 END AS is_perfect
  FROM DISC$log#static demerits WITH(NOLOCK)
  WHERE demerits.logtypeid = 3223
    AND demerits.schoolid = 73253    
  GROUP BY demerits.studentid
          ,demerits.academic_year
          ,DATEPART(WEEK,demerits.entry_date)
 )

SELECT DISTINCT 
       r.student_number
      ,r.studentid
      ,r.academic_year
      ,w.rt           
      ,w.week_of
      ,ISNULL(d.is_perfect, 1) AS is_perfect
      ,CASE WHEN w.rt = curterm.time_per_name AND w.is_past = 1 THEN ISNULL(d.is_perfect, 1) ELSE 0 END AS is_perfect_cur           
FROM roster r
JOIN weeks w
  ON r.academic_year = w.academic_year      
 AND w.calendardate BETWEEN r.entrydate AND r.exitdate
 AND w.is_past = 1
LEFT OUTER JOIN curterm
  ON r.academic_year = curterm.academic_year
LEFT OUTER JOIN demerits d
  ON r.studentid = d.studentid      
 AND r.academic_year = d.academic_year
 AND w.wk = d.wk
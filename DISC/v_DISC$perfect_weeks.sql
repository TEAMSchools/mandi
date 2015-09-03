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
       SELECT CONVERT(DATE,mem.date_value) AS calendardate
             ,DATEPART(WEEK,mem.date_value) AS wk
             ,mem.academic_year
             ,dt.time_per_name AS rt             
             ,CASE 
               WHEN 
                 CONVERT(INT,CONCAT(DATEPART(YEAR,GETDATE()), DATEPART(WEEK,GETDATE()))) > CONVERT(INT,CONCAT(DATEPART(YEAR,mem.date_value), DATEPART(WEEK,mem.date_value))) THEN 1
               ELSE 0
              END AS is_past        
       FROM KIPP_NJ..PS$CALENDAR_DAY mem WITH(NOLOCK)
       JOIN KIPP_NJ..REPORTING$dates dt WITH(NOLOCK)
         ON mem.schoolid = dt.schoolid
        AND mem.academic_year = dt.academic_year
        AND mem.date_value BETWEEN dt.start_date AND dt.end_date 
        AND dt.identifier = 'RT'        
       WHERE mem.schoolid = 73253       
         AND mem.membershipvalue = 1
      ) sub 
 )

,curterm AS (
  SELECT academic_year
        ,time_per_name
  FROM REPORTING$dates WITH(NOLOCK)
  WHERE identifier = 'RT' 
    AND CONVERT(DATE,GETDATE()) BETWEEN start_date AND end_date
    AND schoolid = 73253
 )

,demerits AS (
  SELECT demerits.studentid        
        ,demerits.academic_year
        ,DATEPART(WEEK,demerits.entry_date) AS wk
        ,COUNT(studentid) AS n_demerits
  FROM KIPP_NJ..DISC$log#static demerits WITH(NOLOCK)
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
      ,CASE WHEN d.studentid IS NULL THEN 1 ELSE 0 END AS is_perfect
      ,CASE WHEN w.rt = curterm.time_per_name AND w.is_past = 1 AND d.studentid IS NULL THEN 1 ELSE 0 END AS is_perfect_cur           
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
USE KIPP_NJ
GO

ALTER VIEW TABLEAU$grade_level_tracker#TEAM AS 

WITH roster AS (
  SELECT co.year
        ,co.schoolid
        ,co.studentid
        ,co.student_number
        ,co.lastfirst
        ,co.grade_level
        ,co.team
        ,co.advisor
        ,co.enroll_status      
        ,co.term
        ,CONCAT(DATEPART(YEAR,co.date), DATEPART(WEEK,co.date)) AS yr_week_hash        
        ,co.date AS week_of            
  FROM KIPP_NJ..COHORT$identifiers_scaffold#static co WITH(NOLOCK)
  WHERE co.year = KIPP_NJ.dbo.fn_Global_Academic_Year()
    AND co.schoolid = 133570965 
    AND co.date <= CONVERT(DATE,GETDATE())
    AND DATEPART(DW,co.date) = 6
)

,kb_weekly AS (
  SELECT student_number        
        ,yr_week_hash
        ,SUM(points_denom) + ISNULL(SUM(points_num),0) AS points_total
        --,SUM(points_denom) AS points_denom
        ,ISNULL(
            ROUND(((SUM(points_denom) + SUM(points_num)) / SUM(points_denom)) * 100,2)
           ,SUM(points_denom)
          ) AS points_pct
  FROM
      (
       SELECT bhv.external_id AS student_number
             ,bhv.behavior
             ,bhv.category
             ,CONVERT(DATE,bhv.date) AS date
             ,CONCAT(DATEPART(YEAR,CONVERT(DATE,bhv.date)), DATEPART(WEEK,CONVERT(DATE,bhv.date))) AS yr_week_hash
             ,CASE WHEN bhv.behavior != 'Deposit' THEN CONVERT(FLOAT,bhv.dollar_points) ELSE NULL END AS points_num
             ,CASE WHEN bhv.behavior = 'Deposit' THEN CONVERT(FLOAT,bhv.dollar_points) ELSE NULL END AS points_denom                 
       FROM KIPP_NJ..AUTOLOAD$KICKBOARD_behavior bhv WITH(NOLOCK)
      ) sub
  GROUP BY student_number
          ,yr_week_hash
 )

,trans_talking_pts AS (
  SELECT bhv.external_id AS student_number              
        ,CONCAT(DATEPART(YEAR,CONVERT(DATE,bhv.date)), DATEPART(WEEK,CONVERT(DATE,bhv.date))) AS yr_week_hash
        ,SUM(CONVERT(FLOAT,bhv.dollar_points)) AS deduction_value
        ,COUNT(bhv.external_id) AS N_deductions        
  FROM KIPP_NJ..AUTOLOAD$KICKBOARD_behavior bhv WITH(NOLOCK)
  WHERE bhv.behavior = 'Talking in the hallway'
  GROUP BY bhv.external_id
          ,CONCAT(DATEPART(YEAR,CONVERT(DATE,bhv.date)), DATEPART(WEEK,CONVERT(DATE,bhv.date)))
 )

,conroster AS (
  SELECT student_number
        ,yr_week_hash      
        ,[Bench]
        ,[ISS]
        ,[OSS]
  FROM
      (
       SELECT student_number
             ,yr_week_hash
             ,MIN(assigned_date) AS week_of
             ,consequence_name
             ,COUNT(student_number) AS N
       FROM
           (
            SELECT con.external_id AS student_number
                  ,CONCAT(DATEPART(YEAR,CONVERT(DATE,con.assigned_date)), DATEPART(WEEK,CONVERT(DATE,con.assigned_date))) AS yr_week_hash
                  ,CONVERT(DATE,con.assigned_date) AS assigned_date
                  ,CASE
                    WHEN con.consequence_name LIKE '%Bench%' THEN 'Bench'
                    WHEN con.consequence_name LIKE '%ISS%' THEN 'ISS'
                    WHEN con.consequence_name LIKE '%OSS%' THEN 'OSS'
                   END AS consequence_name      
            FROM KIPP_NJ..AUTOLOAD$KICKBOARD_conroster con WITH(NOLOCK)
            WHERE (con.consequence_name LIKE '%ON%Bench%'
                   OR con.consequence_name LIKE '%ON%ISS%'
                   OR con.consequence_name LIKE '%ON%OSS%')
           ) sub
       GROUP BY student_number
               ,yr_week_hash
               ,consequence_name
      ) sub
  PIVOT(
    MAX(N)
    FOR consequence_name IN ([Bench], [ISS], [OSS])
   ) p
)

,attendance AS (
  SELECT studentid
        ,CONCAT(DATEPART(YEAR,CONVERT(DATE,calendardate)), DATEPART(WEEK,CONVERT(DATE,calendardate))) AS yr_week_hash
        ,AVG(CONVERT(FLOAT,attendancevalue)) AS pct_present
  FROM KIPP_NJ..ATT_MEM$MEMBERSHIP WITH(NOLOCK)
  WHERE academic_year = KIPP_NJ.dbo.fn_Global_Academic_Year()
    AND schoolid = 133570965
  GROUP BY studentid
          ,CONCAT(DATEPART(YEAR,CONVERT(DATE,calendardate)), DATEPART(WEEK,CONVERT(DATE,calendardate)))
 )

SELECT co.year
      ,co.schoolid
      ,co.student_number
      ,co.lastfirst
      ,co.grade_level
      ,co.team
      ,co.advisor
      ,co.enroll_status      
      ,co.term
      ,co.yr_week_hash      
      ,co.week_of      
      ,gpa.GPA_term AS GPA_all
      ,kb.points_total
      ,kb.points_pct
      ,ISNULL(ttp.N_deductions,0) AS ttp_deduction_count
      ,ISNULL(ttp.deduction_value,0) AS ttp_deduction_value
      ,ISNULL(con.[Bench],0) AS bench
      ,ISNULL(con.[ISS],0) AS ISS
      ,ISNULL(con.[OSS],0) AS OSS
      ,att.pct_present
FROM roster co WITH(NOLOCK)
LEFT OUTER JOIN KIPP_NJ..GRADES$GPA_detail_long#static gpa WITH(NOLOCK)
  ON co.student_number = gpa.student_number
 AND co.year = gpa.academic_year
 AND co.term = gpa.term
LEFT OUTER JOIN kb_weekly kb
  ON co.student_number = kb.student_number
 AND co.yr_week_hash = kb.yr_week_hash
LEFT OUTER JOIN trans_talking_pts ttp
  ON co.student_number = ttp.student_number
 AND co.yr_week_hash = ttp.yr_week_hash
LEFT OUTER JOIN conroster con
  ON co.student_number = con.student_number
 AND co.yr_week_hash = con.yr_week_hash
LEFT OUTER JOIN attendance att
  ON co.studentid = att.studentid
 AND co.yr_week_hash = att.yr_week_hash
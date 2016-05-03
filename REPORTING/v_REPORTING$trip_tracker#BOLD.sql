USE KIPP_NJ
GO

ALTER VIEW REPORTING$trip_tracker#BOLD AS

SELECT *
      ,discipline_points
        + att_points
        + uniform_points
        + hw_points
        + BOLD_points AS total_points
FROM
    (
     SELECT co.student_number      
           ,co.lastfirst AS student_name
           ,co.grade_level
           ,co.team
           ,MIN(CONVERT(VARCHAR,co.date,1)) AS start_date
           ,MAX(CONVERT(VARCHAR,co.date,1)) AS end_date
           ,SUM(CASE 
             WHEN logs.subtype = 'Silent Lunch' THEN -2
             WHEN logs.subtype = 'Bench / Choices' THEN -4
			 WHEN logs.subtype = 'Detention' THEN -4
             WHEN logs.subtype = 'Recess Detention' THEN -4
			 WHEN logs.subtype = 'Class Removal' THEN -6
             ELSE 0
            END) AS discipline_points      
           ,SUM(CASE
             WHEN att.ATT_CODE = 'ISS' THEN -8
             WHEN att.ATT_CODE = 'OSS' THEN -10
             WHEN att.ATT_CODE LIKE 'A%' OR att.ATT_CODE LIKE 'T%' THEN 0
             ELSE 1
            END) AS att_points
           ,SUM(CONVERT(INT,ISNULL(dt.FIELD1,0))) AS uniform_points
           ,SUM(CONVERT(INT,ISNULL(dt.FIELD2,0))) AS hw_points
           ,SUM(CONVERT(INT,ISNULL(dt.FIELD3,0))) AS BOLD_points
     FROM KIPP_NJ..COHORT$identifiers_scaffold#static co WITH(NOLOCK)
     LEFT OUTER JOIN DISC$log#static logs WITH(NOLOCK)
       ON co.studentid = logs.studentid
      AND co.year = logs.academic_year
      AND co.date = logs.entry_date
      AND logs.logtypeid = -100000
     LEFT OUTER JOIN KIPP_NJ..ATT_MEM$ATTENDANCE att WITH(NOLOCK)
       ON co.studentid = att.studentid
      AND co.date = att.ATT_DATE
     LEFT OUTER JOIN KIPP_NJ..DAILY$tracking_long#STAGING dt WITH(NOLOCK)
       ON co.studentid = dt.STUDENTID
      AND co.date = dt.ATT_DATE
     WHERE co.year = KIPP_NJ.dbo.fn_Global_Academic_Year()
       AND co.schoolid = 73258
       AND co.enroll_status = 0
       AND co.date BETWEEN '2016-04-21' AND CONVERT(DATE,GETDATE())
       --AND co.date BETWEEN '2016-02-24' AND CONVERT(DATE,GETDATE())
--     AND co.date BETWEEN '2015-11-06' AND CONVERT(DATE,GETDATE())
--	   AND co.date BETWEEN '2015-09-24' AND CONVERT(DATE,GETDATE())
       AND co.date IN (SELECT cal.date_value
                       FROM KIPP_NJ..PS$CALENDAR_DAY cal WITH(NOLOCK)
                       WHERE cal.academic_year = KIPP_NJ.dbo.fn_Global_Academic_Year()
                         AND cal.insession = 1
                         AND cal.schoolid = co.schoolid)
     GROUP BY co.student_number        
             ,co.lastfirst
             ,co.grade_level
             ,co.team
    ) sub
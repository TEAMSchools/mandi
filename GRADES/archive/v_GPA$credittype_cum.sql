USE KIPP_NJ
GO

ALTER VIEW GRADES$GPA_cumulative_credittype AS

WITH gpa_credittype AS (
  SELECT studentid
		      ,ISNULL(credittype,'CUMULATIVE') AS credittype
		      ,CONVERT(FLOAT,ROUND(CONVERT(DECIMAL(4,3),(weighted_points / credit_hours)), 2)) AS cumulative_Y1_gpa
		      --,earned_credits_cum      
		      ,schoolid
  FROM
		    (
       SELECT studentid
			          ,schoolid
			          ,credittype
			          ,ROUND(SUM(CONVERT(FLOAT,weighted_points)),3) AS weighted_points
			          ,CASE
				           WHEN SUM(CONVERT(FLOAT,potentialcrhrs)) = 0 THEN NULL
				           ELSE SUM(CONVERT(FLOAT,potentialcrhrs))
				          END AS credit_hours
			          ,SUM(earnedcrhrs) AS earned_credits_cum            
       FROM 
			        (
			         SELECT sto.studentid
					             ,sto.course_number					             
					             ,sto.GPA_POINTS
					             ,sto.potentialcrhrs                   
					             ,sto.schoolid                   
					             ,(sto.potentialcrhrs * sto.gpa_points) AS weighted_points
					             ,sto.earnedcrhrs  
                  ,ISNULL(cou.credittype,'TRANSFER') AS credittype
			         FROM KIPP_NJ..GRADES$STOREDGRADES#static sto WITH(NOLOCK)
			         LEFT OUTER JOIN KIPP_NJ..PS$COURSES#static cou WITH(NOLOCK)
				          ON sto.course_number = cou.course_number
			         WHERE sto.storecode = 'Y1'
				          AND sto.schoolid IN (73252, 73253, 133570965, 73258)				
				          AND sto.excludefromgpa = 0							              
			        ) sub
       GROUP BY studentid, schoolid, CUBE(credittype)
      ) sub
 )

SELECT *
FROM
	   (
		   SELECT co.STUDENT_NUMBER
			        ,co.LASTFIRST			
			        ,co.grade_level
			        ,co.advisor
			        ,gpa.credittype
			        ,gpa.cumulative_Y1_gpa
			        ,co.schoolid
		   FROM KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK)
		   JOIN gpa_credittype gpa
		     ON co.studentid = gpa.studentid
		     AND co.schoolid = gpa.schoolid
       AND gpa.cumulative_Y1_gpa IS NOT NULL
		   WHERE co.year = KIPP_NJ.dbo.fn_Global_Academic_Year()
		     AND co.rn = 1
		     AND co.enroll_status = 0
	   ) sub
PIVOT (
	MAX(cumulative_Y1_gpa)
	FOR credittype IN ([ART]
                   ,[CAREER]
                   ,[COCUR]
                   ,[CUMULATIVE]
                   ,[ELEC]
                   ,[ENG]
                   ,[LOG]
                   ,[MATH]
                   ,[PHYSED]
                   ,[RHET]
                   ,[SCI]
                   ,[SOC]
                   ,[STUDY]
                   ,[TRANSFER]
                   ,[WLANG])
 ) p
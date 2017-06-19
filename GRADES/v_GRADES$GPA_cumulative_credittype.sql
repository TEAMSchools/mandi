USE KIPP_NJ
GO

ALTER VIEW GRADES$GPA_cumulative_credittype AS

WITH gpa_credittype AS (
	 SELECT studentid
		      ,credittype
		      ,ROUND(weighted_points / credit_hours,2) AS cumulative_Y1_gpa
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
					             ,CASE
                    WHEN sto.COURSE_NUMBER IN ('FREN10','FREN1000','FREN11','FREN12','FREN20','FREN30','FREN300','FREN40','FREN45','FREN900')
                           OR sto.course_number = 'TRANSFER' AND cou.COURSE_NAME IN ('French I','French II ','Honors French I') THEN 'FRENCH'
                    WHEN sto.COURSE_NUMBER IN ('SPAN10','SPAN1000','SPAN11','SPAN12','SPAN20','SPAN30','SPAN305','SPAN40','SPAN45','SPAN901')
                           OR sto.COURSE_NUMBER = 'TRANSFER' AND cou.COURSE_NAME IN ('Spanish ','Spanish 1','Spanish 2','Spanish I ','Spanish I ADV','Spanish II','Spanish II (H)') THEN 'SPANISH'
                    WHEN sto.COURSE_NUMBER IN ('ARAB10','ARAB20') THEN 'ARABIC'
                    ELSE cou.credittype
                   END AS credittype
					             ,sto.GPA_POINTS
					             ,sto.potentialcrhrs                   
					             ,sto.schoolid                   
					             ,sto.potentialcrhrs * sto.gpa_points AS weighted_points
					             ,sto.earnedcrhrs                   
			         FROM KIPP_NJ..GRADES$STOREDGRADES#static sto WITH(NOLOCK)
			         LEFT OUTER JOIN KIPP_NJ..PS$COURSES#static cou WITH(NOLOCK)
				          ON sto.course_number = cou.course_number
			         WHERE sto.storecode = 'Y1'
				          AND sto.schoolid IN (73252, 73253, 133570965, 73258)				
				          AND sto.excludefromgpa = 0							
			        ) sub
		     GROUP BY studentid, schoolid, credittype
		    ) sub
 )

SELECT *
FROM
	   (
		   SELECT co.STUDENT_NUMBER
			        --,co.studentid
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
		   WHERE co.year = KIPP_NJ.dbo.fn_Global_Academic_Year()
		     AND co.rn = 1
		     AND co.enroll_status = 0
	   ) sub
PIVOT (
	MAX(cumulative_Y1_gpa)
	FOR credittype IN ([ART]
						,[ENG]                     
						,[MATH]
						,[PHYSED]
						,[RHET]
						,[SCI]
						,[SOC]
						--,[WLANG]
      ,[FRENCH]
      ,[SPANISH]
      ,[ARABIC])
 ) p
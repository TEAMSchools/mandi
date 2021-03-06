USE KIPP_NJ
GO

ALTER VIEW ROSTERS$PS_access_accounts AS 

WITH clean_names AS (
  SELECT CONVERT(INT,s.student_number) AS student_number
        ,sch.ABBREVIATION AS school_name
        ,s.grade_level
        ,CONVERT(INT,s.SCHOOLID) AS SCHOOLID
        ,s.FIRST_NAME
        ,s.LAST_NAME
        ,s.ENROLL_STATUS
        ,KIPP_NJ.dbo.REMOVESPECIALCHARS(LOWER(s.FIRST_NAME)) AS first_name_clean
        ,LEFT(LOWER(s.first_name),1) AS first_init           
        ,KIPP_NJ.dbo.REMOVESPECIALCHARS(LOWER(
           CASE
            WHEN s.LAST_NAME LIKE 'St %' OR s.LAST_NAME LIKE 'St. %' THEN s.LAST_NAME
            WHEN s.LAST_NAME LIKE '% II%' THEN LEFT(s.LAST_NAME,CHARINDEX(' I',s.LAST_NAME) - 1)
            WHEN CHARINDEX('-',s.LAST_NAME) + CHARINDEX(' ',s.LAST_NAME) = 0 THEN REPLACE(s.LAST_NAME, ' JR', '')
            WHEN CHARINDEX(' ',s.LAST_NAME) > 0 AND CHARINDEX('-',s.LAST_NAME) > 0 AND CHARINDEX(' ',s.LAST_NAME) < CHARINDEX('-',s.LAST_NAME) THEN LEFT(s.LAST_NAME,CHARINDEX(' ',s.LAST_NAME) - 1)        
            WHEN CHARINDEX('-',s.LAST_NAME) > 0 AND CHARINDEX(' ',s.LAST_NAME) > 0 AND CHARINDEX('-',s.LAST_NAME) < CHARINDEX(' ',s.LAST_NAME) THEN LEFT(s.LAST_NAME,CHARINDEX('-',s.LAST_NAME) - 1)
            WHEN s.LAST_NAME NOT LIKE 'De %' AND CHARINDEX(' ',s.LAST_NAME) > 0 THEN LEFT(s.LAST_NAME,CHARINDEX(' ',s.LAST_NAME) - 1)        
            WHEN CHARINDEX('-',s.LAST_NAME) > 0 THEN LEFT(s.LAST_NAME,CHARINDEX('-',s.LAST_NAME) - 1)
            ELSE REPLACE(s.LAST_NAME, ' JR', '')
           END)) AS last_name_clean
        ,CONVERT(VARCHAR,DATEPART(MONTH,s.DOB)) AS dob_month
        ,CONVERT(VARCHAR,RIGHT(DATEPART(DAY,s.DOB),2)) AS dob_day
        ,CONVERT(VARCHAR,RIGHT(DATEPART(YEAR,s.DOB),2)) AS dob_year                
        ,LEFT(CASE 
               WHEN s.SCHOOLID = 73253 THEN LEFT(advisory.advisor, CHARINDEX(',', advisory.advisor) - 1)
               WHEN s.SCHOOLID = 179902 THEN sci.SECTION_NUMBER
               ELSE cc.SECTION_NUMBER 
              END, 10) AS team
  FROM KIPP_NJ..PS$STUDENTS#static s WITH(NOLOCK)
  JOIN KIPP_NJ..PS$SCHOOLS#static sch WITH(NOLOCK)
    ON s.SCHOOLID = sch.SCHOOL_NUMBER
  LEFT OUTER JOIN KIPP_NJ..PS$CC#static cc WITH(NOLOCK)
    ON s.id = cc.STUDENTID
   AND cc.COURSE_NUMBER = 'HR'
   AND CONVERT(DATE,GETDATE()) BETWEEN cc.dateenrolled AND cc.dateleft
   AND cc.rn = 1
  LEFT OUTER JOIN KIPP_NJ..PS$course_enrollments#static sci WITH(NOLOCK)
    ON s.STUDENT_NUMBER = sci.student_number  
   AND sci.CREDITTYPE = 'SCI'
   AND CONVERT(DATE,GETDATE()) BETWEEN sci.dateenrolled AND sci.dateleft
   AND sci.rn_subject = 1  
  LEFT OUTER JOIN KIPP_NJ..PS$advisory_roster#static advisory WITH(NOLOCK)
    ON s.id = advisory.STUDENTID
   AND advisory.academic_year = KIPP_NJ.dbo.fn_Global_Academic_Year()
   AND advisory.rn = 1
  WHERE s.ENROLL_STATUS != -1          
 )

SELECT STUDENT_NUMBER
      ,schoolid
      ,team
      ,ENROLL_STATUS
      ,base_username
      ,alt_username
      ,CASE         
        WHEN alt_dupe_audit > 1 THEN first_init + last_name_clean + dob_month + dob_day        
        WHEN uses_alt = 1 THEN alt_username 
        ELSE base_username 
       END AS student_web_id
      ,CASE
        WHEN student_number = 11085 THEN first_name_clean + dob_month /* manual override of passwords */
        WHEN student_number = 10611 THEN first_name_clean + dob_month /* manual override of passwords */
        WHEN student_number = 15343 THEN first_name_clean + CONVERT(VARCHAR(20),student_number) /* manual override of passwords */
		WHEN student_number = 18022 THEN first_name_clean + CONVERT(VARCHAR(20),student_number) /* manual override of passwords */
		WHEN student_number = 16702 THEN first_name_clean + CONVERT(VARCHAR(20),student_number) /* manual override of passwords */
        WHEN GRADE_LEVEL >= 2 THEN last_name_clean + dob_year 
        ELSE LOWER(school_name) + '1'
       END AS student_web_password
      ,uses_alt
      ,base_dupe_audit
      ,alt_dupe_audit
FROM
    (
     SELECT STUDENT_NUMBER
           ,SCHOOLID
           ,GRADE_LEVEL
           ,ENROLL_STATUS
           ,school_name
           ,team
           ,first_name_clean
           ,first_init
           ,last_name_clean
           ,dob_month
           ,dob_day
           ,dob_year
           ,base_username
           ,alt_username
           ,base_dupe_audit
           ,CASE 
             WHEN base_dupe_audit > 1 THEN 1 
             WHEN LEN(base_username) > 16 THEN 1 
             ELSE 0 
            END AS uses_alt
           ,ROW_NUMBER() OVER(
             PARTITION BY CASE WHEN base_dupe_audit > 1 THEN alt_username ELSE base_username END
               ORDER BY student_number) AS alt_dupe_audit
     FROM
         (         
          SELECT STUDENT_NUMBER
                ,SCHOOLID
                ,ENROLL_STATUS
                ,GRADE_LEVEL
                ,team
                ,school_name
                ,first_name_clean
                ,first_init
                ,last_name_clean
                ,dob_month
                ,dob_day
                ,dob_year
                ,last_name_clean
                  + dob_month 
                  + dob_day
                  AS base_username
                ,first_name_clean
                  + dob_month 
                  + dob_day
                  AS alt_username
                ,ROW_NUMBER() OVER(
                  PARTITION BY last_name_clean + dob_month + dob_day
                    ORDER BY student_number) AS base_dupe_audit           
          FROM clean_names         
         ) sub
    ) sub
     
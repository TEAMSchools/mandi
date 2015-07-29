USE KIPP_NJ
GO

ALTER VIEW ROSTERS$PS_access_accounts AS 

WITH clean_names AS (
  SELECT s.student_number
        ,sch.ABBREVIATION AS school_name
        ,s.grade_level
        ,s.FIRST_NAME
        ,s.LAST_NAME
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
  FROM KIPP_NJ..STUDENTS s WITH(NOLOCK)
  JOIN KIPP_NJ..PS$SCHOOLS#static sch WITH(NOLOCK)
    ON s.SCHOOLID = sch.SCHOOL_NUMBER
  WHERE s.ENROLL_STATUS != -1          
 )

SELECT STUDENT_NUMBER
      ,base_username
      ,alt_username
      ,CASE 
        WHEN alt_dupe_audit > 1 THEN first_init + last_name_clean + dob_month + dob_day
        WHEN base_dupe_audit > 1 THEN alt_username 
        ELSE base_username 
       END AS student_web_id
      ,CASE
        WHEN GRADE_LEVEL >= 2 THEN last_name_clean + dob_year 
        ELSE LOWER(school_name) + '1'
       END AS student_web_password
      ,uses_alt
      ,base_dupe_audit
      ,alt_dupe_audit
FROM
    (
     SELECT STUDENT_NUMBER
           ,GRADE_LEVEL
           ,school_name
           ,first_name_clean
           ,first_init
           ,last_name_clean
           ,dob_month
           ,dob_day
           ,dob_year
           ,base_username
           ,alt_username
           ,base_dupe_audit
           ,CASE WHEN base_dupe_audit > 1 THEN 1 ELSE 0 END AS uses_alt
           ,ROW_NUMBER() OVER(
             PARTITION BY CASE WHEN base_dupe_audit > 1 THEN alt_username ELSE base_username END
               ORDER BY student_number) AS alt_dupe_audit
     FROM
         (         
          SELECT STUDENT_NUMBER
                ,GRADE_LEVEL
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
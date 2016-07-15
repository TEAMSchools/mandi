USE KIPP_NJ

GO

ALTER VIEW TABLEAU$audit#student_info AS 

SELECT *
FROM
    (
     SELECT schoolid
           ,school_name
           ,student_number
	          ,lastfirst
	          ,grade_level
	          ,'Name Spelling' AS element
	          ,lastfirst AS detail
	          ,CASE 
             WHEN lastfirst LIKE '%;%' THEN 1
		           WHEN lastfirst LIKE '%  %' THEN 1
		           WHEN lastfirst LIKE '%/%' THEN 1
		           WHEN lastfirst LIKE '%\%' THEN 1
		           WHEN lastfirst LIKE '%.%' THEN 1
		           ELSE 0 
            END AS flag
	     FROM KIPP_NJ..COHORT$identifiers_long#static WITH(NOLOCK)
	     WHERE year = KIPP_NJ.dbo.fn_Global_Academic_Year()
	       AND schoolid != 999999

      UNION ALL

      SELECT schoolid
            ,school_name
            ,student_number
	           ,lastfirst
	           ,grade_level
	           ,'Email' AS element
	           ,CASE WHEN guardianemail IS NULL THEN '[Missing]' ELSE guardianemail END AS detail
	           ,CASE 
              WHEN guardianemail LIKE '%;%' THEN 1
		            WHEN guardianemail LIKE '%:%' THEN 1
		            WHEN guardianemail LIKE '% %' THEN 1
		            WHEN guardianemail LIKE '%  %' THEN 1
		            WHEN guardianemail LIKE '%/%' THEN 1
		            WHEN guardianemail LIKE '%\%' THEN 1
		            WHEN guardianemail LIKE '%''%' THEN 1
		            WHEN guardianemail LIKE '%@ %' THEN 1
		            WHEN guardianemail IS NULL THEN 1
		            ELSE 0 
             END AS flag
      FROM KIPP_NJ..COHORT$identifiers_long#static WITH(NOLOCK)
      WHERE year = KIPP_NJ.dbo.fn_Global_Academic_Year()
	       AND schoolid != 999999

      UNION ALL
	        
      SELECT schoolid
            ,school_name
            ,student_number
	           ,lastfirst
	           ,grade_level
	           ,'Phone - Mother Cell' AS element
	           ,MOTHER_CELL AS detail
	           ,CASE 
              WHEN MOTHER_CELL LIKE '%;%' THEN 1
	             WHEN MOTHER_CELL LIKE '%:%' THEN 1
	             WHEN MOTHER_CELL LIKE '% %' THEN 1
	             WHEN MOTHER_CELL LIKE '%  %' THEN 1
	             WHEN MOTHER_CELL LIKE '%/%' THEN 1
	             WHEN MOTHER_CELL LIKE '%\%' THEN 1
	             WHEN MOTHER_CELL LIKE '%''%' THEN 1
	             WHEN MOTHER_CELL LIKE '%@ %' THEN 1
	             ELSE 0 
             END AS flag
      FROM KIPP_NJ..COHORT$identifiers_long#static WITH(NOLOCK)
      WHERE year = KIPP_NJ.dbo.fn_Global_Academic_Year()
	       AND schoolid != 999999
      
      UNION ALL
      
      SELECT schoolid
            ,school_name
            ,student_number
	           ,lastfirst
	           ,grade_level
	           ,'Phone - Father Cell' AS element
	           ,FATHER_CELL AS detail
	           ,CASE 
              WHEN FATHER_CELL LIKE '%;%' THEN 1
	             WHEN FATHER_CELL LIKE '%:%' THEN 1
	             WHEN FATHER_CELL LIKE '% %' THEN 1
	             WHEN FATHER_CELL LIKE '%  %' THEN 1
	             WHEN FATHER_CELL LIKE '%/%' THEN 1
	             WHEN FATHER_CELL LIKE '%\%' THEN 1
	             WHEN FATHER_CELL LIKE '%''%' THEN 1
	             WHEN FATHER_CELL LIKE '%@ %' THEN 1
	             ELSE 0 
             END AS flag
      FROM KIPP_NJ..COHORT$identifiers_long#static WITH(NOLOCK)
      WHERE year = KIPP_NJ.dbo.fn_Global_Academic_Year()
	       AND schoolid != 999999

      UNION ALL

      SELECT schoolid
            ,school_name
            ,student_number
	           ,lastfirst
	           ,grade_level
	           ,'Phone - Home' AS element
	           ,FATHER_CELL AS detail
	           ,CASE
              WHEN HOME_PHONE LIKE '%;%' THEN 1
	             WHEN HOME_PHONE LIKE '%:%' THEN 1
	             WHEN HOME_PHONE LIKE '% %' THEN 1
	             WHEN HOME_PHONE LIKE '%  %' THEN 1
	             WHEN HOME_PHONE LIKE '%/%' THEN 1
	             WHEN HOME_PHONE LIKE '%\%' THEN 1
	             WHEN HOME_PHONE LIKE '%''%' THEN 1
	             WHEN HOME_PHONE LIKE '%@ %' THEN 1
	             WHEN HOME_PHONE IS NULL THEN 1
	             ELSE 0 
             END AS flag
      FROM KIPP_NJ..COHORT$identifiers_long#static WITH(NOLOCK)
      WHERE year = KIPP_NJ.dbo.fn_Global_Academic_Year()
	       AND schoolid != 999999
    ) sub
WHERE flag = 1
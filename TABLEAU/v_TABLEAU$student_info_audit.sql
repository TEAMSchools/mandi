USE KIPP_NJ

GO

ALTER VIEW TABLEAU$student_info_audit AS 

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

	UNION ALL

     SELECT schoolid
           ,school_name
           ,student_number
	       ,lastfirst
	       ,grade_level
	       ,'Missing Ethnicity' AS element
	       ,ethnicity AS detail
	       ,CASE 
             WHEN ethnicity IS NULL THEN 1
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
	,'Missing Gender' AS element
	,gender AS detail
	,CASE 
		WHEN gender IS NULL THEN 1
		ELSE 0
	END AS flag

	FROM KIPP_NJ..COHORT$identifiers_long#static WITH(NOLOCK)
	WHERE year = KIPP_NJ.dbo.fn_Global_Academic_Year()
	AND schoolid != 999999

	UNION ALL

	SELECT co.schoolid
	,co.school_name
	,co.student_number
	,co.lastfirst
	,co.grade_level
	,'Missing SID' AS element
	,co.SID AS detail
	,CASE 
		WHEN co.SID IS NULL THEN 1
		ELSE 0
	END AS flag

	FROM KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK)	
	WHERE co.year = KIPP_NJ.dbo.fn_Global_Academic_Year()
	AND co.schoolid != 999999

	UNION ALL

	SELECT co.schoolid
	,co.school_name
	,co.student_number
	,co.lastfirst
	,co.grade_level
	,'Missing FTEID' AS element
	,CONVERT(VARCHAR(32),s.FTEID) AS detail
	,CASE 
		WHEN S.FTEID IS NULL THEN 1
		WHEN S.FTEID = 0 THEN 1
		ELSE 0
	END AS flag

	FROM KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK)
	JOIN KIPP_NJ..PS$students#static s WITH(NOLOCK)
	  ON co.studentid = s.id
	WHERE co.year = KIPP_NJ.dbo.fn_Global_Academic_Year()
	AND co.schoolid != 999999

    ) sub
WHERE flag = 1

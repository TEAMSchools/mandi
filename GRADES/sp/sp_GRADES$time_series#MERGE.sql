USE KIPP_NJ
GO

ALTER PROCEDURE sp_GRADES$time_series#MERGE AS

BEGIN

		IF OBJECT_ID(N'tempdb..#ts_update') IS NOT NULL
		BEGIN
						DROP TABLE #ts_update
		END;

  WITH ts_update AS (
    SELECT student_number
          ,schoolid      
          ,course_number
          ,term AS finalgradename
          ,term_grade_percent AS moving_average
    FROM KIPP_NJ..GRADES$final_grades_long#static WITH(NOLOCK)
    WHERE academic_year = KIPP_NJ.dbo.fn_Global_Academic_Year()
      AND term_grade_percent IS NOT NULL

    UNION ALL

    SELECT student_number
          ,schoolid
          ,course_number
          ,'Y1' AS finalgradename
          ,y1_grade_percent_adjusted AS moving_average
    FROM KIPP_NJ..GRADES$final_grades_long#static WITH(NOLOCK)
    WHERE academic_year = KIPP_NJ.dbo.fn_Global_Academic_Year()
      AND is_curterm = 1
      AND y1_grade_percent_adjusted IS NOT NULL    

    UNION ALL

    SELECT e.student_number
          ,e.schoolid
          ,e.course_number
          ,e.grade_category + RIGHT(e.rt,1) AS finalgradename
          ,e.grade_category_pct AS moving_average
    FROM KIPP_NJ..GRADES$category_grades_long#static e WITH(NOLOCK)    
    WHERE e.academic_year = KIPP_NJ.dbo.fn_Global_Academic_Year()
      AND e.course_number != 'ALL'
      AND e.grade_category_pct IS NOT NULL

    UNION ALL

        SELECT e.student_number
          ,e.schoolid
          ,e.course_number
          ,CONCAT(e.grade_category, 'Y') AS finalgradename
          ,e.grade_category_pct_y1 AS moving_average
    FROM KIPP_NJ..GRADES$category_grades_long#static e WITH(NOLOCK)    
    WHERE e.academic_year = KIPP_NJ.dbo.fn_Global_Academic_Year()
      AND e.course_number != 'ALL'
      AND e.grade_category_pct_y1 IS NOT NULL
      AND e.is_curterm = 1
   )
    
  SELECT *
        ,KIPP_NJ.dbo.fn_DateToSY(CONVERT(DATE,GETDATE())) AS academic_year
        ,CONVERT(DATE,GETDATE()) AS date
  INTO #ts_update
  FROM ts_update
  WHERE moving_average IS NOT NULL
    AND course_number IS NOT NULL;

  MERGE KIPP_NJ..GRADES$time_series AS TARGET
  USING #ts_update AS SOURCE
     ON TARGET.student_number = SOURCE.student_number
    AND TARGET.date = SOURCE.date
    AND TARGET.course_number = SOURCE.course_number
    AND TARGET.finalgradename = SOURCE.finalgradename
  WHEN MATCHED THEN
   UPDATE
    SET TARGET.moving_average = SOURCE.moving_average      
       ,TARGET.academic_year = SOURCE.academic_year       
  WHEN NOT MATCHED THEN
   INSERT
    (student_number
    ,schoolid
    ,date
    ,course_number
    ,finalgradename
    ,moving_average
    ,academic_year)
   VALUES
    (SOURCE.student_number
    ,SOURCE.schoolid	
    ,SOURCE.date
    ,SOURCE.course_number
    ,SOURCE.finalgradename
    ,SOURCE.moving_average
    ,SOURCE.academic_year);

END

GO
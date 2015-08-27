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
          ,term_pct AS moving_average
    FROM KIPP_NJ..GRADES$detail_long#static WITH(NOLOCK)

    UNION ALL

    SELECT student_number
          ,schoolid
          ,course_number
          ,'Y1' AS finalgradename
          ,AVG(CONVERT(FLOAT,y1_pct)) AS moving_average
    FROM KIPP_NJ..GRADES$detail_long#static WITH(NOLOCK)
    GROUP BY student_number
            ,schoolid
            ,course_number

    UNION ALL

    SELECT co.student_number
          ,co.schoolid
          ,e.course_number
          ,e.pgf_type + CASE WHEN e.term LIKE 'Y%' THEN 'Y' ELSE RIGHT(e.term,1) END AS finalgradename
          ,e.grade AS moving_average
    FROM KIPP_NJ..GRADES$elements_long e WITH(NOLOCK)
    JOIN KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK)
      ON e.studentid = co.studentid
     AND e.academic_year = co.year
     AND co.rn = 1
    WHERE e.course_number != 'all_courses'
   )
    
  SELECT *
        ,KIPP_NJ.dbo.fn_DateToSY(CONVERT(DATE,GETDATE())) AS academic_year
        ,CONVERT(DATE,GETDATE()) AS date
  INTO #ts_update
  FROM ts_update;

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
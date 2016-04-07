USE KIPP_NJ
GO

ALTER PROCEDURE sp_PS$course_section_scaffold#MERGE AS

BEGIN

  /* SELECT all enrollments by day INTO temp table */
  IF OBJECT_ID(N'tempdb..#sections_scaffold') IS NOT NULL
  BEGIN
				  DROP TABLE #sections_scaffold;
  END

  SELECT co.studentid
        ,co.year
        ,co.date
        ,co.term
        ,cc.COURSE_NUMBER
        ,cc.SECTIONID
        ,t.LASTFIRST AS teacher_name                
  INTO #sections_scaffold
  FROM KIPP_NJ..COHORT$identifiers_scaffold#static co WITH(NOLOCK)
  JOIN KIPP_NJ..PS$CC#static cc WITH(NOLOCK)
    ON co.studentid = cc.STUDENTID
   AND co.date BETWEEN cc.DATEENROLLED AND cc.DATELEFT
  JOIN KIPP_NJ..PS$SECTIONS#static sec WITH(NOLOCK)
    ON ABS(cc.SECTIONID) = sec.ID
  JOIN KIPP_NJ..PS$TEACHERS#static t WITH(NOLOCK)
    ON sec.teacher = t.ID
  WHERE co.year = KIPP_NJ.dbo.fn_Global_Academic_Year();

  /* SELECT most recent enrollments by term and year INTO another temp table */
  IF OBJECT_ID(N'tempdb..#sections_scaffold_rn') IS NOT NULL
  BEGIN
				  DROP TABLE #sections_scaffold_rn;
  END

  SELECT *
  INTO #sections_scaffold_rn
  FROM
      (
       SELECT studentid
             ,year
             ,term
             ,COURSE_NUMBER
             ,SECTIONID
             ,teacher_name
             ,ROW_NUMBER() OVER(
                PARTITION BY studentid, year, term, course_number
                  ORDER BY date DESC, sectionid DESC) AS rn_term
             ,ROW_NUMBER() OVER(
                PARTITION BY studentid, year, course_number
                  ORDER BY date DESC, sectionid DESC) AS rn_year
       FROM #sections_scaffold
      ) sub
  WHERE rn_term = 1 OR rn_year = 1;

  /* SELECT final scaffold INTO final temp table */
  IF OBJECT_ID(N'tempdb..#sections_scaffold_final') IS NOT NULL
  BEGIN
				  DROP TABLE #sections_scaffold_final;
  END

  SELECT s1.studentid
        ,s1.year
        ,s1.term
        ,s1.COURSE_NUMBER
        ,ABS(COALESCE(s1.SECTIONID, s2.SECTIONID)) AS sectionid
        ,COALESCE(s1.teacher_name, s2.teacher_name) AS teacher_name
  INTO #sections_scaffold_final
  FROM #sections_scaffold_rn s1
  LEFT OUTER JOIN #sections_scaffold_rn s2
    ON s1.studentid = s2.studentid
   AND s1.year = s2.year
   AND s1.course_number = s2.course_number
   AND s2.rn_year = 1
  WHERE s1.rn_term = 1;

  /* MERGE into destiniation table */
  MERGE KIPP_NJ..PS$course_section_scaffold#static AS TARGET
  USING #sections_scaffold_final AS SOURCE    
     ON TARGET.studentid = SOURCE.studentid
    AND TARGET.year = SOURCE.year
    AND TARGET.term = SOURCE.term
    AND TARGET.course_number = SOURCE.course_number
  WHEN MATCHED THEN 
    UPDATE  
      SET TARGET.sectionid = SOURCE.sectionid
         ,TARGET.teacher_name = SOURCE.teacher_name            
  WHEN NOT MATCHED THEN 
    INSERT
      (studentid
      ,year
      ,term
      ,course_number
      ,sectionid
      ,teacher_name)
    VALUES 
      (SOURCE.studentid
      ,SOURCE.year
      ,SOURCE.term
      ,SOURCE.course_number
      ,SOURCE.sectionid
      ,SOURCE.teacher_name);

END
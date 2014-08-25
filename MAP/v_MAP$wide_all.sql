USE KIPP_NJ
GO

ALTER VIEW MAP$wide_all AS
--/*
SELECT studentid      
      /*--WINTER--*/
      ,[w_2015_READ_RIT]
      ,[w_2015_READ_pctle]
      ,[w_2015_MATH_RIT]
      ,[w_2015_MATH_pctle]
      ,[w_2015_LANG_RIT]
      ,[w_2015_LANG_pctle]
      ,[w_2015_GEN_RIT]
      ,[w_2015_GEN_pctle]
      ,[w_2014_READ_RIT]
      ,[w_2014_READ_pctle]
      ,[w_2014_MATH_RIT]
      ,[w_2014_MATH_pctle]
      ,[w_2014_LANG_RIT]
      ,[w_2014_LANG_pctle]
      ,[w_2014_GEN_RIT]
      ,[w_2014_GEN_pctle]
      ,[w_2013_READ_RIT]
      ,[w_2013_READ_pctle]
      ,[w_2013_MATH_RIT]
      ,[w_2013_MATH_pctle]
      ,[w_2013_LANG_RIT]
      ,[w_2013_LANG_pctle]
      ,[w_2013_GEN_RIT]
      ,[w_2013_GEN_pctle]
      ,[w_2013_CP_RIT]
      ,[w_2013_CP_pctle]
      ,[w_2010_GEN_RIT]
      ,[w_2010_GEN_pctle]
      ,[w_2010_CP_RIT]
      ,[w_2010_CP_pctle]
      ,[w_2009_READ_RIT]
      ,[w_2009_READ_pctle]
      ,[w_2009_MATH_RIT]
      ,[w_2009_MATH_pctle]
      ,[w_2009_LANG_RIT]
      ,[w_2009_LANG_pctle]
      ,[w_2009_GEN_RIT]
      ,[w_2009_GEN_pctle]
      ,[w_2009_CP_RIT]
      ,[w_2009_CP_pctle]
      /*--SPRING--*/
      ,[spr_2015_READ_RIT]
      ,[spr_2015_READ_pctle]
      ,[spr_2015_MATH_RIT]
      ,[spr_2015_MATH_pctle]
      ,[spr_2015_LANG_RIT]
      ,[spr_2015_LANG_pctle]
      ,[spr_2015_GEN_RIT]
      ,[spr_2015_GEN_pctle]
      ,[spr_2014_READ_RIT]
      ,[spr_2014_READ_pctle]
      ,[spr_2014_MATH_RIT]
      ,[spr_2014_MATH_pctle]
      ,[spr_2014_LANG_RIT]
      ,[spr_2014_LANG_pctle]
      ,[spr_2014_GEN_RIT]
      ,[spr_2014_GEN_pctle]
      ,[spr_2013_READ_RIT]
      ,[spr_2013_READ_pctle]
      ,[spr_2013_MATH_RIT]
      ,[spr_2013_MATH_pctle]
      ,[spr_2013_LANG_RIT]
      ,[spr_2013_LANG_pctle]
      ,[spr_2013_GEN_RIT]
      ,[spr_2013_GEN_pctle]
      ,[spr_2013_CP_RIT]
      ,[spr_2013_CP_pctle]
      ,[spr_2012_READ_RIT]
      ,[spr_2012_READ_pctle]
      ,[spr_2012_MATH_RIT]
      ,[spr_2012_MATH_pctle]
      ,[spr_2012_LANG_RIT]
      ,[spr_2012_LANG_pctle]
      ,[spr_2012_GEN_RIT]
      ,[spr_2012_GEN_pctle]
      ,[spr_2012_CP_RIT]
      ,[spr_2012_CP_pctle]
      ,[spr_2011_READ_RIT]
      ,[spr_2011_READ_pctle]
      ,[spr_2011_MATH_RIT]
      ,[spr_2011_MATH_pctle]
      ,[spr_2011_LANG_RIT]
      ,[spr_2011_LANG_pctle]
      ,[spr_2011_GEN_RIT]
      ,[spr_2011_GEN_pctle]
      ,[spr_2011_CP_RIT]
      ,[spr_2011_CP_pctle]
      ,[spr_2010_READ_RIT]
      ,[spr_2010_READ_pctle]
      ,[spr_2010_MATH_RIT]
      ,[spr_2010_MATH_pctle]
      ,[spr_2010_LANG_RIT]
      ,[spr_2010_LANG_pctle]
      ,[spr_2010_GEN_RIT]
      ,[spr_2010_GEN_pctle]
      ,[spr_2010_CP_RIT]
      ,[spr_2010_CP_pctle]
      ,[spr_2009_READ_RIT]
      ,[spr_2009_READ_pctle]
      ,[spr_2009_MATH_RIT]
      ,[spr_2009_MATH_pctle]
      ,[spr_2009_LANG_RIT]
      ,[spr_2009_LANG_pctle]
      ,[spr_2009_GEN_RIT]
      ,[spr_2009_GEN_pctle]
      ,[spr_2009_CP_RIT]      
      ,[spr_2009_CP_pctle]
      /*--FALL--*/
      ,[f_2014_READ_RIT]
      ,[f_2014_READ_pctle]
      ,[f_2014_MATH_RIT]
      ,[f_2014_MATH_pctle]
      ,[f_2014_LANG_RIT]
      ,[f_2014_LANG_pctle]
      ,[f_2014_GEN_RIT]
      ,[f_2014_GEN_pctle]
      ,[f_2013_READ_RIT]
      ,[f_2013_READ_pctle]
      ,[f_2013_MATH_RIT]
      ,[f_2013_MATH_pctle]
      ,[f_2013_LANG_RIT]
      ,[f_2013_LANG_pctle]
      ,[f_2013_GEN_RIT]
      ,[f_2013_GEN_pctle]
      ,[f_2012_READ_RIT]
      ,[f_2012_READ_pctle]
      ,[f_2012_MATH_RIT]
      ,[f_2012_MATH_pctle]
      ,[f_2012_LANG_RIT]
      ,[f_2012_LANG_pctle]
      ,[f_2012_GEN_RIT]
      ,[f_2012_GEN_pctle]
      ,[f_2012_CP_RIT]
      ,[f_2012_CP_pctle]
      ,[f_2011_READ_RIT]
      ,[f_2011_READ_pctle]
      ,[f_2011_MATH_RIT]
      ,[f_2011_MATH_pctle]
      ,[f_2011_LANG_RIT]
      ,[f_2011_LANG_pctle]
      ,[f_2011_GEN_RIT]
      ,[f_2011_GEN_pctle]
      ,[f_2011_CP_RIT]
      ,[f_2011_CP_pctle]
      ,[f_2010_READ_RIT]
      ,[f_2010_READ_pctle]
      ,[f_2010_MATH_RIT]
      ,[f_2010_MATH_pctle]
      ,[f_2010_LANG_RIT]
      ,[f_2010_LANG_pctle]
      ,[f_2010_GEN_RIT]
      ,[f_2010_GEN_pctle]
      ,[f_2010_CP_RIT]
      ,[f_2010_CP_pctle]
      ,[f_2009_READ_RIT]
      ,[f_2009_READ_pctle]
      ,[f_2009_MATH_RIT]
      ,[f_2009_MATH_pctle]
      ,[f_2009_LANG_RIT]
      ,[f_2009_LANG_pctle]
      ,[f_2009_GEN_RIT]
      ,[f_2009_GEN_pctle]
      ,[f_2009_CP_RIT]
      ,[f_2009_CP_pctle]
      ,[f_2008_READ_RIT]
      ,[f_2008_READ_pctle]
      ,[f_2008_MATH_RIT]
      ,[f_2008_MATH_pctle]
      ,[f_2008_LANG_RIT]
      ,[f_2008_LANG_pctle]
      ,[f_2008_GEN_RIT]
      ,[f_2008_GEN_pctle]
      ,[f_2008_CP_RIT]
      ,[f_2008_CP_pctle]     
--*/
FROM      
    (
     SELECT *
     FROM
         (
          SELECT ps_studentid AS studentid
                ,CASE
                  WHEN LTRIM(RTRIM(fallwinterspring)) = 'Fall' THEN 'f' 
                  WHEN LTRIM(RTRIM(fallwinterspring)) = 'Winter' THEN 'w'
                  WHEN LTRIM(RTRIM(fallwinterspring)) = 'Spring' THEN 'spr'
                  ELSE NULL 
                 END + '_'
                  + CASE 
                     WHEN fallwinterspring IN ('Winter','Spring') THEN CONVERT(VARCHAR,(map_year_academic + 1)) 
                     ELSE CONVERT(VARCHAR,map_year_academic) END + '_'              
                  + CASE
                     WHEN measurementscale = 'Reading' THEN 'READ'
                     WHEN measurementscale = 'Mathematics' THEN 'MATH'
                     WHEN measurementscale = 'Language Usage' THEN 'LANG'
                     WHEN measurementscale = 'Science - General Science' THEN 'GEN'
                     WHEN measurementscale = 'Science - Concepts and Processes' THEN 'CP'
                     ELSE NULL
                    END
                  + '_RIT' AS pivot_on
                ,testritscore AS value                        
                ,ROW_NUMBER() OVER (
                   PARTITION BY map.studentid, map.map_year, map.termname, CASE WHEN map.testname LIKE '%Algebra%' THEN 'Algebra' ELSE map.measurementscale END
                       ORDER BY map.teststartdate DESC) AS rn_curr
          FROM STUDENTS s WITH(NOLOCK)
          JOIN MAP$comprehensive#identifiers map WITH(NOLOCK)
            ON s.ID = map.ps_studentid
           AND map.testname NOT LIKE '%Algebra%'
          WHERE s.ENROLL_STATUS = 0            
     
          UNION ALL
     
          SELECT ps_studentid AS studentid
                ,CASE
                  WHEN LTRIM(RTRIM(fallwinterspring)) = 'Fall' THEN 'f' 
                  WHEN LTRIM(RTRIM(fallwinterspring)) = 'Winter' THEN 'w'
                  WHEN LTRIM(RTRIM(fallwinterspring)) = 'Spring' THEN 'spr'
                  ELSE NULL 
                 END + '_'
                  + CASE 
                     WHEN fallwinterspring IN ('Winter','Spring') THEN CONVERT(VARCHAR,(map_year_academic + 1)) 
                     ELSE CONVERT(VARCHAR,map_year_academic) END + '_'              
                  + CASE
                     WHEN measurementscale = 'Reading' THEN 'READ'
                     WHEN measurementscale = 'Mathematics' THEN 'MATH'
                     WHEN measurementscale = 'Language Usage' THEN 'LANG'
                     WHEN measurementscale = 'Science - General Science' THEN 'GEN'
                     WHEN measurementscale = 'Science - Concepts and Processes' THEN 'CP'
                     ELSE NULL
                    END
                  + '_pctle' AS pivot_on
                ,percentile_2011_norms AS value
                ,ROW_NUMBER() OVER (
                   PARTITION BY map.studentid, map.map_year, map.termname, CASE WHEN map.testname LIKE '%Algebra%' THEN 'Algebra' ELSE map.measurementscale END
                       ORDER BY map.teststartdate DESC) AS rn_curr
          FROM STUDENTS s WITH(NOLOCK)
          JOIN MAP$comprehensive#identifiers map WITH(NOLOCK)
            ON s.ID = map.ps_studentid
           AND map.testname NOT LIKE '%Algebra%'
          WHERE s.ENROLL_STATUS = 0                   
         ) sub0
     WHERE rn_curr = 1
    ) sub

--/*    
PIVOT (
  MAX(value)
  FOR pivot_on IN (      
                   /*--WINTER--*/
                   [w_2015_READ_RIT]
                  ,[w_2015_READ_pctle]
                  ,[w_2015_MATH_RIT]
                  ,[w_2015_MATH_pctle]
                  ,[w_2015_LANG_RIT]
                  ,[w_2015_LANG_pctle]
                  ,[w_2015_GEN_RIT]
                  ,[w_2015_GEN_pctle]
                  ,[w_2014_READ_RIT]
                  ,[w_2014_READ_pctle]
                  ,[w_2014_MATH_RIT]
                  ,[w_2014_MATH_pctle]
                  ,[w_2014_LANG_RIT]
                  ,[w_2014_LANG_pctle]
                  ,[w_2014_GEN_RIT]
                  ,[w_2014_GEN_pctle]
                  ,[w_2013_READ_RIT]
                  ,[w_2013_READ_pctle]
                  ,[w_2013_MATH_RIT]
                  ,[w_2013_MATH_pctle]
                  ,[w_2013_LANG_RIT]
                  ,[w_2013_LANG_pctle]
                  ,[w_2013_GEN_RIT]
                  ,[w_2013_GEN_pctle]
                  ,[w_2013_CP_RIT]
                  ,[w_2013_CP_pctle]
                  ,[w_2010_GEN_RIT]
                  ,[w_2010_GEN_pctle]
                  ,[w_2010_CP_RIT]
                  ,[w_2010_CP_pctle]
                  ,[w_2009_READ_RIT]
                  ,[w_2009_READ_pctle]
                  ,[w_2009_MATH_RIT]
                  ,[w_2009_MATH_pctle]
                  ,[w_2009_LANG_RIT]
                  ,[w_2009_LANG_pctle]
                  ,[w_2009_GEN_RIT]
                  ,[w_2009_GEN_pctle]
                  ,[w_2009_CP_RIT]
                  ,[w_2009_CP_pctle]
                  /*--SPRING--*/
                  ,[spr_2015_READ_RIT]
                  ,[spr_2015_READ_pctle]
                  ,[spr_2015_MATH_RIT]
                  ,[spr_2015_MATH_pctle]
                  ,[spr_2015_LANG_RIT]
                  ,[spr_2015_LANG_pctle]
                  ,[spr_2015_GEN_RIT]
                  ,[spr_2015_GEN_pctle]
                  ,[spr_2014_READ_RIT]
                  ,[spr_2014_READ_pctle]
                  ,[spr_2014_MATH_RIT]
                  ,[spr_2014_MATH_pctle]
                  ,[spr_2014_LANG_RIT]
                  ,[spr_2014_LANG_pctle]
                  ,[spr_2014_GEN_RIT]
                  ,[spr_2014_GEN_pctle]
                  ,[spr_2013_READ_RIT]
                  ,[spr_2013_READ_pctle]
                  ,[spr_2013_MATH_RIT]
                  ,[spr_2013_MATH_pctle]
                  ,[spr_2013_LANG_RIT]
                  ,[spr_2013_LANG_pctle]
                  ,[spr_2013_GEN_RIT]
                  ,[spr_2013_GEN_pctle]
                  ,[spr_2013_CP_RIT]
                  ,[spr_2013_CP_pctle]
                  ,[spr_2012_READ_RIT]
                  ,[spr_2012_READ_pctle]
                  ,[spr_2012_MATH_RIT]
                  ,[spr_2012_MATH_pctle]
                  ,[spr_2012_LANG_RIT]
                  ,[spr_2012_LANG_pctle]
                  ,[spr_2012_GEN_RIT]
                  ,[spr_2012_GEN_pctle]
                  ,[spr_2012_CP_RIT]
                  ,[spr_2012_CP_pctle]
                  ,[spr_2011_READ_RIT]
                  ,[spr_2011_READ_pctle]
                  ,[spr_2011_MATH_RIT]
                  ,[spr_2011_MATH_pctle]
                  ,[spr_2011_LANG_RIT]
                  ,[spr_2011_LANG_pctle]
                  ,[spr_2011_GEN_RIT]
                  ,[spr_2011_GEN_pctle]
                  ,[spr_2011_CP_RIT]
                  ,[spr_2011_CP_pctle]
                  ,[spr_2010_READ_RIT]
                  ,[spr_2010_READ_pctle]
                  ,[spr_2010_MATH_RIT]
                  ,[spr_2010_MATH_pctle]
                  ,[spr_2010_LANG_RIT]
                  ,[spr_2010_LANG_pctle]
                  ,[spr_2010_GEN_RIT]
                  ,[spr_2010_GEN_pctle]
                  ,[spr_2010_CP_RIT]
                  ,[spr_2010_CP_pctle]
                  ,[spr_2009_READ_RIT]
                  ,[spr_2009_READ_pctle]
                  ,[spr_2009_MATH_RIT]
                  ,[spr_2009_MATH_pctle]
                  ,[spr_2009_LANG_RIT]
                  ,[spr_2009_LANG_pctle]
                  ,[spr_2009_GEN_RIT]
                  ,[spr_2009_GEN_pctle]
                  ,[spr_2009_CP_RIT]      
                  ,[spr_2009_CP_pctle]
                  /*--FALL--*/
                  ,[f_2014_READ_RIT]
                  ,[f_2014_READ_pctle]
                  ,[f_2014_MATH_RIT]
                  ,[f_2014_MATH_pctle]
                  ,[f_2014_LANG_RIT]
                  ,[f_2014_LANG_pctle]
                  ,[f_2014_GEN_RIT]
                  ,[f_2014_GEN_pctle]
                  ,[f_2013_READ_RIT]
                  ,[f_2013_READ_pctle]
                  ,[f_2013_MATH_RIT]
                  ,[f_2013_MATH_pctle]
                  ,[f_2013_LANG_RIT]
                  ,[f_2013_LANG_pctle]
                  ,[f_2013_GEN_RIT]
                  ,[f_2013_GEN_pctle]
                  ,[f_2012_READ_RIT]
                  ,[f_2012_READ_pctle]
                  ,[f_2012_MATH_RIT]
                  ,[f_2012_MATH_pctle]
                  ,[f_2012_LANG_RIT]
                  ,[f_2012_LANG_pctle]
                  ,[f_2012_GEN_RIT]
                  ,[f_2012_GEN_pctle]
                  ,[f_2012_CP_RIT]
                  ,[f_2012_CP_pctle]
                  ,[f_2011_READ_RIT]
                  ,[f_2011_READ_pctle]
                  ,[f_2011_MATH_RIT]
                  ,[f_2011_MATH_pctle]
                  ,[f_2011_LANG_RIT]
                  ,[f_2011_LANG_pctle]
                  ,[f_2011_GEN_RIT]
                  ,[f_2011_GEN_pctle]
                  ,[f_2011_CP_RIT]
                  ,[f_2011_CP_pctle]
                  ,[f_2010_READ_RIT]
                  ,[f_2010_READ_pctle]
                  ,[f_2010_MATH_RIT]
                  ,[f_2010_MATH_pctle]
                  ,[f_2010_LANG_RIT]
                  ,[f_2010_LANG_pctle]
                  ,[f_2010_GEN_RIT]
                  ,[f_2010_GEN_pctle]
                  ,[f_2010_CP_RIT]
                  ,[f_2010_CP_pctle]
                  ,[f_2009_READ_RIT]
                  ,[f_2009_READ_pctle]
                  ,[f_2009_MATH_RIT]
                  ,[f_2009_MATH_pctle]
                  ,[f_2009_LANG_RIT]
                  ,[f_2009_LANG_pctle]
                  ,[f_2009_GEN_RIT]
                  ,[f_2009_GEN_pctle]
                  ,[f_2009_CP_RIT]
                  ,[f_2009_CP_pctle]
                  ,[f_2008_READ_RIT]
                  ,[f_2008_READ_pctle]
                  ,[f_2008_MATH_RIT]
                  ,[f_2008_MATH_pctle]
                  ,[f_2008_LANG_RIT]
                  ,[f_2008_LANG_pctle]
                  ,[f_2008_GEN_RIT]
                  ,[f_2008_GEN_pctle]
                  ,[f_2008_CP_RIT]
                  ,[f_2008_CP_pctle]
                 )
) piv
--*/
USE KIPP_NJ
GO

WITH rost AS
  (SELECT sub.*
         ,ROW_NUMBER() OVER
            (PARTITION BY studentid
             ORDER BY rn
                     ,course_number
             ) AS rn_format
   FROM     
        (SELECT studentid
               ,course_number
               ,schoolid
               ,ROW_NUMBER() OVER 
                  (PARTITION BY studentid
                   ORDER BY CASE
                              WHEN credittype LIKE '%MATH%' THEN '1'
                              WHEN credittype LIKE '%ENG%'  THEN '2'
                              WHEN credittype LIKE '%SCI%'  THEN '3'
                              WHEN credittype LIKE '%SOC%'  THEN '4'
                            END
                  ) AS rn
         FROM KIPP_NJ..GRADES$DETAIL#MS
         WHERE credittype IN ('MATH','ENG','SCI','SOC')
           --AND studentid > 5900
         )sub
   )
  
SELECT *
FROM
       --course name   
      (SELECT rost.studentid, rost.schoolid
	            ,'rc' + CAST(rost.rn_format AS VARCHAR) + '_course_name' AS pivot_on
	            ,pivot_ele.course_name AS value
       FROM rost
       JOIN KIPP_NJ..GRADES$DETAIL#MS pivot_ele
         ON rost.studentid = pivot_ele.studentid
        AND rost.course_number = pivot_ele.course_number
        
       UNION ALL
       
       SELECT rost.studentid, rost.schoolid
	            ,'rc' + CAST(rost.rn_format AS VARCHAR) + '_T1_pct' AS pivot_on
	            ,CAST(pivot_ele.T1 AS VARCHAR) AS value
       FROM rost
       JOIN KIPP_NJ..GRADES$DETAIL#MS pivot_ele
         ON rost.studentid = pivot_ele.studentid
        AND rost.course_number = pivot_ele.course_number
        
       UNION ALL

       SELECT rost.studentid, rost.schoolid
	            ,'rc' + CAST(rost.rn_format AS VARCHAR) + '_T2_pct' AS pivot_on
	            ,CAST(pivot_ele.T2 AS VARCHAR) AS value
       FROM rost
       JOIN KIPP_NJ..GRADES$DETAIL#MS pivot_ele
         ON rost.studentid = pivot_ele.studentid
        AND rost.course_number = pivot_ele.course_number
        
       UNION ALL       
 
       SELECT rost.studentid, rost.schoolid
	         ,'rc' + CAST(rost.rn_format AS VARCHAR) + '_T1_ltr' AS pivot_on
	         ,CAST(pivot_ele.T1_LETTER AS VARCHAR) AS value
       FROM rost
       JOIN KIPP_NJ..GRADES$DETAIL#MS pivot_ele
         ON rost.studentid = pivot_ele.studentid
        AND rost.course_number = pivot_ele.course_number
  
       UNION ALL

       SELECT rost.studentid, rost.schoolid
	         ,'rc' + CAST(rost.rn_format AS VARCHAR) + '_T2_ltr' AS pivot_on
	         ,CAST(pivot_ele.T2_LETTER AS VARCHAR) AS value
       FROM rost
       JOIN KIPP_NJ..GRADES$DETAIL#MS pivot_ele
         ON rost.studentid = pivot_ele.studentid
        AND rost.course_number = pivot_ele.course_number
       
       UNION ALL
       
       SELECT rost.studentid, rost.schoolid
	         ,'rc' + CAST(rost.rn_format AS VARCHAR) + '_H1_pct' AS pivot_on
	         ,CAST(pivot_ele.grade_1 AS VARCHAR) AS value
       FROM rost
       JOIN KIPP_NJ..GRADES$elements pivot_ele
         ON rost.studentid = pivot_ele.studentid
        AND rost.course_number = pivot_ele.course_number
        AND pivot_ele.pgf_type = 'H'
       
       UNION ALL
       
       SELECT rost.studentid, rost.schoolid
	         ,'rc' + CAST(rost.rn_format AS VARCHAR) + '_H2_pct' AS pivot_on
	         ,CAST(pivot_ele.grade_2 AS VARCHAR) AS value
       FROM rost
       JOIN KIPP_NJ..GRADES$elements pivot_ele
         ON rost.studentid = pivot_ele.studentid
        AND rost.course_number = pivot_ele.course_number
        AND pivot_ele.pgf_type = 'H'
       
       UNION ALL
              
       SELECT rost.studentid, rost.schoolid
	         ,'rc' + CAST(rost.rn_format AS VARCHAR) + '_A1_pct' AS pivot_on
	         ,CAST(pivot_ele.grade_1 AS VARCHAR) AS value
       FROM rost
       JOIN KIPP_NJ..GRADES$elements pivot_ele
         ON rost.studentid = pivot_ele.studentid
        AND rost.course_number = pivot_ele.course_number
        AND pivot_ele.pgf_type = 'A'
              
       ) sub
--/*
PIVOT (
  MAX(value) 
  FOR pivot_on 
  IN (rc1_course_name
     ,rc1_T1_pct
     ,rc1_T2_pct

     ,rc1_T1_ltr
     ,rc1_T2_ltr
     
     ,rc1_H1_pct
     ,rc1_H2_pct
     
     ,rc2_course_name
     ,rc2_T1_pct
     ,rc2_T2_pct

     ,rc2_T1_ltr
     ,rc2_T2_ltr
     
     ,rc2_H1_pct
     
     ,rc3_course_name
     ,rc3_T1_pct
     ,rc3_T2_pct

     ,rc3_T1_ltr
     ,rc3_T2_ltr
     
     ,rc3_H1_pct
     )
) AS nothing
--*/
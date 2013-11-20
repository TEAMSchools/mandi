USE KIPP_NJ
GO

ALTER VIEW NJASK$Math_wide AS
SELECT TOP (100) PERCENT 
       s.id AS studentid
      ,s.lastfirst
      ,s.grade_level
      ,s.schoolid
      -- 12-13
      ,NJASK13.subject            AS Subject_2013
      ,NJASK13.NJASK_Scale_Score  AS Score_2013
      ,NJASK13.NJASK_Proficiency  AS Prof_2013
      ,NJASK13.test_grade_level   AS Gr_Lev_2013
      -- 11-12
      ,NJASK12.subject            AS Subject_2012
      ,NJASK12.NJASK_Scale_Score  AS Score_2012
      ,NJASK12.NJASK_Proficiency  AS Prof_2012
      ,NJASK12.test_grade_level   AS Gr_Lev_2012
      -- 10-11
      ,NJASK11.subject            AS Subject_2011
      ,NJASK11.NJASK_Scale_Score  AS Score_2011
      ,NJASK11.NJASK_Proficiency  AS Prof_2011
      ,NJASK11.test_grade_level   AS Gr_Lev_2011
      -- 09-10
      ,NJASK10.subject            AS Subject_2010
      ,NJASK10.NJASK_Scale_Score  AS Score_2010
      ,NJASK10.NJASK_Proficiency  AS Prof_2010
      ,NJASK10.test_grade_level   AS Gr_Lev_2010   

FROM STUDENTS s WITH (NOLOCK)
LEFT OUTER JOIN NJASK$detail#static NJASK13 WITH (NOLOCK)
  ON s.id = NJASK13.studentid
 AND NJASK13.subject    = 'Math'                            
 AND NJASK13.test_date >= '2013-01-01'                      
 AND NJASK13.test_date <= '2013-06-01'                      
LEFT OUTER JOIN NJASK$detail#static NJASK12 WITH (NOLOCK)
  ON s.id = NJASK12.studentid          
 AND NJASK12.subject    = 'Math'                            
 AND NJASK12.test_date >= '2012-01-01'                      
 AND NJASK12.test_date <= '2012-06-01'                      
LEFT OUTER JOIN NJASK$detail#static NJASK11 WITH (NOLOCK)
  ON s.id = NJASK11.studentid          
 AND NJASK11.subject    = 'Math'                           
 AND NJASK11.test_date >= '2011-01-01'                      
 AND NJASK11.test_date <= '2011-06-01'                      
LEFT OUTER JOIN NJASK$detail#static NJASK10 WITH (NOLOCK)
  ON s.id = NJASK10.studentid           
 AND NJASK10.subject    = 'Math'                            
 AND NJASK10.test_date >= '2010-01-01'                       
 AND NJASK10.test_date <= '2010-06-01'                       
WHERE s.enroll_status = 0
  AND s.grade_level >= 3
  AND s.grade_level <= 9
ORDER BY s.grade_level DESC, s.lastfirst
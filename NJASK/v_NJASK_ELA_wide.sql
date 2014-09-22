USE KIPP_NJ
GO

ALTER VIEW NJASK$ELA_wide AS

SELECT ROW_NUMBER() OVER(
          PARTITION BY s.id 
              ORDER BY s.lastfirst) AS rn
      ,s.id AS studentid
      ,s.lastfirst
      ,s.grade_level
      ,s.schoolid
      -- 13-14
      ,NJASK14.subject            AS Subject_2014
      ,NJASK14.NJASK_Scale_Score  AS Score_2014
      ,NJASK14.NJASK_Proficiency  AS Prof_2014
      ,NJASK14.test_grade_level   AS Gr_Lev_2014
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
LEFT OUTER JOIN NJASK$detail#static NJASK14 WITH (NOLOCK)
  ON s.id = NJASK14.studentid
 AND NJASK14.subject    = 'ELA'                            
 AND NJASK14.test_year = 2013
LEFT OUTER JOIN NJASK$detail#static NJASK13 WITH (NOLOCK)
  ON s.id = NJASK13.studentid
 AND NJASK13.subject    = 'ELA'                            
 AND NJASK13.test_year = 2012
LEFT OUTER JOIN NJASK$detail#static NJASK12 WITH (NOLOCK)
  ON s.id = NJASK12.studentid          
 AND NJASK12.subject    = 'ELA'                            
 AND NJASK12.test_year = 2011
LEFT OUTER JOIN NJASK$detail#static NJASK11 WITH (NOLOCK)
  ON s.id = NJASK11.studentid          
 AND NJASK11.subject    = 'ELA'                           
 AND NJASK11.test_year = 2010
LEFT OUTER JOIN NJASK$detail#static NJASK10 WITH (NOLOCK)
  ON s.id = NJASK10.studentid           
 AND NJASK10.subject    = 'ELA'                            
 AND NJASK10.test_year = 2009
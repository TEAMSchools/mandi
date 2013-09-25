USE KIPP_NJ
GO

ALTER VIEW NJASK$ELA_wide AS
SELECT *
FROM OPENQUERY(KIPP_NWK,'
       SELECT DISTINCT s.id
                      ,s.lastfirst
                      ,s.grade_level
                      ,s.schoolid
                      ,NJASK08.subject            AS Subject_2013
                      ,NJASK08.NJASK_Scale_Score  AS Score_2013
                      ,NJASK08.NJASK_Proficiency  AS Prof_2013
                      ,NJASK08.test_grade_level   AS Gr_Lev_2013
                      ,NJASK07.subject            AS Subject_2012
                      ,NJASK07.NJASK_Scale_Score  AS Score_2012
                      ,NJASK07.NJASK_Proficiency  AS Prof_2012
                      ,NJASK07.test_grade_level   AS Gr_Lev_2012
                      ,NJASK01.subject            AS Subject_2011
                      ,NJASK01.NJASK_Scale_Score  AS Score_2011
                      ,NJASK01.NJASK_Proficiency  AS Prof_2011
                      ,NJASK01.test_grade_level   AS Gr_Lev_2011
                      ,NJASK02.subject            AS Subject_2010
                      ,NJASK02.NJASK_Scale_Score  AS Score_2010
                      ,NJASK02.NJASK_Proficiency  AS Prof_2010
                      ,NJASK02.test_grade_level   AS Gr_Lev_2010
                      --,NJASK03.subject            AS Subject_2009
                      --,NJASK03.NJASK_Scale_Score  AS Score_2009
                      --,NJASK03.NJASK_Proficiency  AS Prof_2009
                      --,NJASK03.test_grade_level   AS Gr_Lev_2009
                      --,NJASK04.subject            AS Subject_2008
                      --,NJASK04.NJASK_Scale_Score  AS Score_2008
                      --,NJASK04.NJASK_Proficiency  AS Prof_2008
                      --,NJASK04.test_grade_level   AS Gr_Lev_2008
                      --,NJASK05.subject            AS Subject_2007
                      --,NJASK05.NJASK_Scale_Score  AS Score_2007
                      --,NJASK05.NJASK_Proficiency  AS Prof_2007
                      --,NJASK05.test_grade_level   AS Gr_Lev_2007
                      --,NJASK06.subject            AS Subject_2006
                      --,NJASK06.NJASK_Scale_Score  AS Score_2006
                      --,NJASK06.NJASK_Proficiency  AS Prof_2006  
                      --,NJASK06.test_grade_level   AS Gr_Lev_2006        
       FROM STUDENTS@PS_TEAM s
       LEFT OUTER JOIN NJASK$DETAIL NJASK08
         ON s.id = NJASK08.njask_studentid
        AND NJASK08.subject    = ''ELA''                            
        AND NJASK08.test_date >= ''2013-01-01''                      
        AND NJASK08.test_date <= ''2013-06-01''                      
       LEFT OUTER JOIN NJASK$DETAIL NJASK07
         ON s.id = NJASK07.njask_studentid          
        AND NJASK07.subject    = ''ELA''                            
        AND NJASK07.test_date >= ''2012-01-01''                      
        AND NJASK07.test_date <= ''2012-06-01''                      
       LEFT OUTER JOIN NJASK$DETAIL NJASK01
         ON s.id = NJASK01.njask_studentid          
        AND NJASK01.subject    = ''ELA''                           
        AND NJASK01.test_date >= ''2011-01-01''                      
        AND NJASK01.test_date <= ''2011-06-01''                      
       LEFT OUTER JOIN NJASK$DETAIL NJASK02
         ON s.id = NJASK02.njask_studentid           
        AND NJASK02.subject    = ''ELA''                            
        AND NJASK02.test_date >= ''2010-01-01''                       
        AND NJASK02.test_date <= ''2010-06-01''                       
       /*  
         LEFT OUTER JOIN NJASK$DETAIL NJASK03
       ON s.id                    =  NJASK03.njask_studentid           
       AND NJASK03.subject        =  ''ELA''                            
       AND NJASK03.test_date      >= ''2009-01-01''                       
       and NJASK03.test_date      <= ''2009-06-01''                       
         LEFT OUTER JOIN NJASK$DETAIL NJASK04
       ON s.id                    =  NJASK04.njask_studentid           
       AND NJASK04.subject        =  ''ELA''                            
       AND NJASK04.test_date      >= ''2008-01-01''                       
       and NJASK04.test_date      <= ''2008-06-01''                       
         LEFT OUTER JOIN NJASK$DETAIL NJASK05
       ON s.id                    =  NJASK05.njask_studentid           
       AND NJASK05.subject        =  ''ELA''                            
       AND NJASK05.test_date      >= ''2007-01-01''                       
       and NJASK05.test_date      <= ''2007-06-01''                       
          LEFT OUTER JOIN NJASK$DETAIL NJASK06
       ON s.id                    =  NJASK06.njask_studentid           
       AND NJASK06.subject        =  ''ELA''                            
       AND NJASK06.test_date      >= ''2006-01-01''                       
       and NJASK06.test_date      <= ''2006-06-01''                              
       */
       WHERE s.enroll_status = 0
       ORDER BY s.grade_level DESC, s.lastfirst
       ')
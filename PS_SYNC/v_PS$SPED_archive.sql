USE KIPP_NJ
GO

ALTER VIEW PS$SPED_archive AS

SELECT sub.studentid
      ,sub.academic_year
      ,sub.SPEDLEP
      ,sub.SPEDCODE
FROM
    (
     SELECT studentid
           ,academic_year
           ,SPEDLEP
           ,SPEDCODE
     FROM
         (
          SELECT studentid      
                ,CONVERT(INT,'20' + REVERSE(SUBSTRING(REVERSE(field),3,2))) AS academic_year      
                ,LEFT(field, (CHARINDEX('_', field) - 1)) AS field           
                ,value
          FROM
              (
               SELECT studentid
                     ,CONVERT(VARCHAR(64),SPEDLEP_1314) AS SPEDLEP_1314
                     ,CONVERT(VARCHAR(64),SPEDCODE_1314) AS SPEDCODE_1314
               FROM OPENQUERY(PS_TEAM,'
                 SELECT s.id AS studentid
                       ,ext.SPEDLEP_1314
                       ,ext.SPEDCODE_1314
                 FROM U_DEF_EXT_STUDENTS ext
                 JOIN STUDENTS s
                   ON ext.studentsdcid = s.dcid  
               ')
              ) sub
          UNPIVOT (
            value
            FOR field IN (SPEDLEP_1314, SPEDCODE_1314)
           ) u    
         ) sub
     PIVOT(
       MAX(value)
       FOR field IN ([SPEDCODE], [SPEDLEP])
      ) p
    ) sub
JOIN COHORT$comprehensive_long#static co
  ON sub.studentid = co.studentid
 AND sub.academic_year = co.year
 AND co.rn = 1
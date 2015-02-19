USE KIPP_NJ
GO

ALTER PROCEDURE sp_ATT_MEM$attendance_time_series#UPSERT AS

BEGIN

  WITH ts_update AS (
    SELECT studentid
          ,school
          ,grade_level
          ,academic_year           
          ,reporting_hash
          ,MAX(n_mem) AS n_mem
          ,MAX(n_att) AS n_att
          ,MAX(n_tardy) AS n_tardy
          ,CASE 
            WHEN MAX(CONVERT(FLOAT,n_mem)) = 0 THEN NULL
            ELSE ROUND(MAX(CONVERT(FLOAT,n_att)) / MAX(CONVERT(FLOAT,n_mem)) * 100,1) 
           END AS att_pct
          ,CASE 
            WHEN MAX(CONVERT(FLOAT,n_mem)) = 0 THEN NULL
            ELSE ROUND(MAX(CONVERT(FLOAT,n_tardy)) / MAX(CONVERT(FLOAT,n_mem)) * 100,1) 
           END AS tardy_pct
          ,CASE
            WHEN MAX(CONVERT(FLOAT,n_mem)) = 0 THEN NULL
            WHEN MAX(CONVERT(FLOAT,n_att)) / MAX(CONVERT(FLOAT,n_mem)) < .9 THEN 1.0
            WHEN MAX(CONVERT(FLOAT,n_att)) / MAX(CONVERT(FLOAT,n_mem)) >= .9 THEN 0.0
            ELSE NULL
           END AS is_offtrack_att
          ,CASE
            WHEN MAX(CONVERT(FLOAT,n_mem)) = 0 THEN NULL
            WHEN MAX(CONVERT(FLOAT,n_tardy)) / MAX(CONVERT(FLOAT,n_mem)) >= .2 THEN 1.0
            WHEN MAX(CONVERT(FLOAT,n_tardy)) / MAX(CONVERT(FLOAT,n_mem)) < .2 THEN 0.0
            ELSE NULL
           END AS is_offtrack_tardy
    FROM
        (
         SELECT co.studentid            
               ,co.school_name AS school
               ,co.grade_level            
               ,co.year AS academic_year
               ,co.date
               ,CONVERT(VARCHAR,DATEPART(YEAR,co.date) * 100 + DATEPART(WEEK,co.date)) AS reporting_hash
               ,SUM(CONVERT(FLOAT,ISNULL(mem.membershipvalue,0))) OVER(
                  PARTITION BY co.studentid, co.year
                    ORDER BY co.date
                  ROWS UNBOUNDED PRECEDING
                 ) AS n_mem
               ,SUM(CONVERT(FLOAT,ISNULL(mem.attendancevalue,0))) OVER(
                  PARTITION BY co.studentid, co.year
                    ORDER BY co.date
                  ROWS UNBOUNDED PRECEDING
                 ) AS n_att                           
               ,SUM(CASE WHEN att.ATT_CODE IN ('T', 'T10') THEN 1.0 ELSE 0.0 END) OVER(
                  PARTITION BY co.studentid, co.year
                    ORDER BY co.date
                  ROWS UNBOUNDED PRECEDING
                 ) AS n_tardy
         FROM KIPP_NJ..COHORT$identifiers_scaffold#static co WITH(NOLOCK) -- keeps all weeks active for reporting purposes
         LEFT OUTER JOIN KIPP_NJ..ATT_MEM$MEMBERSHIP mem WITH(NOLOCK)
           ON co.studentid = mem.studentid
          AND co.date = mem.CALENDARDATE
         LEFT OUTER JOIN KIPP_NJ..ATT_MEM$ATTENDANCE att WITH(NOLOCK)
           ON co.studentid = att.STUDENTID
          AND co.date = att.ATT_DATE       
         WHERE co.year = KIPP_NJ.dbo.fn_Global_Academic_Year() -- production
         --WHERE co.date <= CONVERT(DATE,GETDATE()) -- for backfilling
        ) sub
    GROUP BY studentid
            ,school
            ,grade_level
            ,academic_year
            ,reporting_hash     
   ) 

  MERGE KIPP_NJ..ATT_MEM$attendance_time_series AS TARGET
  USING ts_update AS SOURCE
     ON TARGET.studentid = SOURCE.studentid
    AND TARGET.academic_year = SOURCE.academic_year
    AND TARGET.reporting_hash = SOURCE.reporting_hash
  WHEN MATCHED THEN
   UPDATE
    SET TARGET.school = SOURCE.school
       ,TARGET.grade_level = SOURCE.grade_level
       ,TARGET.n_mem = SOURCE.n_mem
       ,TARGET.n_att = SOURCE.n_att
       ,TARGET.n_tardy = SOURCE.n_tardy
       ,TARGET.att_pct = SOURCE.att_pct
       ,TARGET.tardy_pct = SOURCE.tardy_pct
       ,TARGET.is_offtrack_att = SOURCE.is_offtrack_att
       ,TARGET.is_offtrack_tardy = SOURCE.is_offtrack_tardy
  WHEN NOT MATCHED THEN
   INSERT
    (studentid
    ,school
    ,grade_level
    ,academic_year
    ,reporting_hash
    ,n_mem
    ,n_att
    ,n_tardy
    ,att_pct
    ,tardy_pct
    ,is_offtrack_att
    ,is_offtrack_tardy)
   VALUES
    (SOURCE.studentid
    ,SOURCE.school
    ,SOURCE.grade_level
    ,SOURCE.academic_year
    ,SOURCE.reporting_hash
    ,SOURCE.n_mem
    ,SOURCE.n_att
    ,SOURCE.n_tardy
    ,SOURCE.att_pct
    ,SOURCE.tardy_pct
    ,SOURCE.is_offtrack_att
    ,SOURCE.is_offtrack_tardy);

END

GO

/*-- unused code for aggregating by school --*/
--SELECT school
--      ,ISNULL(CONVERT(VARCHAR,grade_level),'campus') AS grade_level
--      ,academic_year
--      ,reporting_hash
--      ,COUNT(studentid) AS n_enrollment
--      ,SUM(n_mem) AS total_mem
--      ,SUM(n_att) AS total_att
--      ,CASE
--        WHEN SUM(n_mem) = 0 THEN NULL
--        ELSE ROUND((SUM(n_att) / SUM(n_mem)) * 100, 2)
--       END AS total_att_pct      
--      ,ISNULL(SUM(is_offtrack),0) AS n_off_track
--      ,ROUND(AVG(is_offtrack) * 100, 2) AS pct_off_track
--FROM
--    (

--    ) sub
--GROUP BY school
--        ,CUBE(grade_level)
--        ,academic_year
--        ,reporting_hash
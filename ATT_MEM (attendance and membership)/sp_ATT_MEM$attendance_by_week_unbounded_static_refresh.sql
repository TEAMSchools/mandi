USE [SPI]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
 
ALTER PROCEDURE [dbo].[sp_ATT_MEM$attendance_by_week_unbounded#static|refresh] AS
BEGIN

 DECLARE @sql AS VARCHAR(MAX)='';

 --STEP 1: make sure no temp table
		IF OBJECT_ID(N'tempdb..#ATT_MEM$attendance_by_week_unbounded#static|refresh') IS NOT NULL
		BEGIN
						DROP TABLE [#ATT_MEM$attendance_by_week_unbounded#static|refresh]
		END
		
		--STEP 2: load into a TEMPORARY staging table.
		SELECT *
		INTO [#ATT_MEM$attendance_by_week_unbounded#static|refresh]
				--FOR CREATING TABLE FIRST TIME
		--INTO ATT_MEM$attendance_by_week_unbounded#static
FROM OPENQUERY(PS_TEAM, '
SELECT studentid
      ,school
      ,grade_level
      ,reporting_hash
      ,mem
      ,att
      ,nvl(off_track,0) AS off_track
      ,N
      ,percent_off_track
      ,CASE
         WHEN mem = 0 THEN null
         ELSE ROUND(((att / mem) * 100), 2)
       END AS att_pct
       ,yearid
FROM
--LEVEL 7: rollup by school
(SELECT DECODE(GROUPING(studentid),0,TO_CHAR(studentid),''campus'') AS studentid
      ,school
      ,grade_level
      ,yearid
      ,reporting_hash
      ,SUM(mem_dense) AS mem
      ,SUM(att_dense) AS att
      ,COUNT(*) AS n   
      ,SUM(off_track_indicator) AS off_track
      ,ROUND(AVG(off_track_indicator)*100,2) AS percent_off_track
FROM
   --LEVEL 6: 
   (SELECT studentid
          ,school
          ,grade_level
          ,yearid
          ,reporting_hash
          ,mem_dense
          ,att_dense
          ,CASE
             WHEN mem_dense = 0 THEN NULL
             WHEN att_dense / mem_dense < .9  THEN 1
             WHEN att_dense / mem_dense >= .9 THEN 0
             ELSE NULL
           END AS off_track_indicator
    FROM
        --LEVEL 5: densify data/fill in NULLS by right outer join 
       (SELECT studentid
              ,school
              ,grade_level
              ,yearid
              ,weeks.reporting_hash
              ,max_hash
              ,min_hash
              ,nvl(
                 last_value(rolling_mem IGNORE NULLS) OVER 
                (PARTITION BY studentid
                             ,grade_level
                             ,yearid
                 ORDER BY  weeks.reporting_hash ASC)
               ,0) mem_dense
               ,nvl(
                 last_value(rolling_att IGNORE NULLS) OVER 
                (PARTITION BY studentid 
                             ,grade_level
                             ,yearid
                 ORDER BY  weeks.reporting_hash ASC)
               ,0) att_dense
        FROM
            --LEVEL 4: pull end of week (eg MAX) value 
            (SELECT studentid
                  ,school
                  ,grade_level
                  ,yearid
                  ,reporting_hash
                  ,max_hash
                  ,min_hash
                  ,MAX(rolling_mem) AS rolling_mem
                  ,MAX(rolling_att) AS rolling_att
            FROM
                --LEVEL 3: unbounded sum -- absences and membership
                (SELECT studentid
                      ,school
                      ,grade_level
                      ,yearid
                      ,calendardate
                      ,reporting_hash
                      ,mem_value
                      ,att_value
                      ,SUM(SUM(mem_value)) OVER
                         (PARTITION BY studentid
                                      ,grade_level
                                      ,yearid
                          ORDER BY studentid
                                  ,calendardate
                          ROWS UNBOUNDED PRECEDING) AS rolling_mem
                      ,SUM(SUM(att_value)) OVER
                         (PARTITION BY studentid
                                      ,grade_level
                                      ,yearid
                          ORDER BY studentid
                                  ,calendardate
                          ROWS UNBOUNDED PRECEDING) AS rolling_att
                      ,MAX(reporting_hash) OVER
                          (PARTITION BY studentid
                                       ,grade_level
                                       ,yearid
                          ORDER BY studentid
                                  ,calendardate
                          ROWS UNBOUNDED PRECEDING) AS max_hash
                      ,MIN(reporting_hash) OVER
                          (PARTITION BY studentid
                                       ,grade_level
                                       ,yearid
                          ORDER BY studentid
                                  ,calendardate
                          ROWS UNBOUNDED PRECEDING) AS min_hash
                FROM 
                   --LEVEL 2: get att status for each day 
                   (SELECT level_1.studentid
                          ,level_1.school
                          ,level_1.grade_level
                          ,terms.id AS yearid
                          ,level_1.calendardate
                          ,(to_char(calendardate, ''YYYY'') * 
                              100 + to_char(calendardate, ''WW'')) 
                              AS reporting_hash
                          ,level_1.mem_value
                          ,CASE 
                             WHEN att_d.presence_status_cd IS NULL THEN 1
                             WHEN att_d.presence_status_cd = ''Present'' THEN 1
                             WHEN att_d.presence_status_cd = ''Absent'' THEN 0
                           END AS att_value
                    FROM 
                        --LEVEL 1: get granular day by day 
                       (SELECT att.studentid AS studentid
                              ,students.lastfirst
                              ,att.grade_level
                              ,schools.abbreviation AS school
                              ,att.calendardate
                              ,att.membershipvalue AS mem_value
                          FROM students
                          LEFT OUTER JOIN PS_ADAADM_DAILY_CTOD att
                            ON students.id = att.studentid
                          LEFT OUTER JOIN schools
                            ON att.schoolid = schools.school_number
                          WHERE students.id = 2542
                        ) level_1 
                    LEFT OUTER JOIN PS_ATTENDANCE_DAILY ATT_D
                      ON level_1.studentid=att_d.studentid
                     AND level_1.calendardate = att_d.att_date
                    JOIN TERMS
                      ON level_1.calendardate >= terms.firstday
                     AND level_1.calendardate <= terms.lastday
                     AND terms.portion = 1
                    WHERE level_1.mem_value != 0
                    ) level_2      
                GROUP BY studentid
                        ,school
                        ,grade_level
                        ,yearid
                        ,calendardate
                        ,reporting_hash
                        ,mem_value
                        ,att_value
                ) level_3
            GROUP BY studentid
                    ,school
                    ,grade_level
                    ,yearid
                    ,reporting_hash
                    ,max_hash
                    ,min_hash
            ) level_4
        PARTITION BY (studentid
                     ,school
                     ,grade_level
                     ,yearid)
        RIGHT OUTER JOIN 
          (SELECT reporting_hash
           FROM
              (SELECT 2004 + (FLOOR(sub.n / 52) - 1) || to_char(mod(sub.n,52) + 1,''FM00'') AS reporting_hash
               FROM
                    (SELECT ROWNUM n
                     FROM ( SELECT 1 just_a_column
                            FROM dual
                            GROUP BY CUBE(1,2,3,4,5,6,7,8,9,10) )
                     ) sub        
               WHERE n >= 52)
           WHERE reporting_hash >= 200432
             AND reporting_hash <= 201326
          ) weeks
          ON level_4.reporting_hash = weeks.reporting_hash
        ) level_5
        WHERE reporting_hash <= max_hash
          AND reporting_hash >= min_hash
    ) level_6
GROUP BY ROLLUP(studentid)
        ,school
        ,grade_level
        ,yearid
        ,reporting_hash
) level_7
ORDER BY school
        ,studentid
        ,reporting_hash
')

  --STEP 3: LOCK destination table exclusively load into a TEMPORARY staging table.
  --SELECT 1 FROM [ATT_MEM$weekly_off_track_totals] WITH (TABLOCKX);

  --STEP 4: truncate 
  EXEC('TRUNCATE TABLE dbo.[ATT_MEM$attendance_by_week_unbounded#static]');

  --STEP 5: disable all nonclustered indexes on table
  SELECT @sql = @sql + 
   'ALTER INDEX ' + indexes.name + ' ON  dbo.' + objects.name + ' DISABLE;' +CHAR(13)+CHAR(10)
  FROM 
   sys.indexes
  JOIN 
   sys.objects 
   ON sys.indexes.object_id = sys.objects.object_id
  WHERE sys.indexes.type_desc = 'NONCLUSTERED'
   AND sys.objects.type_desc = 'USER_TABLE'
   AND sys.objects.name = 'ATT_MEM$attendance_by_week_unbounded#static';

 EXEC (@sql);

 -- step 3: insert rows from remote source
 INSERT INTO SPI..[ATT_MEM$attendance_by_week_unbounded#static]
 SELECT *
 FROM [#ATT_MEM$attendance_by_week_unbounded#static|refresh];

 -- Step 4: rebuld all nonclustered indexes on table
 SELECT @sql = @sql + 
  'ALTER INDEX ' + indexes.name + ' ON  dbo.' + objects.name +' REBUILD;' +CHAR(13)+CHAR(10)
 FROM 
  sys.indexes
 JOIN 
  sys.objects 
  ON sys.indexes.object_id = sys.objects.object_id
 WHERE sys.indexes.type_desc = 'NONCLUSTERED'
  AND sys.objects.type_desc = 'USER_TABLE'
  AND sys.objects.name = 'ATT_MEM$attendance_by_week_unbounded#static';

 EXEC (@sql);
  
END
GO

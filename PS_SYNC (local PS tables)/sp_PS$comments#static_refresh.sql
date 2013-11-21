USE [KIPP_NJ]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER PROCEDURE [dbo].[sp_PS$comments#static|refresh] AS
BEGIN

 DECLARE @sql AS VARCHAR(MAX)='';

 --STEP 1: make sure no temp table
		IF OBJECT_ID(N'tempdb..#PS$comments#static|refresh') IS NOT NULL
		BEGIN
						DROP TABLE [#PS$comments#static|refresh]
		END
		
		--STEP 2: load into a TEMPORARY staging table.
  SELECT *
		INTO [#PS$comments#static|refresh]
  FROM (SELECT s.id
              ,cc.course_number
              ,tco.sectionid
              ,tco.finalgradename
              ,CASE WHEN cc.course_number IN ('HR','Adv') THEN NULL ELSE tco.teacher_comment END AS teacher_comment
              ,CASE WHEN cc.course_number IN ('HR','Adv') THEN tco.teacher_comment ELSE NULL END AS advisor_comment
        FROM STUDENTS s
        JOIN OPENQUERY(PS_TEAM,'
               SELECT pgf.studentid            
                     ,pgf.sectionid           
                     ,pgf.finalgradename             
                     ,CAST(SUBSTR(pgf.comment_value,1,4000) AS varchar2(4000)) AS teacher_comment
               FROM pgfinalgrades pgf       
               WHERE (pgf.finalgradename LIKE ''T%'' OR pgf.finalgradename LIKE ''Q%'')       
                 AND pgf.startdate >= TO_DATE(CASE
                                               WHEN TO_CHAR(SYSDATE,''MON'') IN (''JAN'',''FEB'',''MAR'',''APR'',''MAY'',''JUN'',''JUL'')
                                               THEN TO_CHAR(TO_CHAR(SYSDATE,''YYYY'') - 1)
                                               ELSE TO_CHAR(SYSDATE,''YYYY'')
                                              END || ''-08-01'',''YYYY-MM-DD'')    
                 AND pgf.comment_value IS NOT NULL         
               ') tco
          ON s.id = tco.studentid
        LEFT OUTER JOIN CC
          ON s.id = cc.studentid
         AND cc.sectionid = tco.sectionid
       ) zappaisgod;
   
  --STEP 3: LOCK destination table exclusively load into a TEMPORARY staging table.
  --SELECT 1 FROM [] WITH (TABLOCKX);

  --STEP 4: truncate 
  EXEC('TRUNCATE TABLE KIPP_NJ..PS$comments#static');

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
   AND sys.objects.name = 'PS$comments#static';

 EXEC (@sql);

 -- step 6: insert into final destination
 INSERT INTO [dbo].[PS$comments#static]
 SELECT *
 FROM [#PS$comments#static|refresh];

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
  AND sys.objects.name = 'PS$comments#static|refresh';

 EXEC (@sql);
  
END
GO
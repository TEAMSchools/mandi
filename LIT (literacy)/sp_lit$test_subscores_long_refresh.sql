USE KIPP+AF8-NJ
GO

SET ANSI+AF8-NULLS ON
GO

SET QUOTED+AF8-IDENTIFIER ON
GO

ALTER PROCEDURE dbo.+AFs-sp+AF8-lit+ACQ-test+AF8-subscores+AF8-long+AHw-refresh+AF0- AS
BEGIN

--variables
DECLARE +AEA-sql AS VARCHAR(MAX)+AD0-''+ADs-

 --step 1: truncate result table
 EXEC('TRUNCATE TABLE KIPP+AF8-NJ.DBO.LIT+ACQ-TEST+AF8-SUBSCORES+AF8-LONG')

 --step 2: disable nonclustered indexes on table
 SELECT +AEA-sql +AD0- +AEA-sql +- 
  'ALTER INDEX ' +- indexes.name +- ' ON  dbo.' +- objects.name +- ' DISABLE+ADs-' +-CHAR(13)+-CHAR(10)
 FROM 
  sys.indexes
 JOIN 
  sys.objects 
  ON sys.indexes.object+AF8-id +AD0- sys.objects.object+AF8-id
 WHERE sys.indexes.type+AF8-desc +AD0- 'NONCLUSTERED'
  AND sys.objects.type+AF8-desc +AD0- 'USER+AF8-TABLE'
  AND sys.objects.name +AD0- 'LIT+ACQ-TEST+AF8-SUBSCORES+AF8-LONG'+ADs-
  
 EXEC (+AEA-sql)+ADs-

 --step 3: insert rows from remote
 INSERT INTO dbo.lit+ACQ-test+AF8-subscores+AF8-long
   (+AFs-CUST+AF8-STUDENTID+AF0-
   ,+AFs-STUDENTID+AF0-
   ,+AFs-STUDENT+AF8-NUMBER+AF0-
   ,+AFs-RD+AF8-TESTID+AF8-BASE+AF0-
   ,+AFs-SCOREID+AF0-
   ,+AFs-DATE+AF8-TAKEN+AF0-
   ,+AFs-RDG+AF8-LEVEL+AF0-
   ,+AFs-STATUS+AF0-
   ,+AFs-DCID+AF0-
   ,+AFs-RD+AF8-TESTID+AF8-SUB+AF0-
   ,+AFs-TEST+AF8-NAME+AF0-
   ,+AFs-SUBTEST+AF8-NAME+AF0-
   ,+AFs-FIELDNAME+AF0-
   ,+AFs-SORTORDER+AF0-
   ,+AFs-VALUE+AF0-)
 SELECT sub.+ACo-
   --uncomment to create a destination table
   --INTO LIT+ACQ-TEST+AF8-SUBSCORES+AF8-LONG
 FROM OPENQUERY(PS+AF8-TEAM, '
   WITH base+AF8-tests AS
    (SELECT foreignKey                       AS cust+AF8-studentid
           ,s.id                             AS studentid
           ,s.student+AF8-number
           ,scores.foreignKey+AF8-alpha          AS rd+AF8-testid+AF8-base
           ,scores.unique+AF8-id                 AS scoreid
           ,scores.user+AF8-defined+AF8-date         AS date+AF8-taken
           ,user+AF8-defined+AF8-text                AS rdg+AF8-level
           ,user+AF8-defined+AF8-text2               AS status
     FROM virtualtablesdata3 scores
     JOIN students s on s.id +AD0- scores.foreignKey 
     WHERE scores.related+AF8-to+AF8-table +AD0- ''readingScores'' 
     ORDER BY scores.schoolid, s.grade+AF8-level, s.team, s.lastfirst, scores.user+AF8-defined+AF8-date DESC),

    subscores AS
    (SELECT main+AF8-test.dcid
           ,main+AF8-test.id rd+AF8-testid+AF8-sub
           ,main+AF8-test.name AS test+AF8-name
           ,subtest.NAME AS subtest+AF8-name
           ,subtest.value2 AS fieldname
           ,subtest.sortorder
     FROM gen main+AF8-test
     JOIN gen subtest 
       ON main+AF8-test.id +AD0- subtest.valueli 
      AND subtest.cat +AD0- ''rdgTestField''
     WHERE main+AF8-test.cat +AD0- ''rdgTest''
     ORDER BY main+AF8-test.name)
    
 SELECT base+AF8-tests.+ACo-
       ,subscores.+ACo-
       ,PS+AF8-CUSTOMFIELDS.GETCF(''readingScores'', subscore+AF8-values.unique+AF8-id, subscores.fieldname) AS value
 FROM base+AF8-tests
 JOIN subscores
   ON base+AF8-tests.rd+AF8-testid+AF8-base +AD0- subscores.rd+AF8-testid+AF8-sub
 JOIN virtualtablesdata3 subscore+AF8-values
   ON base+AF8-tests.scoreid +AD0- subscore+AF8-values.unique+AF8-id'
 ) sub


 -- Step 4: rebuld all nonclustered indexes on table
 SELECT +AEA-sql +AD0- +AEA-sql +- 
  'ALTER INDEX ' +- indexes.name +- ' ON  dbo.' +- objects.name +-' REBUILD+ADs-' +-CHAR(13)+-CHAR(10)
 FROM 
  sys.indexes
 JOIN 
  sys.objects 
  ON sys.indexes.object+AF8-id +AD0- sys.objects.object+AF8-id
 WHERE sys.indexes.type+AF8-desc +AD0- 'NONCLUSTERED'
  AND sys.objects.type+AF8-desc +AD0- 'USER+AF8-TABLE'
  AND sys.objects.name +AD0- 'LIT+ACQ-TEST+AF8-SUBSCORES+AF8-LONG'+ADs-

 EXEC (+AEA-sql)+ADs-

END
GO

  
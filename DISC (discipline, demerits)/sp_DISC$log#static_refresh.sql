USE [KIPP_NJ]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER PROCEDURE [dbo].[sp_DISC$log#static|refresh] AS
BEGIN

 DECLARE @sql AS VARCHAR(MAX)='';

  --STEP 1: make sure no temp table
		IF OBJECT_ID(N'tempdb..#DISC$log#static|refresh1') IS NOT NULL
		BEGIN
						DROP TABLE [#DISC$log#static|refresh1]
		END


  --STEP 2: load into a TEMPORARY staging table.
  SELECT *
		INTO [#DISC$log#static|refresh1]
  FROM (
        SELECT oq.schoolid
              ,CAST(studentid AS INT) AS studentid
              ,entry_author
              ,CONVERT(DATE,entry_date) AS entry_date
              ,CONVERT(DATE,discipline_incidentdate) AS consequence_date
              ,logtypeid      
              ,consequence
              ,CASE      
                --ES Discipline Log
                WHEN subtype = '01' AND logtypeid = 3123 THEN 'Tantrum - Dangerous'
                WHEN subtype = '02' AND logtypeid = 3123 THEN 'Tantrum - Disruptive'
                WHEN subtype = '03' AND logtypeid = 3123 THEN 'Aggr Phys Contact'
                WHEN subtype = '04' AND logtypeid = 3123 THEN 'Inapprop Contact'
                WHEN subtype = '05' AND logtypeid = 3123 THEN 'Inapprop. Contact'
                WHEN subtype = '06' AND logtypeid = 3123 THEN 'Running Away'
                WHEN subtype = '07' AND logtypeid = 3123 THEN 'Fighting'
                WHEN subtype = '08' AND logtypeid = 3123 THEN 'Other - Please spec'            
                --ES Bus Log
                WHEN subtype = '01' AND logtypeid = 3124 THEN 'Bullying'
                WHEN subtype = '02' AND logtypeid = 3124 THEN 'Disrespect'
                WHEN subtype = '03' AND logtypeid = 3124 THEN 'Fighting'
                WHEN subtype = '04' AND logtypeid = 3124 THEN 'Horseplay'
                WHEN subtype = '05' AND logtypeid = 3124 THEN 'Moving / Standing'
                WHEN subtype = '06' AND logtypeid = 3124 THEN 'Unsafe / Throwing'
                WHEN subtype = '07' AND logtypeid = 3124 THEN '[OTHER]'               
                --ES/MS codes
                WHEN subtype = '01' AND logtypeid = -100000 THEN 'Detention'
                WHEN subtype = '02' AND logtypeid = -100000 THEN 'Silent Lunch'
                WHEN subtype = '03' AND logtypeid = -100000 THEN 'Choices'
                WHEN subtype = '04' AND logtypeid = -100000 THEN 'Bench'
                WHEN subtype = '05' AND logtypeid = -100000 THEN 'ISS'
                WHEN subtype = '06' AND logtypeid = -100000 THEN 'OSS'
                WHEN subtype = '07' AND logtypeid = -100000 THEN 'Bus Warning'
                WHEN subtype = '08' AND logtypeid = -100000 THEN 'Bus Suspension'
                WHEN subtype = '09' AND logtypeid = -100000 THEN 'Class Removal'
                WHEN subtype = '10' AND logtypeid = -100000 THEN 'Bullying'
                WHEN subtype = '11' AND logtypeid = -100000 THEN 'Silent Lunch (5 Day)'
                WHEN subtype = '12' AND logtypeid = -100000 THEN 'Paycheck'                
                --NCA merits
                WHEN subtype = '01' AND logtypeid = 3023 THEN 'No Demerits'
                WHEN subtype = '02' AND logtypeid = 3023 THEN 'Panther Pride'
                WHEN subtype = '03' AND logtypeid = 3023 THEN 'Work Crew'
                WHEN subtype = '04' AND logtypeid = 3023 THEN 'Courage'
                WHEN subtype = '05' AND logtypeid = 3023 THEN 'Excellence'
                WHEN subtype = '06' AND logtypeid = 3023 THEN 'Humanity'
                WHEN subtype = '07' AND logtypeid = 3023 THEN 'Leadership'
                WHEN subtype = '08' AND logtypeid = 3023 THEN 'Parent'
                WHEN subtype = '09' AND logtypeid = 3023 THEN 'Other'                
                --NCA demerits
                WHEN subtype = '01' AND logtypeid = 3223 THEN 'Off Task'
                WHEN subtype = '02' AND logtypeid = 3223 THEN 'Gum'
                WHEN subtype = '03' AND logtypeid = 3223 THEN 'Eating/Drinking'
                WHEN subtype = '04' AND logtypeid = 3223 THEN 'Play Fight'
                WHEN subtype = '05' AND logtypeid = 3223 THEN 'Excessive Volume'
                WHEN subtype = '06' AND logtypeid = 3223 THEN 'Language'
                WHEN subtype = '07' AND logtypeid = 3223 THEN 'No Pass'
                WHEN subtype = '08' AND logtypeid = 3223 THEN 'Uniform'
                WHEN subtype = '09' AND logtypeid = 3223 THEN '> 4 Min Late'
                WHEN subtype = '10' AND logtypeid = 3223 THEN 'Other'        
                ELSE NULL
               END AS subtype      
              ,CASE
                WHEN discipline_incidenttype = 'AD' THEN 'Dishonesty / Plagiarism / Forgery'
                WHEN discipline_incidenttype = 'CE' THEN 'Cell Phone/Electronics'
                WHEN discipline_incidenttype = 'CH' THEN 'Cheating'
                WHEN discipline_incidenttype = 'CU' THEN 'Cutting'
                WHEN discipline_incidenttype = 'DC' THEN 'Dress Code Violation'
                WHEN discipline_incidenttype = 'DIS' THEN 'Misbehavior - Classroom'
                WHEN discipline_incidenttype = 'DOC' THEN 'Misbehavior - Off Campus'
                WHEN discipline_incidenttype = 'DS' THEN 'Disrespect to Students'
                WHEN discipline_incidenttype = 'DT' THEN 'Disrespect to Adults'
                WHEN discipline_incidenttype = 'DV' THEN 'Defacing School Property / Vandalism'
                WHEN discipline_incidenttype = 'DW' THEN 'Refusal To Do Work'
                WHEN discipline_incidenttype = 'EC' THEN 'Excessive Crying'
                WHEN discipline_incidenttype = 'ED' THEN 'Eating / Drinking / Gum'
                WHEN discipline_incidenttype = 'EU' THEN 'Unprepared/Off-Task in Detention'
                WHEN discipline_incidenttype = 'EV' THEN 'Excessive Volume'
                WHEN discipline_incidenttype = 'FI' THEN 'Fighting'
                WHEN discipline_incidenttype = 'GO' THEN 'Going Somewhere w/o Permission'
                WHEN discipline_incidenttype = 'HR' THEN 'Harassment / Intimidation / Bullying'
                WHEN discipline_incidenttype = 'IL' THEN 'Inappropriate Language'
                WHEN discipline_incidenttype = 'MH' THEN 'Missing Homework'
                WHEN discipline_incidenttype = 'MN' THEN 'Unsigned/Missing Notice'
                WHEN discipline_incidenttype = 'NC' THEN 'Name Calling / Teasing'
                WHEN discipline_incidenttype = 'NFI' THEN 'Not Following Directions'
                WHEN discipline_incidenttype = 'O' THEN 'Other - Please specify'
                WHEN discipline_incidenttype = 'OL' THEN 'Out of Line'
                WHEN discipline_incidenttype = 'PBA' THEN 'Paycheck Below $90'
                WHEN discipline_incidenttype = 'PBB' THEN 'Paycheck Below $80'
                WHEN discipline_incidenttype = 'PF' THEN 'Play Fighting / Horseplay'
                WHEN discipline_incidenttype = 'T' THEN 'Tardy to School'
                WHEN discipline_incidenttype = 'TB' THEN 'Talking Back'
                WHEN discipline_incidenttype = 'TBS' THEN 'Talking to Benched Student'
                WHEN discipline_incidenttype = 'TC' THEN 'Tardy to Class'
                WHEN discipline_incidenttype = 'TK' THEN 'Talking out of Turn'
                WHEN discipline_incidenttype = 'TO' THEN 'Refusal To Go to Time Out'
                WHEN discipline_incidenttype = 'TS' THEN 'Theft/Stealing'
                WHEN discipline_incidenttype = 'TU' THEN 'Throwing Objects / Unsafe Behavior'
                WHEN discipline_incidenttype = 'UA' THEN 'Unexcused Absence'
                ELSE NULL
               END AS discipline_details
              ,CASE
                WHEN discipline_actiontaken = 'ISS' THEN 'ISS'
                WHEN discipline_actiontaken = 'OSS' THEN 'OSS'
                WHEN discipline_actiontaken = 'SC' THEN 'Sent back to class'
                WHEN discipline_actiontaken = 'SA' THEN 'Sent to another class'  
                ELSE NULL
               END AS actiontaken
              ,CASE
                WHEN discipline_actiontakendetail = 'TO' THEN 'Time Out'
                WHEN discipline_actiontakendetail = 'WR' THEN 'Wrote Reflection'
                WHEN discipline_actiontakendetail = 'CA' THEN 'Completed Assignment(s)'
                WHEN discipline_actiontakendetail = 'SP' THEN 'Spoke to Parent/Guardian'
                WHEN discipline_actiontakendetail = 'CU' THEN 'Clean Up'
                WHEN discipline_actiontakendetail = 'LC' THEN 'Logical Consequence'
                WHEN discipline_actiontakendetail = 'PP' THEN 'Peace Path'
                WHEN discipline_actiontakendetail = 'SW' THEN 'Social Work Referral'
                ELSE NULL
               END AS followup
              ,dates.time_per_name AS RT
              ,ROW_NUMBER() OVER(
                  PARTITION BY studentid, logtypeid
                      ORDER BY entry_date DESC) AS rn
        FROM OPENQUERY(PS_TEAM,'
          SELECT studentid
                ,schoolid
                ,entry_author
                ,entry_date                     
                ,discipline_incidentdate
                ,logtypeid
                ,subtype                     
                ,discipline_incidenttype             
                ,Discipline_ActionTaken
                ,Discipline_ActionTakendetail                     
                ,consequence             
          FROM log               
          WHERE log.entry_date >= TO_DATE(CASE
                                           WHEN TO_CHAR(SYSDATE,''MON'') IN (''JAN'',''FEB'',''MAR'',''APR'',''MAY'',''JUN'',''JUL'') 
                                           THEN TO_CHAR(TO_CHAR(SYSDATE,''YYYY'') - 1)
                                           ELSE TO_CHAR(SYSDATE,''YYYY'')
                                          END || ''-08-01'',''YYYY-MM-DD'')
            AND log.entry_date <= SYSDATE
            AND logtypeid IN (-100000,3223,3023,3123,3124)
            AND schoolid IN (73252,73253,133570965)
               
          UNION ALL
               
          SELECT studentid
                ,schoolid
                ,entry_author
                ,entry_date                     
                ,discipline_incidentdate
                ,logtypeid
                ,subtype                     
                ,discipline_incidenttype             
                ,Discipline_ActionTaken
                ,Discipline_ActionTakendetail                     
                ,consequence             
          FROM log               
          WHERE log.entry_date >= TO_DATE(CASE
                                           WHEN TO_CHAR(SYSDATE,''MON'') IN (''JAN'',''FEB'',''MAR'',''APR'',''MAY'',''JUN'',''JUL'') 
                                           THEN TO_CHAR(TO_CHAR(SYSDATE,''YYYY'') - 1)
                                           ELSE TO_CHAR(SYSDATE,''YYYY'')
                                          END || ''-08-01'',''YYYY-MM-DD'')
            AND log.entry_date <= SYSDATE
            AND logtypeid IN (-100000,3223,3023,3123,3124)
            AND schoolid IN (73254,73255,73256)
        ') oq
        JOIN REPORTING$dates dates WITH (NOLOCK)
          ON oq.entry_date >= dates.start_date
         AND oq.entry_date <= dates.end_date
         AND oq.schoolid = dates.schoolid
         AND dates.identifier = 'RT'
       ) sub;
         

  --STEP 4: truncate 
  EXEC('TRUNCATE TABLE KIPP_NJ..DISC$log#static');


  --STEP 5: disable all nonclustered indexes on table
  SELECT @sql = @sql + 'ALTER INDEX ' 
                 + indexes.name + ' ON dbo.' 
                 + objects.name + ' DISABLE;' + CHAR(13) + CHAR(10)
  FROM sys.indexes
  JOIN sys.objects 
    ON sys.indexes.object_id = sys.objects.object_id
  WHERE sys.indexes.type_desc = 'NONCLUSTERED'
    AND sys.objects.type_desc = 'USER_TABLE'
    AND sys.objects.name = 'DISC$log#static';
  EXEC (@sql);


 -- STEP 6: insert into final destination
 INSERT INTO [dbo].[DISC$log#static]
 SELECT *
 FROM [#DISC$log#static|refresh1];
 

 -- STEP 7: rebuld all nonclustered indexes on table
 SELECT @sql = @sql + 'ALTER INDEX ' 
                 + indexes.name + ' ON dbo.' 
                 + objects.name + ' REBUILD;' + CHAR(13) + CHAR(10)
  FROM sys.indexes
  JOIN sys.objects 
    ON sys.indexes.object_id = sys.objects.object_id
  WHERE sys.indexes.type_desc = 'NONCLUSTERED'
    AND sys.objects.type_desc = 'USER_TABLE'
    AND sys.objects.name = 'DISC$log#static';
  EXEC (@sql);
  
END
GO
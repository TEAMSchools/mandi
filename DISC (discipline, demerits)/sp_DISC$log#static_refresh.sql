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
  FROM (SELECT oq.schoolid
              ,CAST(studentid AS INT) AS studentid
              ,entry_author
              ,CONVERT(DATE,entry_date) AS entry_date
              ,logtypeid
              ,subject
              ,entry      
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
                WHEN subtype = '1'  AND logtypeid = -100000 THEN 'Detention'
                WHEN subtype = '01' AND logtypeid = -100000 THEN 'Detention'
                WHEN subtype = '2'  AND logtypeid = -100000 THEN 'Silent Lunch'
                WHEN subtype = '02' AND logtypeid = -100000 THEN 'Silent Lunch'
                WHEN subtype = '3'  AND logtypeid = -100000 THEN 'Choices'
                WHEN subtype = '03' AND logtypeid = -100000 THEN 'Choices'
                WHEN subtype = '4'  AND logtypeid = -100000 THEN 'Bench'
                WHEN subtype = '04' AND logtypeid = -100000 THEN 'Bench'
                WHEN subtype = '5'  AND logtypeid = -100000 THEN 'ISS'
                WHEN subtype = '05' AND logtypeid = -100000 THEN 'ISS'
                WHEN subtype = '6'  AND logtypeid = -100000 THEN 'OSS'
                WHEN subtype = '06' AND logtypeid = -100000 THEN 'OSS'
                WHEN subtype = '7'  AND logtypeid = -100000 THEN 'Bus Warning'
                WHEN subtype = '07' AND logtypeid = -100000 THEN 'Bus Warning'
                WHEN subtype = '8'  AND logtypeid = -100000 THEN 'Bus Suspension'
                WHEN subtype = '08' AND logtypeid = -100000 THEN 'Bus Suspension'
                WHEN subtype = '9'  AND logtypeid = -100000 THEN 'Class Removal'
                WHEN subtype = '09' AND logtypeid = -100000 THEN 'Class Removal'
                WHEN subtype = '10' AND logtypeid = -100000 THEN 'Bullying'
                
                --NCA merits
                WHEN subtype = '01' AND logtypeid = 3023 THEN 'No Demerits'
                WHEN subtype = '1'  AND logtypeid = 3023 THEN 'No Demerits'
                WHEN subtype = '02' AND logtypeid = 3023 THEN 'Panther Pride'
                WHEN subtype = '2'  AND logtypeid = 3023 THEN 'Panther Pride'
                WHEN subtype = '3'  AND logtypeid = 3023 THEN 'Work Crew'
                WHEN subtype = '03' AND logtypeid = 3023 THEN 'Work Crew'
                WHEN subtype = '4'  AND logtypeid = 3023 THEN 'Courage'
                WHEN subtype = '04' AND logtypeid = 3023 THEN 'Courage'
                WHEN subtype = '5'  AND logtypeid = 3023 THEN 'Excellence'
                WHEN subtype = '05' AND logtypeid = 3023 THEN 'Excellence'
                WHEN subtype = '6'  AND logtypeid = 3023 THEN 'Humanity'
                WHEN subtype = '06' AND logtypeid = 3023 THEN 'Humanity'
                WHEN subtype = '7'  AND logtypeid = 3023 THEN 'Leadership'
                WHEN subtype = '07' AND logtypeid = 3023 THEN 'Leadership'
                WHEN subtype = '8'  AND logtypeid = 3023 THEN 'Parent'
                WHEN subtype = '08' AND logtypeid = 3023 THEN 'Parent'
                WHEN subtype = '9'  AND logtypeid = 3023 THEN 'Other'
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
                --WHEN subtype = '11' AND logtypeid = 3223 THEN 'T2 Other'
                --WHEN subtype = '12' AND logtypeid = 3223 THEN 'Tier 3'
                ELSE NULL
               END AS subtype

              --Demerit tiers
              ,CASE
                WHEN subtype = '01' AND logtypeid = 3223 THEN 'Tier 1'
                WHEN subtype = '02' AND logtypeid = 3223 THEN 'Tier 1'
                WHEN subtype = '03' AND logtypeid = 3223 THEN 'Tier 1'
                WHEN subtype = '04' AND logtypeid = 3223 THEN 'Tier 1'
                WHEN subtype = '05' AND logtypeid = 3223 THEN 'Tier 1'
                WHEN subtype = '06' AND logtypeid = 3223 THEN 'Tier 1'
                WHEN subtype = '07' AND logtypeid = 3223 THEN 'Tier 1'
                WHEN subtype = '08' AND logtypeid = 3223 THEN 'Tier 1'
                WHEN subtype = '09' AND logtypeid = 3223 THEN 'Tier 1'
                WHEN subtype = '10' AND logtypeid = 3223 THEN 'Tier 1'
                WHEN subtype = '11' AND logtypeid = 3223 THEN 'Tier 1'
                WHEN subtype = '12' AND logtypeid = 3223 THEN 'Tier 1'
                ELSE NULL
               END AS tier
              ,CASE
                WHEN discipline_incidenttype = 'CE' THEN 'Cell Phone/Electronics'
                WHEN discipline_incidenttype = 'C' THEN 'Cheating'
                WHEN discipline_incidenttype = 'CU' THEN 'Cut Detention, Help Hour, Work Crew'
                WHEN discipline_incidenttype = 'SP' THEN 'Defacing School Property'
                WHEN discipline_incidenttype = 'DM' THEN 'Demerits (NCA)'
                WHEN discipline_incidenttype = 'D' THEN 'Dress Code'
                WHEN discipline_incidenttype = 'DT' THEN 'Disrespect (to Teacher)'
                WHEN discipline_incidenttype = 'DS' THEN 'Disrespect (to Student)'
                WHEN discipline_incidenttype = 'L' THEN 'Dishonesty/Forgery'
                WHEN discipline_incidenttype = 'DIS' THEN 'Disruptive/Misbehavior IN Class'
                WHEN discipline_incidenttype = 'DOC' THEN 'Misbehavior off School Campus'
                WHEN discipline_incidenttype = 'FI' THEN 'Fighting'
                WHEN discipline_incidenttype = 'PF' THEN 'Play Fighting/Inappropriate Touching'
                WHEN discipline_incidenttype = 'GO' THEN 'Going Somewhere w/o Permission'
                WHEN discipline_incidenttype = 'G' THEN 'Gum Chewing/CANDy/Food'
                WHEN discipline_incidenttype = 'HR' THEN 'Harassment/Bullying'
                WHEN discipline_incidenttype = 'H' THEN 'Homework'
                WHEN discipline_incidenttype = 'M' THEN 'Missing notices'
                WHEN discipline_incidenttype = 'PA' THEN 'Missing Major Assign. (NCA)'
                WHEN discipline_incidenttype = 'NFI' THEN 'Not Following Instructions'
                WHEN discipline_incidenttype = 'P' THEN 'Profanity'
                WHEN discipline_incidenttype = 'TB' THEN 'Talking to Benchster (TEAM/RISE)'
                WHEN discipline_incidenttype = 'T' THEN 'Tardy to School'
                WHEN discipline_incidenttype = 'TC' THEN 'Tardy to Class'
                WHEN discipline_incidenttype = 'S' THEN 'Theft/Stealing'
                WHEN discipline_incidenttype = 'UA' THEN 'Unexcused Absence'
                WHEN discipline_incidenttype = 'EU' THEN 'Unprepared or Off-Task IN Det.'
                WHEN discipline_incidenttype = 'O' THEN 'Other'
                WHEN discipline_incidenttype = 'RCHT' THEN 'Rise-Cheating'
                WHEN discipline_incidenttype = 'RHON' THEN 'Rise-Dishonesty'
                WHEN discipline_incidenttype = 'RRSP' THEN 'Rise-Disrespect'
                WHEN discipline_incidenttype = 'RFHT' THEN 'Rise-Fighting'
                WHEN discipline_incidenttype = 'RNFD' THEN 'Rise-NFD'
                WHEN discipline_incidenttype = 'RLOG' THEN 'Rise-Logistical'
                WHEN discipline_incidenttype = 'ROTH' THEN 'Rise-Other'
                WHEN discipline_incidenttype = 'SEC' THEN 'SPARK-Excessive Crying'
                WHEN discipline_incidenttype = 'STB' THEN 'SPARK-Talking Back'
                WHEN discipline_incidenttype = 'SNC' THEN 'SPARK-Name Calling'
                WHEN discipline_incidenttype = 'SH' THEN 'SPARK-Hitting'
                WHEN discipline_incidenttype = 'ST' THEN 'SPARK-Tantrum'
                WHEN discipline_incidenttype = 'STO' THEN 'SPARK-Wont Go To Time Out'
                WHEN discipline_incidenttype = 'SDW' THEN 'SPARK-Refusal To Do Work'
                WHEN discipline_incidenttype = 'BED' THEN 'BUS: Eating/Drinking'
                WHEN discipline_incidenttype = 'BPR' THEN 'BUS: Profanity'
                WHEN discipline_incidenttype = 'BOL' THEN 'BUS: Out of Line'
                WHEN discipline_incidenttype = 'BMS' THEN 'BUS: Moving Seats/StANDing'
                WHEN discipline_incidenttype = 'BTK' THEN 'BUS: Talking IN the morning'
                WHEN discipline_incidenttype = 'BND' THEN 'BUS: Not Following Directions'
                WHEN discipline_incidenttype = 'BDY' THEN 'BUS: Loud, Disruptive, or Yelling'
                WHEN discipline_incidenttype = 'BTU' THEN 'BUS: Throwing objects/Unsafe Behav.'
                WHEN discipline_incidenttype = 'BDR' THEN 'BUS: Disrespect'
                WHEN discipline_incidenttype = 'BNC' THEN 'BUS: Name Calling or Bullying'
                WHEN discipline_incidenttype = 'BIP' THEN 'BUS: Phones/iPods/Games'
                WHEN discipline_incidenttype = 'BFI' THEN 'BUS: Fighting'
                WHEN discipline_incidenttype = 'BNR' THEN 'BUS: Not reporting incidents'
                ELSE NULL
               END AS incident_decoded                    
              ,CASE
                WHEN Discipline_ActionTaken = 'WR' THEN 'Wrote Reflection'
                WHEN Discipline_ActionTaken = 'SPOKE' THEN 'Spoke with Staff'
                WHEN Discipline_ActionTaken = 'CLASS' THEN 'Sent Back to Class'
                WHEN Discipline_ActionTaken = 'CLASSR' THEN 'Sent Back to Class + Reflection'
                WHEN Discipline_ActionTaken = 'CLASSS' THEN 'Sent Back to Class + Spoke'
                WHEN Discipline_ActionTaken = 'STAYED' THEN 'Spent Remainder of Day'
                WHEN Discipline_ActionTaken = 'STAYEDR' THEN 'Spent Day + Reflection'
                WHEN Discipline_ActionTaken = 'STAYEDS' THEN 'Spent Day + Spoke'
                WHEN Discipline_ActionTaken = 'S' THEN 'Suspension'
                WHEN Discipline_ActionTaken = 'SR' THEN 'Suspension + Reflection'
                WHEN Discipline_ActionTaken = 'SS' THEN 'Suspension + Spoke'
                WHEN Discipline_ActionTaken = 'SCR' THEN 'Stayed in class - wrote reflection/ apology'
                WHEN Discipline_ActionTaken = 'SCP' THEN 'Stayed in class - called parent'
                WHEN Discipline_ActionTaken = 'SCT' THEN 'Stayed in class - time out'
                WHEN Discipline_ActionTaken = 'SCTO' THEN 'Stayed in class - time out in other class'
                WHEN Discipline_ActionTaken = 'ORR' THEN 'Office referral - wrote reflection/apology'
                WHEN Discipline_ActionTaken = 'ORO' THEN 'Office referral - spent remainder of day elsewhere'
                WHEN Discipline_ActionTaken = 'ORS' THEN 'Office referral - suspension '
                WHEN Discipline_ActionTaken = 'O' THEN 'Other'                
                ELSE NULL
               END AS Discipline_ActionTaken_Detail
              ,dates.time_per_name AS RT
              ,ROW_NUMBER() OVER(
                  PARTITION BY studentid, logtypeid
                      ORDER BY entry_date DESC) AS rn
        FROM OPENQUERY(PS_TEAM,'
               SELECT studentid
                     ,schoolid
                     ,entry_author
                     ,entry_date
                     ,logtypeid
                     ,subject
                     ,subtype
                     ,NULL AS entry
                     ,Discipline_ActionTaken
                     ,discipline_incidenttype
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
                     ,logtypeid
                     ,subject
                     ,subtype
                     ,entry
                     ,Discipline_ActionTaken
                     ,discipline_incidenttype
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
         AND dates.identifier = 'RT') sub;

  --STEP 3: LOCK destination table exclusively load into a TEMPORARY staging table.
    --SELECT 1 FROM [] WITH (TABLOCKX);

  --STEP 4: truncate 
  EXEC('TRUNCATE TABLE KIPP_NJ..DISC$log#static');

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
   AND sys.objects.name = 'DISC$log#static';

 EXEC (@sql);

 -- STEP 6: insert into final destination
 INSERT INTO [dbo].[DISC$log#static]
 SELECT *
 FROM [#DISC$log#static|refresh1]
 ORDER BY schoolid, logtypeid, studentid, entry_date DESC;
 
 -- STEP 7: rebuld all nonclustered indexes on table
 SELECT @sql = @sql + 
  'ALTER INDEX ' + indexes.name + ' ON  dbo.' + objects.name +' REBUILD;' +CHAR(13)+CHAR(10)
 FROM 
  sys.indexes
 JOIN 
  sys.objects 
  ON sys.indexes.object_id = sys.objects.object_id
 WHERE sys.indexes.type_desc = 'NONCLUSTERED'
  AND sys.objects.type_desc = 'USER_TABLE'
  AND sys.objects.name = 'DISC$log#static';

 EXEC (@sql);
  
END
GO
/*
SQL Server Status: 2013-09-13 (LD6)
  Using open query to create view
  Need to revisit to create full table on SQL Server

PURPOSE:
  Decode and tag the log table from powerschool

MAINTENANCE:
  MAINTENANCE YEARLY
    dates on reporting terms need to be changed once calendars are in
    entry date logic needs to be updated every school year
    
MAJOR STRUCTURAL REVISIONS OR CHANGES:
  Consider joining to years/terms table to get reporting term dates?
  New disc subtypes added 2013-09-12

CREATED BY:
  AM2

ORIGIN DATE:
  Summer 2011
  
*/


USE KIPP_NJ 
GO

ALTER VIEW DISC$log AS

SELECT *
FROM OPENQUERY(PS_TEAM,'

select CAST(log.studentid AS INT) AS studentid
,log.entry_author
,log.entry_date
,log.subject
,case when log.subtype = ''01'' then ''Detention''
      when log.subtype =  ''1'' then ''Detention''
      when log.subtype = ''02'' then ''Silent Lunch''
      when log.subtype = ''02'' then ''Silent Lunch''
      when log.subtype =  ''3'' then ''Choices''
      when log.subtype = ''03'' then ''Choices''
      when log.subtype =  ''4'' then ''Bench''
      when log.subtype = ''04'' then ''Bench''
      when log.subtype =  ''5'' then ''ISS''
      when log.subtype = ''05'' then ''ISS''
      when log.subtype =  ''6'' then ''OSS''
      when log.subtype = ''06'' then ''OSS''
      when log.subtype =  ''7'' then ''Bus Warning''
      when log.subtype = ''07'' then ''Bus Warning''
      when log.subtype =  ''8'' then ''Bus Suspension''
      when log.subtype = ''08'' then ''Bus Suspension''             
      when log.subtype = ''9'' then ''Class Removal'' 
      when log.subtype = ''09'' then ''Class Removal'' 
      when log.subtype = ''10'' then ''Bullying'' 
      
      
      else null end subtype
--convert all of the incidenttype codes into long form.  this is admittedly dumb, but the 
--application doesn''t seem to store these in any way that you could just join this turkey.
,case 
      when log.discipline_incidenttype = ''CE''   then ''Cell Phone/Electronics''
      when log.discipline_incidenttype = ''C''    then ''Cheating''
      when log.discipline_incidenttype = ''CU''   then ''Cut Detention, Help Hour, Work Crew''
      when log.discipline_incidenttype = ''SP''   then ''Defacing School Property''
      when log.discipline_incidenttype = ''DM''   then ''Demerits (NCA)''
      when log.discipline_incidenttype = ''D''    then ''Dress Code''
      when log.discipline_incidenttype = ''DT''   then ''Disrespect (to Teacher)''
      when log.discipline_incidenttype = ''DS''   then ''Disrespect (to Student)''
      when log.discipline_incidenttype = ''L''    then ''Dishonesty/Forgery''
      when log.discipline_incidenttype = ''DIS''  then ''Disruptive/Misbehavior in Class''
      when log.discipline_incidenttype = ''DOC''  then ''Misbehavior off School Campus''
      when log.discipline_incidenttype = ''FI''   then ''Fighting''
      when log.discipline_incidenttype = ''PF''   then ''Play Fighting/Inappropriate Touching''
      when log.discipline_incidenttype = ''GO''   then ''Going Somewhere w/o Permission''
      when log.discipline_incidenttype = ''G''    then ''Gum Chewing/Candy/Food''
      when log.discipline_incidenttype = ''HR''   then ''Harassment/Bullying''
      when log.discipline_incidenttype = ''H''    then ''Homework''
      when log.discipline_incidenttype = ''M''    then ''Missing notices''
      when log.discipline_incidenttype = ''PA''   then ''Missing Major Assign. (NCA)''
      when log.discipline_incidenttype = ''NFI''  then ''Not Following Instructions''
      when log.discipline_incidenttype = ''P''    then ''Profanity''
      when log.discipline_incidenttype = ''TB''   then ''Talking to Benchster (TEAM/RISE)''
      when log.discipline_incidenttype = ''T''    then ''Tardy to School''
      when log.discipline_incidenttype = ''TC''   then ''Tardy to Class''
      when log.discipline_incidenttype = ''S''    then ''Theft/Stealing''
      when log.discipline_incidenttype = ''UA''   then ''Unexcused Absence''
      when log.discipline_incidenttype = ''EU''   then ''Unprepared or Off-Task in Det.''
      when log.discipline_incidenttype = ''O''    then ''Other''
      when log.discipline_incidenttype = ''RCHT'' then ''Rise-Cheating''
      when log.discipline_incidenttype = ''RHON'' then ''Rise-Dishonesty''
      when log.discipline_incidenttype = ''RRSP'' then ''Rise-Disrespect''
      when log.discipline_incidenttype = ''RFHT'' then ''Rise-Fighting''
      when log.discipline_incidenttype = ''RNFD'' then ''Rise-NFD''
      when log.discipline_incidenttype = ''RLOG'' then ''Rise-Logistical''
      when log.discipline_incidenttype = ''ROTH'' then ''Rise-Other''
      when log.discipline_incidenttype = ''SEC''  then ''SPARK-Excessive Crying''
      when log.discipline_incidenttype = ''STB''  then ''SPARK-Talking Back''
      when log.discipline_incidenttype = ''SNC''  then ''SPARK-Name Calling''
      when log.discipline_incidenttype = ''SH''   then ''SPARK-Hitting''
      when log.discipline_incidenttype = ''ST''   then ''SPARK-Tantrum''
      when log.discipline_incidenttype = ''STO''  then ''SPARK-Wont Go To Time Out''
      when log.discipline_incidenttype = ''SDW''  then ''SPARK-Refusal To Do Work''
      when log.discipline_incidenttype = ''BED''  then ''BUS: Eating/Drinking''
      when log.discipline_incidenttype = ''BPR''  then ''BUS: Profanity''
      when log.discipline_incidenttype = ''BOL''  then ''BUS: Out of Line''
      when log.discipline_incidenttype = ''BMS''  then ''BUS: Moving Seats/Standing''
      when log.discipline_incidenttype = ''BTK''  then ''BUS: Talking in the morning''
      when log.discipline_incidenttype = ''BND''  then ''BUS: Not Following Directions''
      when log.discipline_incidenttype = ''BDY''  then ''BUS: Loud, Disruptive, or Yelling''
      when log.discipline_incidenttype = ''BTU''  then ''BUS: Throwing objects/Unsafe Behav.''
      when log.discipline_incidenttype = ''BDR''  then ''BUS: Disrespect''
      when log.discipline_incidenttype = ''BNC''  then ''BUS: Name Calling or Bullying''
      when log.discipline_incidenttype = ''BIP''  then ''BUS: Phones/iPods/Games''
      when log.discipline_incidenttype = ''BFI''  then ''BUS: Fighting''
      when log.discipline_incidenttype = ''BNR''  then ''BUS: Not reporting incidents''
      else null end as incident_decoded,

 case  
--Middle Schools (Rise & TEAM)
     when log.schoolid IN (73252,133570965)
           and log.entry_date >= ''05-AUG-13'' and log.entry_date <=''22-NOV-13'' 
           then ''RT1''
     when log.schoolid IN (73252,133570965)
           and log.entry_date >= ''25-NOV-13'' and log.entry_date <=''7-MAR-14'' 
           then ''RT2''
     when log.schoolid IN (73252,133570965)
           and log.entry_date >= ''10-MAR-14'' and log.entry_date <=''20-JUN-14'' 
           then ''RT3''
--NCA
     when log.schoolid = 73253 
           and log.entry_date >= ''03-SEP-13'' and log.entry_date <=''8-NOV-13''
           then ''RT1''
     when log.schoolid = 73253 
           and log.entry_date >= ''12-NOV-13'' and log.entry_date <=''27-JAN-14''
           then ''RT2''
     when log.schoolid = 73253 
           and log.entry_date >= ''3-FEB-14'' and log.entry_date <=''4-APR-14''
           then ''RT3''       
     when log.schoolid = 73253 
           and log.entry_date >= ''21-APR-14'' and log.entry_date <=''20-JUN-14''
           then ''RT4''             
--Elementary Schools (SPARK, THRIVE, Seek)
     when log.schoolid IN (73254,73255,73256)
           and log.entry_date >= ''19-AUG-13'' and log.entry_date <=''30-AUG-13''
           then ''RT1''
     when log.schoolid IN (73254,73255,73256)
           and log.entry_date >= ''04-SEP-13'' and log.entry_date <=''22-NOV-13''
           then ''RT2''
     when log.schoolid IN (73254,73255,73256)
           and log.entry_date >= ''25-NOV-13'' and log.entry_date <=''14-FEB-14''
           then ''RT3''             
     when log.schoolid IN (73254,73255,73256)
           and log.entry_date >= ''25-FEB-14'' and log.entry_date <=''16-MAY-14''
           then ''RT4''
     when log.schoolid IN (73254,73255,73256)
           and log.entry_date >= ''19-MAY-14'' and log.entry_date <=''13-JUN-14''
           then ''RT5''         
     else null end RT    
     
     ,row_number() over 
                  (partition by log.studentid 
                   order by log.entry_date desc) as rn
      from log

--Remember to change entry date as well, when converting to a new year (2011-2012).

where SchoolID != 999999 and entry_date > ''2013-08-01'' and entry_date < ''2014-06-30'' and logtypeid= -100000 and log.studentid > 0
order by log.studentid, log.entry_date desc
')
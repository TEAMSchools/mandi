/*
END OF SEPTEMBER AND IT'S ALREADY ~5000 ROWS!  THIS WILL PROBABLY NEED TO BECOME AN SP -> STATIC TABLE (CB)

SQL Server Status: 2013-09-13 (LD6)
  Using open query to create view
  Need to revisit to create full table on SQL Server
  Merged with NCA's merits and demerits (CB)
  Added logtypeid for JOINS (CB)
  Ported directly from PowerSchool (CB)
  
PURPOSE:
  Decode AND tag the log table FROM powerschool

MAINTENANCE:
  MAINTENANCE YEARLY
    dates on reporting terms need to be changed once calendars are in entry date logic needs to be updated every school year
    
MAJOR STRUCTURAL REVISIONS OR CHANGES:
  Consider joining to years/terms table to get reporting term dates?
  New disc subtypes added 2013-09-12
  Ported to SQL Server, see top for detatils - CB

CREATED BY:
  AM2

ORIGIN DATE:
  Summer 2011
  
LAST MODIFIED:
  FALL 2013
*/


USE KIPP_NJ 
GO

--ALTER VIEW DISC$log AS
SELECT TOP (100) PERCENT *
FROM
     (SELECT schoolid
            ,CAST(studentid AS INT) AS studentid
            ,entry_author
            ,entry_date
            ,logtypeid
            ,subject
            ,CASE
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

            --convert all of the incidenttype codes into long form. this is admittedly dumb,
            --but PS doesn't seem to store these in any way that you could just JOIN this turkey.
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

            --Reporting Terms
            ,CASE
              --Middle Schools (Rise & TEAM)
              WHEN schoolid IN (73252,133570965) AND entry_date >= '2013-08-05' AND entry_date <= '2013-11-22' THEN 'RT1'
              WHEN schoolid IN (73252,133570965) AND entry_date >= '2013-11-25' AND entry_date <= '2014-03-07' THEN 'RT2'
              WHEN schoolid IN (73252,133570965) AND entry_date >= '2014-03-10' AND entry_date <= '2014-06-20' THEN 'RT3'
              --NCA
              WHEN schoolid = 73253 AND entry_date >= '2013-09-03' AND entry_date <= '2013-11-08' THEN 'RT1'
              WHEN schoolid = 73253 AND entry_date >= '2013-11-12' AND entry_date <= '2014-01-27' THEN 'RT2'
              WHEN schoolid = 73253 AND entry_date >= '2014-02-03' AND entry_date <= '2014-04-04' THEN 'RT3'
              WHEN schoolid = 73253 AND entry_date >= '2014-04-21' AND entry_date <= '2014-06-20' THEN 'RT4'
              --Elementary Schools (SPARK, THRIVE, Seek)
              WHEN schoolid IN (73254,73255,73256) AND entry_date >= '2013-08-19' AND entry_date <= '2013-08-30' THEN 'RT1'
              WHEN schoolid IN (73254,73255,73256) AND entry_date >= '2013-09-04' AND entry_date <= '2013-11-22' THEN 'RT2'
              WHEN schoolid IN (73254,73255,73256) AND entry_date >= '2013-11-25' AND entry_date <= '2014-02-14' THEN 'RT3'
              WHEN schoolid IN (73254,73255,73256) AND entry_date >= '2014-02-25' AND entry_date <= '2014-05-16' THEN 'RT4'
              WHEN schoolid IN (73254,73255,73256) AND entry_date >= '2014-05-19' AND entry_date <= '2014-06-13' THEN 'RT5'
              ELSE NULL
             END AS RT

            ,ROW_NUMBER() OVER(
                PARTITION BY studentid
                    ORDER BY entry_date DESC) AS rn

      FROM OPENQUERY(PS_TEAM,'
           SELECT s.id AS studentid
                 ,log.schoolid
                 ,entry_author
                 ,entry_date
                 ,logtypeid
                 ,subject
                 ,subtype
                 ,discipline_incidenttype
           FROM STUDENTS s
           LEFT OUTER JOIN log
           ON s.id = log.studentid
           WHERE s.schoolid != 999999
             AND s.enroll_status = 0
             AND log.entry_date >= TO_DATE(''2013-08-01'',''YYYY-MM-DD'') --update for new school year
             AND log.entry_date <= TO_DATE(''2014-06-30'',''YYYY-MM-DD'') --update for new school year
             --AND logtypeid IN (-100000,3223,3023)
       ')
     ) sub
ORDER BY schoolid, logtypeid, studentid, entry_date DESC
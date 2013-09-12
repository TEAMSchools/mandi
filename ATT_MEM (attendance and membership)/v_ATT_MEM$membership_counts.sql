USE KIPP_NJ
GO

ALTER VIEW ATT_MEM$membership_counts AS
SELECT *
FROM OPENQUERY(KIPP_NWK,'
     SELECT id
           ,lastfirst
           ,schoolid
           ,grade_level
           ,CAST(mem AS FLOAT) AS mem
           ,CAST(rt1_mem AS FLOAT) AS rt1_mem
           ,CAST(rt2_mem AS FLOAT) AS rt2_mem
           ,CAST(rt3_mem AS FLOAT) AS rt3_mem
           ,CAST(rt4_mem AS FLOAT) AS rt4_mem
           ,CAST(rt5_mem AS FLOAT) AS rt5_mem
           ,CAST(rt6_mem AS FLOAT) AS rt6_mem
     FROM membership_counts
')

/*

CREATE MATERIALIZED VIEW MEMBERSHIP_COUNTS 
NOCACHE 
NOPARALLEL 
BUILD IMMEDIATE 
USING INDEX 
REFRESH START WITH SYSDATE NEXT SYSDATE + (120/(24*60)) COMPLETE 
DISABLE QUERY REWRITE AS 

select id
      ,lastfirst
      ,schoolid
      ,grade_level
      ,sum(membershipvalue) as mem
      ,sum(case
           when RT = 'RT1' 
           then membershipvalue
           else 0
           end) as RT1_mem
      ,sum(case
           when RT = 'RT2' 
           then membershipvalue
           else 0
           end) as RT2_mem
      ,sum(case
           when RT = 'RT3' 
           then membershipvalue
           else 0
           end) as RT3_mem
      ,sum(case
           when RT = 'RT4' 
           then membershipvalue
           else 0
           end) as RT4_mem
      ,sum(case
           when RT = 'RT5' 
           then membershipvalue
           else 0
           end) as RT5_mem
      ,sum(case
           when RT = 'RT6' 
           then membershipvalue
           else 0
           end) as RT6_mem
from
(select s.id
       ,s.lastfirst
       ,s.schoolid
       ,s.grade_level
       ,ctod.calendardate
       ,ctod.membershipvalue,
         case 
       --Middle Schools (Rise & TEAM)
       when ctod.schoolid IN (73252,133570965)
             and ctod.calendardate >= '05-AUG-13' and ctod.calendardate <='22-NOV-13' 
             then 'RT1'
       when ctod.schoolid IN (73252,133570965)
             and ctod.calendardate >= '25-NOV-13' and ctod.calendardate <='07-MAR-14' 
             then 'RT2'
       when ctod.schoolid IN (73252,133570965)
             and ctod.calendardate >= '10-MAR-14' and ctod.calendardate <='20-JUN-14' 
             then 'RT3'
       --NCA
       when ctod.schoolid = 73253 
             and ctod.calendardate >= '03-SEP-13' and ctod.calendardate <='08-NOV-13' 
             then 'RT1'
       when ctod.schoolid = 73253 
             and ctod.calendardate >= '12-NOV-13' and ctod.calendardate <='27-JAN-14' 
             then 'RT2'
       when ctod.schoolid = 73253 
             and ctod.calendardate >= '03-FEB-14' and ctod.calendardate <='04-APR-14' 
             then 'RT3'
       when ctod.schoolid = 73253 
             and ctod.calendardate >= '21-APR-14' and ctod.calendardate <='20-JUN-14' 
             then 'RT4'
       --Elementary Schools (SPARK, THRIVE, Seek)
       when ctod.schoolid IN (73254,73255,73256)
             and ctod.calendardate >= '19-AUG-13' and ctod.calendardate <='30-AUG-13'
             then 'RT1'
       when ctod.schoolid IN (73254,73255,73256)
             and ctod.calendardate >= '04-SEP-13' and ctod.calendardate <='22-NOV-13'
             then 'RT2'
       when ctod.schoolid IN (73254,73255,73256)
             and ctod.calendardate >= '25-NOV-13' and ctod.calendardate <='14-FEB-14'
             then 'RT3'             
       when ctod.schoolid IN (73254,73255,73256)
             and ctod.calendardate >= '25-FEB-14' and ctod.calendardate <='16-MAY-14'
             then 'RT4'
       when ctod.schoolid IN (73254,73255,73256)
             and ctod.calendardate >= '19-MAY-14' and ctod.calendardate <='13-JUN-14'
             then 'RT5'
/*
         --THRIVE
       when ctod.schoolid = 73255
             and ctod.calendardate >= '20-AUG-12' and ctod.calendardate <='31-AUG-12'
             then 'RT1'
       when ctod.schoolid = 73255
             and ctod.calendardate >= '05-SEP-12' and ctod.calendardate <='20-NOV-12'
             then 'RT2'
       when ctod.schoolid = 73255
             and ctod.calendardate >= '27-NOV-12' and ctod.calendardate <='15-FEB-13'
             then 'RT3'             
       when ctod.schoolid = 73255
             and ctod.calendardate >= '26-FEB-13' and ctod.calendardate <='24-MAY-13'
             then 'RT4'
       when ctod.schoolid = 73255
             and ctod.calendardate >= '28-MAY-13' and ctod.calendardate <='13-JUN-13'
             then 'RT5'    
       --TEAM
       when ctod.schoolid = 133570965 
             and ctod.calendardate >= '08-AUG-12' and ctod.calendardate <='20-NOV-12' 
             then 'RT1'
       when ctod.schoolid = 133570965 
             and ctod.calendardate >= '26-NOV-12' and ctod.calendardate <='08-MAR-13' 
             then 'RT2'
       when ctod.schoolid = 133570965 
             and ctod.calendardate >= '11-MAR-13' and ctod.calendardate <='21-JUN-13' 
             then 'RT3'             
*/
       else null end RT   
from students@PS_TEAM s
left outer join pssis_adaadm_daily_ctod@PS_TEAM ctod on s.id = ctod.studentid 
                                                    and ctod.calendardate > '01-AUG-13' 
                                                    and ctod.calendardate <= sysdate
where s.entrydate >= '01-AUG-13')
group by id, lastfirst, schoolid, grade_level
order by schoolid, grade_level, lastfirst
*/
USE KIPP_NJ
GO

ALTER VIEW ATT_MEM$attendance_counts AS
SELECT *
FROM OPENQUERY(KIPP_NWK,'
     SELECT *
     FROM attendance_counts
')

/*
--language up here is because we are running our own oracle reporting node (express edition - it's free)
CREATE MATERIALIZED VIEW ATTENDANCE_COUNTS
NOCACHE 
NOPARALLEL 
BUILD IMMEDIATE 
USING INDEX 
REFRESH START WITH SYSDATE NEXT SYSDATE + (30/(24*60)) COMPLETE 
DISABLE QUERY REWRITE AS 
--if you're reproducing this query you can start here with the select

select id
      ,lastfirst
      ,schoolid
      ,grade_level
--full year      
      ,absences_undoc + absences_doc as absences_total
      ,absences_undoc
      ,absences_doc
      ,tardies_reg + tardies_T10 as tardies_total
      ,tardies_reg
      ,tardies_T10
      ,iss
      ,oss
--RT1
      ,rt1_absences_undoc + rt1_absences_doc as rt1_absences_total
      ,rt1_absences_undoc
      ,rt1_absences_doc
      ,rt1_tardies_reg + rt1_tardies_T10 as rt1_tardies_total
      ,rt1_tardies_reg
      ,rt1_tardies_T10
      ,rt1_iss
      ,rt1_oss
--rt2
      ,rt2_absences_undoc + rt2_absences_doc as rt2_absences_total
      ,rt2_absences_undoc
      ,rt2_absences_doc
      ,rt2_tardies_reg + rt2_tardies_T10 as rt2_tardies_total
      ,rt2_tardies_reg
      ,rt2_tardies_T10
      ,rt2_iss
      ,rt2_oss
--rt3
      ,rt3_absences_undoc + rt3_absences_doc as rt3_absences_total
      ,rt3_absences_undoc
      ,rt3_absences_doc
      ,rt3_tardies_reg + rt3_tardies_T10 as rt3_tardies_total
      ,rt3_tardies_reg
      ,rt3_tardies_T10
      ,rt3_iss
      ,rt3_oss
--rt4
      ,rt4_absences_undoc + rt4_absences_doc as rt4_absences_total
      ,rt4_absences_undoc
      ,rt4_absences_doc
      ,rt4_tardies_reg + rt4_tardies_T10 as rt4_tardies_total
      ,rt4_tardies_reg
      ,rt4_tardies_T10
      ,rt4_iss
      ,rt4_oss
--rt5
      ,rt5_absences_undoc + rt5_absences_doc as rt5_absences_total
      ,rt5_absences_undoc
      ,rt5_absences_doc
      ,rt5_tardies_reg + rt5_tardies_T10 as rt5_tardies_total
      ,rt5_tardies_reg
      ,rt5_tardies_T10
      ,rt5_iss
      ,rt5_oss
--rt6
      ,rt6_absences_undoc + rt6_absences_doc as rt6_absences_total
      ,rt6_absences_undoc
      ,rt6_absences_doc
      ,rt6_tardies_reg + rt6_tardies_T10 as rt6_tardies_total
      ,rt6_tardies_reg
      ,rt6_tardies_T10
      ,rt6_iss
      ,rt6_oss      
from
(select id
      ,lastfirst
      ,schoolid
      ,grade_level
--full year
      ,sum(case
           when att_code = 'A'
           then 1
           else 0
           end) as absences_undoc
      ,sum(case
           when att_code = 'AD'
           then 1
           when att_code = 'D'
           then 1
           else 0
           end) as absences_doc
      ,sum(case
           when att_code = 'T'
           then 1
           else 0
           end) as tardies_reg
       ,sum(case
           when att_code = 'T10'
           then 1
           else 0
           end) as tardies_T10
       ,sum(case
           when att_code = 'S'
           then 1
           else 0
           end) as ISS
       ,sum(case
           when att_code = 'OS'
           then 1
           else 0
           end) as OSS
--RT 1
      ,sum(case
           when att_code = 'A' and RT = 'RT1' 
           then 1
           else 0
           end) as RT1_absences_undoc
      ,sum(case
           when att_code = 'AD' and RT = 'RT1' 
           then 1
           when att_code = 'D' and RT = 'RT1' 
           then 1
           else 0
           end) as RT1_absences_doc
      ,sum(case
           when att_code = 'T' and RT = 'RT1' 
           then 1
           else 0
           end) as RT1_tardies_reg
       ,sum(case
           when att_code = 'T10' and RT = 'RT1' 
           then 1
           else 0
           end) as RT1_tardies_T10
       ,sum(case
           when att_code = 'S' and RT = 'RT1' 
           then 1
           else 0
           end) as RT1_ISS
       ,sum(case
           when att_code = 'OS' and RT = 'RT1' 
           then 1
           else 0
           end) as RT1_OSS
--RT 2
      ,sum(case
           when att_code = 'A' and RT = 'RT2' 
           then 1
           else 0
           end) as RT2_absences_undoc
      ,sum(case
           when att_code = 'AD' and RT = 'RT2' 
           then 1
           when att_code = 'D' and RT = 'RT2' 
           then 1
           else 0
           end) as RT2_absences_doc
      ,sum(case
           when att_code = 'T' and RT = 'RT2' 
           then 1
           else 0
           end) as RT2_tardies_reg
       ,sum(case
           when att_code = 'T10' and RT = 'RT2' 
           then 1
           else 0
           end) as RT2_tardies_T10
       ,sum(case
           when att_code = 'S' and RT = 'RT2' 
           then 1
           else 0
           end) as RT2_ISS
       ,sum(case
           when att_code = 'OS' and RT = 'RT2' 
           then 1
           else 0
           end) as RT2_OSS
--RT 3
      ,sum(case
           when att_code = 'A' and RT = 'RT3' 
           then 1
           else 0
           end) as RT3_absences_undoc
      ,sum(case
           when att_code = 'AD' and RT = 'RT3' 
           then 1
           when att_code = 'D' and RT = 'RT3' 
           then 1
           else 0
           end) as RT3_absences_doc
      ,sum(case
           when att_code = 'T' and RT = 'RT3' 
           then 1
           else 0
           end) as RT3_tardies_reg
       ,sum(case
           when att_code = 'T10' and RT = 'RT3' 
           then 1
           else 0
           end) as RT3_tardies_T10
       ,sum(case
           when att_code = 'S' and RT = 'RT3' 
           then 1
           else 0
           end) as RT3_ISS
       ,sum(case
           when att_code = 'OS' and RT = 'RT3' 
           then 1
           else 0
           end) as RT3_OSS
--RT 4
      ,sum(case
           when att_code = 'A' and RT = 'RT4' 
           then 1
           else 0
           end) as RT4_absences_undoc
      ,sum(case
           when att_code = 'AD' and RT = 'RT4' 
           then 1
           when att_code = 'D' and RT = 'RT4' 
           then 1
           else 0
           end) as RT4_absences_doc
      ,sum(case
           when att_code = 'T' and RT = 'RT4' 
           then 1
           else 0
           end) as RT4_tardies_reg
       ,sum(case
           when att_code = 'T10' and RT = 'RT4' 
           then 1
           else 0
           end) as RT4_tardies_T10
       ,sum(case
           when att_code = 'S' and RT = 'RT4' 
           then 1
           else 0
           end) as RT4_ISS
       ,sum(case
           when att_code = 'OS' and RT = 'RT4' 
           then 1
           else 0
           end) as RT4_OSS
--RT 5
      ,sum(case
           when att_code = 'A' and RT = 'RT5' 
           then 1
           else 0
           end) as RT5_absences_undoc
      ,sum(case
           when att_code = 'AD' and RT = 'RT5' 
           then 1
           when att_code = 'D' and RT = 'RT5' 
           then 1
           else 0
           end) as RT5_absences_doc
      ,sum(case
           when att_code = 'T' and RT = 'RT5' 
           then 1
           else 0
           end) as RT5_tardies_reg
       ,sum(case
           when att_code = 'T10' and RT = 'RT5' 
           then 1
           else 0
           end) as RT5_tardies_T10
       ,sum(case
           when att_code = 'S' and RT = 'RT5' 
           then 1
           else 0
           end) as RT5_ISS
       ,sum(case
           when att_code = 'OS' and RT = 'RT5' 
           then 1
           else 0
           end) as RT5_OSS
--RT 6
      ,sum(case
           when att_code = 'A' and RT = 'RT6' 
           then 1
           else 0
           end) as RT6_absences_undoc
      ,sum(case
           when att_code = 'AD' and RT = 'RT6' 
           then 1
           when att_code = 'D' and RT = 'RT6' 
           then 1
           else 0
           end) as RT6_absences_doc
           --Y1       
       ,sum(case
           when att_code = 'AE'
           then 1
           else 0
           end) as Excused_Absences           
--Terms      
       ,sum(case
           when att_code = 'AE' and RT = 'RT1'
           then 1
           else 0
           end) as RT1_Excused_Absences            
      ,sum(case
           when att_code = 'T' and RT = 'RT6' 
           then 1
           else 0
           end) as RT6_tardies_reg
       ,sum(case
           when att_code = 'T10' and RT = 'RT6' 
           then 1
           else 0
           end) as RT6_tardies_T10
       ,sum(case
           when att_code = 'S' and RT = 'RT6' 
           then 1
           else 0
           end) as RT6_ISS
       ,sum(case
           when att_code = 'OS' and RT = 'RT6' 
           then 1
           else 0
           end) as RT6_OSS
           
from
--our schools have different trimester/quarter/summer school structures
--because i'd ultimately like to have all of the queries in one table (not broken into separate tables by school)
--i'm normalizing them into what we're calling 'reporting terms'.  these statements down here define the reporting
--terms for each school
(select s.id, s.lastfirst, s.schoolid, s.grade_level, psad.att_date, psad.att_code,
       case 
       --Middle Schools (Rise & TEAM)
       when psad.schoolid IN (73252,133570965)
             and psad.att_date >= '05-AUG-13' and psad.att_date <='22-NOV-13' 
             then 'RT1'
       when psad.schoolid IN (73252,133570965)
             and psad.att_date >= '25-NOV-13' and psad.att_date <='7-MAR-14' 
             then 'RT2'
       when psad.schoolid IN (73252,133570965)
             and psad.att_date >= '10-MAR-14' and psad.att_date <='20-JUN-14' 
             then 'RT3'
       --NCA
       when psad.schoolid = 73253 
             and psad.att_date >= '03-SEP-13' and psad.att_date <='8-NOV-13'
             then 'RT1'
       when psad.schoolid = 73253 
             and psad.att_date >= '12-NOV-13' and psad.att_date <='27-JAN-14'
             then 'RT2'
       when psad.schoolid = 73253 
             and psad.att_date >= '3-FEB-14' and psad.att_date <='4-APR-14'
             then 'RT3'       
       when psad.schoolid = 73253 
             and psad.att_date >= '21-APR-14' and psad.att_date <='20-JUN-14'
             then 'RT4'             
       --Elementary Schools (SPARK, THRIVE, Seek)
       when psad.schoolid IN (73254,73255,73256)
             and psad.att_date >= '19-AUG-13' and psad.att_date <='30-AUG-13'
             then 'RT1'
       when psad.schoolid IN (73254,73255,73256)
             and psad.att_date >= '04-SEP-13' and psad.att_date <='22-NOV-13'
             then 'RT2'
       when psad.schoolid IN (73254,73255,73256)
             and psad.att_date >= '25-NOV-13' and psad.att_date <='14-FEB-14'
             then 'RT3'             
       when psad.schoolid IN (73254,73255,73256)
             and psad.att_date >= '25-FEB-14' and psad.att_date <='16-MAY-14'
             then 'RT4'
       when psad.schoolid IN (73254,73255,73256)
             and psad.att_date >= '19-MAY-14' and psad.att_date <='13-JUN-14'
             then 'RT5'
/*
         --THRIVE
       when psad.schoolid = 73255
             and psad.att_date >= '20-AUG-12' and psad.att_date <='31-AUG-12'
             then 'RT1'
       when psad.schoolid = 73255
             and psad.att_date >= '05-SEP-12' and psad.att_date <='20-NOV-12'
             then 'RT2'
       when psad.schoolid = 73255
             and psad.att_date >= '27-NOV-12' and psad.att_date <='15-FEB-13'
             then 'RT3'             
       when psad.schoolid = 73255
             and psad.att_date >= '26-FEB-13' and psad.att_date <='24-MAY-13'
             then 'RT4'
       when psad.schoolid = 73255
             and psad.att_date >= '28-MAY-13' and psad.att_date <='13-JUN-13'
             then 'RT5'    
    
        --TEAM
       when psad.schoolid = 133570965 
             and psad.att_date >= '08-AUG-12' and psad.att_date <='20-NOV-12' 
             then 'RT1'
       when psad.schoolid = 133570965 
             and psad.att_date >= '26-NOV-12' and psad.att_date <='8-MAR-13' 
             then 'RT2'
       when psad.schoolid = 133570965 
             and psad.att_date >= '11-MAR-13' and psad.att_date <='21-JUN-13' 
             then 'RT3'             
*/
       else null end RT      
from students@PS_TEAM s
left outer join PS_ATTENDANCE_DAILY@PS_TEAM psad     on s.id = psad.studentid 
                                            and psad.att_date >= '01-AUG-13'
                                            and psad.att_date <  '01-JUL-14'
                                            and psad.att_code is not null
where s.entrydate >= '01-AUG-13'
order by s.schoolid, s.grade_level, s.lastfirst, psad.att_date)
group by id, lastfirst, schoolid, grade_level
order by schoolid, grade_level, lastfirst);
*/
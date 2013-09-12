/*
PURPOSE:
  Attendance percentages for students: all schools, all terms
  Total absences, Undoc, Doc, Total Tardies, Tardies, T10

MAINTENANCE:
  Depends on MV Attendance Counts (Oracle) being up to date
  Depends on MV Membership Counts (Oracle) being up to date

MAJOR STRUCTURAL REVISIONS OR CHANGES:
  "Ported" to Server -CB
  
TO DO:
  create attendance_counts & membership_counts as views on Server

CREATED BY: AM2

ORIGIN DATE: Fall 2011
LAST MODIFIED: Fall 2013 (CB)
*/

--CREATE VIEW ATT_MEM$att_percentages AS
SELECT *
FROM OPENQUERY(KIPP_NWK,'
     SELECT *
     FROM attendance_percentages
')

/*
create or replace view attendance_percentages as
select att.id, att.lastfirst, att.schoolid, att.grade_level, 
--attendance percentage total
case when mem = 0 then null else 
       round(((mem - absences_total) / mem) * 100,2) end as y1_att_pct_total,
case when rt1_mem = 0 then null else 
       round(((rt1_mem - rt1_absences_total) / rt1_mem) * 100,2) end as rt1_att_pct_total,
case when rt2_mem = 0 then null else 
       round(((rt2_mem - rt2_absences_total) / rt2_mem) * 100,2) end as rt2_att_pct_total,
case when rt3_mem = 0 then null else 
       round(((rt3_mem - rt3_absences_total) / rt3_mem) * 100,2) end as rt3_att_pct_total, 
case when rt4_mem = 0 then null else 
       round(((rt4_mem - rt4_absences_total) / rt4_mem) * 100,2) end as rt4_att_pct_total,
case when rt5_mem = 0 then null else 
       round(((rt5_mem - rt5_absences_total) / rt5_mem) * 100,2) end as rt5_att_pct_total,
case when rt6_mem = 0 then null else 
       round(((rt6_mem - rt6_absences_total) / rt6_mem) * 100,2) end as rt6_att_pct_total,       
--attendance percentage, excluding documented absences (undocumented only) only
case when mem = 0 then null else 
       round(((mem - absences_undoc) / mem) * 100,2) end as y1_att_pct_undoc,
case when rt1_mem = 0 then null else 
       round(((rt1_mem - rt1_absences_undoc) / rt1_mem) * 100,2) end as rt1_att_pct_undoc,
case when rt2_mem = 0 then null else 
       round(((rt2_mem - rt2_absences_undoc) / rt2_mem) * 100,2) end as rt2_att_pct_undoc,
case when rt3_mem = 0 then null else 
       round(((rt3_mem - rt3_absences_undoc) / rt3_mem) * 100,2) end as rt3_att_pct_undoc, 
case when rt4_mem = 0 then null else 
       round(((rt4_mem - rt4_absences_undoc) / rt4_mem) * 100,2) end as rt4_att_pct_undoc,
case when rt5_mem = 0 then null else 
       round(((rt5_mem - rt5_absences_undoc) / rt5_mem) * 100,2) end as rt5_att_pct_undoc,
case when rt6_mem = 0 then null else 
       round(((rt6_mem - rt6_absences_undoc) / rt6_mem) * 100,2) end as rt6_att_pct_undoc,   
--tardy percentage total
case when mem = 0 then null else 
       round((tardies_total / mem) * 100,2) end as y1_tardy_pct_total,
case when rt1_mem = 0 then null else 
       round((rt1_tardies_total / rt1_mem) * 100,2) end as rt1_tardy_pct_total,
case when rt2_mem = 0 then null else 
       round((rt2_tardies_total / rt2_mem) * 100,2) end as rt2_tardy_pct_total,
case when rt3_mem = 0 then null else 
       round((rt3_tardies_total / rt3_mem) * 100,2) end as rt3_tardy_pct_total, 
case when rt4_mem = 0 then null else 
       round((rt4_tardies_total / rt4_mem) * 100,2) end as rt4_tardy_pct_total,
case when rt5_mem = 0 then null else 
       round((rt5_tardies_total / rt5_mem) * 100,2) end as rt5_tardy_pct_total,
case when rt6_mem = 0 then null else 
       round((rt6_tardies_total / rt6_mem) * 100,2) end as rt6_tardy_pct_total,   
--tardy percentage regular only
case when mem = 0 then null else 
       round((tardies_reg / mem) * 100,2) end as y1_tardy_pct_reg,
case when rt1_mem = 0 then null else 
       round((rt1_tardies_reg / rt1_mem) * 100,2) end as rt1_tardy_pct_reg,
case when rt2_mem = 0 then null else 
       round((rt2_tardies_reg / rt2_mem) * 100,2) end as rt2_tardy_pct_reg,
case when rt3_mem = 0 then null else 
       round((rt3_tardies_reg / rt3_mem) * 100,2) end as rt3_tardy_pct_reg, 
case when rt4_mem = 0 then null else 
       round((rt4_tardies_reg / rt4_mem) * 100,2) end as rt4_tardy_pct_reg,
case when rt5_mem = 0 then null else 
       round((rt5_tardies_reg / rt5_mem) * 100,2) end as rt5_tardy_pct_reg,
case when rt6_mem = 0 then null else 
       round((rt6_tardies_reg / rt6_mem) * 100,2) end as rt6_tardy_pct_reg,
--tardy percentage t10 only
case when mem = 0 then null else 
       round((tardies_T10 / mem) * 100,2) end as y1_tardy_pct_T10,
case when rt1_mem = 0 then null else 
       round((rt1_tardies_T10 / rt1_mem) * 100,2) end as rt1_tardy_pct_T10,
case when rt2_mem = 0 then null else 
       round((rt2_tardies_T10 / rt2_mem) * 100,2) end as rt2_tardy_pct_T10,
case when rt3_mem = 0 then null else 
       round((rt3_tardies_T10 / rt3_mem) * 100,2) end as rt3_tardy_pct_T10, 
case when rt4_mem = 0 then null else 
       round((rt4_tardies_T10 / rt4_mem) * 100,2) end as rt4_tardy_pct_T10,
case when rt5_mem = 0 then null else 
       round((rt5_tardies_T10 / rt5_mem) * 100,2) end as rt5_tardy_pct_T10,
case when rt6_mem = 0 then null else 
       round((rt6_tardies_T10 / rt6_mem) * 100,2) end as rt6_tardy_pct_T10

from attendance_counts att
left outer join membership_counts mem on att.id = mem.id
*/
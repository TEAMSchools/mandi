/*
PURPOSE:
  Calculates cumulative GPA for Rise (average of all Y1 grades)

MAINTENANCE:
  None

MAJOR STRUCTURAL REVISIONS OR CHANGES:
  Ported to SQL Server - CB

TO DO:
  STOREDGRADES needs to be ported over into a static table in order to run this on Server, code commented out below

CREATED BY: LD6

ORIGIN DATE: Winter 2012
LAST MODIFIED: Fall 2013  
*/

USE KIPP_NJ
GO

ALTER VIEW GPA$cumulative#Rise AS
SELECT *
FROM OPENQUERY(KIPP_NWK,'
     SELECT *
     FROM gpa$cumulative#rise
')

/*
create or replace view gpa$cumulative#rise as

select 
   studentid
  ,schoolid
  ,cumulative_y1_gpa
--  ,rank() over (partition by grade_level order by cumulative_Y1_gpa desc) cumulative_Y1_gpa_rank_grade
--  ,rank() over (partition by schoolid order by cumulative_Y1_gpa desc) cumulative_Y1_gpa_rank_school
  ,audit_trail
from
(select sq_2.studentid
      ,sq_2.schoolid
      ,round(weighted_points/credit_hours,2) as cumulative_Y1_gpa
      ,audit_trail

from
     (select sq_1.studentid
            ,sq_1.schoolid
            ,round(sum(sq_1.weighted_points),3) as weighted_points
            ,sum(sq_1.potentialcrhrs) as credit_hours
            ,listagg(audit_hash, ', ') within group (order by grade_level, course_number) as audit_trail
      from
           (select studentid
            --      ,storecode
            --      ,grade
            --      ,percent
                  ,potentialcrhrs
            --      ,earnedcrhrs
            --      ,course_name
                  ,case 
                     when course_number is null then 'TRANSF'
                     else course_number
                   end course_number
            --      ,credit_type
                  ,grade_level
                  ,schoolid
            --      ,teacher_name
            --      ,gpa_points
                  ,excludefromgpa
--                ,earnedcrhrs * gpa_points as weighted_points
                  ,potentialcrhrs * gpa_points as weighted_points
                  ,'|' || course_number || '_gr' || grade_level || '[' || percent ||']' || ' (' || gpa_points || ' pts*' || earnedcrhrs || ' earned_cr)/' || potentialcrhrs || ' pot. cr' || '|'as audit_hash
            from storedgrades@PS_TEAM
            where storecode = 'Y1' and schoolid = 73252
            ) sq_1
      where excludefromgpa != 1
      group by studentid, schoolid
      ) sq_2
      )
*/
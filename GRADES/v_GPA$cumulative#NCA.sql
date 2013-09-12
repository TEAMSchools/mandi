/*
PURPOSE:
  Calculates cumulative GPA for NCA (average of all Y1 grades)

MAINTENANCE:
  None
  
MAJOR STRUCTURAL REVISIONS OR CHANGES:
  Changed calc method to use potential credits instead of earned credits 7/3/2012 LDS
  Ported to SQL Server - CB
  
TO DO:
  STOREDGRADES needs to be ported over into a static table in order to run this on Server, code commented out below

CREATED BY: AM2
  
ORIGIN DATE: Fall 2011
LAST MODIFIED: Fall 2013 (CB)  
*/
USE KIPP_NJ
GO

ALTER VIEW GPA$cumulative#NCA AS
SELECT *
FROM OPENQUERY(KIPP_NWK, '
     SELECT *
     FROM gpa$cumulative#nca
')

/*
create or replace view gpa$cumulative#nca as

select sq_2.studentid
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
            where storecode = 'Y1' and schoolid = 73253
            ) sq_1
      where excludefromgpa != 1
      group by studentid, schoolid
      ) sq_2
*/
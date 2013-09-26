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
SELECT sub.studentid
      ,sub.schoolid
      ,ROUND(weighted_points/credit_hours,2) as cumulative_Y1_gpa
      ,audit_trail
FROM
     (SELECT studentid
            ,schoolid
            ,ROUND(SUM(CONVERT(FLOAT,weighted_points)),3) AS weighted_points
            ,SUM(CONVERT(FLOAT,potentialcrhrs)) AS credit_hours
            ,dbo.GROUP_CONCAT(audit_hash) AS audit_trail
      FROM OPENQUERY(PS_TEAM,'
           SELECT studentid                 
                 ,potentialcrhrs            
                 ,CASE
                   WHEN course_number IS NULL THEN ''TRANSF''
                   ELSE course_number
                  END AS course_number            
                 ,grade_level
                 ,schoolid            
                 ,excludefromgpa
                 ,potentialcrhrs * gpa_points as weighted_points
                 ,''|'' || course_number || ''_gr'' || grade_level || ''['' || percent || '']'' || '' ('' || gpa_points 
                    || '' pts*'' || earnedcrhrs || '' earned_cr)/'' || potentialcrhrs || '' pot. cr'' || ''|'' AS audit_hash
           FROM storedgrades
           WHERE storecode = ''Y1''
             AND schoolid = 73252
           ')
      WHERE excludefromgpa != 1
      GROUP BY studentid, schoolid
      ) sub
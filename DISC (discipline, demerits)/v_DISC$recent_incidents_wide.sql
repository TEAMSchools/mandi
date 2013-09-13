
--Not active
--Need to rebuild pivot

/*
PURPOSE:
  Wide view of recent discipline incidents for purposes of RCs and other reporting
MAINTENANCE:
  None
MAJOR STRUCTURAL REVISIONS OR CHANGES:

CREATED BY:
  AM2
  Added to SQL LD6 2013-09-13
ORIGIN DATE:
  Fall 2011
*/
USE KIPP_NJ
GO

--CREATE VIEW disc$recent_incidents_wide AS

SELECT *
FROM
     (SELECT students.id as base_studentid
            ,substr(disc_log.entry_author,1,instr(disc_log.entry_author,',')-1) AS given_by
            ,disc_log.entry_date       AS date_reported
            ,disc_log.subject          AS subject
            ,disc_log.subtype          AS subtype
            ,disc_log.incident_decoded AS incident
            ,disc_log.rn
      FROM students
      LEFT OUTER JOIN disc$log disc_log ON students.id = disc_log.studentid
      WHERE students.enroll_status = 0
      )
S PIVOT (MAX(given_by)      AS given_by
        ,MAX(date_reported) AS date_reported
        ,MAX(subject)       AS subject
        ,MAX(subtype)       AS subtype
        ,MAX(incident)      AS incident
         FOR rn IN          ('1'    disc_01
                            ,'2'    disc_02
                            ,'3'    disc_03
                            ,'4'    disc_04
                            ,'5'    disc_05
                            ,'6'    disc_06
                            ,'7'    disc_07
                            ,'8'    disc_08
                            ,'9'    disc_09
                            ,'10'   disc_10
                           )
        )
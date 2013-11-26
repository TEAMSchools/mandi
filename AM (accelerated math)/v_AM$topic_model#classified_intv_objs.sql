USE RutgersReady
GO

ALTER VIEW AM$topic_model#classified_intv_objs AS
WITH roster AS
    (SELECT c.studentid
           ,c.year
           ,c.grade_level AS grade
           ,c.schoolid
           ,sch.abbreviation AS school
           ,s.first_name + ' ' + s.last_name AS stu_name
           ,s.lastfirst
           ,c.entrydate
           ,c.exitdate
     FROM KIPP_NJ..COHORT$comprehensive_long#static c
     JOIN KIPP_NJ..STUDENTS s
       ON c.studentid = s.id
      AND s.enroll_status = 0
     JOIN KIPP_NJ..SCHOOLS sch
       ON c.schoolid = sch.school_number
     WHERE c.year = 2013
       AND c.rn = 1
     )

SELECT sub.studentid
      ,sub.year
      ,sub.grade
      ,sub.school
      ,sub.stu_name
      ,sub.lastfirst
      ,sub.chobjectivecode
      ,sub.vchdescription
      ,sub.dtintervenedate AS intv_flagged
      ,lib.dgradelevel
      ,DATEDIFF(day, sub.dtintervenedate, CAST(GETDATE() AS date)) AS intv_flag_days
      ,meta.doc_id
      ,topics.lda_k
      ,topics.topic_bin
      ,sub.rn
FROM
      (SELECT roster.*
             ,am.chobjectivecode
             ,am.vchdescription
             ,am.dtintervenedate
             ,am.ilibraryid
             ,ROW_NUMBER() OVER
                (PARTITION BY roster.studentid
                             ,roster.year
                 ORDER BY am.dtintervenedate DESC) AS rn
       FROM roster
       JOIN KIPP_NJ..AM$detail#static am WITH (NOLOCK)
         ON roster.studentid = am.base_studentid
        AND CAST(am.dtintervenedate AS date) >= roster.entrydate
        AND CAST(am.dtintervenedate AS date) <= roster.exitdate
        AND am.dtmastereddate IS NULL
       ) sub
JOIN [RM9-DSCHEDULER\SQLEXPRESS].[RL_RISE].[dbo].[am_Library] lib WITH (NOLOCK)
  ON sub.ilibraryid = lib.[iLibraryID]
JOIN RutgersReady..AM$topic_model#metadata meta
  ON sub.chobjectivecode = meta.chObjectiveCode
JOIN RutgersReady..AM$topic_model#objective_topics topics
  ON meta.doc_id = topics.doc_id
 
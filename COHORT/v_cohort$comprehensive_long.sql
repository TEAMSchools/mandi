USE KIPP_NJ
GO

ALTER VIEW COHORT$comprehensive_long AS
SELECT * 
FROM OPENQUERY(PS_TEAM, '
     select unioned_tables.studentid
           ,s.lastfirst
           ,s.grade_level as highest_achieved
           ,unioned_tables.grade_level
           ,unioned_tables.schoolid
           ,unioned_tables.abbreviation         
           ,(unioned_tables.yearid + 1990) as year
           ,unioned_tables.yearid + 2003 + 
              (-1 * case 
                      when unioned_tables.grade_level > 12 then null
                      else unioned_tables.grade_level 
                    end) as cohort
           ,unioned_tables.entrycode
           ,unioned_tables.exitcode
           ,unioned_tables.entrydate
           ,unioned_tables.exitdate
           ,row_number() over 
             (partition by unioned_tables.studentid
                          ,unioned_tables.yearid 
              order by unioned_tables.exitdate desc) as rn
           ,ROW_NUMBER() OVER
             (PARTITION BY unioned_tables.studentid
              ORDER BY unioned_tables.yearid ASC) AS year_in_network
     from
     --THIS LEVEL UNIONS FOUR TABLES:    REENROLLMENTS (who completed the year)
     --                                  STUDENTS (midyear transfers)
     --                                  STUDENTS (current year enrollment)
     --                                  GRADUATED STUDENTS
           (SELECT *
            FROM
                 --REENROLLMENTS
                (select reenrollments.*
                 from
                       --reenrollments (all completed school years -- majority of the query)
                     (select re_base.studentid
                            ,re_base.grade_level
                            ,re_base.schoolid
                            ,re_base.entrycode
                            ,re_base.exitcode
                            ,re_base.entrydate
                            ,re_base.exitdate
                            ,terms.abbreviation
                            ,terms.yearid
                            ,row_number() over 
                              (partition by re_base.studentid
                                           ,terms.yearid 
                               order by re_base.exitdate desc) as rn
                      from
                            (select re.studentid as studentid
                                   ,re.schoolid as schoolid
                                   ,re.grade_level as grade_level
                                   ,re.entrydate
                                   ,re.exitdate
                                   ,re.entrycode
                                   ,re.exitcode
                             from reenrollments re
                             where (re.exitdate - re.entrydate) > 0) re_base    
                       left outer join terms on re_base.schoolid = terms.schoolid and terms.portion = 1 
                                                    and re_base.entrydate >= terms.firstday  
                                                    and re_base.exitdate  <= (terms.lastday  + 1)
                       ) reenrollments
                 where reenrollments.rn = 1 --only last reenrollment for any year
                   and reenrollments.yearid < 2200 -- no reenrollments from this year
                 )
           union all
                 --STUDENTS (midyear transfers)
                 (select s_1.studentid
                        ,s_1.grade_level
                        ,s_1.schoolid
                        ,s_1.entrycode
                        ,s_1.exitcode
                        ,s_1.entrydate
                        ,s_1.exitdate
                        ,terms.abbreviation
                        ,terms.yearid
                        ,row_number() over 
                          (partition by s_1.studentid
                                       ,terms.yearid 
                           order by s_1.exitdate desc) as rn
                 from
                       (select s.id as studentid
                              ,s.schoolid as schoolid
                              ,s.grade_level as grade_level
                              ,s.entrydate
                              ,s.exitdate
                              ,s.entrycode
                              ,s.exitcode
                        from students s
                         where s.enroll_status > 0 and s.schoolid != 999999 
                           and (s.exitdate - s.entrydate) > 1 ) s_1
                 left outer join terms on s_1.schoolid = terms.schoolid and terms.portion = 1 
                                               and s_1.entrydate >= terms.firstday  
                                               and s_1.exitdate  <= (terms.lastday  + 1)
                  )
       
           union all
                 --STUDENTS (current year enrollment)
                 (select s_2.studentid
                        ,s_2.grade_level
                        ,s_2.schoolid
                        ,s_2.entrycode
                        ,null as exitcode
                        ,s_2.entrydate
                        ,s_2.exitdate
                        ,terms.abbreviation
                        ,terms.yearid
                        ,row_number() over (partition by s_2.studentid,terms.yearid order by s_2.exitdate desc) as rn
                  from
                        (select s.id as studentid
                               ,s.schoolid as schoolid
                               ,s.grade_level as grade_level
                               ,s.entrydate
                               ,s.entrycode
                               ,s.exitdate
                         from students s
                          where s.enroll_status = 0 and s.schoolid != 999999 
                            and (s.exitdate - s.entrydate) > 1 ) s_2
                   left outer join terms on s_2.schoolid = terms.schoolid and terms.portion = 1 
                                                and s_2.entrydate >= terms.firstday  
                                                and s_2.exitdate  <= (terms.lastday  + 1)
                   )
         
           union all
                 --GRADUATED STUDENTS
                 (select s_3.studentid
                        ,s_3.grade_level
                        ,s_3.schoolid
                        ,null as entrycode
                        ,null as exitcode
                        ,null as entrydate
                        ,null as exitdate
                        ,terms.abbreviation
                        ,terms.yearid
                        ,row_number() over (partition by s_3.studentid,terms.yearid order by s_3.exitdate desc) as rn
                  from
                        (select s.id as studentid
                               ,s.schoolid as schoolid
                               ,s.grade_level as grade_level
                               ,s.entrydate
                               ,s.exitdate
                         from students s
                          where s.enroll_status = 3) s_3
                 left outer join terms on s_3.schoolid = terms.schoolid and terms.portion = 1 
                                              and s_3.entrydate < terms.firstday
                 )
           ) unioned_tables
     left outer join students s on unioned_tables.studentid = s.id
')
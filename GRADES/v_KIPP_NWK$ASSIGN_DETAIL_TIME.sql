CREATE VIEW KIPP_NWK$ASSIGN_DETAIL_TIME AS
SELECT sub_4.*
      ,CASE
         WHEN finalgradesetuptype = 'WeightedFGSetup'
            AND weighting IS NOT NULL THEN 1
         WHEN finalgradesetuptype = 'TotalPoints'
            AND score_inclusion_test = 'INCLUDE' THEN 1
       END AS assignment_count_test
FROM
       --SUB 4 - get grade weighting info and test to se if assignment
       --is excluded b/c of 'drop lowest N' 
       --tuning: cost 30
     (SELECT sub_3.*
            ,psm_finalgradesetup.finalgradesetuptype
            ,psm_finalgradesetup.lowscorestodiscard --only for total points
            ,psm_gradingformulaweighting.gradingformulaweightingtype
            ,psm_gradingformulaweighting.weighting
            ,psm_gradingformulaweighting.lowscorestodiscard AS lowscorestodiscard_cat
            --low scores to drop
            ,CASE
               WHEN psm_finalgradesetup.finalgradesetuptype = 'TotalPoints' 
                 AND rn_all <= NVL(psm_finalgradesetup.lowscorestodiscard,0) THEN 'EXCLUDE'
               WHEN psm_finalgradesetup.finalgradesetuptype = 'TotalPoints' 
                 AND rn_all >  NVL(psm_finalgradesetup.lowscorestodiscard,0) THEN 'INCLUDE'  
               WHEN psm_finalgradesetup.finalgradesetuptype = 'WeightedFGSetup' 
                 AND rn_cat <= NVL(psm_gradingformulaweighting.lowscorestodiscard,0) THEN 'EXCLUDE'
               WHEN psm_finalgradesetup.finalgradesetuptype = 'WeightedFGSetup' 
                 AND rn_cat >  NVL(psm_gradingformulaweighting.lowscorestodiscard,0) THEN 'INCLUDE'
             END AS score_inclusion_test
      FROM
           --SUB 3 - bring in scores and number rows to facilitate dropping low scores
           --tuning: cost 27 without restrictions on reporting term.  68 with!
           (SELECT sub_2.stu_studentid
                  ,sub_2.date_value
                  ,sub_2.course_number
                  ,sub_2.teacher
                  ,sub_2.section_number
                  ,sub_2.psm_sectionid
                  ,sub_2.assignmentcategoryid
                  ,sub_2.cat_abbrev
                  ,sub_2.contentgroupid
                  ,sub_2.weight
                  ,sub_2.pointspossible
                  ,psm_reportingterm.id AS reportingtermid
                  ,psm_reportingterm.name AS rt_name
                  ,psm_assignmentscore.score
                  ,psm_assignmentscore.ismissing
                  
                  --nice to have, for debugging
                  ,sub_2.lastfirst
                  ,sub_2.schoolid
                  ,sub_2.assignment_name                    
                  --DROP LOW SCORES                                
                  ,row_number() OVER 
                    (PARTITION BY sub_2.stu_studentid
                                 ,sub_2.psm_sectionid
                                 ,sub_2.date_value
                                 ,sub_2.assignmentcategoryid
                                 ,psm_reportingterm.name
                     ORDER BY psm_assignmentscore.score 
                             /((sub_2.pointspossible + sub_2.extracreditpoints)+1) ASC)
                   AS rn_cat
                   
                  ,row_number() OVER 
                    (PARTITION BY sub_2.stu_studentid
                                 ,sub_2.psm_sectionid
                                 ,sub_2.date_value
                                 ,psm_reportingterm.name
                     ORDER BY psm_assignmentscore.score 
                             /((sub_2.pointspossible + sub_2.extracreditpoints)+1)   ASC)
                   AS rn_all
                  
             FROM 
                  --SUB 2 - bring in all valid assignments              
                  --tuning: cost is 14
                    --largest: PSM_SECTIONASSIGNMENT    BY INDEX ROWID 14
                 (SELECT  sub_1.*
                        --NEED NEXT TWO TO JOIN TO ASSIGNMENT SCORES
                        ,psm_sectionassignment.id AS sectionassignmentid
                        ,psm_sectionassignment.dateassignmentdue
                        ,psm_sectionassignment.dateassignedtosection
                        ,psm_assignment.pointspossible
                        ,psm_assignment.extracreditpoints
                        ,psm_assignment.weight
                        ,psm_assignment.name AS assignment_name
                        ,psm_assignmentcategory.id AS assignmentcategoryid
                        ,psm_assignmentcategory.abbreviation AS cat_abbrev
                        ,psm_assignmentcategory.contentgroupid
                  FROM
                        --SUB 1 - just ENROLLMENTS and corresponding PSM section IDs
                        --cartesian to get one row per student, date, enrollment
                        --tuning: COST is 5
                       (SELECT /*+ DRIVING_SITE(students) */
                               students.id AS stu_studentid
                              ,students.lastfirst
                              ,students.schoolid
                              ,arb_dates.date_value
                              ,sections.course_number
                              ,sections.teacher
                              ,sections.section_number
                              ,psm_section.id AS psm_sectionid
                              --sectionenrollmentid is one of the two FKs into
                              --assignment scores
                              ,psm_sectionenrollment.id AS sectionenrollmentid
                        FROM students
                        JOIN
                           --generate numbers 1-365
                          (SELECT to_date('01-AUG-13') + n AS date_value
                           FROM
                              (SELECT ROWNUM n
                               FROM ( SELECT 1 just_a_column
                                      FROM dual
                                      GROUP BY CUBE(1,2,3,4,5,6,7,8,9) )
                               WHERE ROWNUM <= 365
                               )
                          ) arb_dates
                          ON 1=1
                          AND arb_dates.date_value <= TRUNC(SYSDATE)
                          --for testing
                        --get current courses that are inside date window generated above
                        JOIN cc
                          ON cc.studentid = students.id
                         AND cc.dateenrolled <= arb_dates.date_value
                         AND cc.dateleft >= arb_dates.date_value
                         AND cc.termid >= 2300
                         
                         --AND students.ID = 532
                         --AND cc.course_number = 'ART12'
                         
                        JOIN sections
                          ON cc.sectionid = sections.id
                        --sync_sectionenrollmentmap is a bridge into PSM tables
                        JOIN sync_sectionenrollmentmap
                          ON cc.dcid = sync_sectionenrollmentmap.ccdcid
                        --once we have sectionenrollmentid we can get psm_sectionenrollment, 
                        ---and then section
                        JOIN psm_sectionenrollment 
                          ON sync_sectionenrollmentmap.sectionenrollmentid = psm_sectionenrollment.id
                        JOIN psm_section 
                          ON psm_sectionenrollment.sectionid = psm_section.id
                       WHERE sections.course_number NOT IN ('HR','CHK')
                         --AND sections.course_number IN ('S105','M105')
                         --AND sections.course_number = 'S105'
                         --AND sections.course_number = par_course_number
                        ) sub_1
                  --now get assignments that are within window via sectionassignment
                  --35816 for 1 6th Rise student at this level of detail on OCT 10th
                  JOIN psm_sectionassignment
                    ON sub_1.psm_sectionid = psm_sectionassignment.sectionid
                   AND psm_sectionassignment.dateassignmentdue <= sub_1.date_value
                   AND psm_sectionassignment.dateassignmentdue >= '01-AUG-13'
                  JOIN psm_assignment
                    ON psm_sectionassignment.assignmentid = psm_assignment.id
                   --only include those assignments that count toward final score
                   AND psm_assignment.isfinalscorecalculated = 1
                  JOIN psm_assignmentcategory
                    ON psm_assignment.assignmentcategoryid = psm_assignmentcategory.id
                  JOIN psm_contentgroup
                    ON psm_assignmentcategory.contentgroupid = psm_contentgroup.id
                  JOIN psm_contentgroup parent_content
                    ON psm_contentgroup.parentcontentgroupid = parent_content.id  
                  ) sub_2
            --PSM assignment score has 2 FKs - sectionassignment (which connects 
            ---assignments to their enrolled sections) and sectionenrollment (which
            ---connects, you know, the score to a kid in that section)
              --tuning: cost with this join 25
            JOIN psm_assignmentscore
              ON psm_assignmentscore.sectionassignmentid = sub_2.sectionassignmentid
             AND psm_assignmentscore.sectionenrollmentid = sub_2.sectionenrollmentid
             --don't include assignments that have been exempted
             AND psm_assignmentscore.exempt = 0
            --tuning: cost with this join 35
            JOIN psm_finalgradesetup
              ON psm_finalgradesetup.sectionid = sub_2.psm_sectionid
            --what reporting term does this fall into? 
            JOIN psm_reportingterm
              ON psm_finalgradesetup.reportingtermid = psm_reportingterm.id
              --Rise uses Q_ for HW quality.  Not wanted here.
              --AND NOT (sub_2.schoolid = 73252 AND psm_reportingterm.name IN ('Q1','Q2','Q3','E1','E2'))
              --these guys tramatically increased query cost.  can we leave off?
                 AND psm_reportingterm.startdate <= sub_2.dateassignmentdue
                 AND psm_reportingterm.enddate   >= sub_2.dateassignmentdue
                 
                 --current term ONLY
                 --AND psm_reportingterm.startdate <= TRUNC(SYSDATE)
                 --AND psm_reportingterm.enddate   >= TRUNC(SYSDATE)
                 
                 --only include overall grades.  not grade elements.
                   --parameterize this.  was:
                AND psm_reportingterm.name IN ('T1','T2','T3','Q1','Q2','Q3','Q4','E1','E2','H1','H2','H3','H4')
                 
                 --don't calculate report terms if the target date is outside their scope
                 --(significant performance bump)
                 AND psm_reportingterm.startdate <= sub_2.date_value
                 AND psm_reportingterm.enddate >= sub_2.date_value
                 
             --overrides for debugging
                 --an example with drop from cat weights
                 --WHERE sub_2.course_number = 'WRI71'
                  -- AND sub_2.stu_studentid = 1090
                 --an example with total points
                 --WHERE sub_2.course_number = 'Sci401'
                 --AND sub_2.stu_studentid = 1131
                 --composite
                 --WHERE sub_2.course_number IN ('WRI71','Sci401')
                 --AND sub_2.stu_studentid IN (1090,1131)
                 --WHERE stu_studentid = 2960
                 --  AND course_number = 'GYM20'
            ) sub_3
      --pushed a change here - ART12 was returning multiple finalgradesetups
      --decode by ID (which is purportedly sequential?) to get most recent finalgradesetup
      --per sectionid and reporting term.
      JOIN
          (SELECT psm_finalgradesetup.*
                 ,ROW_NUMBER() OVER
                   (PARTITION BY psm_finalgradesetup.reportingtermid
                                ,psm_finalgradesetup.sectionid
                    ORDER BY psm_finalgradesetup.ID DESC) AS rn
           FROM psm_finalgradesetup
          ) psm_finalgradesetup
        ON psm_finalgradesetup.sectionid = sub_3.psm_sectionid
       AND psm_finalgradesetup.reportingtermid = sub_3.reportingtermid
       AND psm_finalgradesetup.rn = 1
       
      LEFT OUTER JOIN psm_gradingformula
          ON psm_finalgradesetup.gradingformulaid = psm_gradingformula.id
      LEFT OUTER JOIN psm_gradingformulaweighting
        ON psm_gradingformula.id = psm_gradingformulaweighting.parentgradingformulaid
       AND psm_gradingformulaweighting.assignmentcategoryid = sub_3.assignmentcategoryid
      ) sub_4
WHERE sub_4.score_inclusion_test != 'EXCLUDE'

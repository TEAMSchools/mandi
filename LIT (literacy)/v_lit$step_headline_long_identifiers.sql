USE KIPP_NJ
GO

ALTER VIEW LIT$step_headline_long#identifiers AS
SELECT step.*
      ,cohort.schoolid
      ,cohort.grade_level
      ,cohort.abbreviation
      ,cohort.year
      ,ROW_NUMBER() OVER
         (PARTITION BY step.studentid
                      ,cohort.year
          ORDER BY step.date_taken ASC) AS rn_asc
      ,ROW_NUMBER() OVER
         (PARTITION BY step.studentid
                      ,cohort.year
          ORDER BY step.date_taken DESC) AS rn_desc
FROM LIT$step_headline_long step WITH (NOLOCK)
JOIN COHORT$comprehensive_long#static cohort WITH (NOLOCK)
  ON step.studentid = cohort.studentid
 AND step.date_taken >= cohort.entrydate
 AND step.date_taken <= cohort.exitdate
 AND cohort.rn = 1
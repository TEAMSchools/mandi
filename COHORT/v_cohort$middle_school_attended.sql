USE KIPP_NJ
GO

ALTER VIEW COHORT$middle_school_attended AS
SELECT *
FROM 
      (SELECT c.studentid
             ,c.lastfirst
             ,c.schoolid
             ,sch.abbreviation AS school
             ,c.grade_level AS max_ms_achieved
             ,c.year
             ,ROW_NUMBER() OVER 
               (PARTITION BY c.studentid
                ORDER BY c.grade_level DESC
               ) AS rn
       FROM KIPP_NJ..COHORT$comprehensive_long#static c
       JOIN KIPP_NJ..SCHOOLS sch
         ON c.SCHOOLID = sch.school_number
       WHERE c.rn = 1 
         AND c.schoolid != 999999
         AND c.grade_level >= 5 AND c.grade_level <= 8
       ) sub
WHERE rn = 1
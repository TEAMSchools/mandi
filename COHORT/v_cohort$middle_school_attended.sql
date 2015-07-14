USE KIPP_NJ
GO

ALTER VIEW COHORT$middle_school_attended AS

SELECT studentid
      ,schoolid
      ,school_name
      ,max_ms_achieved
      ,academic_year
FROM 
    (
     SELECT c.studentid
           --,c.lastfirst
           ,c.schoolid
           ,sch.abbreviation AS school_name
           ,c.grade_level AS max_ms_achieved
           ,c.year AS academic_year
           ,ROW_NUMBER() OVER(
              PARTITION BY c.studentid
                ORDER BY c.grade_level DESC) AS rn
     FROM KIPP_NJ..COHORT$comprehensive_long#static c WITH(NOLOCK)
     JOIN KIPP_NJ..PS$SCHOOLS#static sch WITH(NOLOCK)
       ON c.SCHOOLID = sch.school_number
     WHERE c.rn = 1 
       AND c.schoolid != 999999
       AND c.grade_level BETWEEN 5 AND 8
    ) sub
WHERE rn = 1
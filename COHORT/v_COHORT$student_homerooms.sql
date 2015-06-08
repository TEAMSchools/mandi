USE KIPP_NJ
GO

ALTER VIEW COHORT$student_homerooms AS
WITH hr_rost AS
    (SELECT KIPP_NJ.dbo.fn_TermToYear(sect.termid) AS year
          ,cc.studentid
          ,cc.dateenrolled
          ,sch.abbreviation
          ,t.first_name + ' ' + t.last_name AS teacher
          ,sect.section_number
    FROM KIPP_NJ..SECTIONS sect
    JOIN KIPP_NJ..SCHOOLS sch
      ON sect.schoolid = sch.school_number
    JOIN KIPP_NJ..CC
      ON sect.id = ABS(cc.sectionid)
    JOIN KIPP_NJ..TEACHERS t
      ON sect.teacher = t.id
    WHERE sect.course_number = 'HR'
    )
SELECT hr_rost.*
      ,ROW_NUMBER() OVER
        (PARTITION BY studentid
                     ,year
         ORDER BY dateenrolled
        ) AS rn_stu_year
FROM hr_rost
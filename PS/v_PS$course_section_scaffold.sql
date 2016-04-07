USE KIPP_NJ
GO

ALTER VIEW PS$course_section_scaffold AS

WITH scaffold AS (
  SELECT co.studentid
        ,co.year
        ,co.date
        ,co.term
        ,cc.COURSE_NUMBER
        ,cc.SECTIONID
        ,t.LASTFIRST AS teacher_name
        ,ROW_NUMBER() OVER(
           PARTITION BY co.studentid, co.year, co.term, cc.course_number
             ORDER BY co.date DESC, cc.sectionid DESC) AS rn_term
        ,ROW_NUMBER() OVER(
           PARTITION BY co.studentid, co.year, cc.course_number
             ORDER BY co.date DESC, cc.sectionid DESC) AS rn_year
  FROM KIPP_NJ..COHORT$identifiers_scaffold#static co WITH(NOLOCK)
  JOIN KIPP_NJ..PS$CC#static cc WITH(NOLOCK)
    ON co.studentid = cc.STUDENTID
   AND co.date BETWEEN cc.DATEENROLLED AND cc.DATELEFT
  JOIN KIPP_NJ..PS$SECTIONS#static sec WITH(NOLOCK)
    ON ABS(cc.SECTIONID) = sec.ID
  JOIN KIPP_NJ..PS$TEACHERS#static t WITH(NOLOCK)
    ON sec.teacher = t.ID
  WHERE co.year >= 2011
 )

SELECT s1.studentid
      ,s1.year
      ,s1.term
      ,s1.COURSE_NUMBER
      ,ABS(COALESCE(s1.SECTIONID, s2.SECTIONID)) AS sectionid
      ,COALESCE(s1.teacher_name, s2.teacher_name) AS teacher_name
FROM scaffold s1
LEFT OUTER JOIN scaffold s2
  ON s1.studentid = s2.studentid
 AND s1.year = s2.year
 AND s1.course_number = s2.course_number
 AND s2.rn_year = 1
WHERE s1.rn_term = 1
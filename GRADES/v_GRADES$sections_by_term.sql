USE KIPP_NJ
GO

ALTER VIEW GRADES$sections_by_term AS

SELECT sub2.schoolid
      ,sub2.studentid
      ,sub2.student_number
      ,sub2.credittype
      ,sub2.course_number
      ,sub2.term
      ,sub2.sectionid
      ,t.lastfirst AS teacher
FROM
    (
     SELECT schoolid
           ,studentid
           ,student_number
           ,credittype
           ,course_number
           ,LEFT(field, 2) AS term
           ,sectionid
     FROM
         (
          SELECT studentid
                ,student_number
                ,schoolid
                ,credittype
                ,course_number
                ,q1_enr_sectionid
                ,q2_enr_sectionid
                ,q3_enr_sectionid
                ,q4_enr_sectionid
                ,NULL AS t1_enr_sectionid
                ,NULL AS t2_enr_sectionid
                ,NULL AS t3_enr_sectionid
          FROM GRADES$DETAIL#NCA WITH(NOLOCK)

          UNION ALL

          SELECT studentid
                ,student_number
                ,schoolid
                ,credittype
                ,course_number
                ,NULL AS q1_enr_sectionid
                ,NULL AS q2_enr_sectionid
                ,NULL AS q3_enr_sectionid
                ,NULL AS q4_enr_sectionid
                ,t1_enr_sectionid
                ,t2_enr_sectionid
                ,t3_enr_sectionid
          FROM GRADES$DETAIL#MS WITH(NOLOCK)
         ) sub

     UNPIVOT (
       sectionid
       FOR field IN (q1_enr_sectionid
                    ,q2_enr_sectionid
                    ,q3_enr_sectionid
                    ,q4_enr_sectionid
                    ,t1_enr_sectionid
                    ,t2_enr_sectionid
                    ,t3_enr_sectionid)
      ) u
     ) sub2
LEFT OUTER JOIN sections sec WITH(NOLOCK)
  ON sub2.sectionid = sec.id
LEFT OUTER JOIN teachers t WITH(NOLOCK)
  ON sec.teacher = t.id
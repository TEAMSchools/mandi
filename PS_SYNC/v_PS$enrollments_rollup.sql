USE KIPP_NJ
GO

ALTER VIEW PS$enrollments_rollup AS

SELECT enr.STUDENTID
      ,enr.student_number
      ,enr.academic_year
      ,enr.credittype
      ,enr.measurementscale                
      ,KIPP_NJ.dbo.GROUP_CONCAT_D(DISTINCT COURSE_NUMBER, ',') + ',' AS course_number
      ,KIPP_NJ.dbo.GROUP_CONCAT_D(DISTINCT COURSE_NAME, ',') + ',' AS course_name
      ,KIPP_NJ.dbo.GROUP_CONCAT_D(DISTINCT teacher_name, ',') + ',' AS teacher_name
      ,KIPP_NJ.dbo.GROUP_CONCAT_D(DISTINCT period, ',') + ',' AS period
      ,KIPP_NJ.dbo.GROUP_CONCAT_D(DISTINCT COALESCE(period, section_number), ',') + ',' AS section
      ,KIPP_NJ.dbo.GROUP_CONCAT_D(DISTINCT tier, ',') + ',' AS rti_tier
      ,KIPP_NJ.dbo.GROUP_CONCAT_D(DISTINCT behavior_tier, ',') + ',' AS rti_behavior_tier
      ,KIPP_NJ.dbo.GROUP_CONCAT_D(DISTINCT group_name,', ') + ',' AS illuminate_group
FROM KIPP_NJ..PS$course_enrollments#static enr WITH(NOLOCK)
LEFT OUTER JOIN KIPP_NJ..ILLUMINATE$student_groups#static grp WITH(NOLOCK)
  ON enr.student_number = grp.student_number
 AND enr.academic_year = grp.academic_year
GROUP BY enr.STUDENTID
        ,enr.student_number
        ,enr.academic_year
        ,enr.credittype
        ,enr.measurementscale
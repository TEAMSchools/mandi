USE KIPP_NJ
GO

ALTER VIEW ATT_MEM$cc_attendance_totals_wide_course AS

WITH att_unpivot AS (
  SELECT student_number
        ,term
        ,CONCAT('rc', RIGHT(CONCAT('0', class_rn),2), '_', field) AS pivot_field
        ,value
  FROM
      (
       SELECT gr.student_number
             ,gr.term
             ,gr.class_rn      
             ,ISNULL(cc.CURRENTABSENCES,0) AS CURRENT_ABSENCES
             ,ISNULL(cc.CURRENTTARDIES,0) AS CURRENT_TARDIES
       FROM KIPP_NJ..GRADES$final_grades_wide#static gr WITH(NOLOCK)
       JOIN KIPP_NJ..PS$STUDENTS#static s WITH(NOLOCK)
         ON gr.student_number = s.STUDENT_NUMBER
       LEFT OUTER JOIN KIPP_NJ..PS$CC#static cc WITH(NOLOCK)
         ON s.id = cc.STUDENTID
        AND gr.sectionid = cc.SECTIONID
       WHERE gr.academic_year = KIPP_NJ.dbo.fn_Global_Academic_Year()
      ) sub
  UNPIVOT(
    value
    FOR field IN (current_absences, current_tardies)
   ) u
 )

SELECT *
FROM att_unpivot
PIVOT(
  MAX(value)
  FOR pivot_field IN ([rc01_current_absences]
                     ,[rc01_current_tardies]
                     ,[rc02_current_absences]
                     ,[rc02_current_tardies]
                     ,[rc03_current_absences]
                     ,[rc03_current_tardies]
                     ,[rc04_current_absences]
                     ,[rc04_current_tardies]
                     ,[rc05_current_absences]
                     ,[rc05_current_tardies]
                     ,[rc06_current_absences]
                     ,[rc06_current_tardies]
                     ,[rc07_current_absences]
                     ,[rc07_current_tardies]
                     ,[rc08_current_absences]
                     ,[rc08_current_tardies]
                     ,[rc09_current_absences]
                     ,[rc09_current_tardies]
                     ,[rc10_current_absences]
                     ,[rc10_current_tardies]
                     ,[rc11_current_absences]
                     ,[rc11_current_tardies]
                     ,[rc12_current_absences]
                     ,[rc12_current_tardies])
 ) p
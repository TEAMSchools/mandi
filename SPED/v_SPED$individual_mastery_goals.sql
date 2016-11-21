USE KIPP_NJ
GO

ALTER VIEW SPED$individual_mastery_goals AS

SELECT sn AS student_number
      ,academic_year
      ,CASE
        WHEN subject_area = 'text_study' THEN 'Text Study'
        WHEN subject_area = 'mathematics' THEN 'Mathematics'
       END AS subject_area
      ,goal
FROM KIPP_NJ..AUTOLOAD$GDOCS_SPED_individual_mastery_goals WITH(NOLOCK)
UNPIVOT(
  goal
  FOR subject_area IN (text_study, mathematics)
 ) u
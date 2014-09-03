-- frozen for the summer

USE KIPP_NJ
GO

ALTER VIEW CUSTOM_GROUPINGS$intervention_block#NCA AS
--CTE
  --get biggest epoch number for NCA intervention block
  WITH cur_epoch AS
      (
       SELECT MAX(epoch_number) AS max_epoch
       FROM KIPP_NJ..CUSTOM_GROUPINGS$assignments a WITH(NOLOCK)
       WHERE a.group_type = 'NCA Intervention Block'
         AND a.start_date <= '2014-05-30'
         AND a.end_date >= '2014-05-30'
      )

SELECT a.subgroup AS group_name
      ,e.studentid
      ,a.assignmentid
FROM KIPP_NJ..CUSTOM_GROUPINGS$assignments a WITH(NOLOCK)
JOIN cur_epoch
  ON a.epoch_number = cur_epoch.max_epoch
JOIN KIPP_NJ..CUSTOM_GROUPINGS$assignments_students e WITH(NOLOCK)
  ON e.assignmentid = a.assignmentid
JOIN STUDENTS s WITH(NOLOCK)
  ON e.studentid = s.id
 --AND s.enroll_status = 0
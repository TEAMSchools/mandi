USE KIPP_NJ
GO

ALTER VIEW CUSTOM_GROUPINGS$intervention_block#NCA AS
--CTE
  --get biggest epoch number for NCA intervention block
  WITH cur_epoch AS
      (SELECT MAX(epoch_number) AS max_epoch
      FROM KIPP_NJ..CUSTOM_GROUPINGS$assignments a
      WHERE a.group_type = 'NCA Intervention Block'
        AND a.end_date <= CAST(GETDATE() AS date)
      )

SELECT a.subgroup AS group_name
      ,e.studentid
      ,a.assignmentid
FROM KIPP_NJ..CUSTOM_GROUPINGS$assignments a
JOIN cur_epoch
  ON a.epoch_number = cur_epoch.max_epoch
JOIN KIPP_NJ..CUSTOM_GROUPINGS$assignments_students e
  ON e.assignmentid = a.assignmentid
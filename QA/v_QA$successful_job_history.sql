USE master
GO

ALTER VIEW QA$successful_job_history AS

SELECT j.name AS job_name
      ,msdb.dbo.agent_datetime(h.run_date, h.run_time) AS run_date_format
      ,DateDiff(minute, msdb.dbo.agent_datetime(h.run_date, h.run_time), CURRENT_TIMESTAMP) AS minutes_old
      ,h.message
      ,RIGHT('000000' + CONVERT(VARCHAR(6),h.run_duration),6 ) AS run_duration
      ,ROW_NUMBER() OVER
         (PARTITION BY j.job_id
          ORDER BY msdb.dbo.agent_datetime(h.run_date, h.run_time) DESC) AS rn
FROM msdb.dbo.sysjobs j 
JOIN msdb.dbo.sysjobhistory h 
 ON j.job_id = h.job_id 
WHERE j.enabled = 1 
  AND msdb.dbo.agent_datetime(run_date, run_time) >= DATEADD(day, -1, GETDATE())
  AND h.step_id = 0
  AND h.run_status = 1
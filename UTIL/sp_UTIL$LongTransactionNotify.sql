USE master
GO

ALTER PROCEDURE sp_UTIL$LongTransactionNotify AS

/* NOTE: You have to configure/set the following 3 variables */
DECLARE @AlertingThresholdMinutes int = 15;
DECLARE @MailProfileToSendVia sysname = 'DataRobot';
DECLARE @OperatorName sysname = 'DataRescueTeam';

-------------------------------------------------------------
SET NOCOUNT ON;

DECLARE @LongestRunningTransaction int
DECLARE @LongSessions NVARCHAR(100)
DECLARE @LongSessionTime INT;

SELECT @LongestRunningTransaction = MAX(DATEDIFF(n, dtat.transaction_begin_time, GETDATE())) 
FROM sys.dm_tran_active_transactions dtat 
JOIN sys.dm_exec_requests r
  ON dtat.transaction_id = r.transaction_id
 --AND r.wait_type = 'OLEDB'
INNER JOIN sys.dm_tran_session_transactions dtst 
  ON dtat.transaction_id = dtst.transaction_id
--WHERE is_user_transaction = 0
  
SELECT @LongSessions = dbo.GROUP_CONCAT_D(dtst.session_id, ', ')
FROM sys.dm_tran_active_transactions dtat 
JOIN sys.dm_exec_requests r
  ON dtat.transaction_id = r.transaction_id
 --AND r.wait_type = 'OLEDB'
INNER JOIN sys.dm_tran_session_transactions dtst 
  ON dtat.transaction_id = dtst.transaction_id
WHERE DATEDIFF(n, dtat.transaction_begin_time, GETDATE()) >= @AlertingThresholdMinutes
  --AND is_user_transaction = 0

SELECT @LongSessionTime = MAX(DATEDIFF(n, dtat.transaction_begin_time, GETDATE()))
FROM sys.dm_tran_active_transactions dtat 
JOIN sys.dm_exec_requests r
  ON dtat.transaction_id = r.transaction_id
 --AND r.wait_type = 'OLEDB'
INNER JOIN sys.dm_tran_session_transactions dtst 
  ON dtat.transaction_id = dtst.transaction_id
WHERE DATEDIFF(n, dtat.transaction_begin_time, GETDATE()) >= @AlertingThresholdMinutes
  --AND is_user_transaction = 0;

IF ISNULL(@LongestRunningTransaction,0) >= @AlertingThresholdMinutes BEGIN 

        DECLARE @Warning nvarchar(800);
        DECLARE @Subject nvarchar(100);

        SET @subject = '[Warning] Transaction running longer than ' + CONVERT(VARCHAR,@AlertingThresholdMinutes) + ' minutes on ' + @@SERVERNAME;
        SET @Warning = 'SessionID(s): ' + @LongSessions + '
        
The longest job has been running for at least ' + CONVERT(VARCHAR,@LongSessionTime) + ' minutes.
        
Check SSMS Activity Monitor!';
        
        EXEC msdb..sp_notify_operator
                @profile_name = @MailProfileToSendVia,
                @name = @OperatorName,
                @subject = @subject, 
                @body = @warning;
        
        PRINT @warning

END
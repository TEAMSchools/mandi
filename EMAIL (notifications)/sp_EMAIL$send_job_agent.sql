USE KIPP_NJ
GO

ALTER PROCEDURE sp_EMAIL$send_job_agent AS

BEGIN

DECLARE @job_to_send      NCHAR(100)
       ,@jobid            INT
       ,@job_start        DATETIME
       ,@send_again_sql   NVARCHAR(4000)
       ,@send_again_value DATETIME
       

SET @job_start = GETDATE()

DECLARE send_email CURSOR FOR
  SELECT job_name
        ,id
  FROM KIPP_NJ..EMAIL$template_queue WITH (NOLOCK)
  WHERE SENT IS NULL
    AND send_at <= GETDATE()
  FOR READ ONLY

OPEN send_email
WHILE 1=1
BEGIN
  FETCH NEXT FROM send_email INTO @job_to_send, @jobid
  
  --exit if no value
  IF @@FETCH_STATUS != 0
  BEGIN
    BREAK
  END

  --send the job
  EXEC dbo.sp_EMAIL$send_template_job
    @job_name = @job_to_send
   ,@send_again = @send_again_sql OUTPUT
  
    --build next date
    SET @send_again_sql = 'SELECT @send_again_value = ' + @send_again_sql
    --evaluate it
    EXEC sp_executesql @send_again_sql, N'@send_again_value DATETIME OUTPUT', @send_again_value OUTPUT;   

    INSERT INTO KIPP_NJ..email$template_queue
      (job_name
      ,run_type
      ,send_at)
    VALUES
      (@job_to_send
      ,'auto'
      ,@send_again_value
      )

    --mark as sent
    UPDATE
      KIPP_NJ..EMAIL$template_queue
    SET 
      sent = 1
     ,sent_at = CURRENT_TIMESTAMP
    WHERE
      id = @jobid

END

CLOSE send_email
DEALLOCATE send_email

END
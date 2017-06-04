USE KIPP_NJ
GO

ALTER PROCEDURE sp_AR$StaleDataNotify AS

/* NOTE: You have to configure/set the following 3 variables */
DECLARE @MailProfileToSendVia sysname = 'DataRobot';
DECLARE @OperatorName sysname = 'DataRescueTeam'
-------------------------------------------------------------
SET NOCOUNT ON;

DECLARE @MostRecentQuiz DATETIME;

SELECT @MostRecentQuiz = MAX(dtTakenOriginal)
FROM KIPP_NJ..AR$test_event_detail#static;

IF ((DATEPART(DW,GETDATE()) NOT IN (1,2) AND DATEDIFF(DAY, @MostRecentQuiz, GETDATE()) > 1) 
     OR (DATEPART(DW,GETDATE()) = 1 AND DATEDIFF(DAY, @MostRecentQuiz, GETDATE()) > 2)
     OR (DATEPART(DW,GETDATE()) = 2 AND DATEDIFF(DAY, @MostRecentQuiz, GETDATE()) > 3))
  BEGIN 

    DECLARE @subject NVARCHAR(100);
    DECLARE @warning NVARCHAR(800);  

    SET @subject = '[Warning] RenLearning Data Is Out of Date';
    SET @warning = '
The most recent quiz data is from ' + CONCAT(DATENAME(DW,@MostRecentQuiz),', ', CONVERT(VARCHAR,@MostRecentQuiz)) + '.

Check the integration scripts for errors, and reach out to RenLearning if necessary.
';
        
    EXEC msdb..sp_notify_operator
            @profile_name = @MailProfileToSendVia,          
            @name = @OperatorName,
            @body = @warning,
            @subject = @subject;  
        
    PRINT @warning

  END
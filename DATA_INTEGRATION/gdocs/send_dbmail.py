def distress_signal(error_type, conn, body=''):
    cursor = conn.cursor()
    if error_type == 'traceback':
        warn_email = """
            DECLARE @body NVARCHAR(MAX);
            SET @body = '%s';
            EXEC msdb..sp_send_dbmail
                @profile_name = 'DataRobot',
                @recipients = 'cbini@teamschools.org',
                @body = @body,
                @subject = '!!! WARNING - GDocs Traceback !!!',
                @importance = 'High';""" % (body)        
        cursor.execute(warn_email)                
        conn.commit()
        conn.close()        
    elif error_type == 'load':
        warn_email = """            
            DECLARE @body NVARCHAR(MAX);
            SET @body = '%s';
            EXEC msdb..sp_send_dbmail
                @profile_name = 'DataRobot',
                @recipients = 'cbini@teamschools.org',
                @body = @body,
                @subject = '!!! WARNING - GDocs sp_LoadFolder Fail !!!',
                @importance = 'High';
        """ % (body)
        cursor.execute(warn_email)                
        conn.commit()
        conn.close()

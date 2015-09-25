import re
import sqlalchemy as sa

## configurables
DB_TYPE = ''
DB_API = ''
DB_DNS_NAME = ''
DB_SERVER = ''
DB_NAME = ''
DB_USERNAME = ''
DB_PASSWORD = ''

## create database engine and open a connection
DB_CONN_STRING =  '%s+%s://%s'  % (DB_TYPE, DB_API, DB_DNS_NAME)
DB_ENGINE = sa.create_engine(DB_CONN_STRING)

def truncate_and_load(engine, connection, df, tablename):
    """    
    TRUNCATES the table if it exists, and then INSERTS (or CREATES if new) refreshed data
    """ 
    ## clean up column headers
    df.columns = [re.sub(r'[^a-z0-9_]', '', col.lower().strip().replace(' ','_')) for col in df.columns]    
    
    ## TRUNCATE, if exists
    trans = connection.begin()
    try:
        sql = """
            IF OBJECT_ID(N'%s') IS NOT NULL
                BEGIN
                    TRUNCATE TABLE %s
                END
        """ % (tablename, tablename)
        connection.execute(sql)
        trans.commit()                                
    except:        
        trans.rollback()        
    
    ## INSERT or CREATE
    df.to_sql(tablename, engine, if_exists='append', index_label='BINI_ID')        

def distress_signal(engine, error_type, body=''):
    conn = engine.connect()
    trans = conn.begin()
    
    if error_type == 'traceback':
        warn_email = """
            DECLARE @body NVARCHAR(MAX);
            SET @body = '%s';
            EXEC msdb..sp_send_dbmail
                @profile_name = '',
                @recipients = '',
                @body = @body,
                @subject = '!!! WARNING - GDocs Traceback !!!',
                @importance = 'High';""" % (body)        
        conn.execute(warn_email)                
        trans.commit()        
    elif error_type == 'load':
        warn_email = """            
            DECLARE @body NVARCHAR(MAX);
            SET @body = '%s';
            EXEC msdb..sp_send_dbmail
                @profile_name = '',
                @recipients = '',
                @body = @body,
                @subject = '!!! WARNING - GDocs Load Fail !!!',
                @importance = 'High';
        """ % (body)
        conn.execute(warn_email)                
        trans.commit()
    
    conn.close()
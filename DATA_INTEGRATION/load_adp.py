import os
import pandas as pd
import pymssql
from nardoconfig import NARDO_SERVER, NARDO_DB, NARDO_USERNAME, NARDO_PASSWORD

## configure variables
src = r'\\RM9-FSS\ADP'
dst = r'\\WINSQL01\data_robot\ADP'

## function to send an email via dbmail
def send_dbmail(body, subject):
    email_query = """
        DECLARE @body VARCHAR(MAX);        
        EXEC msdb..sp_send_dbmail
            @profile_name = 'DataRobot',
            @importance = 'High',
            @recipients = 'cbini@kippnj.org',
            @body = '""" + body + """',
            @subject = '""" + subject + """';
    """        
    cursor.execute(email_query)
    conn.commit()

## create the destination folder, if it doesn't exist
if not os.path.isdir(dst):
    os.makedirs(dst)

## navigate to ADP directory
#home = os.path.expanduser("~")
#os.chdir(home)
os.chdir(src)
cwd = os.getcwd()

## get list of files
files = os.listdir(cwd)
#print files
    
## load each file into a DataFrame and write it to the destination folder
## there was some weirdness with the headers, so straight up copying them didn't work
for i, f in enumerate(files):    
    infile = files[i]
    outfile = dst + '\\' + infile    
    f = pd.read_csv(infile)
    f.to_csv(outfile, index=False)
    print infile, 'saved to', dst

## establish connection to database and create db cursor
print '\n', 'Connecting to database...'
conn = pymssql.connect(NARDO_SERVER, NARDO_USERNAME, NARDO_PASSWORD, NARDO_DB)
cursor = conn.cursor() 

## change destination path relative to db server
dst_load = dst.replace('\\\\WINSQL01', 'C:')

## trigger sp_LoadFolder
query = r"EXEC sp_LoadFolder '" + NARDO_DB + "', '" + dst_load + "'"
print '\n', query
try:
    cursor.execute(query)
    print 'NARDO say:', str(cursor.fetchall()[0][0])
    conn.commit()
    print 'File loaded into database'
except:
    subject = '!!! WARNING - ERROR LOADING ADP FILE INTO DB !!!'
    body = 'bruh...'
    send_dbmail(body, subject)
    print '!!! WARNING - ERROR LOADING ADP FILE INTO DB !!!'

## trigger MERGE procedure
query = r"""
    DECLARE @return_value int
    EXEC @return_value = [dbo].[sp_PEOPLE$ADP_detail#MERGE]
    SELECT 'Return Value' = @return_value
"""
print '\n', query
try:
    cursor.execute(query)
    print 'NARDO say:', str(cursor.fetchall()[0][0])
    conn.commit()
    print 'File successfully merged into destination table'
except:    
    subject = '!!! WARNING - ERROR MERGING ADP FILE INTO TABLE !!!'
    body = 'bruh...'
    send_dbmail(body, subject)
    print '!!! WARNING - ERROR MERGING ADP FILE INTO TABLE !!!'

## send confirmation email
subject = 'ADP People Data File Load Successful'
body = 'Have a nice day!'
send_dbmail(body, subject)

## g'out!
conn.close()

print '\n', 'All done. Hurray!'
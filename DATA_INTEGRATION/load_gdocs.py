__author__ = 'CBini'

import os
import csv
import json
import gspread
import pymssql
import unicodewriter
from oauth2client.client import SignedJwtAssertionCredentials

def distress_signal(error_type, server_name, db_user, db_pass, db_name, save_path, url):
    conn = pymssql.connect(server_name, db_user, db_pass, db_name)
    cursor = conn.cursor()
    if error_type == "http":
        print '!!! ERROR NAVIGATING TO URL !!!'
        conn = pymssql.connect(server_name, db_user, db_pass, db_name)
        cursor = conn.cursor()
        warn_email = """
            DECLARE @body VARCHAR(MAX);
            SET @body = 'Navigation failed for ' + '""" + save_path + """' + '.  Check that the GDocs URL is correct.';

            EXEC msdb..sp_send_dbmail
                @profile_name = 'DataRobot',
                @recipients = 'cbini@teamschools.org',
                @body = @body,
                @subject = '!!! WARNING - GDocs HTTP Error !!!',
                @importance = 'High';
        """        
        cursor.execute(warn_email)                
        conn.commit()
        conn.close()        
    elif error_type == "load":
        print '!!! ERROR LOADING FOLDER !!!'
        warn_email = """
            DECLARE @body VARCHAR(MAX);
            SET @body = 'The database load failed for ' + '""" + save_path + ' (' + url + ')' + """' + '.  Check that the GDocs source still matches the destination table and reset if necessary.';

            EXEC msdb..sp_send_dbmail
                @profile_name = 'DataRobot',
                @recipients = 'cbini@teamschools.org',
                @body = @body,
                @subject = '!!! WARNING - GDocs sp_LoadFolder fail !!!',
                @importance = 'High';
        """        
        cursor.execute(warn_email)                
        conn.commit()
        conn.close()        

"""
CONFIG
"""
# file locations
secret_file = "../config/secret.json"
oauth_file = '../config/gspread-efdc9f69f2c3.json'
config_file = "gdocs.csv"

# keys
scope = ['https://spreadsheets.google.com/feeds']
oauth_key = json.load(open(oauth_file))
gdocs_credentials = SignedJwtAssertionCredentials(oauth_key['client_email'], oauth_key['private_key'], scope)

keys = json.load(file(secret_file))
server_name = keys['NARDO']['server_name']
db_user = keys['NARDO']['login']['USERNAME']
db_pass = keys['NARDO']['login']['PASSWORD']


"""
DOWNLOAD
"""
# open config file
with open(config_file, 'rb') as f:
    next(f)  # skip header
    gdocs = csv.reader(f, delimiter=',')
    wkbk_list = []
    for record in gdocs:
        print record
        wkbk_list.append(record)
    print

# initialize GDocs client
client = gspread.authorize(gdocs_credentials)

# iterate over urls in config csv
for record in wkbk_list:
    url = record[0]
    tag = record[1]
    db_name = record[2]
    folder = record[3]
    start_sheet = int(record[4])
    end_sheet = int(record[5]) + 1  # range() will create a 0-indexed list of integers, so the +1 adjusts for that
    start_row = int(record[6])

    # file paths
    save_path = "C:\\data_robot\\gdocs\\" + folder + "\\"
    

    print 'Navigating to ' + url
    try:
        workbook = client.open_by_url(url)
    except:
        distress_signal("http", server_name, db_user, db_pass, db_name, save_path, url)
        continue
    sheet_names = workbook.worksheets()
    print
    
    print 'Now saving worksheets ' + str(start_sheet + 1) + ' through ' + str(end_sheet) + '...'    
    print
    print 'Let\'s go!'
    print

    # iterate over sequential worksheets
    for i in range(start_sheet, end_sheet):
        worksheet = workbook.get_worksheet(i)
        sheet_name = worksheet._title        
        clean_name = sheet_name.replace(' ', '_')  # removes spaces

        print 'Opening worksheet ' + str(i + 1) + ': "' + str(clean_name) + '"'                        
        
        print 'Getting and cleaning data...'
        data = worksheet.get_all_values()
        # list comprehension quickly removes unwanted header rows
        data = [line for x, line in enumerate(data) if x >= start_row]

        filename = save_path + 'GDOCS_' + tag + '_' + clean_name + '.csv'        
        print 'Downloading file ' + filename + ' to server, starting at line ' + str(start_row + 1)
        if not os.path.exists(save_path):
            os.makedirs(save_path)
        with open(filename, 'wb') as f:
            writer = unicodewriter.UnicodeWriter(f)
            writer.writerows(data)

        print 'Done!'
        print

    """
    LOAD INTO DB
    """
    print 'Download complete! Loading into NARDO...'
    print

    conn = pymssql.connect(server_name, db_user, db_pass, db_name)
    cursor = conn.cursor()

    query = "sp_LoadFolder '" + db_name + "', '" + save_path + "'"
    print 'Running "EXEC ' + query + '"'
    try:
        cursor.execute(query)
        print 'NARDO say: ' + cursor.fetchall()[0][0]
        conn.commit()
        conn.close()
    except:
        distress_signal("load", server_name, db_user, db_pass, db_name, save_path, url)
        continue
    
    print
    print 'Next workbook!'
    print

print
print 'All done!'

import gspread
import pandas as pd
from gspreadconfig import GDOCS_CREDENTIALS, DOWNLOAD_CONFIG_URL, LOCAL_TZ
from datetime import datetime
from dateutil import parser as time_parser
from StringIO import StringIO
import traceback

## import database configuration from parent directory
## config contains SQLalchemy engine and a few functions
import sys
sys.path.append('../config')
from databaseconfig import DB_ENGINE, truncate_and_load, distress_signal

## get last run datetime from log
with open('gspread.log', 'a+') as f:
    log = f.readline()
    if len(log) == 0:
        lastrun = LOCAL_TZ.localize(time_parser.parse('1900-01-01 00:00:00'))
    else:
        lastrun = LOCAL_TZ.localize(time_parser.parse(log))

## intialize gspread client
client = gspread.authorize(GDOCS_CREDENTIALS)

## get config spreadsheet
url = DOWNLOAD_CONFIG_URL
spreadsheet = client.open_by_url(url)
worksheet = spreadsheet.get_worksheet(0)
config_dict = exports = worksheet.get_all_records()

## create variable to contain tracebacks
traceback_email = ''
load_email = ''

conn = DB_ENGINE.connect()

## loop through each spreadsheet and download worksheets as CSV
for d in config_dict:    
    url = d['url']    
    start_sheet = d['start_sheet']
    end_sheet = d['end_sheet'] + 1
    start_row = d['start_row']
    tag = d['tag']        
    print tag    
    
    try:
        spreadsheet = client.open_by_url(url)                      
        for sheet in range(start_sheet, end_sheet):
            ## Google Docs uses UTC time, so timezone conversion is necessary
            worksheet = spreadsheet.get_worksheet(sheet)
            updated = time_parser.parse(worksheet.updated).astimezone(LOCAL_TZ)

            if updated > lastrun:
                clean_title = worksheet.title.lower().strip().replace(' ', '_')

                ## export data
                export = worksheet.export(format='csv')
                export_read = export.read()
                print '\tExporting', tag, clean_title

                ## load into DF
                df = pd.read_csv(StringIO(export_read), skiprows=start_row)
                nrows, ncols = df.shape

                ## truncate existing table and load new data into db
                if nrows > 0:
                    try:
                        table_name = 'AUTOLOAD$GDOCS_%s_%s' % (tag, clean_title)
                        print '\tLoading', table_name
                        truncate_and_load(DB_ENGINE, conn, df, table_name)
                    except:
                        print '\t!!! LOAD ERROR !!!'
                        load_email += '%s > %s\n' % (url, clean_title)
    except:
        print '!!! CONNECTION ERROR !!!'
        traceback_string = str(traceback.format_exc())
        traceback_email += "\"" + url + "\"" + '\n' + traceback_string + '\n'

## email any errors
if len(traceback_email) > 0:
    #print traceback_email
    distress_signal(DB_ENGINE, 'traceback', traceback_email)
if len(load_email) > 0:
    distress_signal(DB_ENGINE, 'load', load_email)

conn.close()

if len(traceback_email) == 0 and len(load_email) == 0:
    ## log run timestamp to logfile if fully successful
    with open('gspread.log', 'w+') as f:
        f.write(str(datetime.now()))

print '\nDone'
import os, traceback
from dateutil import parser as time_parser
import gspread
from StringIO import StringIO
import pandas as pd
import pymssql
from send_dbmail import distress_signal
from gspreadconfig import OAUTH_FILE, GDOCS_SCOPE, CONFIG_URL, LOCAL_TZ

## get last run datetime from log
## a+ will create the file if it doesn't already exist
with open('gspread.log', 'a+') as f:    
    logs = f.readlines()    
    ## if log is empty (e.g. first time), set it to a basic date (1900-01-01)        
    if len(logs) == 0:
        lastrun = '1900-01-01 00:00:00'
        lastrun = time_parser.parse(lastrun).replace(tzinfo=LOCAL_TZ)
    else:
        lastrun = logs[-1].strip()
        lastrun = time_parser.parse(lastrun).replace(tzinfo=LOCAL_TZ)
#print lastrun

## authenticate to GDocs
import json
from oauth2client.client import SignedJwtAssertionCredentials
oauth_file = OAUTH_FILE
oauth_key = json.load(open(oauth_file))
scope = [GDOCS_SCOPE]
gdocs_credentials = SignedJwtAssertionCredentials(oauth_key['client_email'], oauth_key['private_key'], scope)

## intialize gspread client
Client = gspread.authorize(gdocs_credentials)

## navigate to config spreadsheet
url = CONFIG_URL
Spreadsheet = Client.open_by_url(url)
Worksheet = Spreadsheet.get_worksheet(0)
config = Worksheet.export(format='csv').read()
## parse config and get unique list of folders
config_df = pd.read_csv(StringIO(config))
folders = config_df.folder.unique().tolist()
## create dict of config records
config_dict = config_df.to_dict(orient='records')

## open connection to database
## pymssql will use trusted Windows connections by default
## commit all transactions upon completion
from databaseconfig import DB_SERVER, DB_NAME
Connection = pymssql.connect(server=DB_SERVER, database=DB_NAME)
Connection.autocommit(True)

## set current directory as base
## create variable to contain tracebacks
base_dir = os.getcwd()
traceback_email = ''
load_email = ''

def get_worksheets(**kwargs):        
    ## unpack varibles from dict
    url = kwargs['url']    
    start_sheet = kwargs['start_sheet']
    end_sheet = kwargs['end_sheet'] + 1
    start_row = kwargs['start_row']
    tag = kwargs['tag']
    
    ## navigate to spreadsheet
    Spreadsheet = Client.open_by_url(url)

    ## loop over each worksheet
    for sheet in range(start_sheet, end_sheet):        
        ## get worksheet and last update time
        ## Google uses UTC time, so timezone conversion is necessary
        Worksheet = Spreadsheet.get_worksheet(sheet)
        updated = time_parser.parse(Worksheet.updated).astimezone(LOCAL_TZ)                        
        
        ## check if worksheet has been updated since last run. if so, then export                
        #print updated, updated > lastrun
        if updated > lastrun:            
            ## get worksheet name and clean up for filename
            title = Worksheet.title.lower().strip().replace(' ', '_')            
            filename = 'GDOCS_%s_%s.csv' % (tag, title)
            print '\tExporting', filename
            ## export worksheet as csv string
            export_csv = Worksheet.export(format='csv').read()
            ## pandas parse into dataframe
            ## csv object is a string, so StringIO must be passed
            export_df = pd.read_csv(StringIO(export_csv), skiprows=start_row)                        
            ## save as csv file
            export_df.to_csv(filename, index=False)
            counter = 1
        else:
            counter = 0
    return counter

## loop through spreadsheets, grouping by folder
for f in folders:    
    export_count = 0
    print f    
    
    ## if the destination folder exists, change to it. if not, create it
    dst_folder = '%s\\tmp\\%s' % (base_dir, f)
    if not os.path.exists(dst_folder):
        os.makedirs(dst_folder)
    os.chdir(dst_folder)
    
    ## get all records matching the current folder
    dicts = [config_dict[i] for i, d in enumerate(config_dict) if config_dict[i]['folder'] == f]
    
    ## loop through each spreadsheet and download worksheets as CSV
    for d in dicts:        
        try:
            counter = get_worksheets(**d)
            export_count += counter            
        ## if there's an exception raised, append it to string to be emailed        
        except:
            print '!!! EXPORT ERROR !!!'             
            traceback_string = str(traceback.format_exc())
            traceback_email += "\"" + d['url'] + "\"" + '\n' + traceback_string + '\n'

    if export_count > 0:
        ## load folder into database                
        try:            
            Cursor = Connection.cursor()
            query = r"EXEC sp_LoadFolder '%s', '%s'" % (DB_NAME, dst_folder)        
            print '\n', query
            Cursor.execute(query)
            print 'NARDO say:', str(Cursor.fetchall()[0][0]), '\n'        
        ## if there's an exception raised, append it to string to be emailed
        except:        
            print '!!! LOAD ERROR !!!'
            load_email += dst_folder + '\n'
    
    ## go back up to the top level
    os.chdir(base_dir)    

## email any errors
if len(traceback_email) > 0:
    #print traceback_email
    distress_signal('traceback', Connection, traceback_email)
if len(load_email) > 0:
    distress_signal('load', Connection, load_email)
    
## close database connection
Connection.close()

## log run timestamp to logfile
import logging
logger = logging.getLogger('gspread_logger')
logger.setLevel(logging.INFO)
## create file handler which logs even debug messages
fh = logging.FileHandler('gspread.log', mode='w+')
fh.setLevel(logging.INFO)
## create formatter and add it to the handlers
formatter = logging.Formatter('%(asctime)s', datefmt='%Y-%m-%d %H:%M:%S')
fh.setFormatter(formatter)
## add the handlers to logger
logger.addHandler(fh)
logger.info('')

print 'Done'

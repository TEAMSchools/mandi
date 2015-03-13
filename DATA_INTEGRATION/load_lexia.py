import pysftp
import pandas as pd
import os
import re
from datetime import date
from ftpconfig import LEXIA_HOST, LEXIA_USER, LEXIA_PASSWD

today = date.today().strftime('%m-%d-%Y') ## get today's date
findfiles = LEXIA_USER + '_' + today + '_(\d{4})(\w*).csv' ## create regex for filename

sftp = pysftp.Connection(LEXIA_HOST, username=LEXIA_USER, password=LEXIA_PASSWD) ## initialize connection to SFTP site
sftp.cwd('export') ## change to export directory

filelist = sftp.listdir() ## get a list of files in export directory
files = [] ## create empty list to append results
for f in filelist:
    m = re.match(findfiles, f) ## regex match on file list
    if m:
        files.append(m.string) ## append matches to results list

## change to destination folder
cwd = os.getcwd()
local_directory = cwd + '\\rawdata\\'
os.chdir(local_directory)

## download files to /rawdata
for f in files:
    sftp.get(f)

## load both files into a dataframe and append a datestamp
detail = pd.read_csv(files[0]) 
detail['import_date'] = date.today().strftime('%Y-%m-%d')
usage = pd.read_csv(files[1])
usage['import_date'] = date.today().strftime('%Y-%m-%d')

## move to db import folder, changing name to table name
usage.to_csv('../for_bob/LEXIA_usage.csv', index=False)
detail.to_csv('../for_bob/LEXIA_detail.csv', index=False)

## TODO: trigger SQL merge

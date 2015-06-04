import os, subprocess
import pandas as pd
from StringIO import StringIO

## go to GAM directory
os.chdir('C:\GAM')

## get accounts under /Students org and put into dataframe
cmd = r'gam print users query "orgUnitPath=/Students"'
students = subprocess.check_output(cmd)
accounts = pd.read_csv(StringIO(students))

## run roster query on NARDO and put results into dataframe
from db import DB
NARDO = DB(profile='NARDO')
query = """
    SELECT DISTINCT 'Test' AS firstname
          ,CASE WHEN enroll_status = 0 THEN school_name ELSE 'Disabled' END AS lastname      
          ,LOWER(CASE WHEN enroll_status = 0 THEN school_name ELSE 'Disabled' END + 'GAMtest' + '@teamstudents.org') AS email
          ,'testing123' AS password      
          ,CASE WHEN enroll_status = 0 THEN 'off' ELSE 'on' END AS suspended
          ,'/Students/' + CASE WHEN enroll_status = 0 THEN school_name ELSE 'Disabled' END AS org
    FROM KIPP_NJ..COHORT$identifiers_long#static WITH(NOLOCK)
    WHERE year = KIPP_NJ.dbo.fn_Global_Academic_Year()
      AND rn = 1
      AND STUDENT_WEB_ID IS NOT NULL
"""
all_students = NARDO.query(query)

## join the dataframes and create column indicating whether or not account already exists
import_roster = pd.merge(all_students, accounts, how='left', left_on='email', right_on='primaryEmail')
import_roster['exists'] = import_roster.primaryEmail.apply(pd.notnull)

## put the accounts that need to be created into one dataframe and the updates into another
create_roster = import_roster[import_roster.exists == False]
update_roster = import_roster[import_roster.exists == True]

## save as CSV
create_roster.to_csv('imports/createstudents.csv', index=False)
update_roster.to_csv('imports/updatestudents.csv', index=False)

## run the create command for the create df
createcmd = 'gam csv imports/createstudents.csv gam create user ~email firstname ~firstname lastname ~lastname password ~password suspended ~suspended org ~org'
subprocess.check_output(createcmd)

## run the update command for the update df
updatecmd = 'gam csv imports/updatestudents.csv gam update user ~email firstname ~firstname lastname ~lastname password ~password suspended ~suspended org ~org'
subprocess.check_output(updatecmd)

## print results
print str(len(create_roster)), 'created,', str(len(update_roster)), 'updated'
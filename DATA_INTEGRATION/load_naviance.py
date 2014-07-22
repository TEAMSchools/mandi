__author__ = 'CBini'

from mechanize import Browser
import pymssql
import json


"""
CONFIG
"""
# file paths
save_path = "W:\\data_robot\\naviance\\"
save_path_server = "C:\\data_robot\\naviance\\"

# login files
nav_secret = "W:\\data_robot\\logistical\\naviance_secret.json"
db_secret = "W:\\data_robot\\logistical\\nardo_secret.json"

# urls
LOGIN_URL = 'https://succeed.naviance.com/auth/signin'
EXPORT_URL = 'https://succeed.naviance.com/setupmain/export.php'

# db config
server_name = "WINSQL01\NARDO"
db_name = "KIPP_NJ"

# keys
keys = json.load(file(nav_secret))
nav_hsid = keys['HSID']
nav_user = keys['USERNAME']
nav_pass = keys['SECRET']

keys = json.load(file(db_secret))
db_user = keys['NARDO_USERNAME']
db_pass = keys['NARDO_PASSWORD']


"""
DOWNLOAD
"""
br = Browser()  # create a browser object
br.set_handle_robots(False)  # ignore robots.txt ...bad robot!
br.addheaders = [('User-agent', 'Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.9.0.1) Gecko/2008071615 Fedora/3.0.1-1.fc9 Firefox/3.0.1')]

# open the login page
br.open(LOGIN_URL)
br.select_form(name='login')
#set form values
br['hsid'] = nav_hsid
br['username'] = nav_user
br['password'] = nav_pass

#submit and store response
response = br.submit()
if response.code == 200:  # check that we're in
    print response.geturl() + ': Login success!'
else:
    print response.geturl() + ': Login FAILED! :('

#once logged in, navigate to export page
response = br.open(EXPORT_URL)
if response.code == 200:  # check that we're in
    print response.geturl() + ': Navigating to export page...'
else:
    print response.geturl() + ': Navigation FAILED!'

br.select_form(nr=0)
form = br.form

# create a list of report type values
control = form.find_control('type', type='select')
get_files = []
for item in control.items:
    get_files.append(item.name)
exclude = ['4', '5']  # exclude multi-column reports
get_files = list(set(get_files) - set(exclude))

# create a list of end_year values
control = form.find_control('end_year', type='select')
end_year = []
for item in control.items:
    end_year.append(item.name)

# export and save each report type
for item in get_files:
    # need to navigate back to export page after each iteration
    br.open(EXPORT_URL)
    br.select_form(nr=0)

    # ListControl, must set a sequence
    br.form['start_year'] = ['1900', ]
    br.form['end_year'] = [end_year.pop(), ]
    br.form['type'] = [item, ]
    response = br.submit()

    # extract file name from headers
    headers = response.info()
    fname_start = headers['Content-Disposition'].find('"')
    fname_end = headers['Content-Disposition'].find('.', fname_start)
    fname = headers['Content-Disposition'][(fname_start + 1):fname_end]
    data = response.read()
    print 'Now downloading... ' + fname

    # write the file with today's date stamp
    DEST_FILE = save_path + 'NAVIANCE_' + fname + '.csv'
    # for keeping a running record of files + '_' + datetime.now().strftime('%Y%m%d')
    with open(DEST_FILE, 'wb') as csv_file:
        csv_file.write(data)
print


"""
LOAD INTO DB
"""
print 'Connecting to SQL Server to load csv files into database...'
conn = pymssql.connect(server_name, db_user, db_pass, db_name)
cursor = conn.cursor()

query = "sp_LoadFolder '" + db_name + "', '" + save_path_server + "'"
print 'Running "EXEC ' + query + '"'
cursor.execute(query)

print 'NARDO say: ' + cursor.fetchall()[0][0]
conn.commit()
conn.close()

print
print 'All done! Have a great day!'

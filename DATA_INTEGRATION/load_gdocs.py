__author__ = 'CBini'

import os
import csv
import json
import gspread
import pymssql
import codecs
import cStringIO


"""
CONFIG
"""
# db config
server_name = "WINSQL01\NARDO"

# key files
gdocs_secret = "C:\\data_robot\\logistical\\gdocs_secret.json"
db_secret = "C:\\data_robot\\logistical\\nardo_secret.json"
config_path = "C:\\data_robot\\gdocs\\gdocs.csv"

# keys
keys = json.load(file(gdocs_secret))
gdocs_user = keys['GDOCS_USERNAME']
gdocs_pass = keys['GDOCS_PASSWORD']

keys = json.load(file(db_secret))
db_user = keys['NARDO_USERNAME']
db_pass = keys['NARDO_PASSWORD']


"""
A CSV writer which will write rows to CSV file "f",
which is encoded in the given encoding.
"""
class UnicodeWriter:
    def __init__(self, f, dialect=csv.excel, encoding="utf-8", **kwds):
        # Redirect output to a queue
        self.queue = cStringIO.StringIO()
        self.writer = csv.writer(self.queue, dialect=dialect, **kwds)
        self.stream = f
        self.encoder = codecs.getincrementalencoder(encoding)()

    def writerow(self, row):
        self.writer.writerow([s.encode("utf-8") for s in row])
        # Fetch UTF-8 output from the queue ...
        data = self.queue.getvalue()
        data = data.decode("utf-8")
        # ... and reencode it into the target encoding
        data = self.encoder.encode(data)
        # write to the target stream
        self.stream.write(data)
        # empty queue
        self.queue.truncate(0)

    def writerows(self, rows):
        for row in rows:
            self.writerow(row)

"""
DOWNLOAD
"""
# open config file
with open(config_path, 'rb') as f:
    next(f)  # skip header
    gdocs = csv.reader(f, delimiter=',')
    wkbk_list = []
    for record in gdocs:
        print record
        wkbk_list.append(record)
    print

client = gspread.login(gdocs_user, gdocs_pass)

# iterate over urls in config csv
for record in wkbk_list:
    url = record[0]
    tag = record[1]
    db_name = record[2]
    folder = record[3]
    start_sheet = int(record[4])
    end_sheet = int(record[5]) + 1  # range() will create a 0-indexed list of integers, so this adjusts for that
    start_row = int(record[6])

    # file paths
    save_path = "C:\\data_robot\\gdocs\\" + folder + "\\"
    

    print 'Navigating to ' + url
    workbook = client.open_by_url(url)
    print 'Now saving worksheets ' + str(start_sheet + 1) + ' through ' + str(end_sheet) + '...'
    print 'Getting worksheet names...'
    sheet_names = workbook.worksheets()
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
            writer = UnicodeWriter(f)
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
        print "!!! ERROR LOADING FOLDER !!!"
        print 'NARDO say: ' + cursor.fetchall()[0][0]
        continue

    print
    print 'Next workbook!'

print
print 'All done!'

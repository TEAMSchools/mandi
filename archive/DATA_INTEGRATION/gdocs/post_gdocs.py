import gspread
from db import DB
from gspreadconfig import GDOCS_CREDENTIALS, GDOCS_SCOPE, UPLOAD_CONFIG_URL

def get_col_letters(n):
    """
    Returns the ultimate column letter based on number of columns (n) 
    in the DataFrame
    """
    n = n - 1
    result = ''
    while n >= 0:
        remainder = n % 26
        result = chr(remainder + 65) + result;
        n = (n // 26) - 1
    return result

def post_df(df, wksht):
    """
    Takes a DataFrame and posts it to the active worksheet
    """
    ## build the update range, using df shape
    nrows, ncols = df.shape
    final_col = get_col_letters(ncols)
    
    ## post header
    if ncols > 0:
        columns = df.columns.values.tolist()
        header_range = wksht.range('A1:' + final_col + '1')
        for cell in header_range:
            val = columns[cell.col - 1]
            if type(val) is str:
                val = val.decode('utf-8')
            cell.value = val
        wksht.update_cells(header_range)
    
    ## post data
    if nrows > 0:                
        data_range = wksht.range('A2:' + final_col + str(nrows))
        for cell in data_range:            
            val = df.iloc[(cell.row - 2), (cell.col - 1)]
            if type(val) is str:
                val = val.decode('utf-8')
            elif val == None:
                val = ''
            cell.value = val
        wksht.update_cells(data_range)

## initialize DB object
db = DB(hostname='WINSQL01\NARDO', dbtype='mssql')
    
## authenticate to GDocs and intialize gspread client
client = gspread.authorize(GDOCS_CREDENTIALS)

## open config sheet and get all records
spreadsheet = client.open_by_url(UPLOAD_CONFIG_URL)
worksheet = spreadsheet.get_worksheet(0)
exports = worksheet.get_all_records()

for i, e in enumerate(exports):
    url = exports[i]['url']
    query = exports[i]['query']
    dest_sheet = exports[i]['dest_sheet']
    print exports[i]['descr']
    
    ## navigate to destination sheet    
    spreadsheet = client.open_by_url(url)        
    worksheet = spreadsheet.get_worksheet(dest_sheet)        
    
    ## query DB and put results into DataFrame
    df = db.query(query)

    ## post to destination sheet
    post_df(df, worksheet)

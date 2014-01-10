import pyodbc
import requests
import BeautifulSoup
import re
from string import printable

def make_db_conn():
    f = open("C:/data_robot/logistical/nardo_secret.txt", "r")
    secret = f.read()
    conn = pyodbc.connect(driver='{SQL Server}', server='WINSQL01\NARDO', database='DIY', uid='sa', pwd=secret)
    return conn

def query(query_str):
    conn  = make_db_conn()
    cursor = conn.cursor()
    cursor.execute(query_str)
    return [dict(zip([column[0] for column in cursor.description], row))
             for row in cursor.fetchall()]

def make_amazon_link(title, author):
    stem = 'http://www.amazon.com/s/rh=n%3A283155%2Ck%3A'
    auth = author
    #modify author
    auth_regex = re.compile('(.*),')
    auth_result = auth_regex.search(str(author))
    auth = not_none(auth_result)
    url = title + ' ' + author if auth == None else title + ' ' + auth

    url = url.replace(" ",'+')
    url = url.replace(",",'+')
    url = url.replace(".", '')
    url = filter(lambda x: x in printable, url)
    url = stem + url
    return url

def not_none(list):
    if not list == None:
        list = list.group(1)
    return list

def tversky_index(set_x, set_y, alpha, beta):
    x_intersect_y = len(set_x.intersection(set_y))

    x_minus_y_rel = len(set_x - set_y)
    y_minus_x_rel = len(set_y - set_x)
    #print('union: %s  x-y_rel: %s  y-x_rel: %s') %(x_union_y, x_minus_y_rel, y_minus_x_rel)

    denom = x_intersect_y + (alpha * x_minus_y_rel) + (beta * y_minus_x_rel)
    #print '%s   %s' %((alpha * x_minus_y_rel), (beta * y_minus_x_rel))
    tversky = x_intersect_y / float(denom)

    return(1-tversky)

def get_amazon_results(page, title_in, author_in, alpha, beta):
    soup = BeautifulSoup.BeautifulSoup(page)
    results = soup.find('div', {'id': 'atfResults'})
    top_result = results.find('div', {'id': 'result_0'})
    #extract isbn, author, title
    title_div = top_result.find('div', {'class': 'productTitle'})

    #isbn
    isbn_regex = re.compile("/dp/(\d{9}.)")
    isbn = isbn_regex.search(str(title_div))
    isbn = not_none(isbn)

    #title
    title_regex = re.compile('/dp/\d{9}.?">\s(.+?)</a>')
    title = title_regex.search(str(title_div))
    title = not_none(title)

    #author
    author_regex = re.compile('<span class="ptBrand">by\s(.+?)<')
    author = author_regex.search(str(title_div))
    author = not_none(author)
    #strip out link to author page if exists
    auth_page_regex = re.compile('<a\shref="/.+">(.+)')
    if not re.match(auth_page_regex, author) == None:
        author = auth_page_regex.search(author).group(1)

    tversky = None

    if not title == None:
        #print title.lower(), '||', title_in.lower()
        #print title.split()
        string1 = title_in.lower()
        string2 = title.lower()
        tversky = tversky_index(set(string1.split()), set(string2.split()), alpha, beta)
        tversky = round(tversky, 3)
        #jaccard = jaccard_distance(set(string1.split()), set(string2.split()))
        #print 't: %s , j: %s' % (tversky, jaccard)
    return [isbn, title, author, tversky]

#main loop that runs the sequence
def main():
    print '1. GETTING BOOKS'

    top_books = """
        SELECT sub.*
        FROM
              (SELECT ar.vchContentTitle AS title
                     ,ar.vchAuthor AS author
                     ,ar.iQuizNumber AS quiz_number
                     ,isbn.iQuizNumber AS isbn_test
                     ,COUNT(*) AS n
               FROM KIPP_NJ..AR$test_event_detail#static ar WITH (NOLOCK)
               LEFT OUTER JOIN RutgersReady..AR$ISBN isbn WITH (NOLOCK)
                 ON ar.iQuizNumber = isbn.iQuizNumber
               GROUP BY ar.vchContentTitle
                       ,ar.vchAuthor
                       ,ar.iQuizNumber
                       ,isbn.iQuizNumber
               ) sub
        WHERE n >= 1 
          AND isbn_test IS NULL
        ORDER BY n DESC"""

    books = query(top_books)

    print '2. GETTING ISBNs'

    tversky_alpha = 1
    tversky_beta = 0.3

    print 'tversky alpha: %s and beta: %s' % (tversky_alpha, tversky_beta)
    print

    result_list = []

    #initialize db and counter
    conn  = make_db_conn()
    cursor = conn.cursor()
    counter = 1

    for bk in books:
        url = make_amazon_link(bk['title'], bk['author'])

        print
        print '%s   %s' %(bk['title'], bk['author'])
        print url
        try:
            r = requests.get(url)
            az_results = get_amazon_results(r.text, title_in = bk['title'], author_in = bk['author'], alpha = tversky_alpha, beta = tversky_beta)
            for_db = [bk['quiz_number']] + az_results
            print for_db
            cursor.execute("INSERT INTO RutgersReady..AR$ISBN(iQuizNumber, isbn_10, lookup_title, lookup_author, match_confidence) VALUES (?, ?, ?, ?, ?)", (for_db[0], for_db[1], for_db[2], for_db[3], for_db[4]))
            result_list.append(for_db)
            if counter % 10 == 0:
                conn.commit()
                conn  = make_db_conn()
                cursor = conn.cursor()
                print
                print
                print '**** uploaded results, %s rows to date' %(counter)
                print
                print
            counter += 1
        except Exception, e:
            print 'FAILED: %s   %s' %(bk['title'], bk['author'])
            print e
            continue

    #put in db
    conn.commit()
    print result_list

##    for row in result_list:
##        print row
##        if counter % 10 == 0:
##            conn.commit()
##            conn  = make_db_conn()
##            cursor = conn.cursor()
##            print 'uploaded results'
##        cursor.execute("INSERT INTO RutgersReady..AR$ISBN(iQuizNumber, isbn_10, lookup_title, lookup_author, match_confidence) VALUES (?, ?, ?, ?, ?)", (row[0], row[1], row[2], row[3], row[4]))
##        counter += 1
        
    


if __name__ == '__main__':
    main()

#l = make_amazon_link('Outsiders, The', 'Hinton, S.E.')
#r = requests.get(l)
#az_results = get_amazon_results(r.text, 'Outsiders, The', 'Hinton, S.E.', 1, 0.3)
#soup = BeautifulSoup.BeautifulSoup(r.text)
#results = soup.find('div', {'id': 'atfResults'})
#top_result = results.find('div', {'id': 'result_0'})
#title_div = top_result.find('div', {'class': 'productTitle'})

import traceback
import pandas as pd
from bs4 import BeautifulSoup
import random
import requests
from requests.auth import HTTPProxyAuth
from urllib.parse import quote
import re
from flask import json

from books import Book, is_same_book
from catalog import add_book_sql

proxylist = pd.read_csv('gs://biblosphere-210106.appspot.com/proxylist.csv', sep='\t')


# Function to find book in ABEBOOK bookstore
def lookup_abebooks(bookspine, cursor, trace=False, isbn=None):
    if trace:
        print('Lookup Abebooks for [%s]' % bookspine)
    if isbn is not None:
        url = 'https://www.abebooks.com/servlet/SearchResults?kn=&pt=book&isbn=%s' % isbn
    else:
        url = 'https://www.abebooks.com/servlet/SearchResults?kn=%s&sortby=17&pt=book' % quote(bookspine)

    if trace:
        print('URL:', url)

    soup = getAndParseURL(url)
    book_soup = soup.find("div", attrs={"id": "book-1"})

    if book_soup is None:
        if trace:
            print('Book not found in Abebooks')
        return None, False

    # <meta content="9780979862250" itemprop="isbn">
    isbn = book_soup.find('meta', attrs={"itemprop": "isbn"})
    if isbn is not None:
        isbn = isbn.get('content')
        if trace:
            print('ISBN:', isbn)
    else:
        if trace:
            print('ISBN missing for book in Abebooks:', bookspine)
        return None, False

    # <meta content="Title" itemprop="name">
    title = book_soup.find('meta', attrs={"itemprop": "name"})
    if title is not None:
        title = title.get('content')
    else:
        title = ''

    if trace:
        print('Title:', title)

    # <meta content="Author" itemprop="author"/>
    author = book_soup.find('meta', attrs={"itemprop": "author"})
    if author is not None:
        author = author.get('content')
    else:
        author = ''

    if trace:
        print('Author:', author)

    # <img class="srp-item-image"> src
    cover = book_soup.find('img', class_="srp-item-image")
    if cover is not None:
        cover = cover.get('src')
    else:
        cover = ''

    if trace:
        print('Image:', cover)

    if isbn is not None and (title is not None or author is not None):
        book = Book(isbn, title, author, cover)

        # Add book to Biblospere DB anyway
        add_book_sql(cursor, book)

        if is_same_book(title + ' ' + author, bookspine, trace=trace):
            return book, True
        else:
            if trace:
                print('Found book do not match with bookspine:', bookspine, title + ' ' + author)
            return book, False

    return None, False


# Function to find book in LIVELIB website
def lookup_livelib(bookspine, cursor, trace=False):
    if trace:
        print('Lookup Livelib for [%s]' % bookspine)

    url = 'https://www.livelib.ru/find/books/%s' % quote(bookspine)

    if trace:
        print('URL:', url)

    soup = getAndParseURL(url)
    # if trace:
    #    print('SEARCH RESULTS')
    #   print(soup)

    # <div class="object-wrapper object-edition ll-redirect-book" data-link="/book/1000939900-zelenyj-drajver-kod-k-ekologichnoj-zhizni-v-gorode-roman-sablin">
    book_ref_soup = soup.find("div", class_="object-wrapper object-edition ll-redirect-book")
    if book_ref_soup is None:
        if trace:
            print('BOOK LINK MISSED')
            print(soup)
        return None

    link = book_ref_soup.get('data-link')
    if link is None:
        return None

    url = 'https://www.livelib.ru' + link

    if trace:
        print('Book URL:', url)

    soup = getAndParseURL(url)
    # if trace:
    #    print('BOOK PAGE')
    #    print(soup)

    # <div class="block-border card-block">
    book_soup = soup.find("div", class_="block-border card-block")

    if trace:
        print('BOOK PAGE')
        print(book_soup)

    if book_soup is None:
        return None, False

    # <span itemprop="isbn">
    isbn = book_soup.find('span', attrs={"itemprop": "isbn"})
    if isbn is not None:
        isbn = isbn.text.strip()
        if isbn is not None:
            isbn = re.sub('[^0-9]', '', isbn)
        if trace:
            print('ISBN:', isbn)
    else:
        if trace:
            print('ISBN not found on livelib for:', bookspine)
        return None, False

    # <span itemprop="name">Зеленый драйвер. Код к экологичной жизни в городе</span>
    title = book_soup.find('span', attrs={"itemprop": "name"})
    if title is not None:
        title = title.text.strip()
    else:
        title = ''

    if trace:
        print('Title:', title)

    # <a id="book-author" href="/author/503964-roman-sablin" title="Роман Саблин">Роман Саблин</a>
    author = book_soup.find('a', attrs={"id": "book-author"})
    if author is not None:
        author = author.text.strip()
    else:
        author = ''

    if trace:
        print('Author:', author)

    # <img id="main-image-book"
    cover = book_soup.find('img', attrs={"id": "main-image-book"})
    if cover is not None:
        cover = cover.get('src')
    else:
        cover = ''

    if trace:
        print('Image:', cover)

    if isbn is not None and (title is not None or author is not None):
        book = Book(isbn, title, author, cover)

        # Add book to Biblospere DB anyway
        add_book_sql(cursor, book)

        if is_same_book(title + ' ' + author, bookspine, trace=trace):
            return book, True
        else:
            if trace:
                print('Found book do not match with bookspine:', bookspine, title + ' ' + author)
            return book, False

    elif trace:
        print('Book record incomplete on Livelib for:', bookspine)

    return None, False


# Function to find book in OZON bookstore
def lookup_ozon(bookspine, cursor, trace=False):
    if trace:
        print('Lookup Ozon for [%s]' % bookspine)

    url = 'https://www.ozon.ru/category/knigi-16500/?text=%s' % quote(bookspine)

    if trace:
        print('URL:', url)

    soup = getAndParseURL(url)
    if trace:
        print('SEARCH RESULTS')
        print(soup)

    # <a data-test-id="tile-name"
    book_ref_soup = soup.find("div", attrs={"type": "action"})
    if book_ref_soup is None:
        if trace:
            print('BOOK LINK MISSED')
            # print(soup)
        return None, False

    link = book_ref_soup.get('tileLink')
    if link is None:
        print('BOOK LINK ATTRIBUTE MISSED')
        return None, False

    url = 'https://www.ozon.ru' + link

    if trace:
        print('Book URL:', url)

    soup = getAndParseURL(url)
    # if trace:
    #    print('BOOK PAGE')
    #    print(soup)

    # <h1 class="b6i0" data-v-41940272><span>
    book_header = soup.find("h1")
    if book_header is not None:
        title = book_header.span.text
        author = ''
        title, author = split_title(title)

    if trace:
        print('Author: %s, Title: %s' % (author, title))

    # <meta data-n-head="true" data-hid="property::og:image" content="https://cdn1.ozone.ru/multimedia/1019366563.jpg" property="og:image">
    cover = soup.find('meta', attrs={"property": "og:image"})
    if cover is not None:
        cover = cover.get('content')
    else:
        cover = ''

    if trace:
        print('Image:', cover)

    isbn = None
    # <div id="section-characteristics"
    book_details = soup.find("div", attrs={"id": "section-characteristics"})
    if book_details is not None:
        # print('Details found: ', book_details)
        spans = book_details.find_all('span')
        for s in spans:
            if s.text == 'Автор':
                dd = s.find_next('dd')
                if dd is not None:
                    a = dd.text
                    if a is not None:
                        # print('Author found: ', a)
                        author = a
            elif s.text == 'Автор на обложке' and author == '':
                dd = s.find_next('dd')
                if dd is not None:
                    a = dd.text
                    if a is not None:
                        # print('Author found: ', a)
                        author = a
            elif s.text == 'ISBN':
                dd = s.find_next('dd')
                if dd is not None:
                    if dd.text is not None:
                        isbn = re.sub('[^0-9\,]', '', dd.text).split(',')[0]
                        # print('ISBN parsed: ', book.isbn)

    if isbn is not None and (title is not None or author is not None):
        book = Book(isbn, title, author, cover)

        # Add book to Biblospere DB anyway
        add_book_sql(cursor, book)

        if is_same_book(title + ' ' + author, bookspine, trace=trace):
            return book, True
        else:
            if trace:
                print('Found book do not match with bookspine:', bookspine, title + ' ' + author)
            return book, False

    elif trace:
        print('Book record incomplete on Ozon for:', bookspine)

    return None, False


# Split title and author separated by |
def split_title(str):
    m = re.compile("(.*)\|(.*)")
    g = m.search(str)
    if g:
        title = g.group(1).rstrip()
        author = g.group(2).lstrip()
    else:
        title = str
        author = ''
    return title, author


############################################################################################
# Google Books search (books.google.com)
#
############################################################################################
def parse_google(data, trace=False):
    author, title, isbn, image = '', '', '', ''
    volume = data['volumeInfo']
    if 'title' in volume:
        title = volume['title']
        if trace:
            print('Title:', title)

    if 'authors' in volume:
        author = ';'.join(volume['authors'])
        if trace:
            print('Authors:', author)

    if 'imageLinks' in volume and 'thumbnail' in volume['imageLinks']:
        image = volume['imageLinks']['thumbnail']
        if trace:
            print('Image:', image)

    if 'industryIdentifiers' in volume:
        ids = [id['identifier'] for id in volume['industryIdentifiers'] if id['type'] == 'ISBN_13']
        if len(ids) > 0:
            isbn = ids[0]
            if trace:
                print('ISBN:', isbn)

    if 'language' in volume:
        language = volume['language']
        if trace:
            print('Language:', language)

    return Book(isbn, title, author, image, language)


# Google Book search
def search_google_by_isbn(isbn, cursor, trace=False):
    try:
        api_key = 'AIzaSyDJR_BnU_JVJyGTfaWcj086UuQxXP3LoTU'
        uri = 'https://www.googleapis.com/books/v1/volumes?q=isbn:%s&key=%s&printType=books' % (isbn, api_key)
        res = requests.get(uri)

        # print(res.content)
        data = json.loads(res.content)
        # print(data)

        if data['totalItems'] > 0:
            book = parse_google(data['items'][0], trace)

            if len(book.title) > 0 or len(book.author) > 0:
                # Add book to Biblospere DB
                add_book_sql(cursor, book)
                return book

        return None
    except Exception as e:
        print('Exception occured:', e)
        traceback.print_exc()
        return None


def search_google_by_titleauthor(text, cursor, trace=False):
    try:
        api_key = 'AIzaSyDJR_BnU_JVJyGTfaWcj086UuQxXP3LoTU'
        uri = 'https://www.googleapis.com/books/v1/volumes?q=%s&key=%s&printType=books' % (quote(text), api_key)
        res = requests.get(uri)

        if trace:
            print(res.content)

        data = json.loads(res.content)

        if trace:
            print(data)

        if 'totalItems' in data and data['totalItems'] > 0:
            books = [parse_google(b, trace) for b in data['items']]
            books = [b for b in books if len(b.isbn) > 0 and (len(b.title) > 0 or len(b.authors) > 0)]

            # Add books to Biblospere DB
            for b in books:
                add_book_sql(cursor, b)

            return books
        else:
            return []

    except Exception as e:
        print('Exception occured:', e)
        traceback.print_exc()
        return []


############################################################################################
# RSL search (search.rsl.ru)
#
############################################################################################
def search_rsl_by_isbn(isbn, cursor, trace=False):
    books = search_rsl('isbn:%s' % isbn, cursor, limit=1, trace=False)
    if books is not None and len(books) > 0:
        return books[0]
    else:
        return None


# RSL search by title author
def search_rsl_by_titleauthor(text, cursor, trace=False):
    books = search_rsl(quote(text), cursor, trace=trace)
    if books is not None:
        return books
    else:
        return []


def parse_rsl(soup, trace=False):
    author, title, isbn, image = '', '', '', ''
    author_el = soup.find('b', class_='js-item-authorinfo')
    if author_el is not None:
        author = author_el.text
        if trace:
            print('Author:', author)

    main_el = soup.find('span', class_='js-item-maininfo')
    if main_el is not None:
        if trace:
            print('Main text:', main_el.text)
        match = re.match('^([^\[]+)', main_el.text)
        if match is not None:
            title = match[0]
            if trace:
                print('Title:', title)

        match = re.findall('ISBN\s+([-0-9]+)', main_el.text)
        if match is not None and len(match) > 0:
            isbn = match[0].replace('-', '')
            if trace:
                print('ISBN:', isbn)

    img_el = soup.find('img', class_='js-cover-image')
    if img_el is not None:
        image = img_el.get('src')
        image = 'https://search.rsl.ru' + image

    return Book(isbn, title, author, image)


def search_rsl(text, cursor, limit=None, trace=False):
    # Two requests needed. One to get CSRF cookie and second one to make a query.
    # Undocumented API reverse-engineered from search.rsl.ru/ru/search
    author, title = None, None
    try:
        headers = {
            'Upgrade-Insecure-Requests': '1',
        }

        uri = 'https://search.rsl.ru/ru/search'
        res = requests.get(uri, headers=headers)

        cookie = res.headers['set-cookie']
        # print('Raw cookies:', cookie)

        # Clean cookies from additional attributes
        matched_cookies = re.findall(r'([_a-zA-Z0-9]+)=([^,;]+);\s(expires=[^;]+;)*[^,]+(,|$)', cookie)

        # print('Response cookies:', matched_cookies)

        clean_cookie = [s[0] + '=' + s[1] for s in matched_cookies]
        # print('Clean cookies:', clean_cookie)

        body = str(res.content)

        tag = body.find('csrf-token')
        if tag != -1:
            start = body.find('"', tag + 11) + 1
            end = body.find('"', start)
            token = body[start:end]
            # print('CSRF token found:', token)

        uri = 'https://search.rsl.ru/site/ajax-search'
        headers = {
            'Content-Type': 'application/x-www-form-urlencoded',
            'Accept': 'application/json, text/javascript, */*; q=0.01',
            # 'X-CSRF-Token': token,
            'Origin': 'https://search.rsl.ru',
            'User-Agent':
                'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/74.0.3729.108 Safari/537.36',
            'Accept-Language':
                'en-GB,en;q=0.9,ru-RU;q=0.8,ru;q=0.7,ka-GE;q=0.6,ka;q=0.5,en-US;q=0.4',
            'Accept-Encoding': 'gzip, deflate, br',
            'Cookie': ';'.join(clean_cookie) + ';'
        }

        body = 'SearchFilterForm[search]=%s&_csrf=%s' % (text, quote(token))

        # Use Request to control Content-Type header. Client.post add charset to it
        # which does not work with RSL
        res_body = requests.post(uri, data=body, headers=headers)

        if not res_body.ok:
            print('HTTP error:', res_body.status_code, res_body._content)
            return None

        body = res_body.content

        # print('Response body:', body)

        res_json = json.loads(body)
        # print('Response json:', res_json)

        res_str = res_json['content']
        soup = BeautifulSoup(res_str, 'html.parser')

        # if trace:
        #    print('Response soup:', soup)

        # Find all sections with books
        book_els = soup.find_all('div', class_='search-item p10')

        if trace:
            print('%d books found' % len(book_els))

        books = [parse_rsl(b, trace=trace) for b in book_els]
        books = [b for b in books if b.isbn != '' and (b.title != '' or b.authors != '')]

        # Check if image is exist (rsl always return 404 for images)
        # So to check if image is there we use content type
        for b in books:
            if b.image != '':
                res_head = requests.head(b.image)
                if res_head.headers['Content-Type'] != 'image/jpeg':
                    b.image = ''

        # Add books to Biblospere DB
        for b in books:
            add_book_sql(cursor, b)

        if limit is not None:
            return books[:limit]
        else:
            return books

    except Exception as e:
        print('Exception occured:', e)
        traceback.print_exc()
        return None


# Get a page from the URL via proxy
def getAndParseURL(url):
    i = random.randint(0, 99)
    # print('Proxy used: ', i)
    # proxies = {"http":proxylist['ip'][i]+':'+str(proxylist['port'][i]), "https":proxylist['ip'][i]+':'+str(proxylist['port'][i])}
    proxies = {"http": proxylist['ip'][i] + ':' + str(proxylist['port'][i])}
    auth = HTTPProxyAuth(proxylist['name'][i], proxylist['password'][i])

    result = requests.get(url, proxies=proxies, auth=auth)
    soup = BeautifulSoup(result.content, 'html.parser')
    return (soup)

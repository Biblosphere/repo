# Functions to work with MySQL book catalog
# - Search by ISBN
# - Search by words
# - Add catalog entry
from books import Book

lang_codes = {
    'ab': 'abk',
    'aa': 'aar',
    'af': 'afr',
    'ak': 'aka',
    'sq': 'sqi',
    'am': 'amh',
    'ar': 'ara',
    'an': 'arg',
    'hy': 'hye',
    'as': 'asm',
    'av': 'ava',
    'ae': 'ave',
    'ay': 'aym',
    'az': 'aze',
    'bm': 'bam',
    'ba': 'bak',
    'eu': 'eus',
    'be': 'bel',
    'bn': 'ben',
    'bh': 'bih',
    'bi': 'bis',
    'bs': 'bos',
    'br': 'bre',
    'bg': 'bul',
    'my': 'mya',
    'ca': 'cat',
    'ch': 'cha',
    'ce': 'che',
    'ny': 'nya',
    'zh': 'zho',
    'cv': 'chv',
    'kw': 'cor',
    'co': 'cos',
    'cr': 'cre',
    'hr': 'hrv',
    'cs': 'ces',
    'da': 'dan',
    'dv': 'div',
    'nl': 'nld',
    'dz': 'dzo',
    'en': 'eng',
    'eo': 'epo',
    'et': 'est',
    'ee': 'ewe',
    'fo': 'fao',
    'fj': 'fij',
    'fi': 'fin',
    'fr': 'fra',
    'ff': 'ful',
    'gl': 'glg',
    'ka': 'kat',
    'de': 'deu',
    'el': 'ell',
    'gn': 'grn',
    'gu': 'guj',
    'ht': 'hat',
    'ha': 'hau',
    'he': 'heb',
    'hz': 'her',
    'hi': 'hin',
    'ho': 'hmo',
    'hu': 'hun',
    'ia': 'ina',
    'id': 'ind',
    'ie': 'ile',
    'ga': 'gle',
    'ig': 'ibo',
    'ik': 'ipk',
    'io': 'ido',
    'is': 'isl',
    'it': 'ita',
    'iu': 'iku',
    'ja': 'jpn',
    'jv': 'jav',
    'kl': 'kal',
    'kn': 'kan',
    'kr': 'kau',
    'ks': 'kas',
    'kk': 'kaz',
    'km': 'khm',
    'ki': 'kik',
    'rw': 'kin',
    'ky': 'kir',
    'kv': 'kom',
    'kg': 'kon',
    'ko': 'kor',
    'ku': 'kur',
    'kj': 'kua',
    'la': 'lat',
    'lb': 'ltz',
    'lg': 'lug',
    'li': 'lim',
    'ln': 'lin',
    'lo': 'lao',
    'lt': 'lit',
    'lu': 'lub',
    'lv': 'lav',
    'gv': 'glv',
    'mk': 'mkd',
    'mg': 'mlg',
    'ms': 'msa',
    'ml': 'mal',
    'mt': 'mlt',
    'mi': 'mri',
    'mr': 'mar',
    'mh': 'mah',
    'mn': 'mon',
    'na': 'nau',
    'nv': 'nav',
    'nd': 'nde',
    'ne': 'nep',
    'ng': 'ndo',
    'nb': 'nob',
    'nn': 'nno',
    'no': 'nor',
    'ii': 'iii',
    'nr': 'nbl',
    'oc': 'oci',
    'oj': 'oji',
    'cu': 'chu',
    'om': 'orm',
    'or': 'ori',
    'os': 'oss',
    'pa': 'pan',
    'pi': 'pli',
    'fa': 'fas',
    'pl': 'pol',
    'ps': 'pus',
    'pt': 'por',
    'qu': 'que',
    'rm': 'roh',
    'rn': 'run',
    'ro': 'ron',
    'ru': 'rus',
    'sa': 'san',
    'sc': 'srd',
    'sd': 'snd',
    'se': 'sme',
    'sm': 'smo',
    'sg': 'sag',
    'sr': 'srp',
    'gd': 'gla',
    'sn': 'sna',
    'si': 'sin',
    'sk': 'slk',
    'sl': 'slv',
    'so': 'som',
    'st': 'sot',
    'es': 'spa',
    'su': 'sun',
    'sw': 'swa',
    'ss': 'ssw',
    'sv': 'swe',
    'ta': 'tam',
    'te': 'tel',
    'tg': 'tgk',
    'th': 'tha',
    'ti': 'tir',
    'bo': 'bod',
    'tk': 'tuk',
    'tl': 'tgl',
    'tn': 'tsn',
    'to': 'ton',
    'tr': 'tur',
    'ts': 'tso',
    'tt': 'tat',
    'tw': 'twi',
    'ty': 'tah',
    'ug': 'uig',
    'uk': 'ukr',
    'ur': 'urd',
    'uz': 'uzb',
    've': 'ven',
    'vi': 'vie',
    'vo': 'vol',
    'wa': 'wln',
    'cy': 'cym',
    'wo': 'wol',
    'fy': 'fry',
    'xh': 'xho',
    'yi': 'yid',
    'yo': 'yor',
    'za': 'zha',
    'zu': 'zul',
}

select_query = "SELECT title, authors, image, genre, lang, description FROM prints WHERE isbn=%s"
insert_query = "INSERT IGNORE INTO prints (isbn, title, authors, image, lexems, genre, lang, description) VALUES (%s, %s, %s, %s, %s, %s, %s, %s)"
update_query = "UPDATE prints SET title=%s, authors=%s, image=%s, lexems=%s, genre=%s, lang=%s, description=%s WHERE isbn=%s"
select_tags = "SELECT tag FROM tags WHERE isbn=%s"
insert_tags = 'INSERT IGNORE INTO tags(isbn, tag) VALUES (%s, %s)'
select_tags_like = "SELECT DISTINCT tag FROM tags WHERE tag LIKE %s LIMIT 100"


# Function to get list of the tags by starting symbols
def get_tag_list(cursor, query, trace=False):
    # Query tags with given starting
    cursor.execute(select_tags_like, (query+'%',))
    results = cursor.fetchall()

    return [r[0] for r in results]


# Function to get book from MySQl by ISBN
def get_book_sql(cursor, isbn, tags=False, trace=False):
    # Check if book with such ISBN exist
    cursor.execute(select_query, (isbn,))
    results = cursor.fetchall()

    if len(results) > 0:
        book = Book(isbn, results[0][0], results[0][1], results[0][2], genre=results[0][3], \
                    language=results[0][4], description=results[0][5])

        # Query tags for this book if requested
        if tags:
            cursor.execute(select_tags, (isbn,))
            results = cursor.fetchall()
            book.tags = [r[0] for r in results]

        return book

    return None


# Function to add book to MySQl
def add_book_sql(cursor, book, trace=False):
    search_words = ' '.join(book.keys)

    # Check if book with such ISBN exist
    cursor.execute(select_query, (book.isbn,))
    results = cursor.fetchall()

    # Insert if missing
    if len(results) == 0:
        cursor.execute(insert_query, (book.isbn, book.title, book.authors, book.image, search_words, book.genre, book.language, book.description))
    # Update if some information missing in the record
    elif (results[0][0] == '' and book.title != '') \
            or (results[0][1] == '' and book.authors != '') \
            or (results[0][2] == '' and book.image != '') \
            or (results[0][3] == '' and book.genre != '') \
            or (results[0][4] == '' and book.language != '') \
            or (results[0][5] == '' and book.description != ''):
        if book.title == '':
            book.title = results[0][0]
        if book.authors == '':
            book.authors = results[0][1]
        if book.image == '':
            book.image = results[0][2]
        if book.genre == '':
            book.genre = results[0][3]
        if book.language == '':
            book.language = results[0][4]
        if book.description == '':
            book.description = results[0][5]
        cursor.execute(update_query, (book.title, book.authors, book.image, search_words, book.genre, book.language, book.description, book.isbn))

    # Add tags if any
    if len(book.tags) > 0:
        val = [(book.isbn, tag) for tag in book.tags]
        cursor.execute(insert_tags, val)


# MySQL query to search for books
search_query = "SELECT isbn, title, authors, image, MATCH (lexems), genre, lang, description AGAINST (? IN BOOLEAN MODE) AS score FROM prints" \
               " WHERE MATCH (lexems) AGAINST (? IN BOOLEAN MODE) ORDER BY score DESC limit 5"


# Function to find book by words
def find_book(cursor, words, trace=False):
    # Only match by words longer than two letters
    words = set([w for w in words if len(w) > 2])

    if len(words) < 1:
        return None, []

    str_words = ' '.join(words)
    if trace:
        print('Call MqSQL with:', str_words)
    cursor.execute(search_query, (str_words, str_words,))

    results = cursor.fetchall()
    if trace:
        print(results)

    # Nothing found
    if len(results) == 0:
        return None, []

    # Get top score and top results
    max_score = results[0][4]
    top_results = [r for r in results if r[4] == max_score]

    # List of books with same top score
    top_books = [Book(isbn, title, authors, image, genre=genre, language=language, description=description) for isbn, title, authors, image, score, genre, language, description in top_results]

    # Find the shortest book among the top ones
    res_len = [len(r[1]) + len(r[2]) for r in top_results]
    i = res_len.index(min(res_len))
    book = top_books[i]

    if trace:
        print('%d book(s) found (%.2f)' % (len(top_books), max_score), [b.title for b in top_books])

    return book, top_books

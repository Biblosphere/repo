import re

from tools import lexems


class Book:
    def __init__(self, isbn, title, authors, image='', language='', cover_text='',
                 back_text='', tags='', genre='', description=''):
        self.isbn = isbn
        self.title = title
        self.authors = authors
        self.image = image
        self.language = language
        self.cover_text = cover_text
        self.back_text = back_text
        self.tags = tags
        self.genre = genre
        self.description = description
        self.keys = lexems(title + ' ' + authors, full=True)

    @classmethod
    def from_json(cls, obj):
        return cls(obj['isbn'], obj['title'], obj['authors'], obj['image'])

    def catalog_title(self):
        return self.title + ' ' + self.authors

# Check if two strings are the same book title
def is_same_book(catalog_title, bookspine, top=5, trace=False):
    m, p, i, d = alignment_score(catalog_title, bookspine)

    if trace:
        print('-------------------------------------------------')
        print('TITLE:', catalog_title)
        print('BOOKSPINE:', bookspine)
        print('Matches (%d), Permutations (%d), Insertions (%d), Deletions (%d):' % (m, p, i, d))

    # TODO: Euristic criteria. Needs to improve
    # top: give +1 score if it only one book in a top list in DB
    return m >= 3 and p <= 3 and i <= 3 and m - p/2 - i/3 + (5-top)/4 > 2 or \
        m >= 2 and p == 0 and i == 0 and d <= 1


def alignment_score(sent1, sent2, trace=False):
    s1 = lexems(sent1)
    s2 = lexems(sent2)

    isect1 = [w for w in s1 if w in s2]
    isect2 = [w for w in s2 if w in s1]

    # Number of words coinside both sentenses
    matches = min(len(isect1), len(isect2))
    if trace:
        print('Strings after deletion/insertion:', isect1, isect2)

    r1 = group(isect1, isect2)
    r2 = group(isect2, isect1)

    if trace:
        print('Strings after first grouping:', r1, r2)

    # Repeat check for deletion/insertion as it might be duplicated words (The The)
    isect1 = [w for w in r1 if w in r2]
    isect2 = [w for w in r2 if w in r1]

    if trace:
        print('Strings after second deletion/insertion:', isect1, isect2)

    r1 = group(isect1, isect2)
    r2 = group(isect2, isect1)

    if trace:
        print('Strings after second grouping:', r1, r2)

    # Count deletions and insertions
    permutations = max(len(r1), len(r2)) - 1
    deletions = count_missing(s1, r1)
    insertions = count_missing(s2, r2)

    return matches, permutations, insertions, deletions


def group(s1, s2):
    r1 = []
    i = 0
    while i < len(s1):
        w = s1[i]
        # For each entry in s2 find the longest matching sequence
        max_seq = 1
        for j in [n for n, w1 in enumerate(s2) if w1 == w]:
            seq = 1
            while i + seq < len(s1) and j + seq < len(s2) and s1[i + seq] == s2[j + seq]:
                seq += 1
            max_seq = max(seq, max_seq)
        r1.append(' '.join(s1[i:i + max_seq]))
        i += max_seq

    return r1


def count_missing(s1, r1):
    deletions = 0
    trunc1 = (' '.join(r1)).split()

    in_missing = False
    for w in s1:
        # For missing word find whole missing sequence words
        if w not in trunc1:
            if not in_missing:
                deletions += 1
                in_missing = True
        else:
            if in_missing:
                in_missing = False

    return deletions


def has_cyrillic(text):
    return bool(re.search('[а-яА-Я]', text))

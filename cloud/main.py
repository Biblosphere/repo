import re
import os
import cv2
import traceback
import numpy as np
import mysql.connector
import geohash2
from math import pi, sin, cos, atan2, sqrt
from fuzzywuzzy import process, fuzz
from google.cloud import storage, pubsub, exceptions
from flask import jsonify, abort, json
from functools import wraps
from collections import Counter

from tools import imread_blob, ocr_url, ocr_image, convex_for_points, line_angle, distance_to_line, d, \
    center_for_points, box_angle, box_for_words, lexems, lexem, rotate_points, diff_angle, \
    is_overlap, minrect_area, in_section, rotate
from books import is_same_book, has_cyrillic, Book
from catalog import list_books, find_book, add_book_sql, get_book_sql, lang_codes, get_tag_list

import firebase_admin
from firebase_admin import credentials
from firebase_admin import firestore
from firebase_admin import messaging

# Image resize for the thumbnail
from wand.image import Image

#TODO:AVEA - don't merge
#client = storage.Client()
client = storage.Client.from_service_account_json('venv\\keys\\biblosphere-210106-dcfe06610932.json')

# Use the application default credentials
# TODO: Only initialize it for add_user_books(_from_image_sub) functions which use Firestore (Performance)
cred = credentials.ApplicationDefault()
firebase_admin.initialize_app(cred, {
  'projectId': 'biblosphere-210106',
})
#TODO:AVEA - don't merge
#db = firestore.client()

# TODO: Get the client only in function which needs it. Make empty global variable and check it (Performance)
#TODO:AVEA - don't merge
#publisher = pubsub.PublisherClient()

# Function to generate thumbnails for the book shelves
# Deploy with:
# gcloud functions deploy thumbnail_image --runtime python37 --trigger-bucket gs://biblosphere-210106.appspot.com --memory=512MB
THUMBNAIL_PREFIX = "thumbnails/"

def thumbnail_image(data, context):
    #print('DEBUG: Image uploaded:', data)

    # Don't generate a thumbnail for a thumbnail
    if data['name'].startswith(THUMBNAIL_PREFIX):
        return

    # Only process images in image folder
    if not data['name'].startswith('images/'):
        return

    # Only run for JPEG images
    if data['name'][-4:] != '.jpg':
        return

    thumbnail_name = THUMBNAIL_PREFIX + data['name'][7:]

    # Get the bucket which the image has been uploaded to
    bucket = client.get_bucket(data['bucket'])

    # Download the image and resize it
    thumbnail = Image(blob=bucket.get_blob(data['name']).download_as_string())
    thumbnail.resize(thumbnail.width // 5, thumbnail.height // 5)

    #print('DEBUG: Image loaded')

    # Upload the thumbnail with the filename prefix
    thumbnail_blob = bucket.blob(thumbnail_name)
    thumbnail_blob.upload_from_string(thumbnail.make_blob(), 'image/jpeg')
    thumbnail_blob.make_public()

    #print('DEBUG: Thumbnail stored %s' % thumbnail_name)


# Function to send FCM notification message for new chat message
# Deploy with:
# gcloud functions deploy send_notification --runtime python37 --trigger-event providers/cloud.firestore/eventTypes/document.create --trigger-resource 'projects/biblosphere-210106/databases/(default)/documents/messages/{chatId}/{chatCollectionId}/{msgId}'
# gcloud functions logs read send_notification
def send_notification(data, context):
    path_parts = context.resource.split('/documents/')[1].split('/')
    collection_path = path_parts[0]
    document_path = '/'.join(path_parts[1:])
    chat_id = path_parts[1]

    #print('!!!DEBUG: Chat id: ', chat_id)
    #print('!!!DEBUG: Message path: ', collection_path, document_path)

    message = db.collection(collection_path).document(document_path).get().to_dict()
    user_to = db.collection('users').document(message['idTo']).get().to_dict()
    user_from = db.collection('users').document(message['idFrom']).get().to_dict()

    notification = messaging.Message(
        token=user_to['token'],
        notification=messaging.Notification(
            title='Chat message',
            body='Message from ' + user_from['name']
        ),
        data={
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'event': 'new_message',
            'chat': chat_id,
        })

    response = messaging.send(notification)
    # Response is a message ID string.
    print('Successfully sent message:', response)


# Function to calculate distance between two geo-points
def distance_between(p1, p2):
    lat1, lon1 = p1.latitude, p1.longitude
    lat2, lon2 = p2.latitude, p2.longitude

    r = 6378.137 # Radius of earth in KM
    d_lat = lat2 * pi / 180 - lat1 * pi / 180
    d_lon = lon2 * pi / 180 - lon1 * pi / 180
    a = sin(d_lat/2) * sin(d_lat/2) + cos(lat1*pi/180) * cos(lat2*pi/180) * sin(d_lon/2) * sin(d_lon/2)
    c = 2 * atan2(sqrt(a), sqrt(1 - a))
    distance = r * c

    return distance / 1000


def json_abort(status_code, message):
    data = {
        'error': {
            'code': status_code,
            'message': message
        }
    }
    response = jsonify(data)
    response.status_code = status_code
    abort(response)


# Class to encode class objects to JSON
class JsonEncoder(json.JSONEncoder):
    def default(self, obj):
        if isinstance(obj, np.ndarray):
            return obj.tolist()
        elif isinstance(obj, Book):
            data = obj.__dict__
            data['_type'] = 'Book'
            return data
        elif isinstance(obj, Block):
            return {
                '_type': 'Block',
                'bookspine': obj.bookspine,
                'book': obj.book,
                'outline': obj.box,
            }
        return json.JSONEncoder.default(self, obj)


# Class to decode JSON to class objects
class JsonDecoder(json.JSONDecoder):
    def __init__(self, *args, **kwargs):
        json.JSONDecoder.__init__(self, object_hook=self.object_hook, *args, **kwargs)

    def object_hook(self, obj):
        if '_type' not in obj:
            return obj
        type = obj['_type']
        if type == 'Book':
            return Book.from_json(obj)
        elif type == 'Block':
            return Block.from_json(obj)


# Wrapper for MySQL connection
def connect_mysql(f):
    @wraps(f)
    def wrapper(request):
        try:
            cnx = mysql.connector.connect(user='biblosphere', password='biblosphere',
                                          unix_socket='/cloudsql/biblosphere-210106:us-central1:biblosphere',
                                          database='biblosphere',
                                          use_pure=False)

            cnx.autocommit = True
            cursor = cnx.cursor(prepared=True)
        except Exception as e: # MySQL error
            json_abort(401, message="MySQL connection failed")

        result = f(request, cursor)
        cursor.close()
        cnx.close()

        return result

    return wrapper


# Wrapper for MySQL connection for Firestore trigger
def connect_mysql_firestore(f):
    @wraps(f)
    def wrapper(data, context):
        try:
            cnx = mysql.connector.connect(user='biblosphere', password='biblosphere',
                                          unix_socket='/cloudsql/biblosphere-210106:us-central1:biblosphere',
                                          database='biblosphere',
                                          use_pure=False)

            cnx.autocommit = True
            cursor = cnx.cursor(prepared=True)
        except Exception as e: # MySQL error
            print("MySQL connection failed")
            json_abort(401, message="MySQL connection failed")

        result = f(data, context, cursor)
        cursor.close()
        cnx.close()

        return result

    return wrapper


# HTTP API function to add books
# gcloud functions deploy add_books --runtime python37 --trigger-http --allow-unauthenticated --memory=512MB --timeout=300s
# gcloud functions logs read add_books
@connect_mysql
def add_books(request, cursor):
    try:
        body = request.get_json(silent=True)

        if body['books'] is None:
            json_abort(400, message="Missing list of books")

        print('Request body:', body)
        print('Request books:', body['books'])

        for b in body['books']:
            if 'isbn' not in b:
                print('Isbn missing for', b)
                continue

            book = Book(b['isbn'], b['title'], b['authors'], b['image'])
            print('Path', book.isbn, book.title, book.authors, book.image)

            add_book_sql(cursor, book)
            print('Book added to MySQL', book.isbn, book.title, book.authors)

        return 'Success'

    except Exception as e:
        print('Exception for add_books', e)
        traceback.print_exc()
        json_abort(400, message="%s" % e)


# HTTP API function to get book by ISBN
# gcloud functions deploy get_tags --runtime python37 --trigger-http --allow-unauthenticated --memory=1024MB --timeout=30s
# gcloud functions logs read get_tags
@connect_mysql
def get_tags(request, cursor):
    query = ''
    try:
        req_json = request.get_json(silent=True)
        req_args = request.args

        if req_args is not None and 'query' in req_args:
            query = req_args['query']
        elif req_json is not None and 'query' in req_json:
            isbn = req_json['query']
        else:
            json_abort(400, message="Missing [query] parameter")

        print('Query', query)

        if len(query) >= 2:
            # Search book in Biblosphere
            tags = get_tag_list(cursor, query, trace=False)
            return json.dumps(tags, cls=JsonEncoder)
        else:
            return []

    except Exception as e:
        print('Exception for tag query [%s]' % query, e)
        traceback.print_exc()
        return json_abort(400, message="%s" % e)


# HTTP API function to get book by ISBN
# gcloud functions deploy get_book --runtime python37 --trigger-http --allow-unauthenticated --memory=512MB --timeout=30s
# gcloud functions logs read get_book
@connect_mysql
def get_book(request, cursor):
    try:
        req_args = request.args

        if req_args is not None and 'isbn' in req_args:
            isbn = req_args['isbn']
        else:
            json_abort(400, message="Missing [isbn] parameter")

        print('ISBN', isbn)

        # Search book in Biblosphere
        book = get_book_sql(cursor, isbn, trace=True)

        books = []
        if book is not None:
            books = [book]

        return json.dumps(books, cls=JsonEncoder)

    except Exception as e:
        print('Exception for get_book', e)
        traceback.print_exc()
        json_abort(400, message="%s" % e)



# HTTP API function to search book
# gcloud functions deploy search_book --runtime python37 --trigger-http --allow-unauthenticated --memory=512MB --timeout=300s
# gcloud auth print-identity-token
# gcloud functions logs read search_book
@connect_mysql
def search_book(request, cursor):
    print('!!!DEBUG Search book %s, v.10' % request)
    try:
        req_json = request.get_json(silent=True)
        req_args = request.args

        if req_args is not None and 'q' in req_args:
            text = req_args['q']
        elif req_json is not None and 'q' in req_json:
            text = req_json['q']
        else:
            json_abort(400, message="Missing [q] parameter")

        # Search book in Biblosphere
        books = list_books(cursor, text)

        return json.dumps(books, cls=JsonEncoder)

    except Exception as e:
        print('Exception for search_book', e)
        traceback.print_exc()
        json_abort(400, message="%s" % e)


# Extract blocks from book cover recognition response
def read_text(response, trace=False):
    # blocks = []
    # for p in response.full_text_annotation.pages:
    #    for b in p.blocks:
    #        words = []
    #        for par in b.paragraphs:
    #            for w in par.words:
    #                word = ''.join([s.text for s in w.symbols])
    #                words.append(word)

    #        if len(words) > 0:
    #            blocks.append(' '.join(words))
    # return '\n'.join(blocks)

    texts = response.text_annotations

    if texts is not None and len(texts) > 0:
        locale = texts[0].locale
        print('Locale:', locale)

        if locale in lang_codes:
            lang = lang_codes[locale]
        else:
            lang = None

        text = texts[0].description

        # Replace CRLF with space to make it easy to edit
        text = text.replace('\n', ' ')

        print(text)

        return lang, text
    else:
        return None, None


# HTTP API function to add book cover to GCS. It resize original cover and do OCR if requested.
# gcloud functions deploy add_cover --runtime python37 --trigger-http --allow-unauthenticated --memory=512MB --timeout=55s
# gcloud functions logs read add_cover
def add_cover(request):
    isbn = ''
    try:
        params = request.get_json(silent=True)

        if params is None:
            json_abort(400, message="Missing input parameters")

        # Validate params
        if 'uri' not in params or 'uid' not in params or 'isbn' not in params :
            # TODO: Make proper error handling
            print('ERROR: uri/uid/isbn parameters missing.')
            return 'uri/uid/isbn parameters missing.'

        filename = params['uri']
        uid = params['uid']
        isbn = params['isbn']
        ocr = 'ocr' in params and params['ocr']

        #client = storage.Client()
        bucket = client.get_bucket('biblosphere-210106.appspot.com')
        blob = bucket.blob(filename)

        # Do OCR if requested
        cover_text = None
        locale = None
        if ocr:
            response = ocr_url('gs://biblosphere-210106.appspot.com/' + blob.name)
            lang, cover_text = read_text(response)

        # Resize image (to the width 300)
        img = imread_blob(blob)
        scale_percent = 300.0/img.shape[1]
        width = int(img.shape[1] * scale_percent)
        height = int(img.shape[0] * scale_percent)
        img_res = cv2.resize(img, (width, height))

        # Upload resized image to GCS
        cover_file = 'covers/'+isbn+'.jpg'
        blob = bucket.blob(cover_file)
        res, data = cv2.imencode('.jpg', img_res)
        blob.upload_from_string(bytes(data), 'image/jpeg')
        blob.make_public()

        # Return book with cover image, isbn and cover text (if any)
        book = Book(isbn, '', '', image=blob.public_url, cover_text=cover_text, language=lang)

        return json.dumps([book], cls=JsonEncoder)

    except Exception as e:
        print('Exception for book [%s]' % isbn, e)
        traceback.print_exc()
        return json_abort(400, message="%s" % e)


# HTTP API function to add book cover to GCS. It resize original cover and do OCR if requested.
# gcloud functions deploy add_back --runtime python37 --trigger-http --allow-unauthenticated --memory=512MB --timeout=55s
# gcloud functions logs read add_back
def add_back(request):
    isbn = ''
    try:
        params = request.get_json(silent=True)

        if params is None:
            json_abort(400, message="Missing input parameters")

        # Validate params
        if 'uri' not in params or 'uid' not in params or 'isbn' not in params :
            # TODO: Make proper error handling
            print('ERROR: uri/uid/isbn parameters missing.')
            return 'uri/uid/isbn parameters missing.'

        filename = params['uri']
        uid = params['uid']
        isbn = params['isbn']
        ocr = 'ocr' in params and params['ocr']

        #client = storage.Client()
        bucket = client.get_bucket('biblosphere-210106.appspot.com')
        blob = bucket.blob(filename)

        # Do OCR if requested
        back_text = None
        if ocr:
            response = ocr_url('gs://biblosphere-210106.appspot.com/' + blob.name)
            lang, back_text = read_text(response)

        # Return book with cover image, isbn and cover text (if any)
        book = Book(isbn, '', '', back_text=back_text, language=lang)

        return json.dumps([book], cls=JsonEncoder)

    except Exception as e:
        print('Exception for book [%s]' % isbn, e)
        traceback.print_exc()
        return json_abort(400, message="%s" % e)


class RecognitionStatus:
    none, upload, scan, outline, catalogs_lookup, rescan, completed, failed, store = range(0, 9)

class Place:
    def __init__(self, id, name, contact, location):
        self.id = id
        self.name = name
        self.contact = contact
        self.location = location

    @classmethod
    def from_json(cls, obj):
        return cls(obj['id'], obj['name'], obj['contact'], obj.get('location', None))


class Photo:
    def __init__(self, id, bookplace, photo, location, url, reporter, width=None, height=None):
        self.id = id
        self.bookplace = bookplace
        self.photo = photo
        self.location = location
        self.url = url
        self.reporter = reporter
        self.width = width
        self.height = height
        # If geohash is missing generate it
        if location['geohash'] is None or location['geohash'] == '':
            self.location['geohash'] = geohash2.encode(location['geopoint'].latitude, location['geopoint'].longitude)[:9]
            db.collection('photos').document(id).update({'location': self.location})

    @classmethod
    def from_json(cls, obj):
        return cls(obj['id'], obj['bookplace'], obj['photo'], obj['location'], obj['url'], obj['reporter'], \
                   obj.get('width', None), obj.get('height', None))



# Function to fit biggest rectangle with given aspect ratio
def fit(ratio, contour):
    # TODO: Make it working for triangles and polygons
    # For each point of the contour draw two diagonals of the potential rectangle
    # Discard diagnals which are outside the angle of enclosing sides
    # Find intersection of diagonal with the rest of the sides
    # Calculate complimentary diagonal and check if corners are inside the photo
    # Choose biggest candidate, if several are biggest join them together

    width, height = abs(contour[2, 0] - contour[0, 0]), abs(contour[2, 1] - contour[0, 1])

    return min(width, height * ratio)


# Function to determine the biggest free part outside of book image
def place_for_cover(width, height, contour):
    # Aspect ration of book cover (Width / Height)
    ratio = 2.0 / 3.0

    min_x, max_x = min(contour[:, 0]), max(contour[:, 0])
    min_y, max_y = min(contour[:, 1]), max(contour[:, 1])

    if min_x > width - max_x:
        candidate1 = np.array([[0, 0], [0, height], [min_x, height], [min_x, 0]])
    else:
        candidate1 = np.array([[max_x, 0], [max_x, height], [width, height], [width, 0]])

    if min_y > height - max_y:
        candidate2 = np.array([[0, 0], [0, min_y], [width, min_y], [width, 0]])
    else:
        candidate2 = np.array([[0, max_y], [0, height], [width, height], [width, max_y]])

    if fit(ratio, candidate1) > fit(ratio, candidate2):
        cover = candidate1
    else:
        cover = candidate2

    return cover


# Function to return book spine rectangle
def spine_rectangle(contour):
    rect = cv2.minAreaRect(contour)
    return np.int0(cv2.boxPoints(rect))


# Function to recognize the books once photo  added to Firestore
# Deploy with:
# gcloud functions deploy photo_created --runtime python37 --trigger-event providers/cloud.firestore/eventTypes/document.create --trigger-resource projects/biblosphere-210106/databases/(default)/documents/photos/{photo}
# gcloud functions logs read photo_created
@connect_mysql_firestore
def photo_created(data, context, cursor):
    path_parts = context.resource.split('/documents/')[1].split('/')
    doc_path = path_parts[0]
    photo_id = path_parts[1]

    rec = db.collection(doc_path).document(photo_id).get().to_dict()

    # Check that all required fields are there
    if not rec.keys() >= {'photo', 'reporter', 'bookplace', 'id', 'location', 'url'}:
        # TODO: Make proper error handling
        print('ERROR: photo/reporter/bookplace/id/location/url parameters missing.', photo_id)
        return

    photo = Photo.from_json(rec)
    print('!!!DEBUG: Photo id: ', photo.id)
    print('!!!DEBUG: Image: ', photo.photo)
    print('!!!DEBUG: User: ', photo.reporter)
    print('!!!DEBUG: Place: ', photo.bookplace)
    print('!!!DEBUG: Location: ', photo.location)

    trace = False
    if 'trace' in rec:
        trace = rec['trace']

    rec = db.collection('bookplaces').document(photo.bookplace).get()

    if rec is None:
        # TODO: Make proper error handling
        print('ERROR: bookplace record not found by id.', photo.bookplace)
        return

    rec_data = rec.to_dict()
    if not rec_data.keys() >= {'id', 'name', 'contact'}:
        # TODO: Make proper error handling
        print('ERROR: id/name/contact missing in bookplace record.', photo.bookplace)
        return

    place = Place.from_json(rec_data)

    if place.id is None or place.id == '':
        place.id = rec.id

    if place.location is None or place.location['geohash'] is None or place.location['geohash'] == '':
        place.location = photo.location

    print('!!!DEBUG: Place id: ', place.id)
    print('!!!DEBUG: Place Name: ', place.name)
    print('!!!DEBUG: Place Location: ', place.location)

    try:
        filename = photo.photo
        uid = photo.reporter
        #place = photo.bookplace

        #client = storage.Client()
        bucket = client.get_bucket('biblosphere-210106.appspot.com')

        # Check if result JSON is available
        result_filename = os.path.splitext(filename)[0] + '.json'
        result_blob = bucket.blob(result_filename)

        # Do recognition only if no results available from previous runs
        already_recognized = False
        if not result_blob.exists():
            b = bucket.blob(filename)
            img = imread_blob(b)

            # Keep photo size
            photo.height, photo.width = img.shape[0:2]

            response = ocr_url('gs://biblosphere-210106.appspot.com/' + b.name)

            # Enable profiler
            # pr.enable()

            # cnx = mysql.connector.connect(user='biblosphere', password='biblosphere',
            #                              host='127.0.0.1',
            #                              database='biblosphere',
            #                              use_pure=False)

            # Extract blocks from Google Cloud Vision responce
            blocks, w_other, max_height = extract_blocks(response, img, trace=trace)

            if max_height is None:
                max_height = img.shape[0] / 3

            # Merge neaby blocks along the same bookspine (by angle, distance and size)
            confident_blocks = merge_bookspines(blocks, w_other, max_height, img, trace=trace)

            # Merge cross lines
            merge_along_confident(blocks, confident_blocks, w_other, img, trace=trace)

            # Search for books (as new words matched to the blocks search might be different)
            lookup_books(cursor, blocks, confident_blocks, trace=trace)

            # Merge smaller blocks with text not in the title/author (usually publisher)
            merge_publisher(blocks, confident_blocks, w_other, img, trace=trace)

            # Assume corrupted blocks are scanned up-side-down. Recognize again.
            rotate_corrupted(cursor, blocks, confident_blocks, w_other, img, trace=trace)

            # Stitch fragments of the same book (if same book is cut to two blocks)
            merge_book_fragments(blocks, confident_blocks, img, trace=trace)

            # Identify unknown books (look for false positives)
            unknown_blocks = list_unknown(cursor, blocks, trace=trace)

            # Clean noise
            remove_noise(blocks, confident_blocks, unknown_blocks, threshold=0.50, trace=trace)

            recognized_blocks = list(set([b for b in blocks if b.book is not None]))
            unrecognized_blocks = list(set([b for b in blocks if b.book is None and b.bookspine is not None]))

            # Disable profiler
            # pr.disable()

            #if trace:
            #    for b in confident_blocks:
            #        cv2.drawContours(img, [np.array(b.box)], 0, (0, 255, 0), img.shape[0] // 300)
            #        print('Book found for:', b.bookspine)
            #        print('>', b.book.authors, b.book.title)
            #    for b in unknown_blocks:
            #        cv2.drawContours(img, [np.array(b.box)], 0, (0, 0, 255), img.shape[0] // 300)
            #    plot_img(img, show=True)
        else:
            already_recognized = True
            # Read JSON with results from cloud storage
            stored_results = json.loads(result_blob.download_as_string(), cls=JsonDecoder)

            recognized_blocks = stored_results['recognized']
            unrecognized_blocks = stored_results['unrecognized']
            if stored_results.keys() >= {'height', 'width'}:
                photo.height, photo.width = stored_results['height'], stored_results['width']
            else:
                # TODO: Temporary for debug perposes for old JSON files (REMOVE)
                b = bucket.blob(filename)
                img = imread_blob(b)
                photo.height, photo.width = img.shape[0:2]

        # Add confident books to the Biblosphere user (Firestore)
        batch = db.batch()

        print('!!!DEBUG Place ', place)
        for b in recognized_blocks:
            # Set the Firestore bookrecord
            ref = db.collection('books').document(place.id+':'+b.book.isbn)
            batch.set(ref, b.book_data(photo, place), merge=True)
            print(b.book.isbn, b.book.title, b.book.authors)
            #print(b['contour'])

        # Commit the batch
        batch.commit()

        # Update status to completed and keep number of recognized books
        db.collection('photos').document(photo_id).update({'status': 'recognized',
                                                            'total': len(recognized_blocks) + len(unrecognized_blocks),
                                                            'recognized': len(recognized_blocks)})

        if not already_recognized:
            # Build JSON with results of the recognition
            # - GCS path to image
            # - List of recognized books (isbn/title/authors, contour)
            # - List of unrecognized books (bookspine line, contour)
            # - Google Cloud Vision response

            data = {
                    'uid': uid,
                    'uri': filename,
                    'height': photo.height,
                    'width': photo.width,
                    'recognized': recognized_blocks,
                    'unrecognized': unrecognized_blocks,
                    # 'cloud_vision_response': response
                   }

            # Store JSON to GCS
            result_blob.upload_from_string(json.dumps(data, cls=JsonEncoder).encode('utf8'), 'application/json')

    except Exception as e:
        print(u'Exception happened: %s' % type(e))
        print(u'Exception during image recognition: %s' % e)
        traceback.print_exc()
        db.collection('photos').document(photo_id).update({'status': 'failed'})


class Line:
    def __init__(self, word):
        self.words = [word]
        self.angle = line_angle(word.direction[1], word.direction[0], full=True)
        self.start = word.direction[0]
        self.end = word.direction[1]

    def join(self, word):
        assert abs(self.angle) <= np.pi / 4, 'Line angle outside the quadrant'

        angle = line_angle(word.direction[1], word.direction[0], full=True)
        assert abs(angle) <= np.pi / 4, 'Word angle outside the quadrant'

        w_len = d(word.direction[1] - word.direction[0])
        l_len = d(self.start - self.end)
        self.angle = (self.angle * l_len + angle * w_len) / (l_len + w_len)
        self.end = word.direction[1]
        self.words.append(word)

    def text(self):
        return ' '.join([w.correct for w in self.words])

    def on(self, word, font_size, trace=False):
        # GAP - distance between end of line and beginning of word
        # INTERVAL - distance from start of word to central line of the line
        # ALIGN - angle between line and word

        angle = line_angle(word.direction[1], word.direction[0], full=True)

        # TODO: Resolve why word angle is outside the quadrant (assertion replaced with 'if' as a workaround)
        #assert abs(self.angle) <= np.pi / 4, 'Line angle outside the quadrant %.2f, %.2f | Try [%s] on line [%s]' % (180 * angle / np.pi, 180 * self.angle / np.pi, word.correct, self.text())
        #assert abs(angle) <= np.pi / 4, 'Word angle outside the quadrant %.2f, %.2f | Try [%s] on line [%s]' % (180 * angle / np.pi, 180 * self.angle / np.pi, word.correct, self.text())
        if abs(self.angle) <= np.pi / 4 or abs(angle) <= np.pi / 4:
            return False

        if trace:
            print('Try [%s] on line [%s]' % (word.correct, self.text()))
            print('Font size:', font_size)
            print('Distance to line:', distance_to_line(word.direction[0], self.start, self.end))

        # Check alignment
        if abs(angle - self.angle) > 0.1:
            if trace:
                print('Angle too big (%d)' % (abs(angle - self.angle) / np.pi * 180))
            return False

        # Check interval (less than 10% of size of the letter)
        if distance_to_line(word.direction[0], self.start, self.end) > 0.1 * font_size:
            if trace:
                print('Interval too big (%.02f)' % (
                            distance_to_line(word.direction[0], self.start, self.end) / font_size))
            return False

        # Check gap (more than 2 letters)
        if d(word.direction[0] - self.end) > 5 * font_size:
            if trace:
                print('Gap too big (%.02f)' % (d(word.direction[0] - self.end) / font_size))
            return False

        return True


class Box:
    def __init__(self, box):
        self.set_box(box)

    def set_box(self, box):
        self.box = box
        self.center, self.angle, self.height, self.width = self.metrics()

    def metrics(self):
        center, height, width = center_for_points(self.box)
        return center, box_angle(self.box, longside=True), height, width

    def in_area(self, center, radius):
        return d(self.center - center) <= radius


# Function to transform (rotate and shift) the box
# TODO: Make it class member for Box
def transform(box, M, d1, d2):
    box += d2
    box = np.int0(cv2.transform(np.array([box]), M)[0])
    box += d1
    return box

# Return the maximum height of the box
def max_block_height(boxes):
    if len(boxes) > 0:
        return np.amax([b.height for b in boxes])
    else:
        return None


class Block(Box):
    def __init__(self, words=None, book=None, bookspine=None, box=None):
        self.matches = set()
        self.unmatched = set()
        self.book = book
        self.keys = set()
        if words is not None:
            self.unmatched = set(words)
        else:
            self.unmatched = set()
        # Arranged bookspine text and it's fragments
        self.bookspine = bookspine
        self.fragments = None

        if box is not None:
            self.box = box
        else:
            super().__init__(box_for_words(self.matches.union(self.unmatched)))


    @classmethod
    def from_json(cls, obj):
        return cls(book=obj['book'], bookspine=obj['bookspine'], box=obj['outline'])


    def clear(self):
        self.matches = set()
        self.unmatched = set()
        self.book = None
        self.keys = set()
        self.box = []

    def empty(self):
        return len(self.matches) + len(self.unmatched) == 0

    def confident(self, max_height):
        score = 0

        # 1 point if no unmatched (more unmatched less score)
        score += 1 / (1 + len(self.unmatched))

        # 1 point for the confidence
        score += np.average([w.confidence for w in self.unmatched.union(self.matches)])

        # 1 point for each mached word if book is found
        if self.book is not None:
            score += len(self.matches)

        # 1 point for the length of the bookspine
        score += self.height / max_height

        return score

    def merge_with(self, b, force=False, remove=True):
        if force:
            b.book = None

        assert b.book is None or self.book is None or self.book.isbn == b.book.isbn, 'Could not merge two blocks with different books'

        if self.book is None and b.book is not None:
            self.book = b.book
            self.refresh_keys()

        self.unmatched.update(b.matches)
        self.unmatched.update(b.unmatched)
        self.refresh_words()
        if remove:
            b.clear()

    def copy(self, b):
        self.matches = b.matches
        self.unmatched = b.unmatched
        self.book = b.book
        self.keys = b.keys
        self.box = b.box
        self.center, self.angle, self.height = b.center, b.angle, b.height
        return self

    # Function to refresh list of books for updated words (unmatched word is corrected)
    def refresh_keys(self):
        self.keys = set()
        if self.book is not None:
            self.keys = lexems(self.book.title + ' ' + self.book.authors, full=True)

    # Function to refresh list of books for updated words (unmatched word is corrected)
    def refresh_words(self):
        self.unmatched.update(self.matches)

        for w in self.unmatched:
            if w.correct in self.keys:
                self.matches.add(w)

        self.unmatched.difference_update(self.matches)
        self.set_box(box_for_words(self.matches.union(self.unmatched)))

    def book_names(self):
        if self.book is not None:
            return [self.book.title + ' ' + self.book.authors]
        else:
            return []

    def words(self, unmatched=True):
        if unmatched:
            return [w.correct for w in self.matches.union(self.unmatched)]
        else:
            return [w.correct for w in self.matches]

    def confidence(self):
        if len(self.matches) == 0 and len(self.unmatched) > 0:
            c = [w.confidence for w in self.unmatched]
            return sum(c) / float(len(c))
        elif len(self.matches) > 0:
            c = [w.confidence for w in self.matches]
            return 2.0 * sum(c) / float(len(c))
        else:
            return 0

    # Read words on bookspine in a right order
    def read(self, trace=False):
        self.bookspine, self.fragments = read_bookspine(self, trace=trace)
        return self.bookspine

    # Look for the book in biblosphere DB and the Web
    def lookup(self, cursor, threshold=60, trace=False):
        set_words = set([w.correct for w in self.matches.union(self.unmatched)])
        if len(set_words) >= 2:
            bookspine = self.read(trace=False)
            if trace:
                print('Bookspine for [%s]: %s' % (','.join(set_words), bookspine))
            book, top = find_book(cursor, set_words, trace=trace)

            if len(top) >= 2:
                # TODO: Performance - skip this step if only one book found
                max_corrections = 0
                max_indx = 0
                for i, b in enumerate(top):
                    corrections = 0
                    missing = set_words - set(b.keys)
                    if trace:
                        print('(1) Look corrections for:', missing, b.keys)
                    for w in missing:
                        if trace:
                            print('(1) Look corrections for [%s] in ' % (w), b.keys)
                        if len(w) > 0:
                            if len(b.keys) > 0:
                                ratio = process.extractOne(w, b.keys, scorer=fuzz.ratio)
                                if trace:
                                    print('(1) Candidate found [%s, %d]' % (ratio[0], ratio[1]))
                                if threshold < ratio[1] < 100:
                                    if trace:
                                        print('%s (%.2f) => %s' % (w, ratio[1], ratio[0]))
                                    corrections += 1
                    if corrections > max_corrections:
                        max_corrections = corrections
                        max_indx = i

                if book != top[max_indx]:
                    book = top[max_indx]
                    if trace:
                        print('Another book choosen based on corrections:', book.title)
            elif len(top) == 0:
                if trace:
                    print('BOOK NOT FOUND IN DB (%s)' % (' '.join(set_words)))

            if book is not None:
                corrected = False
                uw = [w for w in self.matches.union(self.unmatched) if w.lexem() not in book.keys]
                if trace:
                    print('(2) Look corrections for:', [w.lexem() for w in uw], book.keys)
                for w in uw:
                    if trace:
                        print('(2) Look corrections for [%s, %.2f] in ' % (w.lexem(), w.confidence), book.keys)
                    if len(w.lexem()) > 0:
                        if len(book.keys) > 0:
                            ratio = process.extractOne(w.lexem(), book.keys, scorer=fuzz.ratio)
                            if trace:
                                print('(2) Candidate found [%s, %d]' % (ratio[0], ratio[1]))
                            if ratio[1] > threshold and w.confidence > 0.30:
                                if trace:
                                    print('%s (%s, %.2f, %.2f) => %s' % (
                                    w.correct, w.orig, ratio[1], w.confidence, ratio[0]))
                                w.correct = ratio[0]
                                corrected = True

                if corrected:
                    bookspine = self.read(trace=False)

                if not is_same_book(book.catalog_title(), bookspine, top=len(top), trace=False):
                    if trace:
                        print('BOOK DISCARDED (%s) for' % (book.title), bookspine)
                    book = None
                elif trace:
                    print('BOOK FOUND:', book.authors, book.title)


            if book is not None:
                self.book = book
                self.refresh_keys()
                self.refresh_words()

    def bookrecord_id(self, place_id):
        assert self.book is not None, 'Only recognized blocks can be stored in Firestore'
        return '%s:%s' % (place_id, self.book.isbn)


    def book_data(self, photo, place):
        assert self.book is not None, 'Only recognized blocks can be stored in Firestore'
        data = {
                'id': self.bookrecord_id(place.id),
                'authors': self.book.authors.split(sep=';'),
                'title': self.book.title,
                'isbn': self.book.isbn,
                'cover': self.book.image,
                'location': photo.location,
                'outline': [{'x': v[0], 'y': v[1]} for v in np.array(self.box).tolist()],
                'spine': [{'x': v[0], 'y': v[1]} for v in spine_rectangle(np.array(self.box)).tolist()],
                'place_for_cover': [{'x': v[0], 'y': v[1]} for v in place_for_cover(photo.width, photo.height, np.array(self.box)).tolist()],
                'photo': photo.url,
                'photo_id': photo.id,
                'photo_width': photo.width,
                'photo_height': photo.height,
                'bookplace': photo.bookplace,
                'place_name': place.name,
                'place_contact': place.contact
               }

        return data


# Distance from one block to another
# TODO: Add to Box class as member
def box_distance(points, base):
    h = (0.5 * base.height * np.cos(base.angle), 0.5 * base.height * np.sin(base.angle))
    A, B = base.center + h, base.center - h

    distances = np.abs(np.cross(B - A, A - points) / np.sqrt(np.sum((B - A) ** 2)))
    dot = in_section(points, A, B)

    # If no intersection return BIG value
    if np.sum(dot >= 0) == 0:
        return 100000
    else:
        return np.int0(np.amin(distances[dot >= 0]))


def rotate_and_read(block, words, angle, trace=False):
    # Rotate to have words horizontaly from left to right
    rot_words = [w.rotated(block.center, block.height, angle) for w in words]

    max_font = max([w.width for w in words])

    if trace:
        maxX = np.int0(max([w.center[0] + 0.5 * w.height for w in rot_words]))
        maxY = np.int0(max([w.center[1] + 0.5 * w.height for w in rot_words]))

        mask = np.zeros((maxY, maxX), dtype=np.uint8)
        for w in rot_words:
            cv2.drawContours(mask, [w.box], 0, 255, maxX // 200 + 1)
            if w.direction is not None:
                cv2.line(mask, (w.direction[0, 0], w.direction[0, 1]), (w.direction[1, 0], w.direction[1, 1]), 128,
                         maxX // 200 + 1)
                cv2.circle(mask, (w.direction[0, 0], w.direction[0, 1]), maxX // 100 + 1, 255, -1)

            print('[%s] %d, %d' % (w.correct, w.direction[0, 0], w.direction[0, 1]))

        #plot_img(mask, show=True, h=6, w=8)

        # Sort all words to have left-most first (by left edge)
    # Loop through all words and assign them to lines and columns
    # Read columns and lines in sequence to get title and authors

    start_positions = [w.direction[0, 0] for w in rot_words]
    position_idx = np.argsort(start_positions)

    lines = []

    for i in position_idx:
        w = rot_words[i]
        fit = False
        for l in lines:
            if l.on(w, max_font, trace=trace):
                l.join(w)
                fit = True
                break
        if not fit:
            lines.append(Line(w))

    if trace:
        print('%d lines found' % len(lines))
        for l in lines:
            print(l.text())

    # TODO: Performance skip columns if only one line

    start_positions = [l.start[0] for l in lines]
    position_idx = np.argsort(start_positions)

    # Keep the end of the first line
    line_end = lines[position_idx[0]].end[0]

    n = 0
    columns = [[]]
    for i in position_idx:
        l = lines[i]
        # If line begins outside the column create a new one
        if l.start[0] > line_end + block.height / 100:
            n += 1
            line_end = l.end[0]
            columns.append([l])
        else:
            line_end = max(line_end, l.end[0])
            columns[n].append(l)

    # Join columns and lines together
    fragments = []
    for n, c in enumerate(columns):
        start_positions = [l.start[1] for l in c]
        position_idx = np.argsort(start_positions)
        text = ' '.join([c[i].text() for i in position_idx])
        fragments.append(text)
        if trace:
            print('COLUMN %d: ' % n, text)

    return fragments


def read_bookspine(block, threshold=0.2, trace=False):
    words = set([w for w in block.matches.union(block.unmatched) if w.confidence > threshold and len(w.correct) >= 1])

    # Split all words to 4 quadrants/directions
    horizontal_left_to_right = []
    horizontal_right_to_left = []
    vertical_top_to_bottom = []
    vertical_bottom_to_top = []

    for w in words:
        if w.direction is not None:
            angle = line_angle(w.direction[1], w.direction[0], full=True)

            if trace:
                print('[%s] angle=%d (%d, %d)' % (w.correct, angle / np.pi * 180, w.direction[0, 0], w.direction[0, 1]))

            # Difference betwiin block's direction and word's direction
            eps = block.angle - angle

            # Correct difference to be in a range [-np.pi, +np.pi]
            if eps < -np.pi:
                eps += 2 * np.pi
            if eps > np.pi:
                eps -= 2 * np.pi

            # Vertical bottom to top
            if -np.pi / 4 <= eps < np.pi / 4:
                vertical_bottom_to_top.append(w)
            # Horizontal left to right
            elif -np.pi * 3 / 4 <= eps < -np.pi / 4:
                horizontal_left_to_right.append(w)
            # Horizontal right to left
            elif np.pi / 4 <= eps < np.pi * 3 / 4:
                horizontal_right_to_left.append(w)
            # Vertical top to bottom
            if eps < -np.pi * 3 / 4 or eps >= np.pi * 3 / 4:
                vertical_top_to_bottom.append(w)

    fragments = []
    # Loop throught each group of words
    if len(vertical_bottom_to_top) > 0:
        if trace:
            #print('Block: %.2f [%s]' % (180 * block.angle / np.pi, ','.join(block.words())))
            print('vertical_bottom_to_top', len(vertical_bottom_to_top))
        new_fragments = rotate_and_read(block, vertical_bottom_to_top, block.angle, trace=trace)
        fragments.extend(new_fragments)

    if len(horizontal_left_to_right) > 0:
        if trace:
            print('horizontal_left_to_right', len(horizontal_left_to_right))
        new_fragments = rotate_and_read(block, horizontal_left_to_right, block.angle + np.pi / 2, trace=trace)
        fragments.extend(new_fragments)

    if len(vertical_top_to_bottom) > 0:
        if trace:
            print('vertical_top_to_bottom', len(vertical_top_to_bottom))
        new_fragments = rotate_and_read(block, vertical_top_to_bottom, block.angle + np.pi, trace=trace)
        fragments.extend(new_fragments)

    if len(horizontal_right_to_left) > 0:
        if trace:
            print('horizontal_right_to_left', len(horizontal_right_to_left))
        new_fragments = rotate_and_read(block, horizontal_right_to_left, block.angle + 3 * np.pi / 2, trace=trace)
        fragments.extend(new_fragments)

    # Combine text from different directions and columns (keep fragments to match it lated to authors/title/publisher)
    bookspine_text = ' '.join(fragments)
    if trace:
        print('Result bookspine:', bookspine_text)

    return bookspine_text, fragments


# Find the blocks resides on given line
def blocks_on_line(line, blocks, exclude=None):
    results = []
    center, length = (line[0] + line[1]) / 2, d(line[0] - line[1])
    for b in [b for b in blocks if b.in_area(center, 0.5 * (length + b.height))]:
        if exclude is not None and b in exclude or (type(b) == Block and b.empty()):
            continue
        if is_overlap(line, b.box):
            results.append(b)

    return results


# Function to delete empty blocks from the list
def delete_empty(blocks):
    blocks_to_delete = []
    for i, b in enumerate(blocks):
        if len(b.matches) + len(b.unmatched) == 0:
            blocks_to_delete.append(i)

    # Delete empty blocks
    # print('Blocks to delete: ', blocks_to_delete)
    for i in sorted(blocks_to_delete, reverse=True):
        del blocks[i]

    return


class Word(Box):
    def __init__(self, s, b, c, d):
        self.orig = s
        self.correct = lexem(s)
        self.confidence = c
        self.direction = d

        super().__init__(np.array(b))

    def lexem(self):
        return lexem(self.orig)

    def rotated(self, center, size, angle):
        d = rotate_points(center, size, self.direction, angle)
        box = rotate_points(center, size, self.box, angle)
        word = Word(self.orig, box, self.confidence, d)
        word.correct = self.correct
        word.center, word.angle, word.height, word.width = word.metrics()
        return word


# Extract blocks (used on image level)
def extract_blocks(response, img, trace=False):
    blocks = []
    all_words = set()
    for p in response.full_text_annotation.pages:
        for b in p.blocks:
            words = set()
            for par in b.paragraphs:
                for w in par.words:
                    text = ''.join([s.text for s in w.symbols])
                    letters = []
                    for s in w.symbols:
                        v = s.bounding_box.vertices
                        letters.extend([[v[0].x, v[0].y], [v[1].x, v[1].y], [v[2].x, v[2].y], [v[3].x, v[3].y]])

                    confidence = np.average([s.confidence for s in w.symbols])

                    if len(w.symbols) > 1:
                        v1 = w.symbols[0].bounding_box.vertices
                        v2 = w.symbols[-1].bounding_box.vertices
                        direction = np.array([[(v1[0].x + v1[2].x) // 2, (v1[0].y + v1[2].y) // 2],
                                              [(v2[0].x + v2[2].x) // 2, (v2[0].y + v2[2].y) // 2]])
                    else:
                        v = w.symbols[0].bounding_box.vertices
                        direction = np.array([[(v[0].x + v[3].x) // 2, (v[0].y + v[3].y) // 2],
                                              [(v[1].x + v[2].x) // 2, (v[1].y + v[2].y) // 2]])

                    box = convex_for_points(letters)
                    word = Word(text, box, confidence, direction)
                    words.add(word)

                    if trace:
                        print('Word (%s)' % text, confidence)

            if len(words) > 0:
                blocks_to_add, odd_words = words2blocks(words, img.shape[0], trace=trace)
                if len(blocks_to_add) > 0:
                    blocks.extend(blocks_to_add)
                if len(odd_words) > 0:
                    all_words.update(odd_words)

    #if trace:
    #    show_blocks(img, all_words, highlight=[b.box for b in blocks])

    max_height = max_block_height(blocks)

    return blocks, all_words, max_height


# Extract words (used for corrupted regions)
def extract_words(response, img, trace=False):
    blocks = []
    words = set()
    for p in response.full_text_annotation.pages:
        for b in p.blocks:
            dict_words = set()
            for par in b.paragraphs:
                for w in par.words:
                    text = ''.join([s.text for s in w.symbols])
                    letters = []
                    for s in w.symbols:
                        v = s.bounding_box.vertices
                        letters.extend([[v[0].x, v[0].y], [v[1].x, v[1].y], [v[2].x, v[2].y], [v[3].x, v[3].y]])

                    if len(w.symbols) > 1:
                        v1 = w.symbols[0].bounding_box.vertices
                        v2 = w.symbols[-1].bounding_box.vertices
                        direction = np.array([[(v1[0].x + v1[2].x) // 2, (v1[0].y + v1[2].y) // 2],
                                              [(v2[0].x + v2[2].x) // 2, (v2[0].y + v2[2].y) // 2]])
                    else:
                        v = w.symbols[0].bounding_box.vertices
                        direction = np.array([[(v[0].x + v[3].x) // 2, (v[0].y + v[3].y) // 2],
                                              [(v[1].x + v[2].x) // 2, (v[1].y + v[2].y) // 2]])

                    confidence = np.average([s.confidence for s in w.symbols])

                    # v = w.bounding_box.vertices
                    # box = convex_for_points([[v[0].x, v[0].y], [v[1].x, v[1].y], [v[2].x, v[2].y], [v[3].x, v[3].y]])
                    box = convex_for_points(letters)
                    words.add(Word(text, box, confidence, direction))

                    if trace:
                        print('Word (%s)' % text, confidence)

    return words


# Extract blocks from the set of words
def words2blocks(words, max_height, trace=False):
    # List of dictionary words is not empty
    assert len(words) > 0

    block_angle = group_angle(words)

    # Loop through words aligned to books' direction
    aligned_words = [w for w in words if diff_angle(w.angle, block_angle) < 0.2]

    blocks = []

    # Merge words overlaped with center line of aligned words
    for w in aligned_words:
        # Skip if word already added to the block
        if w not in words:
            continue

        h = (0.5 * max_height * np.cos(w.angle), 0.5 * max_height * np.sin(w.angle))
        line = [w.center + h, w.center - h]

        overlap = blocks_on_line(line, words)
        blocks.append(Block(overlap))

        words = words - set(overlap)

    return blocks, words


# Return major angle for the group of the boxes (longer boxes has higher weight)
def group_angle(boxes):
    clusters = []
    weights = []

    for b in boxes:
        found = False
        for i, c in enumerate(clusters):
            # Include box into cluster and recalculate average angle for group
            if diff_angle(b.angle, c) < 0.2:
                if abs(c - b.angle) > 0.75 * np.pi:
                    if c < 0:
                        c += np.pi
                    else:
                        c -= np.pi

                clusters[i] = (c * weights[i] + b.angle * b.height) / (weights[i] + b.height)
                weights[i] += b.height

                if clusters[i] > np.pi / 2:
                    clusters[i] -= np.pi
                elif clusters[i] < -np.pi / 2:
                    clusters[i] += np.pi

                found = True
                break
        if not found:
            clusters.append(b.angle)
            weights.append(b.height)

    i = weights.index(max(weights))

    return clusters[i]

# *********************************************************************************************************

# Function to merge blocks which are belongs to same bookspine based on aligment and overlap
def merge_bookspines(blocks, other_words, max_height, img, corrupted=False, threshold=60, trace=False):
    if trace:
        print('AVERAGE HEIGHT:', max_height)

    #if trace:
    #    show_blocks(img, blocks, highlight=[w.box for w in other_words])

    # Try to join blocks which are exactly aligned
    for b1 in blocks:
        # Skip empty blocks
        if b1.empty():  # or box_height(b1.box) < 0.2 * max_height:
            continue

        if trace:
            print('-------------------------------------------')
            print('SEARCHING ALIGNED for: ', b1.words())

        # Go through all blocks and merge if it's on the same bookspine and well aligned
        for b2 in [b for b in blocks if b.in_area(b1.center, 1.5 * max_height)]:
            # Skip same block and empty blocks
            if b2 == b1 or b2.empty() or b2.height < 0.1 * max_height:
                continue
            distance = bookspine_distance(b1, b2)
            box = Box(convex_for_points(np.concatenate((b1.box, b2.box))))
            if distance < 1.5 * max_height and box.height < 2.0 * max_height:
                if is_aligned(b1, b2, gap=0.5, trace=False) and not is_overlap_blocks(box, blocks, exclude=[b1, b2]):
                    if trace:
                        print('Blocks aligned: ', b1.words(), b2.words())
                    # TODO: Do it more accurately (check which block has higher score)
                    b1.merge_with(b2, force=True)

                elif trace:
                    print('Block alignment discarded (not aligned or overlap)', b1.words(), b2.words())
            elif trace and distance < 1000000:
                print(
                    'Block alignment discarded (too long) %.2f %.2f' % (distance / max_height, box.height / max_height),
                    b1.words(), b2.words())

        # Go through all blocks and merge if it's on the same bookspine and well aligned
        words_to_remove = []
        for w in [w for w in other_words if w.in_area(b1.center, 1.5 * max_height) and w.height > 0.1 * max_height]:
            distance = bookspine_distance(b1, w)
            box = Box(convex_for_points(np.concatenate((b1.box, w.box))))
            if distance < 1.5 * max_height and box.height < 2.0 * max_height:
                if is_aligned(b1, w, gap=0.5, trace=False) and not is_overlap_blocks(box, blocks, exclude=[b1]):
                    if trace:
                        print('Block and word aligned: ', b1.words(), w.correct)
                    # TODO: Do it more accurately (check which block has higher score)
                    b1.matches.add(w)
                    b1.refresh_words()
                    words_to_remove.append(w)
                elif trace:
                    print('Word alignment discarded (not aligned or overlap)', b1.words(), w.correct)
            elif trace and distance < 1000000:
                print(
                    'Word alignment discarded (too long) %.2f %.2f' % (distance / max_height, box.height / max_height),
                    b1.words(), w.correct)

        other_words.difference_update(words_to_remove)

    delete_empty(blocks)

    #if trace:
    #    show_blocks(img, blocks)

    # Take most confident 30% of the blocks
    confident_score = [-b.confident(max_height) for b in blocks]
    confidence_idx = np.argsort(confident_score)
    if trace:
        print('Confidense score:', [confident_score[i] for i in confidence_idx])

    confident_blocks = [blocks[i] for i in confidence_idx if -confident_score[i] >= 5.0]
    if len(confident_blocks) <= 4:
        confident_blocks = [blocks[i] for i in confidence_idx[:len(blocks) // 4]]

    if trace:
        print('CONFIDENT BLOCKS')
        #show_blocks(img, confident_blocks)
        print('Confidence index:', [-confident_score[i] for i in confidence_idx])

    if len(blocks) > 0 and not corrupted:
        max_height = max_block_height(blocks)

    if trace:
        print('AVERAGE HEIGHT:', max_height)

    # First search corrections ONLY for confident blocks
    for b1 in confident_blocks:
        if b1.empty() or len(b1.keys) == 0:  # or box_height(b1.box) < 0.2 * max_height:
            continue

        if trace:
            print('-------------------------------------------')
            print('SEARCH CORRECTIONS for: ', b1.words(), b1.keys)

        # Go through all single word blocks and try corrections
        for b2 in [b for b in blocks if b.in_area(b1.center, 1.5 * max_height)]:
            # Skip same block, empty blocks, end blocks with more than 1 word
            if b2 == b1 or b2.empty() or len(b2.matches) > 1:
                continue
            distance = bookspine_distance(b1, b2)
            box = Box(convex_for_points(np.concatenate((b1.box, b2.box))))

            assert len(b2.matches) == 1
            w = list(b2.matches)[0]

            # Only accept 1 symbol words if it's close
            if (distance < 1.5 * max_height and len(
                    w.correct) > 1 or distance < 1.0 * max_height) and box.height < 1.5 * max_height:
                # or np.pi/2 - 0.2 <= angle <= np.pi/2 and box_height(b1.box) < 0.19 * max_height and box_height(b2.box) < 0.19 * max_height:

                if len(re.sub('[\;\(\)\"\,\/\&\!\?\:\.\-\*\·\|\+\$\'\«\@\•]', '', w.correct)) > 0:
                    ratio = process.extractOne(w.correct, b1.keys, scorer=fuzz.ratio)
                    if ratio[1] > threshold and 0.50 < w.confidence < 0.90 or ratio[1] == 100:
                        if trace:
                            # print('Corrected word found for ', b1.words())
                            print('%s (%s, %.2f, %.2f) => %s' % (w.correct, w.orig, ratio[1], w.confidence, ratio[0]))

                        if not is_overlap_blocks(box, confident_blocks, exclude=[b1, b2]):
                            w.correct = ratio[0]
                            b1.matches.add(w)
                            b1.refresh_words()
                            b2.clear()
                        elif trace:
                            print('Discarded (OVERLAP)')
                    # elif trace:
                    #    print('Candidate: %s (%s, %.2f, %.2f) => %s' % (w.correct, w.orig, ratio[1], w.confidence, ratio[0]))
            # elif trace and 0.0 <= angle <= 0.2 and distance < 6.0 * max_height:
            #    print('Blocks outside bookspine: (%.2f, %.2f)' % (angle, distance), b1.words(), b2.words())

        # Go through all non-dictionary words and try corrections
        words_to_remove = []
        for w in [w for w in other_words if w.in_area(b1.center, 1.5 * max_height)]:
            distance = bookspine_distance(b1, w)
            box = Box(convex_for_points(np.concatenate((b1.box, w.box))))
            if (distance < 1.5 * max_height and len(
                    w.correct) > 1 or distance < 1.0 * max_height) and box.height < 1.5 * max_height:
                # or np.pi/2 - 0.2 <= angle <= np.pi/2 and box_height(b1.box) < 0.19 * max_height and box_height(w.box) < 0.19 * max_height:
                # Check if blocks has word in the keys
                if len(re.sub('[\;\(\)\"\,\/\&\!\?\:\.\-\*\·\|\+\$\'\«\@\•]', '', w.correct)) > 0:
                    ratio = process.extractOne(w.correct, b1.keys, scorer=fuzz.ratio)
                    if ratio[1] > threshold and w.confidence > 0.50:
                        if trace:
                            # print('Corrected word found for ', b1.words())
                            print('%s (%s, %.2f, %.2f) => %s' % (w.correct, w.orig, ratio[1], w.confidence, ratio[0]))
                        box = Box(convex_for_points(np.concatenate((b1.box, w.box))))
                        if not is_overlap_blocks(box, confident_blocks, exclude=[b1]):
                            w.correct = ratio[0]
                            b1.matches.add(w)
                            b1.refresh_words()
                            words_to_remove.append(w)
                        elif trace:
                            print('Discarded (OVERLAP)')
                    # elif trace:
                    #    print('Candidate: %s (%s, %.2f, %.2f) => %s' % (w.correct, w.orig, ratio[1], w.confidence, ratio[0]))

        # Remove linked words from the list
        other_words.difference_update(words_to_remove)

    delete_empty(blocks)

    # After confident blocks search for the rest
    for b1 in list(set(blocks) - set(confident_blocks)):
        if b1.empty() or len(b1.keys) == 0:  # or box_height(b1.box) < 0.2 * max_height:
            continue

        if trace:
            print('-------------------------------------------')
            print('SEARCH CORRECTIONS for: ', b1.words(), b1.keys)

        # Go through all single word blocks and try corrections
        for b2 in [b for b in blocks if b.in_area(b1.center, 1.5 * max_height)]:
            # Skip same block, empty blocks, end blocks with more than 1 word
            if b2 == b1 or b2.empty() or len(b2.matches) > 1:
                continue
            distance = bookspine_distance(b1, b2)
            box = Box(convex_for_points(np.concatenate((b1.box, b2.box))))
            assert len(b2.matches) == 1
            w = list(b2.matches)[0]

            # Only accept 1 symbol words if it's close
            if (distance < 1.5 * max_height and len(
                    w.correct) > 1 or distance < 1.0 * max_height) and box.height < 1.5 * max_height:
                # or np.pi/2 - 0.2 <= angle <= np.pi/2 and box_height(b1.box) < 0.19 * max_height and box_height(b2.box) < 0.19 * max_height:

                if len(re.sub('[\;\(\)\"\,\/\&\!\?\:\.\-\*\·\|\+\$\'\«\@\•]', '', w.correct)) > 0:
                    ratio = process.extractOne(w.correct, b1.keys, scorer=fuzz.ratio)
                    if ratio[1] > threshold and w.confidence > 0.50:
                        if trace:
                            # print('Corrected word found for ', b1.words())
                            print('%s (%s, %.2f, %.2f) => %s' % (w.correct, w.orig, ratio[1], w.confidence, ratio[0]))

                        if not is_overlap_blocks(box, confident_blocks, exclude=[b1, b2]):
                            w.correct = ratio[0]
                            b1.matches.add(w)
                            b1.refresh_words()
                            b2.clear()
                        elif trace:
                            print('Discarded (OVERLAP)')
                    # elif trace:
                    #    print('Candidate: %s (%s, %.2f, %.2f) => %s' % (w.correct, w.orig, ratio[1], w.confidence, ratio[0]))
            # elif trace and 0.0 <= angle <= 0.2 and distance < 6.0 * max_height:
            #    print('Blocks outside bookspine: (%.2f, %.2f)' % (angle, distance), b1.words(), b2.words())

        # Go through all non-dictionary words and try corrections
        words_to_remove = []
        for w in [w for w in other_words if w.in_area(b1.center, 1.5 * max_height)]:
            distance = bookspine_distance(b1, w)
            box = Box(convex_for_points(np.concatenate((b1.box, w.box))))
            if (distance < 1.5 * max_height and len(
                    w.correct) > 1 or distance < 1.0 * max_height) and box.height < 1.5 * max_height:
                # or np.pi/2 - 0.2 <= angle <= np.pi/2 and box_height(b1.box) < 0.19 * max_height and box_height(w.box) < 0.19 * max_height:
                # Check if blocks has word in the keys
                if len(re.sub('[\;\(\)\"\,\/\&\!\?\:\.\-\*\·\|\+\$\'\«\@\•]', '', w.correct)) > 0:
                    ratio = process.extractOne(w.correct, b1.keys, scorer=fuzz.ratio)
                    if ratio[1] > threshold and w.confidence > 0.50:
                        if trace:
                            # print('Corrected word found for ', b1.words())
                            print('%s (%s, %.2f, %.2f) => %s' % (w.correct, w.orig, ratio[1], w.confidence, ratio[0]))
                        if not is_overlap_blocks(box, confident_blocks, exclude=[b1]):
                            w.correct = ratio[0]
                            b1.matches.add(w)
                            b1.refresh_words()
                            words_to_remove.append(w)
                        elif trace:
                            print('Discarded (OVERLAP)')
                    # elif trace:
                    #    print('Candidate: %s (%s, %.2f, %.2f) => %s' % (w.correct, w.orig, ratio[1], w.confidence, ratio[0]))

        # Remove linked words from the list
        other_words.difference_update(words_to_remove)

    delete_empty(blocks)

    #if trace:
    #    show_blocks(img, blocks)

    # Take most confident 30% of the blocks
    confident_score = [-b.confident(max_height) for b in blocks]
    confidence_idx = np.argsort(confident_score)
    confident_blocks[:] = [blocks[i] for i in confidence_idx if -confident_score[i] >= 5.0]
    if len(confident_blocks) <= 4:
        confident_blocks[:] = [blocks[i] for i in confidence_idx[:len(blocks) // 4]]

    if len(blocks) > 0 and not corrupted:
        max_height = max_block_height(blocks)

    # Merge overlap blocks
    # for b1 in blocks:
    for b1 in confident_blocks:
        if b1.empty():
            continue
        # Check if blocks overlap
        for b2 in [b for b in blocks if b.in_area(b1.center, 0.5 * (b1.height + b2.height))]:
            if b1 == b2 or b2.empty():
                continue

            # Unmatched overlaps with matched Or unmatched overlap with smaller unmatched
            if is_overlap(b2.box, b1.box):
                box = Box(convex_for_points(np.concatenate((b1.box, b2.box))))
                overlap = max(minrect_area(b1.box), minrect_area(b2.box)) / minrect_area(
                    np.concatenate((b2.box, b1.box)))
                if trace:
                    print('Overlap found (', overlap, ') ', b1.words(), b2.words())
                # If block inside other block => merge
                if overlap > 0.5 and box.height < 1.5 * max_height:
                    if trace:
                        print('Overlap blocks merged (', overlap, ')', b1.words(), b2.words())
                    b1.merge_with(b2)
                elif trace:
                    print('Overlap blocks NOT merged (', overlap, ')', b1.words(), b2.words())
                    # print(bb.book_names(), sb.book_names())

    delete_empty(blocks)

    # Merge overlaped non-dictionary words
    # for b1 in blocks:
    for b1 in blocks:
        if b1.empty():
            continue
        # Go through all blocks and merge if it's on the same bookspine and belong to same book
        words_to_remove = []
        for w in [w for w in other_words if w.in_area(b1.center, 0.5 * (b1.height + w.height))]:
            # Unmatched overlaps with matched Or unmatched overlap with smaller unmatched
            if is_overlap(b1.box, w.box):
                if trace:
                    print('Overlap with words found ', b1.words(), w.correct)
                box = Box(convex_for_points(np.concatenate((b1.box, w.box))))
                if box.height < 1.5 * max_height:
                    # overlap = max(minrect_area(b1.box), minrect_area(w.box)) / minrect_area(np.concatenate((b1.box, w.box)))
                    # If block inside other block => merge
                    # if overlap > 0.8:
                    b1.unmatched.add(w)
                    b1.set_box(box_for_words(b1.matches.union(b1.unmatched)))
                    words_to_remove.append(w)
                    # elif trace:
                    #    print('Overlap is small to merge (%.2f):' % overlap, b1.words(), w.correct)
                elif trace:
                    print('Overlap is too long (%d):' % (box.height), b1.words(), w.correct)

        # Remove linked words from the list
        other_words.difference_update(words_to_remove)

    # Take most confident 30% of the blocks
    confident_score = [-b.confident(max_height) for b in blocks]
    confidence_idx = np.argsort(confident_score)
    confident_blocks[:] = [blocks[i] for i in confidence_idx if -confident_score[i] >= 5.0]
    if len(confident_blocks) <= 4:
        confident_blocks[:] = [blocks[i] for i in confidence_idx[:len(blocks) // 4]]

    to_remove = []
    for b in confident_blocks:
        if b in to_remove:
            continue
        overlap = is_overlap_blocks(b, confident_blocks, exclude=[b], give_overlap=True)
        if len(overlap) > 0:
            to_remove.append(b)
            to_remove.extend(overlap)

    confident_blocks[:] = [b for b in confident_blocks if b not in to_remove]

    if trace:
        print('ALL BLOCKS')
        #show_blocks(img, blocks)
        print('CONFIDENT BLOCKS')
        #show_blocks(img, confident_blocks)
        for b in confident_blocks:
            print(b.words())

    return confident_blocks


def bookspine_distance(b1, b2, trace=False):
    overlap = 0.0
    if is_overlap(b1.box, b2.box):
        overlap = max(minrect_area(b1.box), minrect_area(b2.box)) / minrect_area(np.concatenate((b2.box, b1.box)))
        if overlap > 0.7:
            # Consider minimum distance
            return 0

    # if trace:
    #    print('Overlap:', overlap)

    distance = 1000000
    angle, d, _ = box_position(b1, b2)
    # if trace:
    #    print('Angle:', angle)

    if 0.0 <= angle <= 0.08 or overlap > 0.4:
        distance = d

    # angle, d = box_position(b2, b1)
    # if 0.0 <= angle <= 0.08 and d < distance:
    #    distance = d

    return distance


# Calculate relation features for two boxes
def box_position(b1, b2, trace=False):
    p1, h = b1.center, (0.5 * b1.height * np.cos(b1.angle), 0.5 * b1.height * np.sin(b1.angle))
    c1_start, c1_end = p1 + h, p1 - h

    p2, h = b2.center, (0.5 * b2.height * np.cos(b2.angle), 0.5 * b2.height * np.sin(b2.angle))
    c2_start, c2_end = p2 + h, p2 - h

    # Flip direction of central line if cos is negative (obtuse angle)
    l1 = c1_end - c1_start
    l2 = c2_end - c2_start
    c = p2 - p1
    dot = np.dot(l1, c)
    if dot < 0:
        c1_start, c1_end, dot, l1 = c1_end, c1_start, -dot, -l1

    # Angle between central line of bigger (b1) rectangle and line between centers of rectangles
    cos = dot / np.sqrt(np.sum(l1 ** 2)) / np.sqrt(np.sum(c ** 2))
    # Correct the value in case of precision error
    if cos > 1:
        cos = 1.0

    if cos < -1:
        cos = -1.0

    alpha = np.arccos(cos)

    dot = np.dot(l1, l2)
    if dot < 0:
        c2_start, c2_end, dot, l2 = c2_end, c2_start, -dot, -l2

    # Angle between central line of bigger (b1) rectangle and central line of smaller rectangle
    cos = dot / np.sqrt(np.sum(l1 ** 2)) / np.sqrt(np.sum(l2 ** 2))
    # Correct the value in case of precision error
    if cos > 1:
        cos = 1.0

    if cos < -1:
        cos = -1.0

    theta = np.arccos(cos)

    # Distance between centers of the boxes
    distance = np.sqrt(np.sum(c ** 2))

    if trace:
        x = np.amax(np.concatenate((b1[:, 0], b2[:, 0])))
        y = np.amax(np.concatenate((b1[:, 1], b2[:, 1])))
        mask = np.zeros((y + 1, x + 1), dtype=np.uint8)
        cv2.drawContours(mask, [b1], 0, 255, 10)
        cv2.drawContours(mask, [b2], 0, 255, 10)
        cv2.circle(mask, (c1_end[0], c1_end[1]), 3, 1, -1)
        # cv2.circle(mask, (c2_end[0], c2_end[1]), 3, 1, -1)
        #plot_img(mask, show=True, h=6, w=8)
        print('alpha, distance, theta: ', alpha, distance, theta)

    return alpha, distance, theta


# Function check that two boxes are on the same central line, have same angles and close to each over
def is_aligned(b1, b2, gap=0.1, trace=False):
    alpha1 = b1.angle
    alpha2 = b2.angle
    theta = box_angle(np.concatenate((b1.box, b2.box)), longside=True)
    d1 = diff_angle(alpha1, alpha2)
    d2 = diff_angle(alpha1, theta)
    d3 = diff_angle(alpha2, theta)
    # if trace:
    #    print('Angles differences %d, %d, %d' % (d1/np.pi*180, d2/np.pi*180, d3/np.pi*180))

    return d1 < 0.1 and d2 < 0.1 and d3 < 0.1 and d(b1.center - b2.center) < 0.5 * (1.0 + gap) * (b1.height + b2.height)


# Function to check if box is overlap with list of boxes
def is_overlap_blocks(box, blocks, exclude=None, give_overlap=False):
    overlap = 0
    results = []
    for b in [b for b in blocks if b.in_area(box.center, 0.5 * (box.height + b.height))]:
        if exclude is not None and b in exclude or b.empty():
            continue
        if is_overlap(box.box, b.box):
            overlap += 1
            if give_overlap:
                results.append(b)

    if give_overlap:
        return results
    else:
        return overlap


# ***************************************************************************************************************


# Function to join blocks with text across bookspine
def merge_along_confident(blocks, confident_blocks, other_words, img, corrupted=False, threshold=60, trace=False):
    if trace:
        print('CONFIDENT vs BLOCKS:')
        #show_blocks(img, blocks, highlight=[b.box for b in confident_blocks])

    # Connect small blocks to the bigger blocks (should I do only matched ones)
    if len(blocks) > 0 and not corrupted:
        max_height = max_block_height(blocks)
    elif len(confident_blocks) > 0:
        max_height = max_block_height(confident_blocks)
    else:
        max_height = max_block_height(other_words)

    confident_blocks[:] = [b for b in confident_blocks if b.height > 0.2 * max_height]

    # Break down all blocks into words and join with other words
    new_blocks = [Block([w]) for w in other_words]

    # Disassemble all non-confident blocks to merge it back (need it to avoid sticked books)
    for b in set(blocks) - set(confident_blocks):
        new_blocks.extend([Block([w]) for w in b.unmatched.union(b.matches)])

    if trace:
        print('CONFIDENT vs WORDS:')
        #show_blocks(img, new_blocks, highlight=[b.box for b in confident_blocks])
        print('Blocks to arrange:', [b.words() for b in new_blocks])

        # print('SEARCH BLOCK:')
        # show_blocks(img, [b for b in new_blocks if len(set(b.words()).intersection(set(['svine', 'chcemt', 'hos']))) > 0], highlight = [b.box for b in new_blocks if len(set(b.words()).intersection(set(['beki']))) > 0])
        # [b for b in new_blocks if len(set(b.words()).intersection(set(['моринтири','hos','beki','bwjovoni', 'chcemt','pybobomnitel','диауанаадолыг','omapod','донишукахои','svine']))) > 0]
        # [b.box for b in new_blocks if len(set(b.words()).intersection(set(['txbmc','рои','koppvot','пәһи','опиген','джеймс','свіind','pupoae']))) > 0]

        # 'svine', 'chcemt', 'hos'

    alignment_blocks = [b for b in confident_blocks]

    for cycle in range(4):
        aligments = False
        # Which confident book is a closest for the block
        confident_book = {}

        # Distance to the confident block to align to
        alignment_distance = [100000] * len(new_blocks)

        # Iterate through blocks to find nearest confident book
        for i, b1 in enumerate(new_blocks):
            # Find closest confident book and a section parallel to it
            # which goes through center of the given block
            # TODO:  if b1.in_area(c.center, 0.5 * (b1.height + c.height) (PERFORMANCE)
            distances = [box_distance(b1.box, c) for c in alignment_blocks]
            center_index = np.argsort(distances)

            # TODO: Skip lines shifter far left/right
            for j in center_index:
                # Skip alignment with self (for second cycle)
                if alignment_blocks[j] == b1:
                    continue

                line = bookspine_line(b1, alignment_blocks[j], max_height)

                # if trace and cycle >= 1 and 'эхадорн' in b1.words():
                #    print('LINE FOR BLOCK эхадорн:', line)
                #    show_blocks(img, [b1], highlight=[alignment_blocks[j].box])

                if line is not None:
                    if b1 in confident_book:
                        # Only add line if the angle is not much different
                        eps = diff_angle(confident_book[b1][0].angle, alignment_blocks[j].angle)
                        if eps < 0.3:
                            confident_book[b1].append(alignment_blocks[j])
                            alignment_distance[i] = distances[j]
                            # if trace:
                            #    print('LINE FOR BLOCK')
                            #    show_blocks(img, [alignment_blocks[j], b1], lines=[line])
                            if len(confident_book[b1]) >= 2:
                                break
                        elif trace:
                            print('Second line discarded (angle): %.1f' % (eps * 180 / np.pi))
                    else:
                        # Long blocks should not have much different angle
                        eps = diff_angle(b1.angle, alignment_blocks[j].angle)
                        if b1.height < 0.25 * max_height or eps < 0.3:
                            confident_book[b1] = [alignment_blocks[j]]
                            alignment_distance[i] = distances[j]
                            # if trace:
                            #    print('LINE FOR BLOCK')
                            #    show_blocks(img, [alignment_blocks[j], b1], lines=[line])

                        elif trace:
                            print('Line discarded (angle): %.1f' % (eps * 180 / np.pi))

            # if trace and cycle == 4 and 'эхадорн' in b1.words():
            #    print('LINES FOR BLOCK эхадорн:')
            #    show_blocks(img, [b1], highlight=[b.box for b in confident_book[b1]])

        # Sort by distance to the closest blocks
        # block_index = np.argsort(alignment_distance)

        # Sort by block size (WORKS BETTER)
        block_index = np.argsort([-b.height for b in new_blocks])

        # Iterate through blocks starting from closest to the confident books
        for i in block_index:
            b1 = new_blocks[i]
            # Skip empty blocks and blocks not aligned to confident books
            if b1.empty() or b1 not in confident_book or len(confident_book[b1]) == 0:
                continue

            line = bookspine_line(b1, confident_book[b1][0], max_height)

            # Line is not none as it was checked in previous cycle
            if line is None:
                # print('LINE IS EMPTY')
                continue

            overlap = blocks_on_line(line, new_blocks, exclude=[b1])
            if trace:
                print('Blocks found on the line:', len(overlap))

            # candidates = []
            # distances = []
            for b2 in overlap:
                # if trace and len(set(b1.words()).intersection(set(['alekcang']))) > 0:
                #    print('ALIGNMENT LINE:')
                #    show_blocks(img, [b1, b2], highlight = [confident_book[b1][0].box], lines=[line])

                # Skip empty blocks block not aligned to confident books or alligned to different confident book
                # Remove check for box size b2.height > b1.height or
                if b1 == b2 or b2.empty() or b2 not in confident_book or len(
                        set(confident_book[b2]).intersection(set(confident_book[b1]))) == 0:
                    if trace and b2 not in confident_book:
                        print(b2.words(), 'has NO ALIGNMENT line (discarded)')
                    elif trace and len(set(confident_book[b2]).intersection(set(confident_book[b1]))) == 0:
                        # if b1 == b2 or b2.empty() or b2 not in confident_book or confident_book[b1][0] not in confident_book[b2]:
                        #    if trace and (b2 not in confident_book or confident_book[b1][0] not in confident_book[b2]):
                        print(b2.words(), 'and', b1.words(), 'aligned to DIFFERENT book')
                        # if trace and 'зоология' in b1.words():
                        #    print('ALIGNMENT LINES:')
                        #    al = [b.box for b in confident_book[b1]]
                        #    show_blocks(img, [b1, b2], highlight=al)
                        #    al = [b.box for b in confident_book[b2]]
                        #    show_blocks(img, [b1, b2], highlight=al)

                    elif trace and b2.height > b1.height:
                        print(b2.words(), 'and', b1.words(), 'alignment to BIGGER block discarded')
                    continue
                eps = diff_angle(b2.angle, line_angle(line[0], line[1]))
                if b2.height < 0.12 * max_height or eps < 0.2 or (
                        abs(eps - np.pi / 2) < 0.2 and b2.height < 0.2 * max_height):
                    box = Box(convex_for_points(np.concatenate((b1.box, b2.box))))
                    if not is_overlap_blocks(box, confident_blocks, exclude=[b1, b2]) and box.height < 1.2 * max_height:
                        # candidates.append(b2)
                        # distances.append(d(b1.center-b2.center))
                        if trace:
                            print(b2.words(), 'and', b1.words(), 'ALIGNED and merged')
                        if b2 not in alignment_blocks:
                            aligments = True
                            b1.merge_with(b2, force=True)
                        elif b2 in alignment_blocks and b1 not in alignment_blocks:
                            aligments = True
                            b2.merge_with(b1, force=True)
                            b1 = b2
                        elif b2 in alignment_blocks and b1 in alignment_blocks:
                            b1.merge_with(b2, force=True, remove=False)
                            if trace:
                                print('Discarded (both are alignment):', b1.words(), b2.words())

                    elif trace:
                        print('Discarded (overlap/too big):', b1.words(), b2.words())
                elif trace:
                    print('Discarded angle too big (%d):' % (eps / np.pi * 180), b1.words(), b2.words())

            # if len(candidates) > 0:
            #    idx = distances.index(min(distances))
            #    b2 = candidates[idx]

        delete_empty(new_blocks)

        # Merge overlaped blocks
        for b1 in new_blocks:
            if b1.empty():
                continue
            # Check if blocks overlap
            for b2 in new_blocks:
                if b1 == b2 or b2.empty():
                    continue

                # Unmatched overlaps with matched Or unmatched overlap with smaller unmatched
                if is_overlap(b2.box, b1.box):
                    box = Box(convex_for_points(np.concatenate((b1.box, b2.box))))
                    if not is_overlap_blocks(box, confident_blocks, exclude=[b1, b2]) and box.height < 1.5 * max_height:
                        if trace:
                            print('Blocks merged: ', b1.words(), b2.words())
                        # Merge blocks
                        b1.merge_with(b2, force=True)
                    elif trace:
                        print('Overlap blocks conflict with confident:', b1.words(), b2.words())

        delete_empty(new_blocks)
        delete_empty(alignment_blocks)

        # TODO: Avoid deleting confidend blocks
        delete_empty(confident_blocks)

        alignment_blocks.extend([b for b in new_blocks if b.height > 0.5 * max_height and b not in alignment_blocks])
        new_blocks.extend([b for b in alignment_blocks if b not in new_blocks])

        if trace:
            print('ALIGNED BLOCKS (cycle %d):' % (cycle + 1))
            #show_blocks(img, new_blocks, highlight=[b.box for b in alignment_blocks])

        # Exit before 4 cycles if no aligments done
        if not aligments:
            break

    blocks[:] = new_blocks

    if trace:
        print('ALL BLOCKS AFTER MERGE ALONG THE CONFIDENT')
        #show_blocks(img, blocks)

    return


# Return alleged bookspine line based on the given confident bookspine
def bookspine_line(box, base, max_height, trace=False):
    # #D vector to calculate perpendicular using cross product
    Z = np.array([0, 0, 1])

    h = (0.5 * base.height * np.cos(base.angle), 0.5 * base.height * np.sin(base.angle))
    A, B, C = base.center + h, base.center - h, box.center

    s1, s2 = B - A, A - C

    # Vector for the height (from line AB to the point C)
    H = np.cross(s1, Z)[:2] / np.linalg.norm(np.cross(s1, Z)[:2]) * np.cross(s1, s2) / np.sqrt(np.sum(s1 ** 2))

    A1, B1 = A + H, B + H

    # Check if points are within the section
    outside = True
    for p in box.box:
        if in_section(p, A1, B1):
            outside = False

    if outside:
        return None
    else:
        # Adjust line if box angle is slightly different than alignment line
        alpha = box.angle
        theta = line_angle(A1, B1)
        eps = diff_angle(alpha, theta)
        # Angles are close to each other and block is bigger than cross-line make a correction rotation
        if eps < 0.4 and box.height > 0.08 * max_height:
            if trace:
                print('Line rotated', eps / np.pi * 180, 'degrees')
            A1 = rotate(C, A1, alpha - theta)
            B1 = rotate(C, B1, alpha - theta)

        return np.int0(np.array([A1, B1]))


# ***************************************************************************************************************


# Search for books with all words in the block
def lookup_books(cursor, blocks, confident_blocks, threshold=60, trace=False):
    for b in blocks:
        if b.empty():
            continue

        # Lookup book in MySQL database
        b.lookup(cursor, threshold=threshold, trace=trace)

    # Consider not confident blocks with less than 3 matches and small in size
    confident_blocks[:] = [b for b in blocks if b.book is not None]

    return

# ***************************************************************************************************************


# Function to merge smaller text blocks (usually publisher) to the rest of the bookspine
def merge_publisher(blocks, confident_blocks, other_words, img, corrupted=False, trace=False):
    delete_empty(confident_blocks)

    if trace:
        print('ALL BLOCKS')
        # show_words(img, [w for w in other_words if w.correct == 'faberar'])
        # show_blocks(img, blocks)

    if len(blocks) > 0 and not corrupted:
        max_height = max_block_height(blocks)
    else:
        max_height = max_block_height(confident_blocks)

    publisher_blocks = [b for b in list(set(blocks) - set(confident_blocks)) if b.height < 0.2 * max_height]
    book_blocks = [b for b in blocks if b.height > 0.5 * max_height or b in confident_blocks]
    validation_blocks = [b for b in blocks if b not in publisher_blocks]

    for b1 in publisher_blocks:
        if b1.empty():
            continue

        if trace:
            print('-------------------------------------------')
            print('LOOKING FOR BOOK FOR: ', b1.words())

        # Go through confident blocks and find the closest one to merge with
        blocks_to_link = []
        distances = []
        # Go through all near by blocks
        for b2 in [b for b in book_blocks if b.in_area(b1.center, 1.5 * max_height)]:
            if b2.empty() or b1 == b2:
                continue

            if trace:
                print('Trying to merge with block:', b2.words())

            distance = bookspine_distance(b2, b1)
            box = Box(convex_for_points(np.concatenate((b1.box, b2.box))))
            if distance < 2.0 * max_height and box.height < 1.5 * max_height:
                if not is_overlap_blocks(box, validation_blocks, exclude=[b1, b2]):
                    if trace:
                        print('Block found for merge (%d):' % distance, b2.words())
                    blocks_to_link.append(b2)
                    distances.append(distance)
                elif trace:
                    print('Resulting block overlap with:', [b.words() for b in
                                                            is_overlap_blocks(box, validation_blocks, exclude=[b1, b2],
                                                                              give_overlap=True)])
            elif trace:
                print('Resulting block too long (%d, %d):' % (distance, box.height / max_height), b2.words())

        # Check which block is closest one
        if len(blocks_to_link) > 0:
            i = distances.index(min(distances))
            blocks_to_link[i].merge_with(b1, force=True)

    delete_empty(blocks)

    if trace:
        print('AFTER PUBLISHER MERGE')
        # show_blocks(img, blocks)

    return

# **************************************************************************************************************


# Find blocks which reads up-side-down and run text recognition again for isolated block
def rotate_corrupted(cursor, blocks, confident_blocks, other_words, img, trace=False):
    if trace:
        print('ALL BLOCKS:')
        # show_blocks(img, blocks)
        print('CONFIDENT BLOCKS:')
        # show_blocks(img, confident_blocks)

    if len(blocks) == 0:
        return

    max_height = max_block_height(blocks)

    if trace:
        print('AVERAGE HEIGHT:', max_height)

    corrupted_blocks = []
    # Add blocks which are matched but have many corrupted words
    for b in blocks:
        # Skip block if only matched
        if b.empty() or len(b.unmatched) == 0 or b in confident_blocks:
            continue

        corrupted = 0
        # EURISTIC: confidence less 0.8 for 50% of words and
        # for blocks with 4 words and above
        for w in b.unmatched:
            if w.confidence < 0.8:
                corrupted += 1
        corruptness = corrupted / (len(b.unmatched) + len(b.matches))
        # if trace:
        #    print('CORRUPTED:', b.words(), corrupted, corruptness, b.confidence())

        if corruptness > 0.35 and len(b.unmatched) >= 2:
            corrupted_blocks.append(b)
            if trace:
                print('BLOCK IDENTIFIED:', b.confidence(), b.words())

    if trace:
        print('CORRUPTED BLOCKS:')
        #show_blocks(img, corrupted_blocks)

    # Rotate and resove
    corrected_blocks = []
    for b in corrupted_blocks:

        if b.empty():
            continue

        # Consider all blocks except current as confident
        new_blocks = recognize_block(b, [b2 for b2 in blocks if b2 != b], img, max_height, trace)

        if len(new_blocks) > 0:
            confidence = np.average([b.confidence() for b in new_blocks])
            words_count = np.sum([len(b.words()) for b in new_blocks])
            if confidence > b.confidence() and words_count > len(b.words()) * 0.5:
                if trace:
                    print('Rotated blocks (%d) has HIGHER confidence: (%.2f, %d)/(%.2f, %d)' % (
                    len(new_blocks), confidence, words_count, b.confidence(), len(b.words())))
                # TODO: Do we need to clean ot only remove current block?!
                clean_overlap(blocks, new_blocks, trace=trace)
                corrected_blocks.extend(new_blocks)

                if trace and len(new_blocks) > 0:
                    print(len(new_blocks), 'BLOCKS FOUND IN CORRUPTED REGION')
                    for nb in new_blocks:
                        print(nb.words())
                    #show_blocks(img, new_blocks)

            elif trace:
                print('Rotated block has LOWER confidence:', confidence, b.confidence())
        elif trace:
            print('No new blocks recognised')

    for b in corrected_blocks:
        b.lookup(cursor, trace=trace)

    if trace:
        print('CORRECTED BLOCKS:')
        #show_blocks(img, corrected_blocks)

    blocks.extend(corrected_blocks)

    # Take most confident 30% of the blocks
    confident_score = [-b.confident(max_height) for b in blocks]
    confidence_idx = np.argsort(confident_score)
    confident_blocks[:] = [blocks[i] for i in confidence_idx if -confident_score[i] >= 5.0]
    if len(confident_blocks) <= 4:
        confident_blocks[:] = [blocks[i] for i in confidence_idx[:len(blocks) // 4]]

    if trace:
        print('ALL BLOCKS')
        #show_blocks(img, blocks)
        print('CONFIDENT BLOCKS')
        #show_blocks(img, confident_blocks)

    return


def extract_region(img, box, trace=False):
    contour = np.array([box])
    theta = box_angle(box)

    # rotate img
    if theta > np.pi * 0.5:
        theta = theta - np.pi

    x, y, w, h = cv2.boundingRect(contour)

    maxY, maxX = img.shape[:2]
    marginX, marginY = np.int0(0.1 * w), np.int0(0.1 * h)

    w, h = w + 2 * marginX, h + 2 * marginY
    x, y = x - marginX, y - marginY

    if x < 0:
        w, x = w - x, 0

    if y < 0:
        h, y = h - y, 0

    if x + w >= maxX:
        w = maxX - x - 1

    if y + h >= maxY:
        h = maxY - y - 1

    rx = w // 2
    ry = h // 2

    # crop source
    d1 = np.array([x, y])
    img_crop = img[y:y + h, x:x + w]
    contour[:, :, 0] = contour[:, :, 0] - x
    contour[:, :, 1] = contour[:, :, 1] - y

    if trace:
        print('Image before rotation: ', img_crop.shape)
        #plot_img(img_crop, show=True)
        print('Contour before rotation: ', contour)
        print('Bounding rectangle: ', x, y, w, h)
        print('Rotation centre: ', rx, ry)

    # grab the rotation matrix
    M = cv2.getRotationMatrix2D((rx, ry), theta / np.pi * 180, 1)

    # grab the sine and cosine (i.e., the rotation components of the matrix)
    cos = np.abs(M[0, 0])
    sin = np.abs(M[0, 1])

    # compute the new bounding dimensions of the image
    nW = int((h * sin) + (w * cos))
    nH = int((h * cos) + (w * sin))

    # adjust the rotation matrix to take into account translation
    M[0, 2] += (nW / 2) - rx
    M[1, 2] += (nH / 2) - ry

    # rotate contour
    contour_rot = np.int0(cv2.transform(contour, M))[0]

    # Rotate image
    img_rot = cv2.warpAffine(img_crop, M, (nW, nH))

    if trace:
        print('Image after rotation: ', img_rot.shape)
        #plot_img(img_rot, show=True)

    # mask = np.zeros(img_rot.shape[0:2])
    # cv2.drawContours(mask, np.array([contour_rot]), -1, 255, -1)
    # img_masked = np.zeros_like(img_rot)
    # img_masked[mask == 255] = img_rot[mask == 255]

    # crop
    x, y, w, h = cv2.boundingRect(contour_rot)

    maxY, maxX = img_rot.shape[:2]
    marginX, marginY = np.int0(0.2 * w), np.int0(0.05 * h)
    w, h = w + 2 * marginX, h + 2 * marginY
    x, y = x - marginX, y - marginY

    if x < 0:
        w, x = w - x, 0

    if y < 0:
        h, y = h - y, 0

    if x + w >= maxX:
        w = maxX - x - 1

    if y + h >= maxY:
        h = maxY - y - 1

    d2 = np.array([x, y])

    # img_crop = img_masked[y:y + h, x:x + w]
    img_crop = img_rot[y:y + h, x:x + w]
    if trace:
        print('Image cropped:', img_crop.shape)
        #plot_img(img_crop, show=True)

    return img_crop, M, d1, d2


# Re-run image recognition for the region of the image
def recognize_block(block, top_blocks, img, max_height, trace=False):
    # print(block.box)
    img_crop, M, d1, d2 = extract_region(img, block.box, trace=False)
    iM = cv2.invertAffineTransform(M)

    response = ocr_image(img_crop)

    # Extract blocks from Google Cloud Vision responce
    words = extract_words(response, img_crop, trace=False)

    if trace:
        print('Words extracted: words=%d' % (len(words)))

    for w in words:
        w.box = transform(w.box, iM, d1, d2)

    # Merge neaby blocks along the same bookspine (by angle, distance and size)
    blocks = []
    # Copy input blocks to keep original list
    confident_blocks = [b for b in top_blocks]

    # Merge cross lines
    merge_along_confident(blocks, confident_blocks, words, img, corrupted=True, trace=False)

    # Merge smaller blocks with text not in the title/author (usually publisher)
    merge_publisher(blocks, confident_blocks, words, img, corrupted=True, trace=False)

    # Exclude original confident blocks
    # blocks = [b for b in blocks if b not in confident_blocks]

    # Remove blocks which were already there
    blocks = [b for b in blocks if b not in top_blocks]

    if trace:
        for b in blocks:
            print(b.words())

    return blocks


# Delete old blocks which overlap with new blocks
def clean_overlap(blocks, new_blocks, trace=False):
    # Merge overlap blocks
    for b1 in new_blocks:
        if b1.empty():
            continue
        # Check if blocks overlap
        for b2 in blocks:
            if b1 == b2 or b2.empty():
                continue

            # Unmatched overlaps with matched Or unmatched overlap with smaller unmatched
            if is_overlap(b2.box, b1.box):
                overlap = max(minrect_area(b1.box), minrect_area(b2.box)) / minrect_area(
                    np.concatenate((b2.box, b1.box)))
                if trace:
                    print('Overlap found to clean (', overlap, ') ', b1.words(), b2.words())
                if overlap > 0.7:
                    if trace:
                        print('Overlap cleaned (', overlap, ') ', b1.words(), b2.words())
                    b2.clear()

    delete_empty(blocks)

# *************************************************************************************************************


# Function to merge text blocks belong to the same book by text
def merge_book_fragments(blocks, confident_blocks, img, corrupted=False, trace=False):
    if len(blocks) > 0 and not corrupted:
        max_height = max_block_height(blocks)
    else:
        max_height = max_block_height(confident_blocks)

    book_blocks = [b for b in blocks if b.book is not None]
    unmatched_blocks = [b for b in blocks if b.book is None]

    if trace:
        print('BOOK & UNMATCHED BLOCKS')
        #show_blocks(img, unmatched_blocks, highlight=[b.box for b in book_blocks])

    for b1 in book_blocks:
        if b1.empty():
            continue
        if trace:
            print('-------------------------------------------')
            print('LOOKING FOR SAME BOOK: ', b1.words())

        # Find the block with the same book
        for b2 in [b for b in book_blocks if not b.empty() and b != b1 and b.in_area(b1.center,
                1.5 * max_height) and b.book.isbn == b1.book.isbn]:
            if b2.empty():
                continue

            if trace:
                print('Candidate for the same book found:', b2.words())

            # Check that it's not an another copy of the same book
            missing = set(b1.keys) - set([w.correct for w in b1.matches])
            isect = missing.intersection(set([w.correct for w in b2.matches]))
            if len(isect) > 0:
                if trace:
                    print('Blocks for the same book found:', b1.words(), b2.words())
                b1.merge_with(b2)

    delete_empty(book_blocks)
    delete_empty(blocks)

    if trace:
        print('AFTER FRAGMENT MERGE')
        #show_blocks(img, blocks)

    return

# *************************************************************************************************************


# Function to keep unknown books into DB for further processing
# TODO: Keep in DB instead of printing
def list_unknown(cursor, blocks, threshold=60, trace=False):
    unmatched_blocks = [b for b in blocks if b.book is None]

    # Try to lookup book in MySQL database again (after merges it might be found)
    for b in unmatched_blocks:
        b.lookup(cursor, threshold=threshold, trace=False)

    unmatched_blocks = [b for b in blocks if b.book is None]

    if trace:
        for b in unmatched_blocks:
            print(b.bookspine)

    return unmatched_blocks

# *************************************************************************************************************


# Function to remove small blocks with low confidence
def remove_noise(blocks, confident, unknown, threshold=0.30, trace=False):
    # Only clean matched blocks. Otherwise there is a ridsk to remove valuable words
    for b in unknown:
        removed = set()
        for w in b.unmatched:
            if len(w.correct) < 2 and w.confidence < threshold:
                if trace:
                    print('Remove noise: %.2f' % (w.confidence), w.correct)
                removed.add(w)

        # Remove noise words and recalculate box
        if len(removed) > 0:
            b.unmatched.difference_update(removed)
            if len(b.words()) > 0:
                b.set_box(box_for_words(b.matches.union(b.unmatched)))

    delete_empty(unknown)

    for b in confident:
        removed = set()
        for w in b.unmatched:
            if w.confidence < threshold:
                if trace:
                    print('Remove noise: %.2f' % (w.confidence), w.correct)
                removed.add(w)

        # Remove noise words and recalculate box
        if len(removed) > 0:
            b.unmatched.difference_update(removed)
            if len(b.words()) > 0:
                b.set_box(box_for_words(b.matches.union(b.unmatched)))

    delete_empty(confident)

    if len(blocks) == 0:
        return

    max_height = max_block_height(blocks)

    if trace:
        print('AVERAGE BOOK HEIGHT: ', max_height)

    for b in unknown:
        if b.height < 0.2 * max_height:
            if trace:
                print('Block deleted:', b.words())
            b.clear()

    delete_empty(blocks)
    delete_empty(unknown)
    delete_empty(confident)

    return

#TODO-AVEA: don't merge
def test_func():
    print('its work!')

#TODO-AVEA: don't merge
#testing run
if __name__ == '__main__':
    test_func()
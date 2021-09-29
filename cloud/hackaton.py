import main as mn
from flask import json
import traceback
from wand.image import Image

INPUT_PHOTO_FILE_NAME = 'input_photo'

# HTTP API
# Deploy with:
# gcloud functions deploy recognize_photo --runtime python37 --trigger-http --allow-unauthenticated --memory=256MB --timeout=300s
@mn.connect_mysql
def recognize_photo(request, cursor):
    print('!!!DEBUG: def recognize_photo started...')
    try:
        if 'photo' not in request.files:
            return 'File for predict is not founded', 400

        file = request.files['photo']
        print(f'Received incoming file - {file.filename}')

        img = Image.open(file)
        # img.save(INPUT_PHOTO_FILE_NAME, format='PNG')

        books = [{'title': 'Мастер и Маргарита', 'author': 'Булгаков М. А.'},
                 {'title': 'Война и мир', 'author': 'Толстой Л.Н.'},
                ]

        print('!!!DEBUG: def rescan_photo finished.')
        return json.dumps(books, cls=mn.JsonEncoder)
    except Exception as e:
        print('Exception: ', e)
        traceback.print_exc()
        return mn.json_abort(400, message="%s" % e)



# HTTP API
# Deploy with:
# gcloud functions deploy search_top_books --runtime python37 --trigger-http --allow-unauthenticated --memory=256MB --timeout=300s
@mn.connect_mysql
def search_top_books(request, cursor):
    search_string = ''
    print('!!!DEBUG: def search_top_books started...')
    try:
        params = request.get_json(silent=True)
        if params is None or 'search_string' not in params:
            mn.json_abort(400, message="Missing input parameters: search_string")

        search_string = params['search_string']
        count = params['count'] if 'search_string' in params else 5

        books = [{'title': 'Мастер и Маргарита', 'author': 'Булгаков М. А.'},
                 {'title': 'Война и мир', 'author': 'Толстой Л.Н.'},
                 {'title': 'Буратино и золотой ключик', 'author': 'Толстой А.Н.'},
                 {'title': 'Белая гвардия', 'author': 'Булгаков М. А.'},
                 {'title': 'Морфий', 'author': 'Булгаков М. А.'},
                 {'title': 'Жизнь господина де Мольера. Театральный роман', 'author': 'Булгаков М. А.'},
                 {'title': 'Собачье сердце', 'author': 'Толстой Л.Н.'}
                ]
        result = {"books": books[:count]}

        print('!!!DEBUG: def search_top_books finished.')
        return json.dumps(result, cls=mn.JsonEncoder)
    except Exception as e:
        print('Exception for search_string [%s]' % search_string, e)
        traceback.print_exc()
        return mn.json_abort(400, message="%s" % e)


# HTTP API
# Deploy with:
# gcloud functions deploy get_recomandations --runtime python37 --trigger-http --allow-unauthenticated --memory=256MB --timeout=300s
@mn.connect_mysql
def get_recomandations(request, cursor):
    like_books = []
    unlike_books = []
    print('!!!DEBUG: def get_recomandations started...')
    try:
        params = request.get_json(silent=True)
        if params is None or 'like_books' not in params or 'unlike_books' not in params:
            mn.json_abort(400, message="Missing input parameters: like_books/unlike_books")

        like_books = params['like_books']
        unlike_books = params['unlike_books']

        books = [{'title': 'Мастер и Маргарита',
                  'author': 'Булгаков М. А.',
                  'image': 'https://cdn1.ozone.ru/multimedia/c250/1011707407.jpg',
                  'description': 'Роман Михаила Афанасьевича Булгакова, работа над которым началась в декабре 1928 года и продолжалась вплоть до смерти писателя. Роман относится к незавершённым произведениям; редактирование и сведение воедино черновых записей осуществляла после смерти мужа вдова писателя - Елена Сергеевна. Первая версия романа, имевшая названия «Копыто инженера», «Чёрный маг» и другие, была уничтожена Булгаковым в 1930 году. В последующих редакциях среди героев произведения появились автор романа о Понтии Пилате и его возлюбленная. Окончательное название - «Мастер и Маргарита» - оформилось в 1937 году.',
                  'pages': 333
                  },

                 {'title': 'Золотой ключик, или Приключения Буратино',
                  'author': 'Толстой Алексей Николаевич',
                  'image': 'https://cdn1.ozone.ru/s3/multimedia-9/c250/6007327593.jpg',
                  'description': 'Повесть-сказка советского писателя Алексея Толстого, представляющая собой литературную обработку сказки Карло Коллоди «Приключения Пиноккио. История деревянной куклы». А. Н. Толстой посвятил книгу своей будущей жене Людмиле Ильиничне Крестинской.',
                  'pages': 123
                  },
                 ]
        result = {"books": books}

        print('!!!DEBUG: def get_recomandations finished.')
        return json.dumps(result, cls=mn.JsonEncoder)
    except Exception as e:
        print('Exception for like_books [%s]' % like_books, e)
        traceback.print_exc()
        return mn.json_abort(400, message="%s" % e)


'''
1)recognize_photo:
  параметры файл с фоткой
  какие-то параметры о клиенте сможешь передать? id может, или данные устройства? Как-то отличать их хотя бы в логах
верну массив данных о книгах
в каждом элементе массива будет автор, название, ? еще что-то надо

2) search_top_books:
  ты передаешь строку которую ввел пользователь
верну массив данных о книгах

3) get_recomandations
  ты передаешь два массива с данными о книгах: нравятся и не нравятся
 верну массив книг рекомендаций.

Массив книг наверное будет в двух вариантах

1 вариант для строки поиска: каждый элемент содержит автора (строку) и название (строку)
2 вариант результат рекомендаций: каждый элемент содержит автора, название, ссылку на картинку, аннотацию, количество страниц, еще что-то
'''
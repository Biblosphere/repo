SERVICE_ACCOUNT_KEY_PATH = 'keys\\biblosphere-210106-dcfe06610932.json'

def test_connect_google_storage():
    from google.cloud import storage

    #storage_client = storage.Client()
    storage_client = storage.Client.from_service_account_json(SERVICE_ACCOUNT_KEY_PATH)

    # Make an authenticated API request
    buckets = list(storage_client.list_buckets())
    print(buckets)

def test_connect_firebase():
    import firebase_admin
    from firebase_admin import credentials
    from firebase_admin import firestore

    cred = credentials.Certificate(SERVICE_ACCOUNT_KEY_PATH)

    firebase_admin.initialize_app(cred, {
        'projectId': 'biblosphere-210106',
    })

    db = firestore.client()

def test_connect_mysql():
    import mysql.connector

    #cnx = mysql.connector.connect(user='biblosphere', password='biblosphere',
    #                              #unix_socket='/cloudsql/biblosphere-210106:us-central1:biblosphere',
    #                              host='35.223.45.184',
    #                              port='3306',
    #                              database='biblosphere',
    #                              use_pure=False)

    cnx = mysql.connector.connect(user='biblosphere',
                                  password='biblosphere',
                                  host='35.223.45.184',
                                  port='3306',
                                  database='biblosphere',
                                  use_pure=True)

    cnx.close()

def test_detectron_get_photo():
    import requests, shutil
    from PIL import Image
    from matplotlib import pyplot as plt
    plt.rcParams["figure.figsize"] = (50, 100)

    URL = 'https://detectron-model-ihj6i2l2aq-uc.a.run.app/predict'
    TEST_PHOTO = '../temp/test_photo.jpg'
    PREDICTED_PHOTO = '../temp/downloaded_photo.png'

    rs = requests.post(URL, data={'output_data': 'photo'}, files={'photo': open(TEST_PHOTO, 'rb')}, stream=True)
    print(rs.status_code, rs.reason)

    with open(PREDICTED_PHOTO, "wb") as receive:
        shutil.copyfileobj(rs.raw, receive)
    del rs

    im = Image.open(PREDICTED_PHOTO)
    plt.imshow(im)

def test_detectron_get_predictions():
    import requests, shutil, joblib
    import numpy as np

    URL = 'https://detectron-model-ihj6i2l2aq-uc.a.run.app/predict'
    TEST_PHOTO = '../temp/test_photo.jpg'
    PREDICTIONS_COMPRESSED_FILE = '../temp/preds.download'

    rs = requests.post(URL, data={'output_data': 'predicted_masks'}, files={'photo': open(TEST_PHOTO, 'rb')},
                       stream=True)
    print(rs.status_code, rs.reason)

    with open(PREDICTIONS_COMPRESSED_FILE, "wb") as receive:
        shutil.copyfileobj(rs.raw, receive)
    del rs

    pred_masks = joblib.load(PREDICTIONS_COMPRESSED_FILE)
    print(type(pred_masks), pred_masks.shape)
    a = 1

def test_detectron_get_predictions2():
    import requests, shutil, joblib
    import numpy as np
    from google.cloud import vision
    from google.cloud import storage
    import os
    import tools

    URL = 'https://detectron-model-ihj6i2l2aq-uc.a.run.app/predict'
    TEST_PHOTO = '../temp/test_photo.jpg'
    PREDICTIONS_COMPRESSED_FILE = '../temp/preds.download'
    TEMP_FILES_DIR = 'temp_files'

    image_path = 'gs://biblosphere-210106.appspot.com/images/UG4o5LvNMTkQ5uFsrw3rUxUeZOv62:v9u0xzj/1625630423984.jpg'

    filename = 'UG4o5LvNMTkQ5uFsrw3rUxUeZOv62:v9u0xzj/1625630423984.jpg'
    client = storage.Client()
    bucket = client.get_bucket('biblosphere-210106.appspot.com')
    b = bucket.blob(filename)
    img = tools.imread_blob(b)



    # image = vision.Image()
    # image.source.image_uri = image_path
    #
    # store = storage.Blob()
    # store.pa

    a = 1
    #import urllib.request
    #photo = urllib.request.urlopen(image_path).read()
    # with open(os.path.join(TEMP_FILES_DIR, "photo_to_predict.jpg"), "wb") as f:
    #     f.write(photo)


    with open(image, 'rb') as f:
        rs = requests.post(URL, data={'output_data': 'predicted_masks'}, files={'photo': open(TEST_PHOTO, 'rb')},
                       stream=True)
    print(rs.status_code, rs.reason)

    with open(PREDICTIONS_COMPRESSED_FILE, "wb") as receive:
        shutil.copyfileobj(rs.raw, receive)
    del rs

    pred_masks = joblib.load(PREDICTIONS_COMPRESSED_FILE)
    print(type(pred_masks), pred_masks.shape)
    a = 1





#test_detectron_get_photo()
#test_detectron_get_predictions2()

#test_connect_firebase()
#test_connect_google_storage()
#test_connect_mysql()


import numpy as np
a = np.empty(shape=(0,0), dtype='int8')
np.concatenate()

print(a.shape)

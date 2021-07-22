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

test_connect_firebase()
test_connect_google_storage()
test_connect_mysql()
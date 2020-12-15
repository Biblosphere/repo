part of "main.dart";

// Singleton class to keep single connection
class Api {
  final client = Client();

  Api._internal();

  static final _singleton = Api._internal();

  factory Api() => _singleton;
}

final api = Api();

// Function to search in catalogue in MySQL
Future<List<Book>> searchByText(String text) async {
  // Search in catalogue in MySQL
  String jwt = await FirebaseAuth.instance.currentUser.getIdToken();

  // Call Python service to recognize
  Response res = await api.client.get(
      'https://biblosphere-api-ihj6i2l2aq-uc.a.run.app/search?q=$text',
      headers: {HttpHeaders.authorizationHeader: "Bearer $jwt"});

  if (res.statusCode != 200) {
    print(
        'EXCEPTION: HTTP request failed with RC=${res.statusCode} ${res.body}');
    return null;
  } else {
    final resJson = json.decode(res.body);

    // TODO: Add language and genre once available in MySQL
    List<Book> books = List<Book>.from(resJson.map((dynamic obj) => Book(
        title: obj['title'],
        authors: obj['authors'].split(';'),
        isbn: obj['isbn'],
        cover: obj['image'])));
    return books;
  }
}

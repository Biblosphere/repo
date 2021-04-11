import 'dart:convert';
import 'dart:io';

import 'package:biblosphere/model/Book.dart';
import 'package:biblosphere/networking/ApiProvider.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BooksRepository {
  ApiProvider _provider = ApiProvider();

// Function to search in catalogue in MySQL
  Future<List<Book>> searchByText(String text) async {
    // Search in catalogue in MySQL
    String jwt = await FirebaseAuth.instance.currentUser.getIdToken();

    // Call Python service to recognize
    final response = await _provider.get('search?q=$text',
        headers: {HttpHeaders.authorizationHeader: "Bearer $jwt"});

    if (response.statusCode != 200) {
      print(
          'EXCEPTION: HTTP request failed with RC=${response.statusCode} ${response.body}');
      return null;
    } else {
      final resJson = json.decode(response.body);

      // TODO: Add language and genre once available in MySQL
      List<Book> books = List<Book>.from(resJson.map((dynamic obj) => Book(
          title: obj['title'],
          authors: obj['authors'].split(';'),
          isbn: obj['isbn'],
          cover: obj['image'])));
      return books;
    }
  }
}

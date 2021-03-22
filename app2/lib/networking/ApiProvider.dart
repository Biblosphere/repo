// Singleton class to keep single connection
import 'dart:io';

import 'package:biblosphere/networking/CustomException.dart';
import 'package:http/http.dart' as http;

class ApiProvider {
  final String _baseUrl = "https://biblosphere-api-ihj6i2l2aq-uc.a.run.app/";

  ApiProvider._internal();

  static final _singleton = ApiProvider._internal();

  factory ApiProvider() => _singleton;

  Future<dynamic> get(String url, {Map<String, String> headers}) async {
    try {
      final response = await http.get(_baseUrl + url,
          headers: headers); // тут могут быть post delete etc.
      return response;
    } on SocketException {
      throw FetchDataException('No Internet connection');
    }
  }
}

// Singleton class to keep single connection
import 'dart:convert';
import 'dart:io';

import 'package:biblosphere/networking/CustomException.dart';
import 'package:http/http.dart' as http;

class ApiProvider {
  final String _baseUrl = "https://biblosphere-api-ihj6i2l2aq-uc.a.run.app/";

  ApiProvider._internal();

  static final _singleton = ApiProvider._internal();

  factory ApiProvider() => _singleton;

  Future<dynamic> get(String url, {Map<String, String> headers}) async {
    var responseJson;
    try {
      final response = await http.get(_baseUrl + url,
          headers: headers); // тут могут быть post delete etc.
      responseJson = _response(response);
    } on SocketException {
      throw FetchDataException('No Internet connection');
    }
    return responseJson;
  }

  dynamic _response(http.Response response) {
    switch (response.statusCode) {
      case 200:
        var responseJson = json.decode(response.body.toString());
        print(responseJson);
        return responseJson;
      case 400:
        throw BadRequestException(response.body.toString());
      case 401:

      case 403:
        throw UnauthorisedException(response.body.toString());
      case 500:

      default:
        throw FetchDataException(
            'Error occured while Communication with Server with StatusCode : ${response.statusCode}');
    }
  }
}

import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;

class NetworkHelper {
  static final NetworkHelper _instance = NetworkHelper._internal();
  factory NetworkHelper() => _instance;
  NetworkHelper._internal();

  Future getData(String url) async {
    http.Response response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print(response.statusCode);
    }
  }

  Future post(String url, Map<String, dynamic> query) async {
    final Response response = await Dio().post(url, data: query);

    return response.data;
  }
}

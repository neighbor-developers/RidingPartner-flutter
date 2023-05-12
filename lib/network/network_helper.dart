import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;

import '../models/result.dart';

class NetworkHelper {
  static final NetworkHelper _instance = NetworkHelper._internal();
  factory NetworkHelper() => _instance;
  NetworkHelper._internal();

  Future<Result> getData(String url) async {
    try {
      http.Response response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        return Result(isSuccess: true, response: jsonDecode(response.body));
      } else {
        return Result(isSuccess: false, response: null);
      }
    } catch (e) {
      return Result(isSuccess: false, response: null);
    }
  }

  Future post(String url, Map<String, dynamic> query) async {
    final Response response = await Dio().post(url, data: query);

    return response.data;
  }
}

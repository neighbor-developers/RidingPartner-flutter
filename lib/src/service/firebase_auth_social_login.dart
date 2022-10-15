import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;

class FirebaseAuthSocialLogin {
  final String url = 'https://';

  Future<String> createCustomToken(Map<String, dynamic> user) async {
    final Response customTokenResponse = await Dio().post(url, data: user);

    return customTokenResponse.data;
  }
}

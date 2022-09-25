// import 'dart:developer' as developer;
// import 'package:http/http.dart' as http;
// import 'dart:convert';
import 'package:ridingpartner_flutter/src/utils/user_location.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';

//class Network
class Network {
  // final _apiKey = dotenv.env['apiKey']!;
  // final _endpointUrl = dotenv.env['endPointUrl']!;

  //getWeatherData
  Future<dynamic> getWeatherData() async {
    MyLocation myLocation = MyLocation();
    await myLocation.getMyCurrentLocation();

    // Map<String, String> queryParams = {
    //   'numOfRows': numoOfRows,
    //   'pageNo': pageNo,
    //   'dataYpe': dataType,
    //   'base_date': baseDate,
    //   'base_time': baseTime,
    //   'nx': MyLocation.longitude,
    //   'ny': MyLocation.latitude,
    //   'serviceKey': _apiKey
    // };

    // final queryString = Uri.parse(queryParameters: queryParams).query;
    // final requestUrl = _endpointUrl +
    //     '?' +
    //     queryString;
    // //getMyCurrentLocation
    //http.get
    // http.Response response = await http.get(Uri.parse());
    // //if
    // if (response.statusCode == 200) {
    //   developer.log(jsonDecode(response.body)['result'][0]['id'].toString());
    //   return jsonDecode(response.body)['result'][0]['id'].toString();
    // } else {
    //   //print

    //   developer.log(response.statusCode.toString());
    //   return response.statusCode.toString();
    // }
    return "test";
  }
}

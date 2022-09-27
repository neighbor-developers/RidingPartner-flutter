import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:ridingpartner_flutter/src/repository/weather_data.dart';
import 'dart:convert';
import 'package:ridingpartner_flutter/src/utils/user_location.dart';
import 'package:ridingpartner_flutter/src/utils/conv_grid_gps.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../utils/weather_int_to_string.dart';

//class Network
class Network {
  final _apiKey = dotenv.env['apiKey']!;

  final String _endpointUrl = dotenv.env['endPointUrl']!;
  //getWeatherData
  Future<dynamic> getWeatherData() async {
    developer.log("apiKey : $_apiKey");
    MyLocation myLocation = MyLocation();
    await myLocation.getMyCurrentLocation();
    //get the current time
    final now = DateTime.now();
    final baseDate = DateFormat('yyyyMMdd').format(now);
    final baseTime = DateFormat('HHmm').format(now);
    developer.log(baseTime);
    final gridData =
        ConvGridGps.gpsToGRID(37.579871128849334, 126.98935225645432);
    final Map<String, String> queryParams = {
      'serviceKey': _apiKey,
      'pageNo': 1,
      'numOfRows': 60,
      'dataType': 'JSON',
      'base_date': baseDate,
      'base_time': '0630',
      'nx': gridData['x'],
      'ny': gridData['y']
    }.map((key, value) => MapEntry(key, value.toString()));
    developer.log(queryParams.values.toString());
    final requestUrl = Uri.https(_endpointUrl,
        '/1360000/VilageFcstInfoService_2.0/getUltraSrtFcst', queryParams);
    developer.log(requestUrl.toString());
    var response = await http.get(requestUrl);
    developer.log("http.get");

    if (response.statusCode == 200) {
      developer.log("response.statusCode == 200");
      var jsonResponse = jsonDecode(response.body);
      var weatherData = WeatherData.fromJson(jsonResponse);
      var weatherItmes = weatherData.response!.body!.items!.item!;
      var simpleWeatherData = SimpleWeatherData();
      for (var i = 0; i < weatherItmes.length; i = i + 6) {
        var weatherItem = weatherItmes[i];
        switch (weatherItmes[i].category) {
          case 'PTY':
            simpleWeatherData.rainType ??= getRainType(weatherItem.fcstValue);
            break;
          case 'SKY':
            simpleWeatherData.skyType ??= getSkyType(weatherItem.fcstValue);
            break;
          case 'T1H':
            simpleWeatherData.temperature ??= weatherItem.fcstValue;
            break;
          case 'REH':
            simpleWeatherData.humidity ??= weatherItem.fcstValue;
            break;
        }
      }
      developer.log(simpleWeatherData.rainType.toString());
      return simpleWeatherData;
    } else {
      developer.log("http.get error");
      developer.log(response.statusCode.toString());
    }
  }
}

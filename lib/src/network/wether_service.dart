import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:ridingpartner_flutter/src/repository/weather_data.dart';
import 'dart:convert';
import 'package:ridingpartner_flutter/src/utils/user_location.dart';
import 'package:ridingpartner_flutter/src/utils/conv_grid_gps.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../utils/weather_int_to_string.dart';
import 'dart:developer' as developer;

//class Network
class Network {
  final _apiKey = dotenv.env['apiKey']!;

  final String _endpointUrl = dotenv.env['endPointUrl']!;
  //getWeatherData
  Future<dynamic> getWeatherData() async {
    var simpleWeatherData = SimpleWeatherData();
    MyLocation myLocation = MyLocation();
    try {
      await myLocation.getMyCurrentLocation();
    } catch (e) {
      developer.log("error : getLocation ${e.toString()}");
    }
    //get the current time
    final now = DateTime.now();
    final baseDate = DateFormat('yyyyMMdd').format(now);
    var baseTime = DateFormat('HHmm').format(now);
    baseTime = redefineBaseTime(baseTime);
    final gridData =
        ConvGridGps.gpsToGRID(myLocation.longitude, myLocation.latitude);
    final Map<String, String> queryParams = {
      'serviceKey': _apiKey,
      'pageNo': 1,
      'numOfRows': 60,
      'dataType': 'JSON',
      'base_date': baseDate,
      'base_time': baseTime,
      'nx': gridData['x'],
      'ny': gridData['y']
    }.map((key, value) => MapEntry(key, value.toString()));
    final requestUrl = Uri.https(_endpointUrl,
        '/1360000/VilageFcstInfoService_2.0/getUltraSrtFcst', queryParams);
    var response = await http.get(requestUrl);

    if (response.statusCode == 200) {
      try {
        var jsonResponse = jsonDecode(response.body);
        var weatherData = WeatherData.fromJson(jsonResponse);
        var weatherItmes = weatherData.response!.body!.items!.item!;

        for (var i = 0; i < weatherItmes.length; i += 6) {
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
        return simpleWeatherData;
      } catch (e) {
        return simpleWeatherData;
      }
    } else {
      return simpleWeatherData;
    }
  }

  redefineBaseTime(baseTime) {
    String h = baseTime.substring(0, 2);
    String m = baseTime.substring(2, 4);
    int hour = int.parse(h);
    int minute = int.parse(m);
    //기상청 api가 최신 데이터를 못받아오는 일이 잦아 1시간전 데이터를 받아오는 것으로 고정
    if (hour == 0) {
      h = '23';
    } else {
      h = (hour - 1).toString();
    }

    if (minute < 45) {
      m = '00';
    } else {
      m = '30';
    }
    return h + m;
  }
}

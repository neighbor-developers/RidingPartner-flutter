import 'dart:developer' as developer;

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:ridingpartner_flutter/src/models/result.dart';
import 'package:ridingpartner_flutter/src/network/network_helper.dart';
import 'package:ridingpartner_flutter/src/utils/user_location.dart';

class OpenWeatherService {
  final String _apiKey = dotenv.env['openWeatherApiKey']!;
  final String _baseUrl = dotenv.env['openWeatherApiBaseUrl']!;

  Future<Result> getWeather() async {
    MyLocation myLocation = MyLocation();
    developer.log("myLocation called in network");
    try {
      await myLocation.getMyCurrentLocation();
    } catch (e) {
      developer.log("error : getLocation ${e.toString()}");
    }

    final result = await NetworkHelper().getData(
        '$_baseUrl?lat=${myLocation.position!.latitude}&lon=${myLocation.position!.longitude}&appid=$_apiKey&units=metric');
    return result;
  }
}

// //class Network
// class WeatherService {
//   final String _apiKey = dotenv.env['apiKey']!;
//   final String _path = dotenv.env['path']!;
//   final String _endpointUrl = dotenv.env['endPointUrl']!;
//   //getWeatherData
//   Future<dynamic> getWeatherData() async {
//     var weather = Weather();
//     MyLocation myLocation = MyLocation();
//     developer.log("myLocation called in network");
//     try {
//       await myLocation.getMyCurrentLocation();
//     } catch (e) {
//       developer.log("error : getLocation ${e.toString()}");
//     }
//     //get the current time
//     final now = DateTime.now();
//     var baseDate = DateFormat('yyyyMMdd').format(now);
//     var baseTime = DateFormat('HHmm').format(now);
//     baseTime = redefineBaseTime(baseTime);
//     if (baseTime.substring(0, 2) == '23') {
//       baseDate = DateFormat('yyyyMMdd').format(now.subtract(Duration(days: 1)));
//     }
//     final gridData =
//         ConvGridGps.gpsToGRID(myLocation.latitude!, myLocation.longitude!);
//     final Map<String, String> queryParams = {
//       'serviceKey': _apiKey,
//       'pageNo': 1,
//       'numOfRows': 60,
//       'dataType': 'JSON',
//       'base_date': baseDate,
//       'base_time': baseTime,
//       'nx': gridData['x'],
//       'ny': gridData['y']
//     }.map((key, value) => MapEntry(key, value.toString()));
//     final requestUrl = Uri.https(_endpointUrl, _path, queryParams);
//     var response = await http.get(requestUrl);
//     developer.log(requestUrl.toString());
//     if (response.statusCode == 200) {
//       try {
//         var jsonResponse = jsonDecode(response.body);
//         var weatherData = WeatherData.fromJson(jsonResponse);
//         var weatherItems = weatherData.response!.body!.items!.item!;

//         for (var i = 0; i < weatherItems.length; i += 6) {
//           var weatherItem = weatherItems[i];

//           switch (weatherItem.category) {
//             case 'PTY':
//               weather.rainType ??=
//                   WeatherInfoConverter.getRainType(weatherItem.fcstValue);
//               break;
//             case 'SKY':
//               weather.skyType ??=
//                   WeatherInfoConverter.getSkyType(weatherItem.fcstValue);
//               break;
//             case 'T1H':
//               weather.temperature ??= weatherItem.fcstValue;
//               break;
//             case 'REH':
//               weather.humidity ??= weatherItem.fcstValue;
//               break;
//           }
//         }
//         developer.log(weather.temperature.toString());
//         return weather;
//       } catch (e) {
//         developer.log('getWeatherData 오류');
//         developer.log(e.toString());
//         return weather;
//       }
//     } else {
//       return weather;
//     }
//   }

//   redefineBaseTime(baseTime) {
//     String h = baseTime.substring(0, 2);
//     String m = baseTime.substring(2, 4);

//     int minute = int.parse(m);
//     //기상청 api가 최신 데이터를 못받아오는 일이 잦아 약 1시간전 데이터를 받아오는 것으로 고정
//     if (h == '00') {
//       h = '23';
//     } else {
//       h = (int.parse(h) - 1).toString();
//     }

//     if (minute < 45) {
//       m = '00';
//     } else {
//       m = '30';
//     }
//     return h + m;
//   }
// }



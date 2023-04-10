import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:ridingpartner_flutter/src/network/network_helper.dart';
import 'package:ridingpartner_flutter/src/models/my_location.dart';

import '../models/weather.dart';
import '../utils/weather_icon.dart';

class OpenWeatherService {
  final String _apiKey = dotenv.env['openWeatherApiKey']!;
  final String _baseUrl = dotenv.env['openWeatherApiBaseUrl']!;

  Future<Weather> getWeather() async {
    MyLocation myLocation = MyLocation();

    try {
      await myLocation.getMyCurrentLocation().timeout(Duration(seconds: 3));
    } catch (e) {
      print(e);
    }

    final result = await NetworkHelper().getData(
        '$_baseUrl?lat=${myLocation.position?.latitude}&lon=${myLocation.position?.longitude}&appid=$_apiKey&units=metric');

    final weatherData = result.response;
    Weather weather = Weather();
    weather.condition = weatherData['weather'][0]['main'];
    weather.humidity = weatherData['main']['humidity'];
    weather.temp = weatherData['main']['temp'];
    weather.temp = (weather.temp! * 10).roundToDouble() / 10;
    if (weather.condition != null) {
      weather.icon = weatherIcon(weather.condition!);
    }
    return weather;
  }
}

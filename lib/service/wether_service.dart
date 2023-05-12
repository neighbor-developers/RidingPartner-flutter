import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:ridingpartner_flutter/network/network_helper.dart';
import 'package:ridingpartner_flutter/service/location_service.dart';

import '../models/weather.dart';
import '../utils/weather_icon.dart';

class OpenWeatherService {
  final String _apiKey = dotenv.env['openWeatherApiKey']!;
  final String _baseUrl = dotenv.env['openWeatherApiBaseUrl']!;

  Position? _position;

  Future<Weather> getWeather() async {
    _position = MyLocation().position;

    final result = await NetworkHelper().getData(
        '$_baseUrl?lat=${_position?.latitude}&lon=${_position?.longitude}&appid=$_apiKey&units=metric');

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

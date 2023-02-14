import 'package:flutter/material.dart';
import 'package:ridingpartner_flutter/src/service/wether_service.dart';
import 'package:ridingpartner_flutter/src/utils/weather_icon.dart';

import '../models/weather.dart';

enum WeatherState { completed, searching, empty }

class WeatherProvider with ChangeNotifier {
  final Weather _weather = Weather();
  Weather get weather => _weather;

  WeatherState _loadingStatus = WeatherState.searching;
  WeatherState get loadingStatus => _loadingStatus;

  bool _disposed = false;

  final OpenWeatherService _openWeatherService = OpenWeatherService();

  Future<void> getWeather() async {
    try {
      final result = await _openWeatherService.getWeather();

      if (result.isSuccess) {
        final weatherData = result.response;

        if (weatherData == null) {
          _loadingStatus = WeatherState.empty;
        } else {
          _loadingStatus = WeatherState.completed;
          weather.condition = weatherData['weather'][0]['main'];
          weather.humidity = weatherData['main']['humidity'];
          weather.temp = weatherData['main']['temp'];
          weather.temp = (weather.temp! * 10).roundToDouble() / 10;
          if (weather.condition != null) {
            weather.icon = weatherIcon(weather.condition!);
          }
        }
      }
    } catch (e) {
      _loadingStatus = WeatherState.empty;
    }

    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  // _disposed == false 일 때만, super.notifyListeners() 호출!
  @override
  notifyListeners() {
    if (!_disposed) {
      super.notifyListeners();
    }
  }

  // WeatherService weatherServie = WeatherService();
  // Future<void> getWeather() async {
  //   try {
  //     _loadingStatus = LoadingStatus.searching;
  //     final weather = await weatherServie.getWeatherData();
  //     if (weather == null) {
  //       _loadingStatus = LoadingStatus.empty;
  //       _message = 'Could not find weather. Please try again.';
  //     } else {
  //       _loadingStatus = LoadingStatus.completed;
  //       _weather = weather;
  //     }
  //     notifyListeners();
  //   } catch (e) {
  //     _loadingStatus = LoadingStatus.empty;
  //     _message = 'Could not find weather. Please try again.';
  //   }
  // }

}

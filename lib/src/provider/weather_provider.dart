import 'package:flutter/material.dart';
import 'package:ridingpartner_flutter/src/service/wether_service.dart';

import '../models/weather.dart';

enum LoadingStatus { completed, searching, empty }

class WeatherProvider with ChangeNotifier {
  final Weather _weather =
      Weather(temp: 20, condition: "Clouds", conditionId: 200, humidity: 50);
  Weather get weather => _weather;

  LoadingStatus _loadingStatus = LoadingStatus.empty;
  LoadingStatus get loadingStatus => _loadingStatus;

  String _message = "Loading...";
  String get message => _message;

  final OpenWeatherService _openWeatherService = OpenWeatherService();

  Future<void> getWeather() async {
    _loadingStatus = LoadingStatus.searching;

    try {
      final result = await _openWeatherService.getWeather();

      if (result.isSuccess) {
        final weatherData = result.response;

        if (weatherData == null) {
          _loadingStatus = LoadingStatus.empty;
          _message = 'Could not find weather. Please try again.';
        } else {
          _loadingStatus = LoadingStatus.completed;
          weather.condition = weatherData['weather'][0]['main'];
          weather.conditionId = weatherData['weather'][0]['id'];
          weather.humidity = weatherData['main']['humidity'];
          weather.temp = weatherData['main']['temp'];
          weather.temp = (weather.temp! * 10).roundToDouble() / 10;
        }
      }
    } catch (e) {
      _loadingStatus = LoadingStatus.empty;
      _message = 'Could not find weather. Please try again.';
    }

    notifyListeners();
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

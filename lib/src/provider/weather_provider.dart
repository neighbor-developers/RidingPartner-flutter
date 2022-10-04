import 'package:flutter/material.dart';
import 'package:ridingpartner_flutter/src/service/wether_service.dart';

import '../models/weather.dart';

enum LoadingStatus { completed, searching, empty }

class WeatherProvider with ChangeNotifier {
  WeatherService weatherServie = WeatherService();

  Weather _weather = Weather();
  Weather get weather => _weather;

  LoadingStatus _loadingStatus = LoadingStatus.empty;
  LoadingStatus get loadingStatus => _loadingStatus;

  String _message = "Loading...";
  String get message => _message;

  Future<void> getWeather() async {
    try {
      _loadingStatus = LoadingStatus.searching;
      final weather = await weatherServie.getWeatherData();
      if (weather == null) {
        _loadingStatus = LoadingStatus.empty;
        _message = 'Could not find weather. Please try again.';
      } else {
        _loadingStatus = LoadingStatus.completed;
        _weather = weather;
      }
      notifyListeners();
    } catch (e) {
      _loadingStatus = LoadingStatus.empty;
      _message = 'Could not find weather. Please try again.';
    }
  }
}

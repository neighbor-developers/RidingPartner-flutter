import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ridingpartner_flutter/src/provider/weather_provider.dart';
import 'dart:developer' as developer;

// ignore: must_be_immutable
class WeatherPage extends StatelessWidget {
  WeatherPage({super.key});
  late WeatherProvider _weatherProvider;

  @override
  Widget build(BuildContext context) {
    _weatherProvider = Provider.of<WeatherProvider>(context, listen: false);
    _weatherProvider.getWeather();
    final weather = _weatherProvider.weather;
    developer.log('build Call');

    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(weather.skyType ?? '날씨'),
            Text(weather.temperature ?? '온도'),
            Text(weather.humidity ?? '습도'),
            Text(weather.rainType ?? '비'),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Go back!'),
            ),
          ],
        ),
      ),
    );
  }
}

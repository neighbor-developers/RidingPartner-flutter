import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ridingpartner_flutter/src/provider/weather_provider.dart';
import 'dart:developer' as developer;

class WeatherPage extends StatefulWidget {
  const WeatherPage({Key? key}) : super(key: key);

  @override
  _WeatherPage createState() => _WeatherPage();
}

class _WeatherPage extends State<WeatherPage> {
  @override
  void initState() {
    super.initState();
    Provider.of<WeatherProvider>(context, listen: false).getWeather();
  }

  @override
  Widget build(BuildContext context) {
    final weather = Provider.of<WeatherProvider>(context).weather;
    developer.log('build Call');

    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(weather.skyType ?? '날씨를 가져오고 있습니다.'),
            Text(weather.temperature ?? ''),
            Text(weather.humidity ?? ''),
            Text(weather.rainType ?? ''),
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

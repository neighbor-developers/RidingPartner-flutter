import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ridingpartner_flutter/src/pages/loding_page.dart';
import 'package:ridingpartner_flutter/src/provider/auth_provider.dart';
import 'package:ridingpartner_flutter/src/provider/home_record_provider.dart';
import 'package:ridingpartner_flutter/src/provider/weather_provider.dart';
import 'dart:developer' as developer;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePage();
}

class _HomePage extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    Provider.of<WeatherProvider>(context, listen: false).getWeather();
    Provider.of<HomeRecordProvider>(context, listen: false).getRecord();
  }

  @override
  Widget build(BuildContext context) {
    final weather = Provider.of<WeatherProvider>(context).weather;
    // final record = Provider.of<HomeRecordProvider>(context).ridingRecord;
    developer.log('weather build');

    return Scaffold(
      appBar: AppBar(),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Text(
                  '${weather.condition} ${getWeatherIcon(weather.conditionId ?? 800)}'),
              Text('현재 온도 : ${weather.temp}'),
              Text('습도 : ${weather.humidity}'),
            ],
          ),
          lastRecord(),
          recordGragh(),
          recommendWidget()
        ],
      ),
    );
  }

  Widget lastRecord() {
    return Container();
  }

  Widget recordGragh() {
    return Container();
  }

  Widget recommendWidget() {
    return Container(
      child: Row(
        children: [recommendRoute(), recommendRoute()],
      ),
    );
  }

  // 임시
  Widget recommendRoute() {
    return Card(
      semanticContainer: true,
      clipBehavior: Clip.antiAliasWithSaveLayer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      elevation: 5,
      margin: const EdgeInsets.all(10),
      child: Image.asset(
        'assets/images/places/lotus_flower_theme_park.jpeg',
        fit: BoxFit.fill,
        height: 150,
      ),
    );
  }

  String getWeatherIcon(int condition) {
    if (condition < 300) {
      return '🌩';
    } else if (condition < 400) {
      return '🌧';
    } else if (condition < 600) {
      return '☔️';
    } else if (condition < 700) {
      return '☃️';
    } else if (condition < 800) {
      return '🌫';
    } else if (condition == 800) {
      return '☀️';
    } else if (condition <= 804) {
      return '☁️';
    } else {
      return '🤷‍';
    }
  }
}

import 'dart:ffi';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:ridingpartner_flutter/src/models/record.dart';
import 'package:ridingpartner_flutter/src/models/weather.dart';
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

  List<Record>? records;

  @override
  Widget build(BuildContext context) {
    final weather = Provider.of<WeatherProvider>(context).weather;
    records = Provider.of<HomeRecordProvider>(context).ridingRecord;
    developer.log('weather build');

    return Scaffold(
      floatingActionButton: floatingButtons(),
      body: Column(
        children: [
          weatherWidget(weather),
          Container(
            height: 70,
          ),
          lastRecord(),
          lastRidingProgress(),
          recordChart(),
          recommendWidget()
        ],
      ),
    );
  }

  Widget weatherWidget(Weather weather) {
    return Row(
      children: [
        Text(
            '${weather.condition} ${getWeatherIcon(weather.conditionId ?? 800)}'),
        Text('현재 온도 : ${weather.temp}° '),
        Text('습도 : ${weather.humidity}%'),
      ],
    );
  }

  Widget lastRecord() {
    return Column(
      children: [
        Text(records?.last.distance.toString() ?? ""),
        Text(records?.last.timestamp.toString() ?? "")
      ],
    );
  }

  Widget lastRidingProgress() {
    double percent = records?.last.distance ?? 3 / 10;
    return Column(
      children: [
        Container(
          alignment: FractionalOffset(percent, 1 - percent),
          child: FractionallySizedBox(
              child: Image.asset('assets/icons/cycling_person.png',
                  width: 30, height: 30, fit: BoxFit.cover)),
        ),
        LinearPercentIndicator(
          padding: EdgeInsets.zero,
          percent: percent,
          lineHeight: 10,
          backgroundColor: Colors.black38,
          progressColor: Colors.indigo.shade900,
          width: MediaQuery.of(context).size.width,
        )
      ],
    );
  }

  Widget recordChart() {
    return AspectRatio(
        aspectRatio: 2,
        child: LineChart(LineChartData(lineBarsData: [
          LineChartBarData(
              spots: records?.map((data) => FlSpot(1, data.distance!)).toList())
        ])));
  }

  Widget? floatingButtons() {
    return SpeedDial(
      animatedIcon: AnimatedIcons.menu_close,
      visible: true,
      curve: Curves.bounceIn,
      backgroundColor: Colors.indigo.shade900,
      children: [
        SpeedDialChild(
            child: const Icon(Icons.settings_sharp, color: Colors.white),
            label: "설정",
            labelStyle: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.white,
                fontSize: 13.0),
            backgroundColor: Colors.indigo.shade900,
            labelBackgroundColor: Colors.indigo.shade900,
            onTap: () {}),
        SpeedDialChild(
          child: const Icon(
            Icons.add_chart_rounded,
            color: Colors.white,
          ),
          label: "내 기록",
          backgroundColor: Colors.indigo.shade900,
          labelBackgroundColor: Colors.indigo.shade900,
          labelStyle: const TextStyle(
              fontWeight: FontWeight.w500, color: Colors.white, fontSize: 13.0),
          onTap: () {},
        )
      ],
    );
  }

  Widget recommendWidget() {
    return Container(
      child: Row(
        children: [recommendRoute(), recommendRoute()],
      ),
    );
  }

  Widget recommendRoute() => Flexible(
        child: Card(
            semanticContainer: true,
            clipBehavior: Clip.antiAliasWithSaveLayer,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            elevation: 5,
            margin: const EdgeInsets.all(10),
            child: InkWell(
              onTap: () {},
              child: Image.asset(
                'assets/images/places/lotus_flower_theme_park.jpeg',
                fit: BoxFit.fill,
              ),
            )),
        flex: 1,
      );

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

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:ridingpartner_flutter/src/models/record.dart';
import 'package:ridingpartner_flutter/src/models/weather.dart';
import 'package:ridingpartner_flutter/src/pages/loding_page.dart';
import 'package:ridingpartner_flutter/src/pages/setting_page.dart';
import 'package:ridingpartner_flutter/src/provider/auth_provider.dart';
import 'package:ridingpartner_flutter/src/provider/home_record_provider.dart';
import 'package:ridingpartner_flutter/src/provider/setting_provider.dart';
import 'package:ridingpartner_flutter/src/provider/weather_provider.dart';
import 'dart:developer' as developer;

import '../models/place.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late WeatherProvider _weatherProvider;
  late HomeRecordProvider _homeRecordProvider;
  late List<Record> records;
  late TabController _tabController;
  @override
  void initState() {
    super.initState();
    Provider.of<WeatherProvider>(context, listen: false).getWeather();
    Provider.of<HomeRecordProvider>(context, listen: false).getRecord();
    _tabController = TabController(length: 14, vsync: this, initialIndex: 13);
  }

  @override
  Widget build(BuildContext context) {
    _weatherProvider = Provider.of<WeatherProvider>(context);
    _homeRecordProvider = Provider.of<HomeRecordProvider>(context);
    _tabController.addListener(() {
      _homeRecordProvider.setIndex(_tabController.index);
    });
    records = _homeRecordProvider.recordFor14Days;

    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text(
            'Riding Partner',
            style: TextStyle(color: Colors.orange[600]),
          ),
          excludeHeaderSemantics: true,
        ),
        floatingActionButton: floatingButtons(),
        body: Column(
          children: [
            weatherWidget(),
            recommendPlaceText(),
            Row(children: [
              recommendPlace(Place(title: '갯골 생태 공원')),
              recommendPlace(Place(title: '갯골 생태 공원'))
            ]),
            weekWidget()
          ],
        ));
  }

  Widget weatherWidget() {
    switch (_weatherProvider.loadingStatus) {
      case WeatherState.searching:
        return Text('날씨를 검색중입니다');
      case WeatherState.empty:
        return Text('날씨를 불러올 수 없습니다.');
      case WeatherState.completed:
        Weather weather = _weatherProvider.weather;
        return Text(
            '${weather.condition} ${getWeatherIcon(weather.conditionId ?? 800)} 현재 온도 : ${weather.temp}° 습도 : ${weather.humidity}%');
      default:
        return Text('날씨를 검색중입니다');
    }
  }

  Widget recommendPlaceText() {
    return Text.rich(
      TextSpan(
          text: '혜진님, 오늘같은 날에는\n',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          children: <TextSpan>[
            TextSpan(
                text: '\'갯골 생태 공원\'',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange[600])),
            TextSpan(
                text: ' 어떠세요?',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold))
          ]),
      textAlign: TextAlign.start,
    );
  }

  Widget recommendPlace(Place place) => Flexible(
        child: Card(
            semanticContainer: true,
            clipBehavior: Clip.antiAliasWithSaveLayer,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            elevation: 5,
            margin: const EdgeInsets.fromLTRB(0, 0, 10, 0),
            child: InkWell(
                onTap: () {},
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: 100,
                  decoration: BoxDecoration(
                      image: DecorationImage(
                    image: AssetImage(
                      'assets/images/places/lotus_flower_theme_park.jpeg',
                    ),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(
                        Colors.black.withOpacity(0.2), BlendMode.dstATop),
                  )),
                  child: Text(
                    place.title!,
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ))),
        flex: 1,
      );

  Widget weekWidget() {
    return Column(children: [
      TabBar(
          onTap: (value) => _homeRecordProvider.setIndex(value),
          controller: _tabController,
          isScrollable: true,
          tabs: _homeRecordProvider.daysFor14.map((e) {
            if (_tabController.index ==
                _homeRecordProvider.daysFor14.indexOf(e)) {
              return Tab(text: e);
            } else {
              return Tab(text: e.substring(0, 2));
            }
          }).toList(),
          unselectedLabelColor: Colors.black54,
          labelColor: Colors.white,
          indicator: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 5,
                blurRadius: 7,
                offset: Offset(0, 3), // changes position of shadow
              )
            ],
            borderRadius: BorderRadius.circular(65.0),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.orange[900]!,
                Colors.orange[600]!,
              ],
            ),
          )),
      // TabBarView(
      //     controller: _tabController,
      //     children: records.map((e) => recordDetailView(e)).toList())
    ]);
  }

  Widget recordDetailView(Record record) {
    return Container(
      child: GridView.builder(
          shrinkWrap: true,
          scrollDirection: Axis.vertical,
          padding: const EdgeInsets.all(10),
          itemCount: 4,
          itemBuilder: (BuildContext context, index) =>
              lastRecordCard(index, record),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1 / 1,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10)),
    );
  }

  Widget lastRecordCard(int index, Record record) {
    String iconRoute = 'assets/icons/cycling_person.png';
    String title = '';
    String data = '';
    switch (index) {
      case 0:
        iconRoute = 'assets/icons/cycling_person.png';
        title = '평균 속도';
        data = '${record.distance! / record.timestamp!}m/s';
        break;
      case 1:
        iconRoute = 'assets/icons/cycling_person.png';
        title = '시간';
        data =
            '${record.timestamp! / 3600} : ${record.timestamp! / 60} : ${record.timestamp! % 60}';
        break;
      case 2:
        iconRoute = 'assets/icons/cycling_person.png';
        title = '순간 최고 속도';
        data = '${record.topSpeed}m/s';
        break;
      case 3:
        iconRoute = 'assets/icons/cycling_person.png';
        title = '거리';
        data = '${record.distance! / 1000}km';
        break;
      default:
    }

    return Card(
        semanticContainer: true,
        clipBehavior: Clip.antiAliasWithSaveLayer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        elevation: 10,
        child: Column(
          children: [
            Row(
              children: [
                Image.asset(iconRoute,
                    width: 30, height: 30, fit: BoxFit.cover),
                Text(
                  title,
                  style: TextStyle(fontSize: 10, color: Colors.black87),
                )
              ],
            ),
            Text(
              title,
              style: TextStyle(fontSize: 15, color: Colors.black87),
            )
          ],
        ));
  }

  Widget recordRateProgress(double distance) {
    double percent = distance / 1000;
    if (percent > 1) {
      percent = 1;
    }
    return Container(
        width: MediaQuery.of(context).size.width,
        child: Card(
            child: Stack(
          children: [
            Positioned(
                left: 0,
                child: Column(
                  children: [
                    Text(
                      '오늘의 목표거리 달성률',
                      style: TextStyle(fontSize: 10, color: Colors.black54),
                    ),
                    Text(
                      '${distance / 1000}km / 10km',
                      style: TextStyle(fontSize: 10, color: Colors.black54),
                    )
                  ],
                )),
            Positioned(
                right: 0,
                child: CircularPercentIndicator(
                    percent: percent,
                    radius: 100,
                    backgroundColor: Colors.black12,
                    progressColor: Colors.orange[600]))
          ],
        )));
  }

  // Widget recordChart() {
  //   return AspectRatio(
  //       aspectRatio: 2,
  //       child: LineChart(LineChartData(lineBarsData: [
  //         LineChartBarData(
  //             spots: records!.map((data) => FlSpot(1, data.distance!)).toList())
  //       ])));
  // }

  Widget? floatingButtons() {
    return SpeedDial(
      animatedIcon: AnimatedIcons.menu_close,
      visible: true,
      curve: Curves.bounceIn,
      backgroundColor: Colors.orange[600],
      children: [
        SpeedDialChild(
            child: const Icon(Icons.settings_sharp, color: Colors.white),
            label: "설정",
            labelStyle: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.white,
                fontSize: 13.0),
            backgroundColor: Colors.orange[600],
            labelBackgroundColor: Colors.orange[600],
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => ChangeNotifierProvider(
                        create: (context) => SettingProvider(),
                        child: SettingPage(),
                      )));
            }),
        SpeedDialChild(
          child: const Icon(
            Icons.add_chart_rounded,
            color: Colors.white,
          ),
          label: "내 기록",
          backgroundColor: Colors.orange[600],
          labelBackgroundColor: Colors.indigo.shade900,
          labelStyle: const TextStyle(
              fontWeight: FontWeight.w500, color: Colors.white, fontSize: 13.0),
          onTap: () {},
        )
      ],
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

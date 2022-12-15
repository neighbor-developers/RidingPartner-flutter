import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:ridingpartner_flutter/src/models/record.dart';
import 'package:ridingpartner_flutter/src/models/weather.dart';
import 'package:ridingpartner_flutter/src/pages/setting_page.dart';
import 'package:ridingpartner_flutter/src/provider/home_record_provider.dart';
import 'package:ridingpartner_flutter/src/provider/setting_provider.dart';
import 'package:ridingpartner_flutter/src/provider/weather_provider.dart';

import '../models/place.dart';

class Data {
  String key;
  String data;
  String icon;

  Data(this.key, this.data, this.icon);
}

const mainFontSize = 22.0;
const recordFontSize = 10.0;
const numberOfRecentRecords = 14;

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
    _tabController = TabController(
        length: numberOfRecentRecords, vsync: this, initialIndex: 13);
  }

  @override
  Widget build(BuildContext context) {
    _weatherProvider = Provider.of<WeatherProvider>(context);
    _homeRecordProvider = Provider.of<HomeRecordProvider>(context);

    records = _homeRecordProvider.recordFor14Days;

    return Scaffold(
        appBar: AppBar(
            backgroundColor: Colors.white,
            title: Image.asset(
              'assets/icons/logo.png',
              height: 25,
            )),
        floatingActionButton: floatingButtons(),
        body: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                recommendPlaceText(),
                Row(children: [
                  recommendPlace(Place(title: '갯골 생태 공원')),
                  recommendPlace(Place(title: '갯골 생태 공원'))
                ]),
                weekWidget()
              ],
            )));
  }

  Widget weatherWidget() {
    switch (_weatherProvider.loadingStatus) {
      case WeatherState.searching:
        return const Text('날씨를 검색중입니다');
      case WeatherState.empty:
        return const Text('날씨를 불러올 수 없습니다.');
      case WeatherState.completed:
        Weather weather = _weatherProvider.weather;
        return Text(
            '${weather.condition} ${getWeatherIcon(weather.conditionId ?? 800)} 현재 온도 : ${weather.temp}° 습도 : ${weather.humidity}%');
      default:
        return const Text('날씨를 검색중입니다');
    }
  }

  Widget recommendPlaceText() {
    return Container(
        padding: const EdgeInsets.fromLTRB(0, 15, 0, 15),
        child: const Text.rich(
          TextSpan(
              text: '혜진님, 오늘같은 날에는\n',
              style: TextStyle(
                  fontSize: mainFontSize, fontWeight: FontWeight.bold),
              children: <TextSpan>[
                TextSpan(
                    text: '\'갯골 생태 공원\'',
                    style: TextStyle(
                        fontSize: mainFontSize,
                        fontWeight: FontWeight.bold,
                        fontFamily: "assets/font/pretendard_medium",
                        color: Color.fromARGB(0xFF, 0xFF, 0xA0, 0x44))),
                TextSpan(
                    text: ' 어떠세요?',
                    style: TextStyle(
                        fontSize: mainFontSize, fontWeight: FontWeight.bold))
              ]),
          textAlign: TextAlign.start,
        ));
  }

  Widget recommendPlace(Place place) => Flexible(
        flex: 1,
        child: Stack(
          children: [
            Card(
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
                      decoration: const BoxDecoration(
                          image: DecorationImage(
                              image: AssetImage(
                                'assets/images/places/lotus_flower_theme_park.jpeg',
                              ),
                              fit: BoxFit.cover)),
                    ))),
            Card(
                semanticContainer: true,
                clipBehavior: Clip.antiAliasWithSaveLayer,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                margin: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                child: Container(
                  alignment: Alignment.bottomRight,
                  width: MediaQuery.of(context).size.width,
                  color: const Color.fromARGB(255, 0, 0, 0),
                  height: 100,
                  child: Text(place.title!,
                      style: const TextStyle(
                        color: Colors.white,
                      )),
                ))
          ],
        ),
      );

  Widget weekWidget() {
    switch (_homeRecordProvider.recordState) {
      case RecordState.loading:
        return const SizedBox(
            height: 100,
            child: Center(
              child: CircularProgressIndicator(
                  color: Color.fromARGB(0xFF, 0xFB, 0x95, 0x32)),
            ));
      case RecordState.empty:
        return const SizedBox(
            height: 100,
            child: Center(
              child: Text(
                "아직 주행한 기록이 없습니다\n라이딩 파트너와 함께 달려보세요!",
                textAlign: TextAlign.center,
              ),
            ));
      case RecordState.fail:
        return const SizedBox(
            height: 100,
            child: Center(
              child: Text("기록 조회에 실패했습니다\n네트워크 상태를 체크해주세요!",
                  textAlign: TextAlign.center),
            ));
      case RecordState.success:
        return Column(children: [
          TabBar(
              padding: const EdgeInsets.fromLTRB(0, 20, 0, 15),
              onTap: (value) => {_tabController.animateTo(value)},
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
              labelStyle: const TextStyle(fontWeight: FontWeight.bold),
              indicator: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: const Color.fromARGB(255, 183, 183, 183)
                        .withOpacity(0.5),
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: const Offset(0, 1), // changes position of shadow
                  )
                ],
                borderRadius: BorderRadius.circular(65.0),
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color.fromARGB(0xFF, 0xEE, 0x75, 0x00),
                    Color.fromARGB(0xFF, 0xFF, 0xA0, 0x44),
                  ],
                ),
              )),
          TabBarView(
              controller: _tabController,
              children: records.map((e) => recordDetailView(e)).toList())
        ]);

      default:
        return const SizedBox(
            height: 100,
            child: Center(
              child: CircularProgressIndicator(
                  color: Color.fromARGB(0xFF, 0xFB, 0x95, 0x32)),
            ));
    }
  }

  Widget recordDetailView(Record record) {
    if (record == Record()) {
      return Container();
    } else {
      List<Data> data = [
        Data('거리', '${record.distance! / 1000}km',
            'assets/icons/home_distance.png'),
        Data(
            '시간',
            '${record.timestamp! / 3600} : ${record.timestamp! / 60} : ${record.timestamp! % 60}',
            'assets/icons/home_time.png'),
        Data('평균 속도', '${record.distance! / record.timestamp!}m/s',
            'assets/icons/home_speed.png'),
        Data('순간 최고 속도', '${record.topSpeed}m/s',
            'assets/icons/home_max_speed.png')
      ];

      List<String> keys = data.map((e) => e.key).toList();
      List<String> values = data.map((e) => e.data).toList();
      List<String> icons = data.map((e) => e.icon).toList();

      return SizedBox(
        height: 100,
        child: GridView.builder(
            shrinkWrap: true,
            scrollDirection: Axis.vertical,
            padding: const EdgeInsets.all(10),
            itemCount: 4,
            itemBuilder: (BuildContext context, index) =>
                recordCard(keys[index], values[index], icons[index]),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1 / 1,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10)),
      );
    }
  }

  Widget recordCard(String key, String data, String icon) {
    return Card(
        semanticContainer: true,
        clipBehavior: Clip.antiAliasWithSaveLayer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        elevation: 5,
        child: Column(
          children: [
            Row(
              children: [
                Image.asset(icon, width: 30, height: 30, fit: BoxFit.cover),
                Text(
                  key,
                  style: const TextStyle(
                      fontSize: recordFontSize, color: Colors.black87),
                )
              ],
            ),
            Text(
              data,
              style: const TextStyle(fontSize: 15, color: Colors.black87),
            )
          ],
        ));
  }

  Widget recordRateProgress(double distance) {
    double percent = distance / 1000;
    if (percent > 1) {
      percent = 1;
    }
    return SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Card(
            child: Stack(
          children: [
            Positioned(
                left: 0,
                child: Column(
                  children: [
                    const Text(
                      '오늘의 목표거리 달성률',
                      style: TextStyle(
                          fontSize: recordFontSize, color: Colors.black54),
                    ),
                    Text(
                      '${distance / 1000}km / 10km',
                      style: const TextStyle(
                          fontSize: recordFontSize, color: Colors.black54),
                    )
                  ],
                )),
            Positioned(
                right: 0,
                child: CircularPercentIndicator(
                    percent: percent,
                    radius: 100,
                    backgroundColor: Colors.black12,
                    progressColor:
                        const Color.fromARGB(0xFF, 0xFB, 0x95, 0x32)))
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
      backgroundColor: const Color.fromARGB(0xFF, 0xFB, 0x95, 0x32),
      children: [
        SpeedDialChild(
            child: const Icon(Icons.settings_sharp, color: Colors.white),
            label: "설정",
            labelStyle: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.white,
                fontSize: 13.0),
            backgroundColor: const Color.fromARGB(0xFF, 0xFB, 0x95, 0x32),
            labelBackgroundColor: const Color.fromARGB(0xFF, 0xFB, 0x95, 0x32),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => ChangeNotifierProvider(
                        create: (context) => SettingProvider(),
                        child: const SettingPage(),
                      )));
            }),
        SpeedDialChild(
          child: const Icon(
            Icons.add_chart_rounded,
            color: Colors.white,
          ),
          label: "내 기록",
          backgroundColor: const Color.fromARGB(0xFF, 0xFB, 0x95, 0x32),
          labelBackgroundColor: const Color.fromARGB(0xFF, 0xFB, 0x95, 0x32),
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

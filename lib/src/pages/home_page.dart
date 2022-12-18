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

class Data {
  String key;
  String data;
  String icon;

  Data(this.key, this.data, this.icon);
}

const mainFontSize = 24.0;
const recordFontSize = 12.0;
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
  int state = 0;
  @override
  void initState() {
    super.initState();
    Provider.of<WeatherProvider>(context, listen: false).getWeather();
    Provider.of<HomeRecordProvider>(context, listen: false).getData();
    _tabController = TabController(
        length: numberOfRecentRecords, vsync: this, initialIndex: 13);
  }

  @override
  Widget build(BuildContext context) {
    _weatherProvider = Provider.of<WeatherProvider>(context);
    _homeRecordProvider = Provider.of<HomeRecordProvider>(context);
    records = _homeRecordProvider.recordFor14Days;

    _weatherProvider.getWeather();
    return Scaffold(
        backgroundColor: const Color.fromARGB(0xFF, 0xF5, 0xF5, 0xF5),
        floatingActionButton: floatingButtons(),
        body: Stack(
          children: [
            Container(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  recommendPlaceText(),
                  Row(children: [
                    recommendPlace(_homeRecordProvider.recommendPlace),
                    recommendPlace(_homeRecordProvider.recommendRoute)
                  ]),
                  Expanded(child: weekWidget()),
                ],
              ),
            ),
            Positioned(
              bottom: 0,
              child: weatherWidget(),
            )
          ],
        ));
  }

  Widget weekWidget() {
    switch (_homeRecordProvider.recordState) {
      case RecordState.loading:
        return const SizedBox(
            height: 100,
            child: Center(
              child: Text(
                "라이더님의 주행 기록을 불러오는 중입니다",
                textAlign: TextAlign.center,
              ),
            ));
      case RecordState.none:
        return const SizedBox(
            height: 100,
            child: Center(
              child: Text(
                "아직 주행한 기록이 없습니다\n라이딩 파트너와 함께 달려보세요!",
                textAlign: TextAlign.center,
              ),
            ));
      case RecordState.empty:
        return const SizedBox(
            height: 100,
            child: Center(
              child: Text(
                "최근 2주간 라이딩한 기록이 없습니다\n라이딩 파트너와 함께 달려보세요!",
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
              onTap: (value) {
                state = 1;
                _homeRecordProvider.setIndex(_tabController.index);
                _tabController.animateTo(value);
              },
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
              labelStyle: const TextStyle(
                  fontSize: 14,
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w700),
              indicator: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: const Color.fromRGBO(0, 0, 0, 0.1),
                    spreadRadius: 2,
                    blurRadius: 3,
                    offset: const Offset(1, 1), // changes position of shadow
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
          Expanded(
              child: TabBarView(
                  controller: _tabController,
                  children: records.map((e) => recordDetailView(e)).toList()))
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
    if (record == Record() || record.date == null) {
      return Container(
        alignment: Alignment.center,
        child: Text('라이딩한 기록이 없습니다'),
      );
    } else {
      List<Data> data = [
        Data('거리', '${record.distance! / 1000}km',
            'assets/icons/home_distance.png'),
        Data('시간', timestampToText(record.timestamp!),
            'assets/icons/home_time.png'),
        Data('평균 속도', '${record.distance! / record.timestamp!}m/s',
            'assets/icons/home_speed.png'),
        Data('순간 최고 속도', '${record.topSpeed}m/s',
            'assets/icons/home_max_speed.png')
      ];

      List<String> keys = data.map((e) => e.key).toList();
      List<String> values = data.map((e) => e.data).toList();
      List<String> icons = data.map((e) => e.icon).toList();

      return Expanded(
          child: GridView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.all(10),
              itemCount: 4,
              scrollDirection: Axis.vertical,
              itemBuilder: (BuildContext context, index) =>
                  recordCard(keys[index], values[index], icons[index]),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1 / 1,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10)));
    }
  }

  Widget recordCard(String key, String data, String icon) {
    return SizedBox(
        height: 50,
        child: Container(
            height: 50,
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(12))),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  alignment: Alignment.topLeft,
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  child: Row(
                    children: [
                      Image.asset(icon,
                          width: 15, height: 15, fit: BoxFit.cover),
                      Text(
                        "  $key",
                        style: const TextStyle(
                            fontSize: 12,
                            fontFamily: 'Pretendard',
                            fontWeight: FontWeight.w500,
                            color: Color.fromRGBO(17, 17, 17, 1)),
                      )
                    ],
                  ),
                ),
                Text(
                  data,
                  style: const TextStyle(
                      fontSize: 24,
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w300,
                      color: Colors.black),
                )
              ],
            )));
  }

  Widget weatherWidget() {
    switch (_weatherProvider.loadingStatus) {
      case WeatherState.searching:
        return Container(
            width: MediaQuery.of(context).size.width,
            color: Colors.white,
            child: Container(
                padding: const EdgeInsets.all(12),
                child: const Text('날씨를 검색중입니다')));
      case WeatherState.empty:
        return Container(
            decoration: BoxDecoration(
              border: Border.all(
                width: 1,
                color: Colors.orange,
              ),
            ),
            width: MediaQuery.of(context).size.width,
            color: Colors.white,
            child: Container(
                padding: const EdgeInsets.all(12),
                child: const Text('날씨를 불러오지 못했습니다,')));
      case WeatherState.completed:
        Weather weather = _weatherProvider.weather;
        return Container(
            width: MediaQuery.of(context).size.width,
            color: Colors.white,
            child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    width: 0.1,
                    color: Color.fromARGB(255, 92, 92, 92),
                  ),
                ),
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Image.asset(
                      weather.icon ?? 'assets/icons/weather_cloud.png',
                      width: 17,
                      height: 17,
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    Text(
                        '오늘의 온도 : ${weather.temp}°C  습도 : ${weather.humidity}%',
                        style: const TextStyle(
                            fontSize: 14,
                            fontFamily: 'Pretendard',
                            fontWeight: FontWeight.w600,
                            color: Color.fromRGBO(51, 51, 51, 1)))
                  ],
                )));

      default:
        return const Text('날씨를 검색중입니다');
    }
  }

  Widget recommendPlaceText() {
    return Container(
        padding: const EdgeInsets.fromLTRB(0, 15, 0, 15),
        child: Text.rich(
          TextSpan(
              text: '${_homeRecordProvider.name}님, 오늘같은 날에는\n',
              style: const TextStyle(
                  fontSize: mainFontSize,
                  fontFamily: "Pretendard",
                  height: 1.4,
                  letterSpacing: 0.02,
                  fontWeight: FontWeight.w800),
              children: const <TextSpan>[
                TextSpan(
                    text: '\'갯골 생태 공원\'',
                    style: TextStyle(
                        fontSize: mainFontSize,
                        letterSpacing: 0.02,
                        fontWeight: FontWeight.w800,
                        fontFamily: "Pretendard",
                        color: Color.fromARGB(255, 253, 154, 55))),
                TextSpan(
                    text: ' 어떠세요?',
                    style: TextStyle(
                        fontSize: mainFontSize,
                        letterSpacing: 0.02,
                        fontFamily: "Pretendard",
                        fontWeight: FontWeight.w800))
              ]),
          textAlign: TextAlign.start,
        ));
  }

  Widget recommendPlace(dynamic data) {
    return Flexible(
      flex: 1,
      child: _homeRecordProvider.recommendPlace == null
          ? Container(
              alignment: Alignment.center,
              height: 130,
              margin: const EdgeInsets.fromLTRB(0, 0, 10, 0),
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(20)),
              ),
              child: Text(
                "추천 명소를\n불러오고 있습니다",
                style: const TextStyle(
                    fontSize: 18,
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w600,
                    color: Colors.white),
              ),
            )
          : Stack(
              children: [
                Container(
                    height: 130,
                    margin: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                    child: InkWell(
                        onTap: () {},
                        child: Stack(children: [
                          Container(
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height,
                            decoration: const BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20)),
                                image: DecorationImage(
                                    image: AssetImage(
                                      'assets/images/places/lotus_flower_theme_park.jpeg',
                                    ),
                                    fit: BoxFit.cover)),
                          ),
                          Container(
                              width: MediaQuery.of(context).size.width,
                              height: MediaQuery.of(context).size.height,
                              decoration: const BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20)),
                                  color: Color.fromARGB(90, 0, 0, 0)))
                        ]))),
                Container(
                  height: 130,
                  padding: const EdgeInsets.all(15),
                  alignment: Alignment.bottomLeft,
                  child: Text(
                    "${data.title}",
                    style: const TextStyle(
                        fontSize: 16,
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w600,
                        color: Colors.white),
                  ),
                )
              ],
            ),
    );
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

  String timestampToText(int timestamp) {
    String hour = "00";
    String minute = "00";
    String second = "00";

    if (timestamp ~/ 3600 < 10) {
      hour = "0${timestamp ~/ 3600}";
    } else {
      hour = "${timestamp ~/ 3600}";
    }

    if (timestamp ~/ 60 < 10) {
      minute = "0${timestamp ~/ 60}";
    } else {
      minute = "${timestamp ~/ 60}";
    }
    if (timestamp % 60 < 10) {
      second = "0${timestamp % 60}";
    } else {
      second = "${timestamp % 60}";
    }

    return '$hour:$minute:$second';
  }
}

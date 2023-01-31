import 'package:flutter/material.dart';
import 'package:line_chart/charts/line-chart.widget.dart';
import 'package:line_chart/model/line-chart.model.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:ridingpartner_flutter/src/models/place.dart';
import 'package:ridingpartner_flutter/src/models/record.dart';
import 'package:ridingpartner_flutter/src/models/weather.dart';
import 'package:ridingpartner_flutter/src/pages/navigation_page.dart';
import 'package:ridingpartner_flutter/src/pages/record_list_page.dart';
import 'package:ridingpartner_flutter/src/provider/home_record_provider.dart';
import 'package:ridingpartner_flutter/src/provider/navigation_provider.dart';
import 'package:ridingpartner_flutter/src/provider/record_list_provider.dart';
import 'package:ridingpartner_flutter/src/provider/riding_provider.dart';
import 'package:ridingpartner_flutter/src/provider/setting_provider.dart';
import 'package:ridingpartner_flutter/src/provider/weather_provider.dart';
import 'package:ridingpartner_flutter/src/utils/timestampToText.dart';

import '../provider/auth_provider.dart';
import 'loding_page.dart';

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
  late SettingProvider _settingProvider;
  late List<Record> _records;
  late TabController _tabController;
  int state = 0;

  List<LineChartModel> data = [
    LineChartModel(amount: 300, date: DateTime(2020, 1, 1)),
    LineChartModel(amount: 200, date: DateTime(2020, 1, 2)),
    LineChartModel(amount: 300, date: DateTime(2020, 1, 3)),
    LineChartModel(amount: 500, date: DateTime(2020, 1, 4)),
    LineChartModel(amount: 800, date: DateTime(2020, 1, 5)),
    LineChartModel(amount: 200, date: DateTime(2020, 1, 6)),
    LineChartModel(amount: 120, date: DateTime(2020, 1, 7)),
  ];

  // int _counter = 0;

  @override
  void initState() {
    super.initState();
    Provider.of<WeatherProvider>(context, listen: false).getWeather();
    Provider.of<HomeRecordProvider>(context, listen: false).getData();
    Provider.of<SettingProvider>(context, listen: false).Version();
    _tabController = TabController(
        length: numberOfRecentRecords, vsync: this, initialIndex: 13);
  }

  final settingTextStyle = const TextStyle(
      fontFamily: 'Pretendard',
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: Color.fromARGB(185, 51, 57, 62));

  @override
  Widget build(BuildContext context) {
    _weatherProvider = Provider.of<WeatherProvider>(context);
    _homeRecordProvider = Provider.of<HomeRecordProvider>(context);
    _settingProvider = Provider.of<SettingProvider>(context);
    _records = _homeRecordProvider.recordFor14Days;
    _incrementCounter(_records);

    if (_weatherProvider.loadingStatus == WeatherState.searching) {
      _weatherProvider.getWeather();
    }

    return Scaffold(
        backgroundColor: const Color.fromARGB(0xFF, 0xF5, 0xF5, 0xF5),
        // floatingActionButton: floatingButtons(),
        body: Stack(
          children: [
            SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: SingleChildScrollView(
                    child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    children: [
                      recommendPlaceText(
                          _homeRecordProvider.recommendPlace?.title ?? '-'),
                      Container(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                        child: Row(children: [
                          recommendPlace(_homeRecordProvider.recommendPlace),
                          const SizedBox(
                            width: 15,
                          ),
                          recommendPlace(_homeRecordProvider.recommendPlace2)
                        ]),
                      ),
                      weekWidget(),
                      settingBox(),
                      SizedBox(
                        height: 60,
                        width: MediaQuery.of(context).size.width,
                      )
                    ],
                  ),
                ))),
            Positioned(
              bottom: 0,
              child: weatherWidget(),
            )
          ],
        ));
  }

  void routeDialog(Place place) => showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(15.0), topRight: Radius.circular(15.0))),
      builder: (BuildContext context) => Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                  padding: const EdgeInsets.fromLTRB(24, 38, 24, 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        place.title!,
                        style: const TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 24,
                            fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      if (place.roadAddress == null ||
                          place.roadAddress == "") ...[
                        Text(
                          place.jibunAddress!,
                          style: const TextStyle(
                              fontFamily: 'Pretendard',
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: Color.fromRGBO(51, 51, 51, 0.5)),
                        )
                      ] else ...[
                        Text(
                          place.roadAddress!,
                          style: const TextStyle(
                              fontFamily: 'Pretendard',
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: Color.fromRGBO(51, 51, 51, 0.5)),
                        )
                      ],
                      const SizedBox(height: 16.0),
                      const Divider(
                        color: Color.fromRGBO(233, 236, 239, 1),
                        thickness: 1.0,
                      ),
                      const SizedBox(height: 16.0),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.asset(
                          place.image!,
                          height: 180.0,
                          width: MediaQuery.of(context).size.width,
                          fit: BoxFit.fill,
                        ),
                      ),
                    ],
                  )),
              InkWell(
                  onTap: () async {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => MultiProvider(
                                  providers: [
                                    ChangeNotifierProvider(
                                        create: (context) =>
                                            NavigationProvider([place])),
                                    ChangeNotifierProvider(
                                        create: (context) => RidingProvider())
                                  ],
                                  child: const NavigationPage(),
                                )));
                  },
                  child: Container(
                      alignment: Alignment.center,
                      width: MediaQuery.of(context).size.width,
                      height: 60,
                      color: const Color.fromRGBO(240, 120, 5, 1),
                      child: const Text('안내 시작',
                          style: TextStyle(
                              fontFamily: 'Pretendard',
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w700))))
            ],
          ));

  Widget weekWidget() {
    switch (_homeRecordProvider.recordState) {
      case RecordState.loading:
        return const SizedBox(
            height: 200,
            child: Center(
              child: Text(
                "라이더님의 주행 기록을 불러오는 중입니다",
                textAlign: TextAlign.center,
              ),
            ));
      case RecordState.none:
        return const SizedBox(
            height: 200,
            child: Center(
              child: Text(
                "아직 주행한 기록이 없습니다\n라이딩 파트너와 함께 달려보세요!",
                textAlign: TextAlign.center,
              ),
            ));
      case RecordState.empty:
        return SizedBox(
            height: 200,
            child: Center(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: const [
                Text(
                  "최근 2주간 라이딩한 기록이 없습니다\n라이딩 파트너와 함께 달려보세요!",
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: 5,
                ),
                Text(
                  '기록 전체보기',
                  style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Color.fromARGB(185, 51, 57, 62)),
                ),
              ],
            )));
      case RecordState.fail:
        return const SizedBox(
            height: 100,
            child: Center(
              child: Text("기록 조회에 실패했습니다\n네트워크 상태를 체크해주세요!",
                  textAlign: TextAlign.center),
            ));
      case RecordState.success:
        return Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
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
                boxShadow: const [
                  BoxShadow(
                    color: Color.fromRGBO(0, 0, 0, 0.1),
                    spreadRadius: 2,
                    blurRadius: 3,
                    offset: Offset(1, 1), // changes position of shadow
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
          SizedBox(
              height: 220,
              width: MediaQuery.of(context).size.width,
              child: TabBarView(
                  controller: _tabController,
                  children: _records.map((e) => recordDetailView(e)).toList())),
          InkWell(
            onTap: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => ChangeNotifierProvider(
                      create: (context) => RecordListProvider(),
                      child: const RecordListPage(),
                    ))),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text('기록 전체보기', style: settingTextStyle),
                  const SizedBox(
                    width: 5,
                  ),
                  const Icon(
                    Icons.add_chart_rounded,
                    color: Color.fromARGB(185, 51, 57, 62),
                    size: 17,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
              height: 330,
              width: MediaQuery.of(context).size.width,
              child: recordChart()),
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

  Widget settingBox() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text('앱 버전 : ${_settingProvider.version}', style: settingTextStyle),
        const Text('   |   '),
        InkWell(
          onTap: () async {
            bool result = await _settingProvider.signOut();
            if (result) {
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ChangeNotifierProvider(
                            create: (context) => AuthProvider(),
                            child: const LodingPage(),
                          )),
                  ((route) => false));
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('로그아웃에 실패했습니다. 잠시후 다시 시도해주세요.',
                      style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 16,
                          fontWeight: FontWeight.w400)),
                ),
              );
            }
          },
          child: Text('로그아웃', style: settingTextStyle),
        ),
        const Text('   |   '),
        InkWell(
          onTap: () => withdrawalDialog(),
          child: Text('계정 탈퇴', style: settingTextStyle),
        ),
      ],
    );
  }

  Widget recordDetailView(Record record) {
    if (record.timestamp == 0) {
      return Container(
        padding: const EdgeInsets.all(20),
        height: 50,
        alignment: Alignment.center,
        child: const Text('라이딩한 기록이 없습니다'),
      );
    } else {
      Data distance = Data('거리', '${record.distance / 1000}km',
          'assets/icons/home_distance.png');
      Data time = Data('시간', timestampToText(record.timestamp),
          'assets/icons/home_time.png');

      Data speed;
      try {
        speed = Data(
            '평균 속도',
            '${((record.distance / 1000 / record.timestamp / 3600 * 10).toInt()) / 10}km/h',
            'assets/icons/home_speed.png');
      } catch (e) {
        speed = Data('평균 속도', '0km/h', 'assets/icons/home_speed.png');
      }
      Data speedMax = Data('순간 최고 속도', '${record.topSpeed}m/s',
          'assets/icons/home_max_speed.png');

      return Container(
          height: 200,
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
          width: MediaQuery.of(context).size.width,
          child: Row(
            children: [
              Flexible(
                  flex: 1,
                  child: Column(
                    children: [
                      recordCard(distance),
                      const SizedBox(
                        height: 8,
                      ),
                      recordCard(speed)
                    ],
                  )),
              const SizedBox(
                width: 8,
              ),
              Flexible(
                  flex: 1,
                  child: Column(
                    children: [
                      recordCard(time),
                      const SizedBox(
                        height: 8,
                      ),
                      recordCard(speedMax)
                    ],
                  ))
            ],
          ));
    }
  }

  Widget recordCard(Data data) {
    return Flexible(
        flex: 1,
        child: Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Color.fromRGBO(0, 41, 135, 0.047),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(1, 1), // changes position of shadow
                  )
                ],
                borderRadius: BorderRadius.all(Radius.circular(12))),
            child: Stack(
              children: [
                Positioned(
                    left: 0,
                    top: 0,
                    child: Row(
                      children: [
                        Image.asset(data.icon,
                            width: 15, height: 15, fit: BoxFit.cover),
                        Text(
                          "  ${data.key}",
                          style: const TextStyle(
                              fontSize: 12,
                              fontFamily: 'Pretendard',
                              fontWeight: FontWeight.w500,
                              color: Color.fromRGBO(17, 17, 17, 1)),
                        )
                      ],
                    )),
                Positioned(
                    bottom: 0,
                    left: 0,
                    child: Text(
                      data.data,
                      style: const TextStyle(
                          fontSize: 24,
                          fontFamily: 'Pretendard',
                          fontWeight: FontWeight.w300,
                          color: Colors.black),
                      textAlign: TextAlign.start,
                    ))
              ],
            )));
  }

  Widget recordChart() {
    return Container(
        decoration: const BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Color.fromRGBO(0, 41, 135, 0.047),
                spreadRadius: 2,
                blurRadius: 10,
                offset: Offset(1, 1), // changes position of shadow
              )
            ],
            borderRadius: BorderRadius.all(Radius.circular(12))),
        padding: const EdgeInsets.all(20),
        margin: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
        alignment: Alignment.topLeft,
        width: MediaQuery.of(context).size.width,
        height: 330,
        child: Column(mainAxisSize: MainAxisSize.max, children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('주행기록',
                  style: TextStyle(
                      fontSize: 14,
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w700,
                      color: Color.fromRGBO(51, 51, 51, 1))),
              // Text('km',
              //     style: TextStyle(
              //         fontSize: 12,
              //         fontFamily: 'Pretendard',
              //         fontWeight: FontWeight.w300,
              //         color: Color.fromRGBO(51, 51, 51, 1))),
            ],
          ),
          Container(
            alignment: Alignment.center,
            width: MediaQuery.of(context).size.width - 90,
            padding: const EdgeInsets.all(10),
            height: 230,
            child: Stack(
              children: [
                Positioned(
                  left: 0,
                  top: 0,
                  child: Text('    ${_getMaxDistance(_records) + 1}km',
                      style: const TextStyle(
                          fontSize: 12,
                          fontFamily: 'Pretendard',
                          fontWeight: FontWeight.w300,
                          color: Color.fromRGBO(51, 51, 51, 1))),
                ),
                Positioned(
                  right: 0,
                  bottom: 20,
                  child:
                      //Text('최근 기록 \n----->',
                      Text('   ${_getLastRecordDate(_records)}',
                          style: const TextStyle(
                              fontSize: 12,
                              fontFamily: 'Pretendard',
                              fontWeight: FontWeight.w300,
                              color: Color.fromRGBO(51, 51, 51, 1))),
                ),
                Container(
                  padding: EdgeInsets.only(bottom: 10),
                  child: const VerticalDivider(
                      width: 1,
                      color: Color.fromRGBO(234, 234, 234, 1),
                      thickness: 1.0),
                ),
                Column(
                  children: [
                    Container(
                      alignment: Alignment.center,
                      height: 200,
                      child: customLineChart(),
                    ),
                    const SizedBox(
                        width: 330,
                        height: 0,
                        child: Divider(
                            color: Color.fromRGBO(234, 234, 234, 1),
                            thickness: 1.0)),
                  ],
                )
              ],
            ),
          )
        ]));
  }

  Widget customLineChart() {
    Paint circlePaint = Paint()
      ..color = const Color.fromARGB(0xFF, 0xFB, 0x95, 0x32);

    Paint insideCirclePaint = Paint()
      ..color = const Color.fromARGB(0xFF, 0xFB, 0x95, 0x32);

    Paint linePaint = Paint()
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke
      ..color = Colors.orange;
    return LineChart(
      width: MediaQuery.of(context).size.width - 110,
      height: 120,
      insidePadding: 30,
      data: data,
      linePaint: linePaint,
      circlePaint: circlePaint,
      showPointer: true,
      showCircles: true,
      customDraw: (Canvas canvas, Size size) {},
      linePointerDecoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.orange,
      ),
      pointerDecoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.deepOrange,
      ),
      insideCirclePaint: insideCirclePaint,
      onValuePointer: (LineChartModelCallback value) {},
      onDropPointer: () {},
    );
  }

  Widget weatherWidget() {
    const TextStyle weatherTextStyle = TextStyle(
        fontSize: 14,
        fontFamily: 'Pretendard',
        fontWeight: FontWeight.w600,
        color: Color.fromRGBO(51, 51, 51, 1));
    switch (_weatherProvider.loadingStatus) {
      case WeatherState.searching:
        return Container(
            width: MediaQuery.of(context).size.width,
            color: Colors.white,
            child: Container(
                padding: const EdgeInsets.all(12),
                child: const Text(
                  '날씨를 검색중입니다',
                  style: weatherTextStyle,
                )));
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
                child: const Text(
                  '날씨를 불러오지 못했습니다,',
                  style: weatherTextStyle,
                )));
      case WeatherState.completed:
        Weather weather = _weatherProvider.weather;
        return Container(
            width: MediaQuery.of(context).size.width,
            color: Colors.white,
            child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    width: 0.7,
                    color: const Color.fromRGBO(234, 234, 234, 1),
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
                      width: 10,
                    ),
                    Text(
                        '오늘의 온도 : ${weather.temp}°C   습도 : ${weather.humidity}%',
                        style: weatherTextStyle)
                  ],
                )));

      default:
        return const Text('날씨를 검색중입니다');
    }
  }

  Widget recommendPlaceText(String title) {
    return Container(
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.fromLTRB(20, 25, 20, 25),
        child: Text.rich(
          TextSpan(
              text: '${_homeRecordProvider.name}님, 오늘같은 날에는\n',
              style: const TextStyle(
                  fontSize: mainFontSize,
                  color: Color.fromRGBO(51, 51, 51, 1),
                  fontFamily: "Pretendard",
                  height: 1.4,
                  letterSpacing: 0.02,
                  fontWeight: FontWeight.w800),
              children: <TextSpan>[
                TextSpan(
                    text: '\'$title',
                    style: const TextStyle(
                        fontSize: mainFontSize,
                        letterSpacing: 0.02,
                        fontWeight: FontWeight.w800,
                        fontFamily: "Pretendard",
                        color: Color.fromARGB(255, 253, 154, 55))),
                const TextSpan(
                    text: ' 어떠세요?',
                    style: TextStyle(
                        fontSize: mainFontSize,
                        letterSpacing: 0.02,
                        color: Color.fromRGBO(51, 51, 51, 1),
                        fontFamily: "Pretendard",
                        fontWeight: FontWeight.w800))
              ]),
          textAlign: TextAlign.start,
        ));
  }

  Widget recommendPlace(Place? place) {
    return Flexible(
      flex: 1,
      child: place == null
          ? Container(
              alignment: Alignment.center,
              height: 130,
              margin: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(20)),
              ),
              child: const Text(
                "추천 명소를\n불러오고 있습니다",
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w500,
                  color: Color.fromRGBO(51, 51, 51, 1),
                ),
              ),
            )
          : Stack(
              children: [
                SizedBox(
                    height: 130,
                    child: InkWell(
                        onTap: () {
                          routeDialog(place);
                        },
                        child: Stack(children: [
                          Container(
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height,
                            decoration: const BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20)),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20.0),
                              child: Image.asset(
                                place.image!,
                                height: 130.0,
                                width: MediaQuery.of(context).size.width,
                                fit: BoxFit.fill,
                              ),
                            ),
                          ),
                          Container(
                              width: MediaQuery.of(context).size.width,
                              height: MediaQuery.of(context).size.height,
                              decoration: const BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20)),
                                  color: Color.fromARGB(45, 0, 0, 0)))
                        ]))),
                Container(
                  height: 130,
                  padding: const EdgeInsets.all(15),
                  alignment: Alignment.bottomRight,
                  child: Text(
                    "${place.title}",
                    style: const TextStyle(
                        fontSize: 16,
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w600,
                        color: Colors.white),
                    textAlign: TextAlign.end,
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

  // Widget? floatingButtons() {
  //   return SpeedDial(
  //     animatedIcon: AnimatedIcons.menu_close,
  //     visible: true,
  //     curve: Curves.bounceIn,
  //     backgroundColor: const Color.fromARGB(0xFF, 0xFB, 0x95, 0x32),
  //     children: [
  //       SpeedDialChild(
  //           child: const Icon(Icons.settings_sharp, color: Colors.white),
  //           label: "설정",
  //           labelStyle: const TextStyle(
  //               fontWeight: FontWeight.w500,
  //               color: Colors.white,
  //               fontSize: 13.0),
  //           backgroundColor: const Color.fromARGB(0xFF, 0xFB, 0x95, 0x32),
  //           labelBackgroundColor: const Color.fromARGB(0xFF, 0xFB, 0x95, 0x32),
  //           onTap: () {
  //             Navigator.of(context).push(MaterialPageRoute(
  //                 builder: (context) => ChangeNotifierProvider(
  //                       create: (context) => SettingProvider(),
  //                       child: const SettingPage(),
  //                     )));
  //           }),
  //       SpeedDialChild(
  //         child: const Icon(
  //           Icons.add_chart_rounded,
  //           color: Colors.white,
  //         ),
  //         label: "내 기록",
  //         backgroundColor: const Color.fromARGB(0xFF, 0xFB, 0x95, 0x32),
  //         labelBackgroundColor: const Color.fromARGB(0xFF, 0xFB, 0x95, 0x32),
  //         labelStyle: const TextStyle(
  //             fontWeight: FontWeight.w500, color: Colors.white, fontSize: 13.0),
  //         onTap: () {
  //           Navigator.of(context).push(MaterialPageRoute(
  //               builder: (context) => ChangeNotifierProvider(
  //                     create: (context) => RecordListProvider(),
  //                     child: const RecordListPage(),
  //                   )));
  //         },
  //       )
  //     ],
  //   );
  // }

  int _getMaxDistance(List<Record> records) {
    double maxDistance = 0;
    int recoredCount = 0;
    for (var element in records) {
      if (element.distance > maxDistance) {
        maxDistance = element.distance;
      }
    }
    return (maxDistance / 1000).round();
  }

  String _getLastRecordDate(List<Record> records) {
    String dateStr = '';
    for (var element in records) {
      if (element.date != '') {
        DateTime date = element.getYearMonthDay();
        dateStr = "${date.month}월 ${date.day}일";
      }
    }
    return dateStr;
  }

  void _incrementCounter(List<Record> _records) {
    setState(() {
      data = [];
      for (var element in _records) {
        if (element.date != '') {
          DateTime day = element.getYearMonthDay();
          data.add(LineChartModel(amount: element.distance, date: day));
        }
      }
    });
  }

  Future<bool> withdrawalDialog() async {
    return await showDialog(
        context: context,
        barrierDismissible: false,
        useRootNavigator: false,
        builder: (BuildContext context) => AlertDialog(
              buttonPadding: const EdgeInsets.all(20),
              alignment: Alignment.center,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0)),
              content: Container(
                  margin: const EdgeInsets.only(top: 20),
                  child: const Text.rich(
                    TextSpan(
                        text: '계정 탈퇴하시겠습니까?\n',
                        style: TextStyle(
                            color: Color.fromARGB(255, 24, 24, 1),
                            fontFamily: 'Pretendard',
                            fontWeight: FontWeight.w600,
                            fontSize: 17),
                        children: <TextSpan>[
                          TextSpan(
                            text: '(모든 기록이 삭제됩니다)',
                            style: TextStyle(
                                color: Color.fromARGB(150, 24, 24, 1),
                                fontFamily: 'Pretendard',
                                height: 1.5,
                                fontWeight: FontWeight.w600,
                                fontSize: 13),
                          )
                        ]),
                    textAlign: TextAlign.center,
                  )),
              actions: <Widget>[
                SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: 55,
                    child: Row(
                      children: [
                        Flexible(
                            child: InkWell(
                          child: Container(
                            margin: const EdgeInsets.fromLTRB(0, 0, 6, 0),
                            alignment: Alignment.center,
                            height: 55,
                            decoration: BoxDecoration(
                              color: const Color.fromRGBO(234, 234, 234, 1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              '취소',
                              style: TextStyle(
                                  color: Color.fromRGBO(102, 102, 102, 1),
                                  fontFamily: 'Pretendard',
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          onTap: () {
                            Navigator.pop(context, false);
                          },
                        )),
                        Flexible(
                            child: InkWell(
                          child: Container(
                            margin: EdgeInsets.fromLTRB(6, 0, 0, 0),
                            alignment: Alignment.center,
                            height: 55,
                            decoration: BoxDecoration(
                              color: const Color.fromRGBO(240, 120, 5, 1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              '탈퇴',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Pretendard',
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          onTap: () async {
                            await _settingProvider.withdrawal();
                            Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        ChangeNotifierProvider(
                                          create: (context) => AuthProvider(),
                                          child: const LodingPage(),
                                        )),
                                ((route) => false));
                          },
                        ))
                      ],
                    ))
              ],
            ));
  }
}

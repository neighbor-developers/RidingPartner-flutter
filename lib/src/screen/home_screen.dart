import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:line_chart/charts/line-chart.widget.dart';
import 'package:line_chart/model/line-chart.model.dart';
import 'package:ridingpartner_flutter/src/models/record.dart';
import 'package:ridingpartner_flutter/src/provider/home_record_provider.dart';
import 'package:ridingpartner_flutter/src/style/palette.dart';
import 'package:ridingpartner_flutter/src/style/textstyle.dart';
import 'package:ridingpartner_flutter/src/utils/timestampToText.dart';
import 'package:ridingpartner_flutter/src/widgets/home/recommend_place_widget.dart';
import 'package:ridingpartner_flutter/src/widgets/home/setting_widget.dart';
import 'package:ridingpartner_flutter/src/widgets/home/weather_widget.dart';

import '../utils/get_riding_data.dart';

class Data {
  String key;
  String data;
  String icon;

  Data(this.key, this.data, this.icon);
}

const numberOfRecentRecords = 14;

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  late HomeRecordProvider _homeRecordProvider;
  late List<Record> _records;
  late TabController _tabController;
  int state = 0;

  List<LineChartModel> data = [];

  // int _counter = 0;

  @override
  void initState() {
    super.initState();
    Provider.of<HomeRecordProvider>(context, listen: false).getData();
    _tabController = TabController(
        length: numberOfRecentRecords, vsync: this, initialIndex: 13);
  }

  GlobalKey _one = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final _homeRecordProvider = Provider.of<HomeRecordProvider>(context);
    _records = _homeRecordProvider.recordFor14Days;
    _incrementCounter(_records);

    return Scaffold(
        backgroundColor: const Color.fromARGB(0xFF, 0xF5, 0xF5, 0xF5),
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
                      const RecommendPlaceWidget(),
                      weekWidget(),
                      const SettingWidget(),
                      SizedBox(
                        height: 60,
                        width: MediaQuery.of(context).size.width,
                      )
                    ],
                  ),
                ))),
            const Positioned(
              bottom: 0,
              child: WeatherWidget(),
            )
          ],
        ));
  }

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
            // onTap: () => Navigator.of(context).push(MaterialPageRoute(
            //     builder: (context) => ChangeNotifierProvider(
            //           create: (context) => RecordListProvider(),
            //           child: const RecordListPage(),
            //         ))),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: const [
                  Text('기록 전체보기', style: TextStyles.settingStyle),
                  SizedBox(
                    width: 5,
                  ),
                  Icon(
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
              child: CircularProgressIndicator(color: Palette.appColor),
            ));
    }
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
      Data distance = Data(
          '거리',
          '${((record.distance / 10).roundToDouble()) / 100}km',
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
      Data speedMax = Data(
          '순간 최고 속도',
          '${record.topSpeed.toStringAsFixed(1)} km/h',
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
                  child: Text('    ${getMaxDistance(_records) + 1}km',
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
                      Text('   ${getLastRecordDate(_records)}',
                          style: const TextStyle(
                              fontSize: 12,
                              fontFamily: 'Pretendard',
                              fontWeight: FontWeight.w300,
                              color: Color.fromRGBO(51, 51, 51, 1))),
                ),
                Container(
                  padding: const EdgeInsets.only(bottom: 10),
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
      ..color = const ui.Color.fromARGB(109, 255, 177, 104);

    Paint insideCirclePaint = Paint()
      ..color = const ui.Color.fromARGB(255, 255, 147, 40);

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

  void _incrementCounter(List<Record> records) {
    List<Record> dataIn7days =
        (((records.reversed).toList()).sublist(0, 7)).reversed.toList();
    List<LineChartModel> model = [];
    for (var element in dataIn7days) {
      if (element.date != '') {
        DateTime day = element.getYearMonthDay();
        model.add(LineChartModel(amount: element.distance, date: day));
      }
    }
    setState(() {
      data = model;
    });
  }
}

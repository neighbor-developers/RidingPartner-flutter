import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:line_chart/charts/line-chart.widget.dart';
import 'package:line_chart/model/line-chart.model.dart';
import 'package:ridingpartner_flutter/src/models/record.dart';
import 'package:ridingpartner_flutter/src/style/textstyle.dart';

import '../widgets/home/home_record_tab.dart';
import '../widgets/home/recommend_place_widget.dart';
import '../widgets/home/setting_widget.dart';
import '../widgets/home/weather_widget.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  List<LineChartModel> data = [];

  @override
  Widget build(BuildContext context) {
    // _incrementCounter(record);

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
                      const RecordTabRow(),
                      SizedBox(
                          height: 330,
                          width: MediaQuery.of(context).size.width,
                          child: recordChart()),
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
              Text('주행기록', style: TextStyles.recordChartTextStyle),
            ],
          ),
          // Container(
          //   alignment: Alignment.center,
          //   width: MediaQuery.of(context).size.width - 90,
          //   padding: const EdgeInsets.all(10),
          //   height: 230,
          //   child: Stack(
          //     children: [
          //       Positioned(
          //         left: 0,
          //         top: 0,
          //         child: Text('    ${getMaxDistance() + 1}km',
          //             style: const TextStyle(
          //                 fontSize: 12,
          //                 fontFamily: 'Pretendard',
          //                 fontWeight: FontWeight.w300,
          //                 color: Color.fromRGBO(51, 51, 51, 1))),
          //       ),
          //       Positioned(
          //         right: 0,
          //         bottom: 20,
          //         child:
          //             //Text('최근 기록 \n----->',
          //             Text('   ${getLastRecordDate(_records)}',
          //                 style: const TextStyle(
          //                     fontSize: 12,
          //                     fontFamily: 'Pretendard',
          //                     fontWeight: FontWeight.w300,
          //                     color: Color.fromRGBO(51, 51, 51, 1))),
          //       ),
          //       Container(
          //         padding: const EdgeInsets.only(bottom: 10),
          //         child: const VerticalDivider(
          //             width: 1,
          //             color: Color.fromRGBO(234, 234, 234, 1),
          //             thickness: 1.0),
          //       ),
          //       Column(
          //         children: [
          //           Container(
          //             alignment: Alignment.center,
          //             height: 200,
          //             child: customLineChart(),
          //           ),
          //           const SizedBox(
          //               width: 330,
          //               height: 0,
          //               child: Divider(
          //                   color: Color.fromRGBO(234, 234, 234, 1),
          //                   thickness: 1.0)),
          //         ],
          //       )
          //     ],
          //   ),
          // )
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

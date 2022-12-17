import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:ridingpartner_flutter/src/provider/bottom_navigation_provider.dart';
import 'package:ridingpartner_flutter/src/provider/home_record_provider.dart';

import '../models/record.dart';
import '../provider/riding_result_provider.dart';
import '../provider/weather_provider.dart';
import 'home_page.dart';

class RecordPage extends StatelessWidget {
  RecordPage({super.key});

  late RidingResultProvider _recordProvider;

  @override
  Widget build(BuildContext context) {
    Record _record = Record();
    num _speed = 0;

    _recordProvider = Provider.of<RidingResultProvider>(context);
    if (_recordProvider.recordState == RecordState.loading) {
      _recordProvider.getRidingData();
    }

    if (_recordProvider.recordState == RecordState.success) {
      _record = _recordProvider.record;
      if (_record.distance != null) {
        _speed = _record.distance as num;
        _speed = _speed / 3 * 3600;
      }
    }

    _record.distance ??= 0.0;
    DateTime today = DateTime.now();
    DateFormat format = DateFormat('yyyy년 MM월 dd일');
    String formattedDate = format.format(today);


    // File _image = _recordProvider.image;

    // 이미지를 보여주는 위젯
    /* Widget showImage() {
      if (_recordProvider.imageStatus == ImageStatus.init) {
        return const Text("init");
      } else if (_recordProvider.imageStatus == ImageStatus.success) {
        return Container(
            color: const Color(0xffd0cece),
            width: MediaQuery
                .of(context)
                .size
                .width,
            height: MediaQuery
                .of(context)
                .size
                .width,
            child: Center(
                child: _image == null
                    ? const Text('No image selected.')
                    : Image.file(File(_image!.path))));
      } else {
        return const Text("fail");
      }
    }*/

    return Scaffold(
        appBar: AppBar(
            centerTitle: true,
            backgroundColor: Colors.white,
            title: Image.asset(
              'assets/icons/logo.png',
              height: 25,
            )),
        body: Container(
            margin: const EdgeInsets.only(bottom: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("주행기록",
                    style: TextStyle(
                        color: Color.fromARGB(255, 0, 0, 0), fontSize: 30.0)),
                Row(children: [
                  const Text(
                    "날짜\t",
                    style: TextStyle(
                        color: Color.fromARGB(255, 0, 0, 0), fontSize: 16.0),
                  ),
                  Text("$formattedDate\n",
                    style: const TextStyle(fontSize: 16),)
                ]),
                Row(children: [
                  const Text(
                    "주행 시간\t",
                    style: TextStyle(
                        color: Color.fromARGB(255, 0, 0, 0), fontSize: 16.0),
                  ),
                  /*Text("${_record.timestamp! / 3600} : ${_record.timestamp! /
                      60} : ${_record.timestamp! % 60}\n",
                    style: const TextStyle(fontSize: 16),)*/
                ]),
                Row(children: [
                  const Text(
                    "평균 속도\t",
                    style: TextStyle(
                        color: Color.fromARGB(255, 0, 0, 0), fontSize: 16.0),
                  ),
                  /*Text("${_record.distance! / _record.timestamp!}km/h\n",
                    style: const TextStyle(fontSize: 16),)*/
                ]),
                Row(children: [
                  const Text(
                    "주행 총 거리\t",
                    style: TextStyle(
                        color: Color.fromARGB(255, 0, 0, 0), fontSize: 16.0),
                  ),
                  Text("${_record.distance! / 1000}km\n",
                    style: const TextStyle(fontSize: 16),)
                ]),
                Row(children: const [
                  Text(
                    "소모 칼로리\t",
                    style: TextStyle(
                        color: Color.fromARGB(255, 0, 0, 0), fontSize: 16.0),
                  ),
                  Text("36.9kcal\n",
                    style: TextStyle(fontSize: 16),)
                ]),
                InkWell(
                    child: Container(
                        width: 60.0,
                        height: 60.0,
                        decoration: const BoxDecoration(
                          shape: BoxShape.rectangle,
                        ),
                        child: Image.asset(
                          'assets/icons/add_image.png',
                          color: Colors.black26,
                        ))),
                const TextField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: "오늘의 라이딩은 어땠나요?",
                    )),
                Container(
                  alignment: Alignment.bottomCenter,
                  child: ElevatedButton(onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) =>
                            MultiProvider(providers: [
                                ChangeNotifierProvider(
                                create: (context) => WeatherProvider()),
                                ChangeNotifierProvider(
                                create: (context) => HomeRecordProvider()),
                                ChangeNotifierProvider(
                                    create: (context) => BottomNavigationProvider())
                    ],
                    child: const HomePage())));
                  },
                    style: ButtonStyle(
                      padding: MaterialStateProperty.all<EdgeInsets>(
                          const EdgeInsets.all(13.0)),
                      backgroundColor: MaterialStateProperty.all<Color>(
                          const Color.fromARGB(0xFF, 0xFB, 0x95, 0x32)),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18.0),
                          )
                      ),
                    ),
                    child:
                    const Text(
                        "기록 저장하기",
                        style: TextStyle(
                            fontSize: 17.0
                        )
                    ),
                  ),
                )
              ],
            )));
  }
}

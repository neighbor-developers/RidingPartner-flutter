import 'dart:ffi';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:ridingpartner_flutter/src/provider/bottom_navigation_provider.dart';
import 'package:ridingpartner_flutter/src/provider/home_record_provider.dart';
import 'package:ridingpartner_flutter/src/utils/timestampToText.dart';

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
    int hKcal = 401;

    // File _image = _recordProvider.image;

    // 이미지를 보여주는 위젯
    /*Widget showImage() {
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
          backgroundColor: const Color.fromARGB(0xFF, 0xEE, 0x75, 0x00),
          elevation: 0.0,
        ),
        body: Container(
            decoration: const BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color.fromARGB(0xFF, 0xEE, 0x75, 0x00),
                      Color.fromARGB(0xFF, 0xFF, 0xA0, 0x44)
                    ])),
            child: Container(
                margin: const EdgeInsets.only(left: 20.0, right: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("즐거운 라이딩\n되셨나요?",
                        style: TextStyle(
                            color: Color.fromARGB(255, 255, 255, 255),
                            fontSize: 31.0)),
                    Container(
                      margin: const EdgeInsets.only(top: 15.0),
                      child: Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                "날짜",
                                style: TextStyle(
                                    fontSize: 16.0,
                                    color: Color.fromARGB(255, 255, 255, 255)),
                              ),
                              Text(
                                "주행 시간",
                                style: TextStyle(
                                    fontSize: 16.0,
                                    color: Color.fromARGB(255, 255, 255, 255)),
                              ),
                              Text(
                                "평균 속도",
                                style: TextStyle(
                                    fontSize: 16.0,
                                    color: Color.fromARGB(255, 255, 255, 255)),
                              ),
                              Text(
                                "주행 총 거리",
                                style: TextStyle(
                                    fontSize: 16.0,
                                    color: Color.fromARGB(255, 255, 255, 255)),
                              ),
                              Text(
                                "소모 칼로리",
                                style: TextStyle(
                                    fontSize: 16.0,
                                    color: Color.fromARGB(255, 255, 255, 255)),
                              )
                            ],
                          ),
                          const SizedBox(width:20.0),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                formattedDate,
                                style: const TextStyle(fontSize: 16.0,
                                    color: Color.fromARGB(255, 255, 255, 255)),
                              ),
                              Text(
                                timestampToText(_record.timestamp!),
                                style: const TextStyle(fontSize: 16.0,
                                    color: Color.fromARGB(255, 255, 255, 255)),
                              ),
                              Text(
                                "${_record.distance! /
                                    _record.timestamp!} km/h",
                                style: const TextStyle(fontSize: 16.0,
                                    color: Color.fromARGB(255, 255, 255, 255)),
                              ),
                              Text(
                                "${_record.distance! / 1000} km",
                                style: const TextStyle(fontSize: 16.0,
                                    color: Color.fromARGB(255, 255, 255, 255)),
                              ),
                              Text(
                                "${(hKcal * (_record.timestamp!) / 4000)
                                    .toStringAsFixed(1)} kcal",
                                style: const TextStyle(fontSize: 16.0,
                                    color: Color.fromARGB(255, 255, 255, 255)),
                              )
                            ],
                          ),
                        ],),
                    ),
                    InkWell(
                      onTap: (){/*showImage();*/},
                        child: Container(
                          margin: const EdgeInsets.only(top: 20.0, bottom: 20.0),
                            width: 60.0,
                            height: 60.0,
                            decoration: const BoxDecoration(
                              shape: BoxShape.rectangle,
                            ),
                            child: Image.asset(
                              'assets/icons/add_image.png',
                              color: Colors.white,
                            ))),
                    const TextField(
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderSide: BorderSide(width: 3,
                                color: Colors.white),
                          ),
                          hintText: "오늘의 라이딩은 어땠나요?",
                          hintStyle: TextStyle(color: Colors.white,
                          ),
                        )),
                    Container(
                      margin: const EdgeInsets.only(top: 20.0),
                      alignment: Alignment.bottomCenter,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.pop(context);
                        },
                        style: ButtonStyle(
                          shadowColor: MaterialStateProperty.all<Color>(Color.fromARGB(0xFF, 0xFB, 0x95, 0x32)),
                          padding: MaterialStateProperty.all<EdgeInsets>(
                              const EdgeInsets.all(13.0)),
                          backgroundColor: MaterialStateProperty.all<Color>(
                              const Color.fromARGB(0xFF, 0xFB, 0x95, 0x32)),
                          shape: MaterialStateProperty.all<
                              RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18.0),
                              )),
                        ),
                        child:
                        const Text("기록 저장하기", style: TextStyle(fontSize: 17.0)),
                      ),
                    )
                  ],
                ))));
  }
}

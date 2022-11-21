import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:ridingpartner_flutter/src/provider/home_record_provider.dart';

import '../models/record.dart';
import '../provider/riding_result_provider.dart';

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
      _speed = _record.distance! / 3 * 3600;
    }

    File _image = _recordProvider.image;

    // 이미지를 보여주는 위젯
    Widget showImage() {
      if (_recordProvider.imageStatus == ImageStatus.init) {
        return Container(
          child: const Text("init"),
        );
      } else if (_recordProvider.imageStatus == ImageStatus.success) {
        return Container(
            color: const Color(0xffd0cece),
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.width,
            child: Center(
                child: _image == null
                    ? const Text('No image selected.')
                    : Image.file(File(_image!.path))));
      } else {
        return Container(
          child: const Text("fail"),
        );
      }
    }

    return Scaffold(
        appBar: AppBar(),
        body: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("${_record.distance!}",
                style: TextStyle(fontSize: 35), textAlign: TextAlign.left),
            Text(
              "킬로미터",
              textAlign: TextAlign.left,
            ),
            Container(
                height: 1.0,
                width: 500.0,
                color: Colors.grey,
                child: InkWell(
                    onTap: () {
                      _recordProvider.getImage(ImageSource.camera);
                    },
                    child: showImage())),
            Row(children: [
              Text("${_record.timestamp!}"),
              Text("${_speed}km/h")
            ]),
            Row(children: [Text("주행 시간"), Text("평균 속도")]),
            Row(children: [
              Text("${_record.distance!}km"),
              Text("${_record.topSpeed!}")
            ]),
            Row(children: [Text("주행 거리"), Text("소모 칼로리")]),
            Container(height: 1.0, width: 500.0, color: Colors.grey)
          ],
        )));
  }
}

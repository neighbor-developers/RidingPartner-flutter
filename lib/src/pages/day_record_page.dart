import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/record.dart';
import '../provider/home_record_provider.dart';
import '../provider/riding_result_provider.dart';
import '../utils/timestampToText.dart';

class DayRecordPage extends StatelessWidget {
  DayRecordPage({super.key});

  late RidingResultProvider _recordProvider;

  @override
  Widget build(BuildContext context) {
    Record _record = Record();
    _recordProvider = Provider.of<RidingResultProvider>(context);
    num _speed = 0;

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

    _record.memo ??= "그 날의 메모가 존재하지 않습니다.";
    _record.kcal ??= 0.0;

    return Scaffold(
      appBar: AppBar(
        shadowColor: const Color.fromRGBO(255, 255, 255, 0.5),
        backgroundColor: Colors.white,
        title: Container(
            padding: const EdgeInsets.fromLTRB(0, 0, 50, 0),
            width: MediaQuery
                .of(context)
                .size
                .width,
            alignment: Alignment.center,
            child: Image.asset(
              'assets/icons/logo.png',
              height: 25,
            )),
        leadingWidth: 50,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back),
          color: const Color(0xFF343A40),
        ),
        elevation: 0.0,
      ),
      resizeToAvoidBottomInset: false,
      body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          const SizedBox(
          width: double.infinity,
          height: 240,
          child: Image(
              image:
              AssetImage('assets/images/img_loading.png'),
              fit: BoxFit.fill
          )),
      Container(
        margin: const EdgeInsets.only(left: 24.0, right: 24.0, top: 30),
        child: Row(
          children: [
            SizedBox(
              width: 100.0,
              height: 120.0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "날짜",
                    style: TextStyle(
                        fontSize: 16.0,
                        fontFamily: "Pretendard",
                        color: Color(0xFF666666)),
                  ),
                  Text(
                    "주행 시간",
                    style: TextStyle(
                        fontSize: 16.0,
                        fontFamily: "Pretendard",
                        color: Color(0xFF666666)),
                  ),
                  Text(
                    "평균 속도",
                    style: TextStyle(
                        fontSize: 16.0,
                        fontFamily: "Pretendard",
                        color: Color(0xFF666666)),
                  ),
                  Text(
                    "주행 총 거리",
                    style: TextStyle(
                        fontSize: 16.0,
                        fontFamily: "Pretendard",
                        color: Color(0xFF666666)),
                  ),
                  Text(
                    "소모 칼로리",
                    style: TextStyle(
                        fontSize: 16.0,
                        fontFamily: "Pretendard",
                        color: Color(0xFF666666)),
                  )
                ],
              ),
            ),
            SizedBox(
              height: 120.0,
              width: 220.0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    _record.date!,
                    style: const TextStyle(
                      fontFamily: "Pretendard",
                      fontSize: 16.0,
                      color: Color(0xFF666666),
                    ),
                  ),
                  Text(
                    timestampToText(_record.timestamp!),
                    style: const TextStyle(
                        fontSize: 16.0,
                        fontFamily: "Pretendard",
                        fontWeight: FontWeight.w500,
                        color:
                        Color(0xFF666666)),
                  ),
                  Text(
                    "${_record.distance! / _record.timestamp!} km/h",
                    style: const TextStyle(
                        fontSize: 16.0,
                        fontFamily: "Pretendard",
                        fontWeight: FontWeight.w500,
                        color:
                        Color(0xFF666666)),
                  ),
                  Text(
                    "${_record.distance! / 1000} km",
                    style: const TextStyle(
                        fontSize: 16.0,
                        fontFamily: "Pretendard",
                        fontWeight: FontWeight.w500,
                        color:
                        Color(0xFF666666)),
                  ),
                  Text(
                    "${_record.kcal.toString()} kcal",
                    style: const TextStyle(
                        fontSize: 16.0,
                        fontFamily: "Pretendard",
                        color: Color(0xFF666666)),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
      Container(
          width: double.infinity,
          height: 200,
          decoration: BoxDecoration(
              border: Border.all(
                color: Colors.transparent
              ),
              borderRadius: BorderRadius.circular(10.0),
              color: const Color.fromARGB(0xFF, 0xEE, 0xF1, 0xF4)
          ),
          margin: const EdgeInsets.only(left: 24.0, right: 24.0),
          padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 12.0),
          child: Text(
          _record.memo!,
          style: TextStyle(
      fontSize: 14.0,
      color: const Color(0x333333).withOpacity(0.8),
    )))
    ]
    ,
    )
    );
  }
}

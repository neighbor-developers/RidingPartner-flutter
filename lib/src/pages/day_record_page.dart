import 'package:flutter/material.dart';

import '../provider/riding_result_provider.dart';

class DayRecordPage extends StatelessWidget {
  DayRecordPage({super.key});

  late RidingResultProvider _recordProvider;

  @override
  Widget build(BuildContext context) {
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
              AssetImage('assets/images/places/gaetgol_park.jpeg'))),
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
              width: 130.0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: const [
                  Text(
                    "2022년 12월 6일",
                    style:  TextStyle(
                      fontFamily: "Pretendard",
                      fontSize: 16.0,
                      color: Color(0xFF666666),
                    ),
                  ),
                  Text(
                    "01:10:02",
                    style:  TextStyle(
                        fontSize: 16.0,
                        fontFamily: "Pretendard",
                        color: Color(0xFF666666)),
                  ),
                  Text(
                    "24 km/h",
                    style:  TextStyle(
                        fontSize: 16.0,
                        fontFamily: "Pretendard",
                        color: Color(0xFF666666)),
                  ),
                  Text(
                    "16 km",
                    style:  TextStyle(
                        fontSize: 16.0,
                        fontFamily: "Pretendard",
                        color: Color(0xFF666666)),
                  ),
                  Text(
                    "600 kcal",
                    style:  TextStyle(
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
          "뭐시기 저시기 기록에 있는 메모 뭐시기 저시기 기록에 있는 메모 뭐시기 저시기 기록에 있는 메모 뭐시기 저시기 기록에 있는 메모",
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

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:ridingpartner_flutter/src/widgets/appbar.dart';

import '../models/record.dart';
import '../provider/home_record_provider.dart';
import '../provider/riding_result_provider.dart';
import '../utils/timestampToText.dart';

class DayRecordPage extends StatefulWidget {
  DayRecordPage({super.key});

  @override
  State<DayRecordPage> createState() => _DayRecordPageState();
}

class _DayRecordPageState extends State<DayRecordPage> {
  late RidingResultProvider _recordProvider;
  late Record _record;

  @override
  Widget build(BuildContext context) {
    _recordProvider = Provider.of<RidingResultProvider>(context);
    num speed = 0;

    Widget successWidget() => Scaffold(
        appBar: appBar(context),
        resizeToAvoidBottomInset: false,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
                width: double.infinity,
                height: 240,
                child: Image(
                    image: AssetImage('assets/images/img_loading.png'),
                    fit: BoxFit.fill)),
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
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF666666)),
                        ),
                        Text(
                          "주행 시간",
                          style: TextStyle(
                              fontSize: 16.0,
                              fontFamily: "Pretendard",
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF666666)),
                        ),
                        Text(
                          "평균 속도",
                          style: TextStyle(
                              fontSize: 16.0,
                              fontFamily: "Pretendard",
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF666666)),
                        ),
                        Text(
                          "주행 총 거리",
                          style: TextStyle(
                              fontSize: 16.0,
                              fontFamily: "Pretendard",
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF666666)),
                        ),
                        Text(
                          "소모 칼로리",
                          style: TextStyle(
                              fontSize: 16.0,
                              fontFamily: "Pretendard",
                              fontWeight: FontWeight.w400,
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
                          DateFormat('yyyy년 MM월 dd일')
                              .format(DateTime.parse(_record.date)),
                          style: const TextStyle(
                            fontFamily: "Pretendard",
                            fontSize: 16.0,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF666666),
                          ),
                        ),
                        Text(
                          timestampToText(_record.timestamp),
                          style: const TextStyle(
                              fontSize: 16.0,
                              fontFamily: "Pretendard",
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF666666)),
                        ),
                        Text(
                          "${_record.distance / _record.timestamp} km/h",
                          style: const TextStyle(
                              fontSize: 16.0,
                              fontFamily: "Pretendard",
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF666666)),
                        ),
                        Text(
                          "${_record.distance / 1000} km",
                          style: const TextStyle(
                              fontSize: 16.0,
                              fontFamily: "Pretendard",
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF666666)),
                        ),
                        Text(
                          "${(_record.kcal)?.toStringAsFixed(1).toString()} kcal",
                          style: const TextStyle(
                              fontSize: 16.0,
                              fontFamily: "Pretendard",
                              fontWeight: FontWeight.w500,
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
                    border: Border.all(color: Colors.transparent),
                    borderRadius: BorderRadius.circular(10.0),
                    color: const Color.fromARGB(0xFF, 0xEE, 0xF1, 0xF4)
                        .withOpacity(0.3)),
                margin: const EdgeInsets.only(left: 24.0, right: 24.0),
                padding:
                    const EdgeInsets.only(left: 16.0, right: 16.0, top: 12.0),
                child: Text(_record.memo ?? '',
                    style: TextStyle(
                      fontSize: 14.0,
                      fontWeight: FontWeight.w400,
                      color: const Color(0x00333333).withOpacity(0.8),
                    )))
          ],
        ));

    switch (_recordProvider.recordState) {
      case RecordState.loading:
        _recordProvider.getRidingData();
        return loadingWidget();
      case RecordState.fail:
        return failWidget();
      case RecordState.success:
        _record = _recordProvider.record;
        speed = _record.distance;
        speed = speed / 3 * 3600;
        return successWidget();
      default:
        return loadingWidget();
    }
  }

  Widget loadingWidget() => Scaffold(
      appBar: appBar(context),
      resizeToAvoidBottomInset: false,
      body: Center(
        child: Text('데이터 불러오는 증'),
      ));

  Widget failWidget() => Scaffold(
      appBar: appBar(context),
      resizeToAvoidBottomInset: false,
      body: Center(
        child: Text('데이터를 불러오는 데에 실패했습니다'),
      ));
}

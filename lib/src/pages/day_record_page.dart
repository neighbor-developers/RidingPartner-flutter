import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:ridingpartner_flutter/src/widgets/appbar.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../models/record.dart';
import '../provider/home_record_provider.dart';
import '../provider/riding_result_provider.dart';
import '../utils/timestampToText.dart';

class DayRecordPage extends StatefulWidget {
  const DayRecordPage({super.key});

  @override
  State<DayRecordPage> createState() => _DayRecordPageState();
}

class _DayRecordPageState extends State<DayRecordPage> {
  late RidingResultProvider _recordProvider;
  late Record _record;
  int hKcal = 550;

  int activeIndex = 0;

  @override
  Widget build(BuildContext context) {
    _recordProvider = Provider.of<RidingResultProvider>(context);
    num speed = 0;
    late List<String>? image = _record.images;

    const textStyle = TextStyle(
        fontSize: 18.5,
        fontFamily: "Pretendard",
        fontWeight: FontWeight.w400,
        color: Color.fromARGB(255, 66, 66, 66));

    const recordStyle = TextStyle(
        fontSize: 18.5,
        fontFamily: "Pretendard",
        fontWeight: FontWeight.w500,
        color: Color.fromARGB(255, 66, 66, 66));

    Widget successWidget() => Scaffold(
        appBar: appBar(context),
        resizeToAvoidBottomInset: false,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(alignment: Alignment.bottomCenter, children: <Widget>[
               if(image != null && image.length > 1)...[
              CarouselSlider.builder(
                options: CarouselOptions(
                  initialPage: 0,
                  viewportFraction: 1,
                  enlargeCenterPage: true,
                  onPageChanged: (index, reason) => setState(() {
                    activeIndex = index;
                  }),
                ),
                itemCount: image.length,
                itemBuilder: (context, index, realIndex) {
                  final path = _record.images![index];
                  return buildImage(path, index);
                },
              )] else if(image != null && image.length == 1)...[
                  SizedBox(
                  width: double.infinity,
                  height: 240,
                  child: Image.network(image[0], fit: BoxFit.cover))
              ] else...[
                SizedBox(
                  width: double.infinity,
                  height: 240,
                  child: Image.asset("assets/images/img_loading.png", fit: BoxFit.cover))
              ],

              Align(alignment: Alignment.bottomCenter, child: buildIndicator())
            ]),
            Container(
              margin:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 30),
              child: Row(
                children: [
                  SizedBox(
                    height: 140.0,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text(
                          "날짜",
                          style: textStyle,
                        ),
                        Text(
                          "주행 시간",
                          style: textStyle,
                        ),
                        Text(
                          "평균 속도",
                          style: textStyle,
                        ),
                        Text("주행 총 거리", style: textStyle),
                        Text("소모 칼로리", style: textStyle)
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(left: 30),
                    height: 140.0,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                            DateFormat('yyyy년 MM월 dd일')
                                .format(DateTime.parse(_record.date)),
                            style: recordStyle),
                        Text(timestampToText(_record.timestamp),
                            style: recordStyle),
                        if(_record.timestamp != 0)...[
                          Text(
                              "${(_record.distance / _record.timestamp).toStringAsFixed(1)} km/h",
                              style: recordStyle)]
                        else...[
                          const Text(
                              "0.0 km/h",
                              style: recordStyle)
                        ],
                        Text("${_record.distance / 1000} km",
                            style: recordStyle),
                        Text(
                            "${(hKcal * (_record.timestamp) / 3600).toStringAsFixed(1)} kcal",
                            style: recordStyle)
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
                child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Text(_record.memo ?? '',
                        style: TextStyle(
                          fontSize: 14.0,
                          fontWeight: FontWeight.w400,
                          color: const Color(0x00333333).withOpacity(0.6),
                        ))))
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
      body: const CircularProgressIndicator(
        color: Color.fromARGB(0xFF, 0xEE, 0x75, 0x00),
      ));

  Widget failWidget() => Scaffold(
      appBar: appBar(context),
      resizeToAvoidBottomInset: false,
      body: const Center(
        child: Text('데이터를 불러오는 데에 실패했습니다'),
      ));

  Widget buildImage(path, index) => Container(
        width: double.infinity,
        height: 240,
        color: Colors.grey,
        child: Image.network(path, fit: BoxFit.cover),
      );

  Widget buildIndicator() => Container(
      margin: const EdgeInsets.only(bottom: 20.0),
      alignment: Alignment.bottomCenter,
      child: AnimatedSmoothIndicator(
        activeIndex: activeIndex,
        count: _record.images?.length ?? 1,
        effect: JumpingDotEffect(
            dotHeight: 6,
            dotWidth: 6,
            activeDotColor: Colors.white,
            dotColor: Colors.white.withOpacity(0.6)),
      ));
}

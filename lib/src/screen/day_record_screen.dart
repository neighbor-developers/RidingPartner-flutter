import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:ridingpartner_flutter/src/widgets/appbar.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../models/record.dart';
import '../provider/home_record_provider.dart';
import '../style/textstyle.dart';
import '../utils/timestampToText.dart';

class DayRecordScreen extends StatefulWidget {
  const DayRecordScreen({super.key});

  @override
  State<DayRecordScreen> createState() => _DayRecordScreenState();
}

class _DayRecordScreenState extends State<DayRecordScreen> {
  late RidingResultProvider _recordProvider;
  late Record _record;
  int hKcal = 550;

  int activeIndex = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    Provider.of<RidingResultProvider>(context, listen: false).getRidingData();
  }

  num speed = 0;
  late List<String>? images = _record.images;
  @override
  Widget build(BuildContext context) {
    _recordProvider = Provider.of<RidingResultProvider>(context);

    Widget successWidget() => Scaffold(
        appBar: appBar(context),
        resizeToAvoidBottomInset: false,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(alignment: Alignment.bottomCenter, children: <Widget>[
              if (images == null) ...[
                SizedBox(
                    width: double.infinity,
                    height: 240,
                    child: Image.asset("assets/images/img_loading.png",
                        fit: BoxFit.cover))
              ] else if (_recordProvider.record.images!.length == 1) ...[
                SizedBox(
                    width: double.infinity,
                    height: 240,
                    child: Image.network(_recordProvider.record.images![0],
                        fit: BoxFit.cover))
              ] else ...[
                CarouselSlider.builder(
                  options: CarouselOptions(
                    initialPage: 0,
                    viewportFraction: 1,
                    enlargeCenterPage: true,
                    onPageChanged: (index, reason) => setState(() {
                      activeIndex = index;
                    }),
                  ),
                  itemCount: images?.length,
                  itemBuilder: (context, index, realIndex) {
                    final path = _record.images![index];
                    return buildImage(path);
                  },
                )
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
                          style: TextStyles.dayRecordtextStyle,
                        ),
                        Text(
                          "주행 시간",
                          style: TextStyles.dayRecordtextStyle,
                        ),
                        Text(
                          "평균 속도",
                          style: TextStyles.dayRecordtextStyle,
                        ),
                        Text("주행 총 거리", style: TextStyles.dayRecordtextStyle),
                        Text("소모 칼로리", style: TextStyles.dayRecordtextStyle)
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
                            style: TextStyles.dayRecordtextStyle2),
                        Text(timestampToText(_record.timestamp),
                            style: TextStyles.dayRecordtextStyle2),
                        if (_record.timestamp != 0) ...[
                          Text(
                              "${(_record.distance / _record.timestamp).toStringAsFixed(1)} km/h",
                              style: TextStyles.dayRecordtextStyle2)
                        ] else ...[
                          const Text("0.0 km/h",
                              style: TextStyles.dayRecordtextStyle2)
                        ],
                        Text(
                            "${(_record.distance / 1000).toStringAsFixed(2)} km",
                            style: TextStyles.dayRecordtextStyle2),
                        if (_record.distance == 0) ...[
                          const Text(
                            '0 kcal',
                            style: TextStyles.dayRecordtextStyle2,
                          )
                        ] else ...[
                          Text(
                              "${(hKcal * (_record.timestamp) / 3600).toStringAsFixed(1)} kcal",
                              style: TextStyles.dayRecordtextStyle2)
                        ]
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
      body: const Center(
          child: CircularProgressIndicator(
        color: Color.fromARGB(0xFF, 0xEE, 0x75, 0x00),
      )));

  Widget failWidget() => Scaffold(
      appBar: appBar(context),
      resizeToAvoidBottomInset: false,
      body: const Center(
        child: Text('데이터를 불러오는 데에 실패했습니다'),
      ));

  Widget buildImage(path) => Container(
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

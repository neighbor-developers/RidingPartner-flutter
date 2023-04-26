import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:ridingpartner_flutter/src/widgets/appbar.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../models/record.dart';
import '../service/firebase_database_service.dart';
import '../style/textstyle.dart';
import '../utils/timestamp_to_text.dart';

class RecordScreen extends ConsumerStatefulWidget {
  const RecordScreen({Key? key, required this.date}) : super(key: key);
  final String date;

  @override
  RecordScreenState createState() => RecordScreenState();
}

class RecordScreenState extends ConsumerState<RecordScreen> {
  late FutureProvider<Record> recordProvider;

  @override
  void initState() {
    super.initState();
    recordProvider = FutureProvider<Record>((ref) {
      return FirebaseDatabaseService().getRecord(widget.date);
    });
  }

  @override
  Widget build(BuildContext context) {
    final record = ref.watch(recordProvider);

    return record.when(
        data: (recordData) {
          return Scaffold(
              appBar: appBar(context),
              resizeToAvoidBottomInset: false,
              body: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ImageSlider(images: recordData.images),
                  recordWidget(recordData),
                  memoWidget(recordData.memo ?? '')
                ],
              ));
        },
        loading: () => Scaffold(
            appBar: appBar(context),
            resizeToAvoidBottomInset: false,
            body: const Center(
                child: CircularProgressIndicator(
              color: Color.fromARGB(0xFF, 0xEE, 0x75, 0x00),
            ))),
        error: (error, stack) => Scaffold(
            appBar: appBar(context),
            resizeToAvoidBottomInset: false,
            body: const Center(
              child: Text('데이터를 불러오는 데에 실패했습니다'),
            )));
  }

  // 기록 상세 화면의 기록 부분
  Widget recordWidget(Record record) {
    return Container(
        margin: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 30),
        child: Row(children: [
          const SizedBox(
            height: 140.0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
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
                        .format(DateTime.parse(record.date)),
                    style: TextStyles.dayRecordtextStyle2),
                Text(timestampToText(record.timestamp, 0),
                    style: TextStyles.dayRecordtextStyle2),
                if (record.timestamp != 0) ...[
                  Text(
                      "${(record.distance / record.timestamp).toStringAsFixed(1)} km/h",
                      style: TextStyles.dayRecordtextStyle2)
                ] else ...[
                  const Text("0.0 km/h", style: TextStyles.dayRecordtextStyle2)
                ],
                Text("${(record.distance / 1000).toStringAsFixed(2)} km",
                    style: TextStyles.dayRecordtextStyle2),
                if (record.distance == 0) ...[
                  const Text(
                    '0 kcal',
                    style: TextStyles.dayRecordtextStyle2,
                  )
                ] else ...[
                  Text("${record.kcal} kcal",
                      style: TextStyles.dayRecordtextStyle2)
                ]
              ],
            ),
          )
        ]));
  }

  // 기록 상세 화면의 메모 부분
  Widget memoWidget(String memo) {
    return Container(
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(
            border: Border.all(color: Colors.transparent),
            borderRadius: BorderRadius.circular(10.0),
            color:
                const Color.fromARGB(0xFF, 0xEE, 0xF1, 0xF4).withOpacity(0.3)),
        margin: const EdgeInsets.only(left: 24.0, right: 24.0),
        padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 12.0),
        child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Text(memo, style: TextStyles.memoWidgetTextStyle)));
  }
}

// 기록 상세 화면의 이미지 슬라이더 인덱스
final activeIndexProvider = StateProvider((ref) => 0);

class ImageSlider extends ConsumerWidget {
  const ImageSlider({super.key, required this.images});

  final List<String>? images;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeIndex = ref.watch(activeIndexProvider);

    // 이미지 위젯
    Widget buildImage(path) => Container(
          width: double.infinity,
          height: 240,
          color: Colors.grey,
          child: Image.network(path, fit: BoxFit.cover),
        );

    // 이미지 슬라이더의 인디케이터
    Widget buildIndicator() => Container(
        margin: const EdgeInsets.only(bottom: 20.0),
        alignment: Alignment.bottomCenter,
        child: AnimatedSmoothIndicator(
          activeIndex: activeIndex,
          count: images?.length ?? 1,
          effect: JumpingDotEffect(
              dotHeight: 6,
              dotWidth: 6,
              activeDotColor: Colors.white,
              dotColor: Colors.white.withOpacity(0.6)),
        ));

    return Stack(alignment: Alignment.bottomCenter, children: <Widget>[
      if (images == null || images!.isEmpty) ...[
        SizedBox(
            width: double.infinity,
            height: 240,
            child:
                Image.asset("assets/images/img_loading.png", fit: BoxFit.cover))
      ] else if (images!.length == 1) ...[
        SizedBox(
            width: double.infinity,
            height: 240,
            child: Image.network(images![0], fit: BoxFit.cover))
      ] else ...[
        // 이미지 슬라이더
        CarouselSlider.builder(
          options: CarouselOptions(
              initialPage: 0,
              viewportFraction: 1,
              enlargeCenterPage: true,
              onPageChanged: (index, reason) {
                ref.read(activeIndexProvider.notifier).state = index;
              }),
          itemCount: images?.length,
          itemBuilder: (context, index, realIndex) {
            final path = images![index];
            return buildImage(path);
          },
        )
      ],
      Align(alignment: Alignment.bottomCenter, child: buildIndicator())
    ]);
  }
}

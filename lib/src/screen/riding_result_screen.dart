import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:ridingpartner_flutter/src/provider/image_pick_provider.dart';
import 'package:ridingpartner_flutter/src/screen/bottom_nav.dart';
import 'package:ridingpartner_flutter/src/screen/riding_screen.dart';
import 'package:ridingpartner_flutter/src/utils/timestampToText.dart';

import '../models/record.dart';
import '../style/textstyle.dart';

// 주행기록의 메모 작성 Provider
final memoProvider = StateProvider((ref) => '');

class RidingResultScreen extends ConsumerStatefulWidget {
  const RidingResultScreen({super.key, required this.date});
  final String date;

  @override
  RidingResultScreenState createState() => RidingResultScreenState();
}

class RidingResultScreenState extends ConsumerState<RidingResultScreen> {
  @override
  void initState() {
    super.initState();
    ref.read(recordProvider.notifier).getData(widget.date);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    ref.invalidate(imageProvider);
    ref.invalidate(memoProvider);
    ref.invalidate(recordProvider);
  }

  @override
  Widget build(BuildContext context) {
    final record = ref.watch(recordProvider);

    return GestureDetector(
        onTap: () {
          FocusManager.instance.primaryFocus?.unfocus(); // 키보드 닫기 이벤트
        },
        child: Scaffold(
            appBar: AppBar(
              backgroundColor: const Color.fromARGB(0xFF, 0xEE, 0x75, 0x00),
              elevation: 0.0,
            ),
            resizeToAvoidBottomInset: false,
            body: Container(
                padding: const EdgeInsets.only(
                    left: 34, bottom: 40, top: 10, right: 34),
                decoration: const BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                      Color.fromARGB(0xFF, 0xEE, 0x75, 0x00),
                      Color.fromARGB(0xFF, 0xFF, 0xA0, 0x44)
                    ])),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    const Text(
                      "즐거운 라이딩\n되셨나요?",
                      style: TextStyles.dayRecordtextStyle3,
                    ),
                    if (record != null) ...[
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 15.0),
                        child: recordWidget(record, record.distance / 3 * 3600),
                      ),
                    ] else ...[
                      const Text("데이터가 없습니다.",
                          style: TextStyles.dayRecordtextStyle3)
                    ],
                    const ImageWidget(),
                    const Divider(
                        color: Color.fromARGB(0xFF, 0xF8, 0xF9, 0xFA)),
                    const MemoWidget(),
                    saveDataButton()
                  ],
                ))));
  }

  Widget recordWidget(Record record, num speed) {
    return Row(
      children: [
        SizedBox(
          width: 100.0,
          height: 120.0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text("날짜", style: TextStyles.ridingRecordTextStyle),
              Text("주행 시간", style: TextStyles.ridingRecordTextStyle),
              Text("평균 속도", style: TextStyles.ridingRecordTextStyle),
              Text("주행 총 거리", style: TextStyles.ridingRecordTextStyle),
              Text("소모 칼로리", style: TextStyles.ridingRecordTextStyle)
            ],
          ),
        ),
        SizedBox(
          height: 120.0,
          width: 130.0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text(DateFormat('yyyy년 MM월 dd일').format(DateTime.now()),
                  style: TextStyles.ridingRecordTextStyle),
              Text(timestampToText(record.timestamp, 0),
                  style: TextStyles.ridingRecordTextStyle),
              if (record.timestamp != 0) ...[
                Text(
                    "${(record.distance / record.timestamp).toStringAsFixed(1)} km/h",
                    style: TextStyles.ridingRecordTextStyle)
              ] else ...[
                const Text("0.0 km/h", style: TextStyles.ridingRecordTextStyle)
              ],
              Text("${(record.distance / 1000).toStringAsFixed(2)} km",
                  style: TextStyles.ridingRecordTextStyle),
              if (record.distance == 0) ...[
                const Text(
                  '0 kcal',
                  style: TextStyles.ridingRecordTextStyle,
                )
              ] else ...[
                Text(
                    "${(550 * (record.timestamp) / 3600).toStringAsFixed(1)} kcal",
                    style: TextStyles.ridingRecordTextStyle)
              ]
            ],
          ),
        ),
      ],
    );
  }

  // 데이터 저장 버튼
  Widget saveDataButton() {
    return SizedBox(
      width: double.infinity,
      height: 56.0,
      child: ElevatedButton(
        onPressed: () {
          saveData();

          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const BottomNavigation(),
              ));
        },
        style: ButtonStyle(
          shadowColor: MaterialStateProperty.all<Color>(Colors.transparent),
          padding:
              MaterialStateProperty.all<EdgeInsets>(const EdgeInsets.all(13.0)),
          backgroundColor: MaterialStateProperty.all<Color>(
              const Color.fromARGB(0xFF, 0xF8, 0xF9, 0xFA)),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25.0),
          )),
        ),
        child: const Text(
          "기록 저장하기",
          style: TextStyles.recordSaveBtnTextStyle,
        ),
      ),
    );
  }

  saveData() async {
    final image = ref.read(imageProvider);
    final memo = ref.read(memoProvider);
    final recordData = ref.read(recordProvider);

    ref.read(recordProvider.notifier).saveData(recordData!, image);

    ref.refresh(recordProvider);
    ref.refresh(imageProvider);
    ref.refresh(memoProvider);
  }
}

// 메모입력 위젯
class MemoWidget extends ConsumerStatefulWidget {
  const MemoWidget({super.key});

  @override
  MemoWidgetState createState() => MemoWidgetState();
}

class MemoWidgetState extends ConsumerState<MemoWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 160,
      width: double.infinity,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(17),
          color: const Color.fromRGBO(255, 255, 255, 0.3)),
      child: TextField(
          cursorColor: Colors.white,
          keyboardType: TextInputType.multiline,
          maxLines: 6,
          maxLength: 300,
          style: const TextStyle(
            fontSize: 14.0,
            color: Colors.black,
          ),
          onChanged: (value) {
            ref.read(memoProvider.notifier).state = value;
          },
          decoration: InputDecoration(
            focusedBorder:
                const UnderlineInputBorder(borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.all(16),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(12),
            ),
            focusColor: Colors.transparent,
            hintText: "오늘의 라이딩은 어땠나요?",
            hintStyle: const TextStyle(
              color: Colors.white,
              fontSize: 14.0,
            ),
          )),
    );
  }
}

// 갤러리 이미지 추가 Provider
final imageProvider = StateNotifierProvider.autoDispose<ImageState, List<File>>(
    (ref) => ImageState());

// 갤러리 이미지 추가 위젯
class ImageWidget extends ConsumerStatefulWidget {
  const ImageWidget({super.key});

  @override
  ImageWidgetState createState() => ImageWidgetState();
}

class ImageWidgetState extends ConsumerState<ImageWidget> {
  @override
  Widget build(BuildContext context) {
    final images = ref.watch(imageProvider);
    return images.isEmpty
        ? Row(
            children: [
              Container(
                  width: 64.0,
                  height: 64.0,
                  margin: const EdgeInsets.only(right: 10.0),
                  child: OutlinedButton(
                      onPressed: () {
                        ref.read(imageProvider.notifier).getImage();
                      },
                      style: ButtonStyle(
                        side: MaterialStateProperty.all(const BorderSide(
                          color: Color.fromARGB(0xFF, 0xFD, 0xD3, 0xAB),
                          width: 2.0,
                        )),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Image(
                            image: AssetImage('assets/icons/add_image.png'),
                            color: Color.fromARGB(255, 255, 255, 255),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Text(
                            "사진",
                            style: TextStyle(
                                color: Color.fromARGB(0xFF, 0xDE, 0xE2, 0xE6),
                                fontSize: 12.0),
                          )
                        ],
                      ))),
              const Center(
                  child: Text(
                "이미지를\n선택해주세요.",
                style: TextStyle(
                  fontSize: 13.0,
                  color: Color.fromARGB(0xFF, 0xDE, 0xE2, 0xE6),
                ),
                textAlign: TextAlign.center,
              ))
            ],
          )
        : Row(
            children: images.map((img) {
            return InkWell(
                onTap: () {
                  ref.read(imageProvider.notifier).getImage();
                },
                child: Container(
                    width: 64.0,
                    height: 64.0,
                    margin: const EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                        border: Border.all(
                            color: const Color.fromARGB(0xFF, 0xFD, 0xD3, 0xAB),
                            width: 2.0),
                        borderRadius: BorderRadius.circular(3.5),
                        color: Colors.transparent),
                    child: Center(
                        child: Image.file(
                      img,
                      width: 64,
                      height: 64,
                      fit: BoxFit.cover,
                    ))));
          }).toList());
  }
}

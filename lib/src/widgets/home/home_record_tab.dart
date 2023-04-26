import 'dart:core';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:line_chart/model/line-chart.model.dart';

import '../../models/record.dart';
import '../../screen/record_list_screen.dart';
import '../../service/firebase_database_service.dart';
import '../../style/palette.dart';
import '../../style/textstyle.dart';
import '../../utils/get_14days_record.dart';
import '../../utils/timestamp_to_text.dart';

class Data {
  String key;
  String data;
  String icon;

  Data(this.key, this.data, this.icon);
}

final homeRecordProvider = FutureProvider((ref) async {
  List<Record> record = await FirebaseDatabaseService().getAllRecords();
  return Get14DaysRecordService().get14daysRecord(record);
});

final recordStateProvider = StateProvider<RecordState>((ref) {
  final record = ref.watch(homeRecordProvider);
  return record.when(
      data: (data) => Get14DaysRecordService().get14daysRecordState(data),
      loading: () => RecordState.loading,
      error: (e, s) => RecordState.fail);
});
final tabIndexProvider = StateProvider((ref) => 0);

class RecordTabRow extends ConsumerStatefulWidget {
  const RecordTabRow({super.key});

  @override
  RecordTabRowState createState() => RecordTabRowState();
}

class RecordTabRowState extends ConsumerState<RecordTabRow>
    with TickerProviderStateMixin {
  late TabController _tabController;
  int state = 0;
  late List<String> tab;

  List<LineChartModel> data = [];

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 14, vsync: this, initialIndex: 13);

    tab = Get14DaysRecordService().setDate(14);
  }

  @override
  void dispose() {
    ref.invalidate(homeRecordProvider);
    ref.invalidate(tabIndexProvider);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final record = ref.watch(homeRecordProvider);
    final recordState = ref.watch(recordStateProvider);

    switch (recordState) {
      case RecordState.loading:
        return const SizedBox(
            height: 200,
            child: Center(
              child: Text(
                "라이더님의 주행 기록을 불러오는 중입니다",
                style: TextStyles.recordDescriptionTextStyle,
                textAlign: TextAlign.center,
              ),
            ));
      case RecordState.none:
        return const SizedBox(
            height: 200,
            child: Center(
              child: Text(
                "아직 주행한 기록이 없습니다\n라이딩 파트너와 함께 달려보세요!",
                style: TextStyles.recordDescriptionTextStyle,
                textAlign: TextAlign.center,
              ),
            ));
      case RecordState.empty:
        return const SizedBox(
            height: 200,
            child: Center(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "최근 2주간 라이딩한 기록이 없습니다\n라이딩 파트너와 함께 달려보세요!",
                  style: TextStyles.recordDescriptionTextStyle,
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: 5,
                ),
                Text(
                  '기록 전체보기',
                  style: TextStyles.recordDescriptionTextStyle,
                ),
              ],
            )));
      case RecordState.fail:
        return const SizedBox(
            height: 100,
            child: Center(
              child: Text("기록 조회에 실패했습니다\n네트워크 상태를 체크해주세요!",
                  style: TextStyles.recordDescriptionTextStyle,
                  textAlign: TextAlign.center),
            ));
      case RecordState.success:
        return record.when(
            data: (data) => recordTab(data),
            loading: () => const SizedBox(
                height: 100,
                child: Center(
                  child: CircularProgressIndicator(color: Palette.appColor),
                )),
            error: (e, s) => const SizedBox());

      default:
        return const SizedBox(
            height: 100,
            child: Center(
              child: CircularProgressIndicator(color: Palette.appColor),
            ));
    }
  }

  Widget recordTab(List<Record> records) {
    final tabIndex = ref.watch(tabIndexProvider);
    return Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
      TabBar(
          padding: const EdgeInsets.fromLTRB(0, 20, 0, 15),
          onTap: (value) {
            ref.read(tabIndexProvider.notifier).state = value;

            _tabController.animateTo(value);
          },
          controller: _tabController,
          isScrollable: true,
          tabs: tab.map((e) {
            if (tab.indexOf(e) == tabIndex) {
              return Tab(text: e);
            } else {
              return Tab(text: e.substring(0, 2));
            }
          }).toList(),
          unselectedLabelColor: Colors.black54,
          labelColor: Colors.white,
          labelStyle: TextStyles.recordTabLabelTextStyle,
          indicator: BoxDecoration(
            boxShadow: const [
              BoxShadow(
                color: Color.fromRGBO(0, 0, 0, 0.1),
                spreadRadius: 2,
                blurRadius: 3,
                offset: Offset(1, 1), // changes position of shadow
              )
            ],
            borderRadius: BorderRadius.circular(65.0),
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color.fromARGB(0xFF, 0xEE, 0x75, 0x00),
                Color.fromARGB(0xFF, 0xFF, 0xA0, 0x44),
              ],
            ),
          )),
      SizedBox(
          height: 220,
          width: MediaQuery.of(context).size.width,
          child: TabBarView(
              controller: _tabController,
              children: records.map((e) => recordDetailView(e)).toList())),
      InkWell(
        onTap: () => Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => const RecordListScreen(),
        )),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text('기록 전체보기', style: TextStyles.settingStyle),
              SizedBox(
                width: 5,
              ),
              Icon(
                Icons.add_chart_rounded,
                color: Color.fromARGB(185, 51, 57, 62),
                size: 17,
              ),
            ],
          ),
        ),
      ),
    ]);
  }

  Widget recordDetailView(Record record) {
    if (record.date == '') {
      return Container(
        padding: const EdgeInsets.all(20),
        height: 50,
        alignment: Alignment.center,
        child: const Text('라이딩한 기록이 없습니다'),
      );
    } else {
      Data distance = Data(
          '거리',
          '${(record.distance / 1000).toStringAsFixed(1)}km',
          'assets/icons/home_distance.png');
      Data time = Data('시간', timestampToText(record.timestamp, 0),
          'assets/icons/home_time.png');

      Data speed;
      try {
        speed = Data(
            '평균 속도',
            '${(record.distance / record.timestamp * 3.6).toStringAsFixed(1)}km/h',
            'assets/icons/home_speed.png');
        if (speed.data == 'NaNkm/h') {
          speed = Data('평균 속도', '0km/h', 'assets/icons/home_speed.png');
        }
      } catch (e) {
        speed = Data('평균 속도', '0km/h', 'assets/icons/home_speed.png');
      }
      Data speedMax = Data(
          '소모 칼로리', '${record.kcal} kcal', 'assets/icons/home_max_speed.png');

      return Container(
          height: 200,
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
          width: MediaQuery.of(context).size.width,
          child: Row(
            children: [
              Flexible(
                  flex: 1,
                  child: Column(
                    children: [
                      recordCard(distance),
                      const SizedBox(
                        height: 8,
                      ),
                      recordCard(speed)
                    ],
                  )),
              const SizedBox(
                width: 8,
              ),
              Flexible(
                  flex: 1,
                  child: Column(
                    children: [
                      recordCard(time),
                      const SizedBox(
                        height: 8,
                      ),
                      recordCard(speedMax)
                    ],
                  ))
            ],
          ));
    }
  }

  Widget recordCard(Data data) {
    return Flexible(
        flex: 1,
        child: Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Color.fromRGBO(0, 41, 135, 0.047),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(1, 1), // changes position of shadow
                  )
                ],
                borderRadius: BorderRadius.all(Radius.circular(12))),
            child: Stack(
              children: [
                Positioned(
                    left: 0,
                    top: 0,
                    child: Row(
                      children: [
                        Image.asset(data.icon,
                            width: 15, height: 15, fit: BoxFit.cover),
                        Text(
                          "  ${data.key}",
                          style: TextStyles.recordCardTitleTextStyle,
                        )
                      ],
                    )),
                Positioned(
                    bottom: 0,
                    left: 0,
                    child: Text(
                      data.data,
                      style: TextStyles.recordCardDataTextStyle,
                      textAlign: TextAlign.start,
                    ))
              ],
            )));
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:ridingpartner_flutter/src/models/record.dart';
import '../service/firebase_database_service.dart';
import '../style/textstyle.dart';
import '../widgets/appbar.dart';
import 'record_screen.dart';

// 저장된 주행 기록을 불러오는 Provider
final recordListProvider = FutureProvider<List<Record>>((ref) async {
  List<Record> record = await FirebaseDatabaseService().getAllRecords();
  record.sort((a, b) {
    return DateTime.parse(a.date).compareTo(DateTime.parse(b.date));
  });
  return record.reversed.toList();
});

class RecordListScreen extends ConsumerStatefulWidget {
  const RecordListScreen({super.key});

  @override
  RecordListScreenState createState() => RecordListScreenState();
}

class RecordListScreenState extends ConsumerState<RecordListScreen> {
  @override
  Widget build(BuildContext context) {
    initializeDateFormatting('ko_KR', null);
    // 주행 기록 리스트
    final recordList = ref.watch(recordListProvider);

    return recordList.when(
        data: (data) {
          if (data.isEmpty) {
            return Scaffold(
                appBar: appBar(context),
                backgroundColor: Colors.white,
                body: const Center(child: Text('기록이 없습니다.')));
          } else {
            return Scaffold(
                appBar: appBar(context),
                backgroundColor: Colors.white,
                body: SizedBox(
                    child: ListView.builder(
                        shrinkWrap: true,
                        scrollDirection: Axis.vertical,
                        itemCount: data.length,
                        itemBuilder: (context, index) {
                          return Column(
                            children: [
                              recordItem(data.elementAt(index)),
                              Container(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 15),
                                child: const Divider(
                                    height: 1,
                                    color: Color.fromARGB(128, 193, 193, 193),
                                    thickness: 0.8),
                              )
                            ],
                          );
                        })));
          }
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => const Center(child: Text('데이터를 불러올 수 없습니다.')));
  }

  // 주행 기록 리스트의 아이템
  Widget recordItem(Record record) {
    return InkWell(
        onTap: () => {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => RecordScreen(date: record.date)))
            },
        child: Container(
            padding:
                const EdgeInsets.only(top: 15, bottom: 10, left: 15, right: 13),
            width: double.infinity,
            child: Stack(
              alignment: Alignment.topLeft,
              children: [
                Container(
                  width: double.infinity,
                  alignment: Alignment.topLeft,
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Text(
                        DateFormat('yyyy.MM.dd')
                            .format(DateTime.parse(record.date)),
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color.fromARGB(241, 120, 120, 120),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                    alignment: Alignment.centerRight,
                    width: double.infinity,
                    margin: const EdgeInsets.only(right: 10, top: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${record.distance / 1000}km',
                          style: TextStyles.detailStyle,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        const Text(
                          '기록 자세히 보기 ->',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color.fromARGB(226, 155, 155, 155),
                          ),
                        )
                      ],
                    ))
              ],
            )));
  }
}

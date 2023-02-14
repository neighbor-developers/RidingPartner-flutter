import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:ridingpartner_flutter/src/models/record.dart';
import 'package:ridingpartner_flutter/src/provider/record_list_provider.dart';

import '../provider/riding_result_provider.dart';
import '../widgets/appbar.dart';
import 'day_record_page.dart';

class RecordListPage extends StatefulWidget {
  const RecordListPage({super.key});

  @override
  State<RecordListPage> createState() => _RecordListPageState();
}

class _RecordListPageState extends State<RecordListPage> {
  @override
  void initState() {
    super.initState();
    Provider.of<RecordListProvider>(context, listen: false).getRecord();
  }

  late RecordListProvider _recordListProvider;
  String message = "";

  TextStyle detailStyle = const TextStyle(
    fontFamily: 'Pretendard',
    fontSize: 18,
    fontWeight: FontWeight.w400,
    color: Color.fromARGB(224, 38, 38, 38),
  );

  @override
  Widget build(BuildContext context) {
    _recordListProvider = Provider.of<RecordListProvider>(context);
    initializeDateFormatting('ko_KR', null);

    return Scaffold(
        appBar: appBar(context),
        backgroundColor: Colors.white,
        body: SizedBox(
            //height: double.infinity,
            //width: double.infinity,
            child: ListView.builder(
                shrinkWrap: true,
                scrollDirection: Axis.vertical,
                itemCount: _recordListProvider.records.length,
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      recordItem(_recordListProvider.records.elementAt(index)),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 15),
                        child: const Divider(
                            height: 1,
                            color: Color.fromARGB(128, 193, 193, 193),
                            thickness: 0.8),
                      )
                    ],
                  );
                })));
  }

  Widget recordItem(Record record) {
    return InkWell(
        onTap: () => {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ChangeNotifierProvider(
                            create: (context) =>
                                RidingResultProvider(record.date),
                            child: DayRecordPage(),
                          )))
            },
        child: Container(
            padding:
                const EdgeInsets.only(top: 15, bottom: 10, left: 15, right: 13),
            // // color: Color.fromARGB(167, 251, 150, 50),
            // height: MediaQuery.of(context).size.height / 8,
            width: double.infinity,
            child: Stack(
              alignment: Alignment.topLeft,
              children: [
                // Image.asset(
                //   'assets/images/white_back.png',
                //   fit: BoxFit.fitWidth,
                //   width: double.infinity,
                // ),
                Container(
                  width: double.infinity,
                  alignment: Alignment.topLeft,
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Text(
                        DateFormat('yyyy.MM.dd')
                            .format(DateTime.parse(record.date)),
                        style: TextStyle(
                          fontSize: 14,
                          color: Color.fromARGB(241, 120, 120, 120),
                        ),
                      ),
                      // Container(
                      //   width: 70,
                      //   height: 70,
                      //   margin: EdgeInsets.only(top: 10),
                      //   decoration: BoxDecoration(
                      //       // borderRadius: BorderRadius.circular(10),
                      //       image: DecorationImage(
                      //     image: AssetImage(
                      //       'assets/images/img_loading.png',
                      //     ),
                      //     fit: BoxFit.cover,
                      //   )),
                      // ),
                    ],
                  ),
                ),

                // Container(
                //   child:
                //   alignment: Alignment.bottomRight,
                // ),
                Container(
                    alignment: Alignment.centerRight,
                    width: double.infinity,
                    margin: EdgeInsets.only(right: 10, top: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${record.distance / 1000}km',
                          style: detailStyle,
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          '기록 자세히 보기 ->',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color.fromARGB(226, 155, 155, 155),
                          ),
                        )
                      ],
                    ))
                // Text(
                //     DateFormat('yyyy년 MM월 dd일')
                //         .format(DateTime.parse(record.date)),
                //     style: const TextStyle(
                //       color: Color.fromARGB(223, 0, 0, 0),
                //       fontFamily: 'Pretendard',
                //       fontSize: 14,
                //       fontWeight: FontWeight.w400,
                // //     )),
                // Text(
                //   timestampToText(record.timestamp),
                //   style: detailStyle,
                // ),

                // ),
                // Container(
                //   // margin:
                //   //     const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                //   width: double.infinity,
                //   alignment: Alignment.topLeft,
                //   child: Text(
                //       DateFormat('yyyy.MM.dd')
                //           .format(DateTime.parse(record.date)),
                //       style: const TextStyle(
                //         color: Color.fromARGB(188, 21, 21, 21),
                //         fontFamily: 'Pretendard',
                //         fontSize: 19,
                //         fontWeight: FontWeight.w800,
                //       )),
                // ),
              ],
            )));
  }
}

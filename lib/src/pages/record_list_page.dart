import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:ridingpartner_flutter/src/models/record.dart';
import 'package:ridingpartner_flutter/src/provider/home_record_provider.dart';
import 'package:ridingpartner_flutter/src/provider/record_list_provider.dart';

import '../utils/timestampToText.dart';

class RecordListPage extends StatefulWidget {
  const RecordListPage({super.key});

  @override
  State<RecordListPage> createState() => _RecordListPageState();
}

class _RecordListPageState extends State<RecordListPage> {
  late RecordListProvider _recordListProvider;
  String message = "";

  TextStyle detailStyle = const TextStyle(
    fontFamily: 'Pretendard',
    fontSize: 15,
    fontWeight: FontWeight.bold,
    color: Colors.grey,
  );

  @override
  Widget build(BuildContext context) {
    _recordListProvider = Provider.of<RecordListProvider>(context);
    initializeDateFormatting('ko_KR', null);

    if (_recordListProvider.recordState == RecordState.loading) {
      _recordListProvider.getRecord();
    } else if (_recordListProvider.recordState == RecordState.none) {
      message = "기록이 존재하지 않습니다.";
    } else {
      message = "로딩에 실패하였습니다. 다시 접속해주세요.";
    }

    return Scaffold(
        appBar: AppBar(
          shadowColor: const Color.fromRGBO(255, 255, 255, 0.5),
          backgroundColor: Colors.white,
          title: Container(
              padding: const EdgeInsets.fromLTRB(0, 0, 50, 0),
              width: MediaQuery.of(context).size.width,
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
            color: const Color.fromRGBO(240, 120, 5, 1),
          ),
          elevation: 10,
        ),
        body: SizedBox(
            height: double.infinity,
            width: double.infinity,
            child: ListView.builder(
                shrinkWrap: true,
                scrollDirection: Axis.vertical,
                itemCount: _recordListProvider.records.length,
                itemBuilder: (context, index) =>
                    recordItem(_recordListProvider.records.elementAt(index)))));
  }

  Widget recordItem(Record? record) {
    return record == null
        ? SizedBox(
            child: Text(message,
                style: const TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 16,
                    fontWeight: FontWeight.w400)))
        : InkWell(
            onTap: () => {
                  // Navigator.push(
                  //     context,
                  //     MaterialPageRoute(
                  //         builder: (context) => ChangeNotifierProvider(
                  //               create: (context) =>
                  //                   RidingResultProvider(record.date!),
                  //               child: RecordPage(),
                  //             )))
                },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(13),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20.0),
                      child: Image.asset(
                        'assets/images/img_loading.png',
                        fit: BoxFit.fill,
                        width: 70,
                        height: 70,
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(children: [
                        Text(
                            DateFormat('yyyy년 MM월 dd일')
                                .format(DateTime.parse(record.date!)),
                            style: const TextStyle(
                              fontFamily: 'Pretendard',
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            )),
                        const SizedBox(width: 15),
                        Text(
                          DateFormat('EEEEE', "ko_KR")
                              .format(DateTime.parse(record.date!)),
                          style: detailStyle,
                        ),
                      ]),
                      Text(
                        timestampToText(record.timestamp!),
                        style: detailStyle,
                      ),
                      Text(
                        "${record.distance.toString()}km",
                        style: detailStyle,
                      )
                    ],
                  ),
                  const Divider(color: Colors.black)
                ],
              ),
            ));
  }
}

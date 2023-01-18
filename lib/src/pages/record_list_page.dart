import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:ridingpartner_flutter/src/models/record.dart';
import 'package:ridingpartner_flutter/src/pages/record_page.dart';
import 'package:ridingpartner_flutter/src/provider/home_record_provider.dart';
import 'package:ridingpartner_flutter/src/provider/record_list_provider.dart';

import '../provider/riding_result_provider.dart';
import '../utils/timestampToText.dart';
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
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: Color.fromRGBO(102, 102, 102, 1),
  );

  @override
  Widget build(BuildContext context) {
    _recordListProvider = Provider.of<RecordListProvider>(context);
    initializeDateFormatting('ko_KR', null);

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
            //height: double.infinity,
            //width: double.infinity,
            child: ListView.builder(
                shrinkWrap: true,
                scrollDirection: Axis.vertical,
                itemCount: _recordListProvider.records.length,
                itemBuilder: (context, index) =>
                    recordItem(_recordListProvider.records.elementAt(index)))));
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
        child: Card(
            color: const Color.fromRGBO(248, 248, 248, 1),
            margin: const EdgeInsets.fromLTRB(10, 5, 10, 5),
            child: Container(
                height: MediaQuery.of(context).size.height / 9,
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween, //spaceAround
                    children: [
                      Container(
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10.0),
                          child: Image.asset(
                            'assets/images/img_loading.png',
                            fit: BoxFit.cover,
                            width: 100,
                            height: 70,
                          ),
                        ),
                      ),
                      //const SizedBox(width: 15),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Row(children: [
                            Text(
                                DateFormat('yyyy년 MM월 dd일')
                                    .format(DateTime.parse(record.date)),
                                style: const TextStyle(
                                  color: Color.fromRGBO(50, 50, 50, 0.9),
                                  fontFamily: 'Pretendard',
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                )),
                            const SizedBox(width: 15),
                            Text(
                              DateFormat('EEEEE', "ko_KR")
                                  .format(DateTime.parse(record.date)),
                              style: detailStyle,
                            ),
                            const SizedBox(width: 40),
                          ]),
                          Text(
                            timestampToText(record.timestamp),
                            style: detailStyle,
                          ),
                          Text(
                            "${record.distance.toString()}km",
                            style: detailStyle,
                          )
                        ],
                      ),
                      //const Divider(color: Colors.black)
                    ],
                  ),
                ))));
  }
}

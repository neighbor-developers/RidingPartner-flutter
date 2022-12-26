import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

class RecordListPage extends StatefulWidget {
  const RecordListPage({super.key});

  @override
  State<RecordListPage> createState() => _RecordListPageState();
}

class _RecordListPageState extends State<RecordListPage> {
  // late RecordListProvider _recordListProvider;
  TextStyle detailStyle = const TextStyle(
    fontFamily: 'Pretendard',
    fontSize: 15,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // _settingProvider = Provider.of<SettingProvider>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('설정'),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back),
          color: Colors.indigo.shade900,
        ),
      ),
      body: Column(
        children: [
          mainStatement(),
          recordInformtion(),
        ],
      ),
    );
  }

  Widget mainStatement() {
    return Container(
        padding: EdgeInsets.only(left: 10),
        color: Colors.deepOrangeAccent,
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height / 8,
        alignment: Alignment.centerLeft,
        child: const Text(
          '즐거운 라이딩 되셨나요?',
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 40,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ));
  }

  Widget recordInformtion() {
    return Container(
      padding: EdgeInsets.only(left: 10),
      color: Colors.deepOrangeAccent,
      width: MediaQuery.of(context).size.width,
      height: (MediaQuery.of(context).size.height / 8) * 6,
      alignment: Alignment.center,
      child: Column(
        children: [
          informationDetail("날짜", "2022년 12월 6일"),
          informationDetail("주행시간", "시간"),
          informationDetail("평균속도", "속도"),
          informationDetail("주행총거리", "거리"),
          informationDetail("소모칼로리", "칼로리"),
          SizedBox(
            height: 20,
          ),
          memoInput(),
          saveButton(),
        ],
      ),
    );
  }

  Widget memoInput() {
    return Container(
      padding: EdgeInsets.only(left: 10),
      color: Colors.deepOrangeAccent,
      width: MediaQuery.of(context).size.width,
      height: (MediaQuery.of(context).size.height / 8) * 2,
      alignment: Alignment.center,
      child: TextField(
        maxLines: 10,
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          hintText: '메모를 입력해주세요',
        ),
      ),
    );
  }

  Widget saveButton() {
    return Container(
      padding: EdgeInsets.only(left: 10),
      color: Colors.deepOrangeAccent,
      width: MediaQuery.of(context).size.width,
      height: (MediaQuery.of(context).size.height / 10) * 1,
      alignment: Alignment.center,
      child: ElevatedButton(
        onPressed: () {},
        child: const Text('기록 저장하기'),
      ),
    );
  }

  Widget informationDetail(title, content) {
    return Row(
      children: [
        Container(
          height: (MediaQuery.of(context).size.height / 30) * 1,
          width: MediaQuery.of(context).size.width / 4,
          child: Text(
            title,
            style: detailStyle,
          ),
        ),
        Container(
          height: (MediaQuery.of(context).size.height / 30) * 1,
          width: MediaQuery.of(context).size.width / 2,
          child: Text(
            content,
            style: detailStyle,
          ),
        )
      ],
    );
  }
}

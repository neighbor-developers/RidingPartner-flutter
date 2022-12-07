import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ridingpartner_flutter/src/models/record.dart';
import 'package:ridingpartner_flutter/src/pages/home_page.dart';
import 'package:ridingpartner_flutter/src/service/firebase_database_service.dart';

import '../service/shared_preference.dart';

enum RecordState { loading, fail, empty, success }

class HomeRecordProvider extends ChangeNotifier {
  final FirebaseDatabaseService _firebaseDatabaseService =
      FirebaseDatabaseService();
  List<String> _daysFor14 = [];
  List<Record> _recordFor14Days = [];
  int _selectedIndex = numberOfRecentRecords - 1;
  Record? _prefRecord;

  List<Record> get recordFor14Days => _recordFor14Days;
  List<String> get daysFor14 => _daysFor14;
  int get selectedIndex => _selectedIndex;

  RecordState _recordState = RecordState.loading;
  RecordState get recordState => _recordState;

  void setIndex(int index) {
    _selectedIndex = index;
    notifyListeners();
  }

  Future getRecord() async {
    setList();
    setDate();
    List<Record>? records = await _firebaseDatabaseService.getAllRecords();
    _prefRecord = PreferenceUtils.getRecordFromPref();

    if (records == null) {
      // 가져오기 실패
      _recordState = RecordState.fail;
    } else if (records.isEmpty) {
      // 기록 없음
      _recordState = RecordState.empty;
    } else {
      // 성공, 기록 있음
      _recordState = RecordState.success;
      if (_prefRecord != records.last && _prefRecord != null) {
        // 마지막 기록과 다르면 다시 저장 (ex. 네트워크 문제)
        saveRecord(_prefRecord!);
        records.add(_prefRecord!);
      }
      get14daysRecord(records);

      notifyListeners();
    }

    notifyListeners();
  }

  void setList() {
    for (int i = 0; i < numberOfRecentRecords; i++) {
      recordFor14Days.add(Record());
    }
  }

  void setDate() {
    DateTime today = DateTime.now();
    for (int i = 0; i < numberOfRecentRecords; i++) {
      DateTime currentDay = today.subtract(Duration(days: i));
      String day = dayToDayString(currentDay.day);
      String weekday = weekdayIntToString(currentDay.weekday);
      if (i == 0) {
        _daysFor14.add("오늘, $day $weekday");
      } else {
        _daysFor14.add("$day $weekday");
      }
    }
    _daysFor14 = _daysFor14.reversed.toList();
  }

  void get14daysRecord(List<Record> records) {
    DateTime today = DateTime.now();

    for (var element in records) {
      int days = int.parse(
          today.difference(DateTime.parse(element.date!)).inDays.toString());
      if (days < numberOfRecentRecords) {
        // 14일 이내이면 그 자리에 넣기
        _recordFor14Days[days] = element;
        // 30, 31, 1, 2, 3 ~ 으로 흐를 경우 날짜 순서를 구분하기 위해 map과 리스트 동시 사용
        // 순서는 리스트로, 기록은 Map으로
      }
    }
    _recordFor14Days = _recordFor14Days.reversed.toList();
  }

  String dayToDayString(int day) {
    if (day < 10) {
      return "0$day";
    }
    return day.toString();
  }

  String weekdayIntToString(int code) {
    switch (code) {
      case 1:
        return "월";
      case 2:
        return "화";
      case 3:
        return "수";
      case 4:
        return "목";
      case 5:
        return "금";
      case 6:
        return "토";
      case 7:
        return "일";
      default:
        return "";
    }
  }

  void saveRecord(Record record) {
    _firebaseDatabaseService.saveRecordFirebaseDb(record);
  }
}

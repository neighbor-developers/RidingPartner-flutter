import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ridingpartner_flutter/src/models/record.dart';
import 'package:ridingpartner_flutter/src/service/firebase_database_service.dart';
import 'package:ridingpartner_flutter/src/service/firestore_service.dart';

import '../models/place.dart';

enum RecordState { loading, fail, none, success, empty }

class HomeRecordProvider extends ChangeNotifier {
  final FirebaseDatabaseService _firebaseDatabaseService =
      FirebaseDatabaseService();
  final FireStoreService _fireStoreService = FireStoreService();
  final _random = Random();

  final String _auth = FirebaseAuth.instance.currentUser!.displayName == null
      ? 'User'
      : FirebaseAuth.instance.currentUser!.displayName!;
  int _selectedIndex = 13;
  List<String> _daysFor14 = [];
  List<Record> _recordFor14Days = [];
  final int _recordLength = 14;
  Record? _prefRecord;
  int _count = 0;
  Place? _recommendPlace;
  Place? _recommendPlace2;

  List<Record> get recordFor14Days => _recordFor14Days;
  List<String> get daysFor14 => _daysFor14;
  int get selectedIndex => _selectedIndex;
  String get name => _auth;
  Place? get recommendPlace => _recommendPlace;
  Place? get recommendPlace2 => _recommendPlace2;

  RecordState _recordState = RecordState.loading;
  RecordState get recordState => _recordState;

  void setIndex(int index) {
    _selectedIndex = index;
    notifyListeners();
  }

  getData() {
    getRecomendPlace();
    getRecord();
  }

  getRecomendPlace() async {
    List<Place> places = await _fireStoreService.getPlaces();
    _recommendPlace = places[_random.nextInt(places.length)];
    _recommendPlace2 = places[_random.nextInt(places.length)];

    while (_recommendPlace == _recommendPlace2) {
      _recommendPlace2 = places[_random.nextInt(places.length)];
    }
  }

  Future getRecord() async {
    setList();
    setDate();

    Map<String, dynamic> result =
        await _firebaseDatabaseService.getAllRecords();
    _recordState = result['state'];

    if (_recordState == RecordState.success) {
      List<Record> data = result['data'];
      if (_prefRecord != data.last && _prefRecord != null) {
        // 마지막 기록과 다르면 다시 저장 (ex. 네트워크 문제)
        saveRecord(_prefRecord!);
        data.add(_prefRecord!);
      }
      get14daysRecord(data);

      notifyListeners();
    }

    notifyListeners();
  }

  void setList() {
    _recordFor14Days = [];
    for (int i = 0; i < 14; i++) {
      _recordFor14Days
          .add(Record(distance: 0.0, date: '', timestamp: 0, topSpeed: 0.0));
    }
  }

  void setDate() {
    _daysFor14 = [];
    DateTime today = DateTime.now();
    for (int i = 0; i < _recordLength; i++) {
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
          today.difference(DateTime.parse(element.date)).inDays.toString());
      if (days < _recordLength) {
        _count++;
        // 14일 이내이면 그 자리에 넣기
        _recordFor14Days[days] = element;
        // 30, 31, 1, 2, 3 ~ 으로 흐를 경우 날짜 순서를 구분하기 위해 map과 리스트 동시 사용
        // 순서는 리스트로, 기록은 Map으로
      }
      if (_count == 0) {
        _recordState = RecordState.empty;
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

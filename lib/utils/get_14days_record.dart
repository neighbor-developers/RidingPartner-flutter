import 'dart:core';

import '../models/record.dart';

enum RecordState { loading, fail, none, success, empty }

class Get14DaysRecordService {
  List<String> setDate(int recordLength) {
    List<String> daysFor14 = [];
    DateTime today = DateTime.now();
    for (int i = 0; i < recordLength; i++) {
      DateTime currentDay = today.subtract(Duration(days: i));
      String day = dayToDayString(currentDay.day);
      String weekday = weekdayIntToString(currentDay.weekday);
      if (i == 0) {
        daysFor14.add("오늘, $day $weekday");
      } else {
        daysFor14.add("$day $weekday");
      }
    }
    return daysFor14.reversed.toList();
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

  List<Record> get14daysRecord(List<Record> records) {
    List<Record> recordFor14Days = [];
    for (int i = 0; i < 14; i++) {
      recordFor14Days.add(Record(
        distance: 0.0,
        date: '',
        timestamp: 0,
      ));
    }
    DateTime today = DateTime.now();

    for (var element in records) {
      int days = int.parse(
          today.difference(DateTime.parse(element.date)).inDays.toString());
      if (days < 14) {
        // 14일 이내이면 그 자리에 넣기
        if (days == 0) {
          if (DateTime.parse(element.date).day != today.day) {
            days = 1;
          }
        }
        if (recordFor14Days[days] !=
            Record(
              distance: 0.0,
              date: '',
              timestamp: 0,
            )) {
          if (recordFor14Days[days].distance < element.distance) {
            recordFor14Days[days] = element;
          }
        } else {
          recordFor14Days[days] = element;
        }
        // 30, 31, 1, 2, 3 ~ 으로 흐를 경우 날짜 순서를 구분하기 위해 map과 리스트 동시 사용
        // 순서는 리스트로, 기록은 Map으로
      }
    }
    return recordFor14Days.reversed.toList();
  }

  RecordState get14daysRecordState(List<Record> records) {
    int count = 0;

    for (var element in records) {
      if (element !=
          Record(
              date: '',
              distance: 0.0,
              timestamp: 0,
              memo: '',
              images: null,
              kcal: 0)) {
        count++;
      }
    }
    if (count == 0) return RecordState.empty;
    return RecordState.success;
  }
}

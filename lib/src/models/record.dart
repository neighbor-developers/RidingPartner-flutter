import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum RidingState { before, riding, pause, stop, error }

class Record {
  double distance;
  int timestamp;
  String date;
  String? memo;
  double? kcal;
  List<String>? images;

  Record(
      {required this.distance,
      required this.date,
      required this.timestamp,
      this.memo,
      this.kcal,
      this.images});

  factory Record.fromDB(db) => Record(
        distance: db["distance"].toDouble(),
        timestamp: db["timestamp"],
        date: db["date"],
        memo: db["memo"],
        kcal: db["kcal"].toDouble(),
        images: db?['images'] != null
            ? List<String>.from(json.decode(db?['images']))
            : null,
      );

  DateTime getYearMonthDay() {
    return DateFormat('yyyy-MM-dd HH:mm:ss').parse(date);
  }

  static saveRecordPref(Record record) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString("date", record.date);
    prefs.setDouble("distance", record.distance.toDouble());
    prefs.setInt("timeStamp", record.timestamp.toInt());
  }

  static saveRecordMemoPref(Record record) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString("memo", record.memo!);
  }

  Future<Record?> getRecordFromPref() async {
    final prefs = await SharedPreferences.getInstance();
    double? distance = prefs.getDouble("distance");
    String? date = prefs.getString("date");
    int? time = prefs.getInt("timeStamp");
    String? memo = prefs.getString("memo");

    if (distance == null) {
      return null;
    } else {
      return Record(
          distance: distance, date: date!, timestamp: time!, memo: memo);
    }
  }
}

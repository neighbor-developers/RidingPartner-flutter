import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Record {
  double distance;
  int timestamp;
  String date;
  double topSpeed;
  String? memo;
  double? kcal;
  List<String>? images;

  Record(
      {required this.distance,
      required this.date,
      required this.timestamp,
      required this.topSpeed,
      this.memo,
      this.kcal,
      this.images});

  factory Record.fromDB(db) => Record(
        distance: db["distance"].toDouble(),
        timestamp: db["timestamp"],
        date: db["date"],
        topSpeed: db["topSpeed"].toDouble(),
        memo: db["memo"],
        kcal: db["kcal"],
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
    prefs.setDouble('topSpeed', record.topSpeed);
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
    double? topSpeed = prefs.getDouble('topSpeed');
    String? memo = prefs.getString("memo");

    if (distance == null) {
      return null;
    } else {
      return Record(
          distance: distance,
          date: date!,
          timestamp: time!,
          topSpeed: topSpeed!,
          memo: memo);
    }
  }
}

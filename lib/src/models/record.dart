import 'dart:convert';

import 'package:intl/intl.dart';

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
}

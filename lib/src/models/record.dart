import 'package:intl/intl.dart';

class Record {
  double distance;
  int timestamp;
  String date;
  double topSpeed;
  String? memo;
  double? kcal;

  Record(
      {required this.distance,
      required this.date,
      required this.timestamp,
      required this.topSpeed,
      this.memo,
      this.kcal});

  factory Record.fromDB(db) => Record(
        distance: db["distance"].toDouble(),
        timestamp: db["timestamp"],
        date: db["date"],
        topSpeed: db["topSpeed"].toDouble(),
        memo: db["memo"],
        kcal: db["kcal"],
      );

  DateTime getYearMonthDay() {
    return DateFormat('yyyy-MM-dd HH:mm:ss').parse(date);
  }
}

class Record {
  double? distance;
  int? timestamp;
  String? date;
  double? topSpeed;

  Record({this.distance, this.date, this.timestamp, this.topSpeed});

  factory Record.fromDB(db) => Record(
        distance: db["distance"].toDouble(),
        timestamp: db["timestamp"],
        date: db["date"],
        topSpeed: db["topSpeed"].toDouble(),
      );

  List<String> getYearMonthDay() {
    List<String> dateList = date!.split('-');
    return dateList;
  }
}

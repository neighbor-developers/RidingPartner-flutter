class Record {
  double? distance;
  int? timestamp;
  String? date;
  double? topSpeed;
  String? memo;
  double? kcal;

  Record(
      {this.distance,
      this.date,
      this.timestamp,
      this.topSpeed,
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

  List<String> getYearMonthDay() {
    List<String> dateList = date!.split('-');
    dateList.last = dateList.last.substring(0, 2);
    return dateList;
  }
}

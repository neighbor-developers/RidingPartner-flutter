class Record {
  double? distance;
  int? timestamp;
  String? date;
  double? topSpeed;
  String? memo;

  Record({this.distance, this.date, this.timestamp, this.topSpeed, this.memo});

  factory Record.fromDB(db) => Record(
        distance: db["distance"].toDouble(),
        timestamp: db["timestamp"],
        date: db["date"],
        topSpeed: db["topSpeed"].toDouble(),
        memo: db["memo"],
      );
}

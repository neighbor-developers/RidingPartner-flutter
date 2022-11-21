class Record {
  double? distance;
  int? timestamp;
  String? date;
  double? topSpeed;

  Record({this.distance, this.date, this.timestamp, this.topSpeed});

  factory Record.fromDB(db) => Record(
        distance: db["distance"],
        timestamp: db["timestamp"],
        date: db["date"],
        topSpeed: db["topSpeed"],
      );
}

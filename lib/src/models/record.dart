class Record {
  double? distance;
  int? timestamp;
  String? date;
  double? kcal;

  Record({this.distance, this.date, this.timestamp, this.kcal});

  factory Record.fromDB(db) => Record(
        distance: db["distance"],
        timestamp: db["timestamp"],
        date: db["date"],
        kcal: db["kcal"],
      );
}

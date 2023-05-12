import '../models/record.dart';

int getMaxDistance(List<Record> records) {
  double maxDistance = 0;
  for (var element in records) {
    if (element.distance > maxDistance) {
      maxDistance = element.distance;
    }
  }
  return (maxDistance / 1000).round();
}

String getLastRecordDate(List<Record> records) {
  String dateStr = '';
  for (var element in records) {
    if (element.date != '') {
      DateTime date = element.getYearMonthDay();
      dateStr = "${date.month}월 ${date.day}일";
    }
  }
  return dateStr;
}

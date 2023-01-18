import 'package:flutter/material.dart';
import 'package:ridingpartner_flutter/src/models/record.dart';
import 'package:ridingpartner_flutter/src/provider/home_record_provider.dart';
import 'package:ridingpartner_flutter/src/service/firebase_database_service.dart';

class RecordListProvider extends ChangeNotifier {
  List<Record> _records = [];
  List<Record> get records => _records;

  final FirebaseDatabaseService _firebaseDatabaseService =
      FirebaseDatabaseService();

  RecordState _recordState = RecordState.loading;
  RecordState get recordState => _recordState;

  Future getRecord() async {
    Map<String, dynamic> result =
        await _firebaseDatabaseService.getAllRecords();
    _recordState = result['state'];

    if (_recordState == RecordState.success) {
      //   성공
      _records = result['data'];
      _records.sort((a, b) {
        return DateTime.parse(a.date).compareTo(DateTime.parse(b.date));
      });
    }

    notifyListeners();
  }
}

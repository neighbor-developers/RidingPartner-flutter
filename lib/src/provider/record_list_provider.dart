import 'package:flutter/material.dart';
import 'package:ridingpartner_flutter/src/models/record.dart';
import 'package:ridingpartner_flutter/src/provider/home_record_provider.dart';
import 'package:ridingpartner_flutter/src/service/firebase_database_service.dart';

class RecordListProvider extends ChangeNotifier {
  List<Record> _records = [];
  FirebaseDatabaseService _firebaseDatabaseService = FirebaseDatabaseService();

  RecordState _recordState = RecordState.loading;
  List<Record> get records => _records;
  RecordState get recordState => _recordState;

  Future getRecord() async {
    Map<String, dynamic> result =
        await _firebaseDatabaseService.getAllRecords();
    _recordState = result['state'];

    if (_recordState == RecordState.success) {
      _records = result['data'];
    }

    notifyListeners();
  }
}

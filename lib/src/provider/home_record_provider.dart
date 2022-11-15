import 'package:flutter/material.dart';
import 'package:ridingpartner_flutter/src/models/record.dart';
import 'package:ridingpartner_flutter/src/service/firebase_database_service.dart';

import '../service/shared_preference.dart';

enum RecordState { loading, fail, empty, success }

class HomeRecordProvider extends ChangeNotifier {
  final FirebaseDatabaseService _firebaseDatabaseService =
      FirebaseDatabaseService();

  late List<Record>? _ridingRecord;
  Record? _lastRecord = null;
  late Record? _prefRecord;

  List<Record>? get ridingRecord => _ridingRecord;
  Record? get lastRecord => _lastRecord;

  RecordState _recordState = RecordState.loading;
  RecordState get recordState => _recordState;

  Future getRecord() async {
    _ridingRecord = await _firebaseDatabaseService.getAllRecords();
    _prefRecord = PreferenceUtils.getRecordFromPref();

    switch (_ridingRecord) {
      case null:
        _recordState = RecordState.fail;
        if (_prefRecord != null) {
          _lastRecord = _prefRecord;
        }
        break;
      case <Record>[]:
        _recordState = RecordState.empty;
        if (_prefRecord != null) {
          _lastRecord = _prefRecord;
        }
        break;
      default:
        _recordState = RecordState.success;
        if (_prefRecord != _ridingRecord!.last && _prefRecord != null) {
          saveRecord(_prefRecord!);
        }
    }
  }

  void saveRecord(Record record) {
    _firebaseDatabaseService.saveRecordFirebaseDb(record);
    _ridingRecord!.add(record);
  }
}

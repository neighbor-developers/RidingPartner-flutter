import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/record.dart';
import '../service/firebase_database_service.dart';
import '../service/save_record_service.dart';

class RecordProvider extends StateNotifier<Record?> {
  RecordProvider() : super(null);

  @override
  set state(Record? value) {
    super.state = value;
  }

  getData(String date) async {
    state = await FirebaseDatabaseService().getRecord(date);
  }

  saveData(Record record, List<File> img) async {
    if (img.isEmpty) {
      FirebaseDatabaseService().saveRecordFirebaseDb(record);
    } else {
      SaveRecordService().saveRecord(record, img);
    }
  }
}

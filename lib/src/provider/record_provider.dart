import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ridingpartner_flutter/src/service/save_record_service.dart';

import '../models/record.dart';
import '../service/firebase_database_service.dart';

class RecordProvider extends StateNotifier<Record?> {
  RecordProvider() : super(null);

  final Stopwatch stopwatch = Stopwatch();

  @override
  set state(Record? value) {
    // TODO: implement state
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

  start() {
    stopwatch.start();
  }

  pause() {
    stopwatch.stop();
  }

  int get time => stopwatch.elapsedMilliseconds;
}

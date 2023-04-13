import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/record.dart';
import '../service/firebase_database_service.dart';

class RecordProvider extends StateNotifier<Record?> {
  RecordProvider() : super(null);

  @override
  set state(Record? value) {
    // TODO: implement state
    super.state = value;
  }

  getData(String date) async {
    state = await FirebaseDatabaseService().getRecord(date);
  }

  saveData(Record record) async {
    await FirebaseDatabaseService().saveRecordFirebaseDb(record);
    state = record;
  }
}

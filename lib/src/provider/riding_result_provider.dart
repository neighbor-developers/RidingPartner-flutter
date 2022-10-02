import 'package:flutter/cupertino.dart';
import 'package:ridingpartner_flutter/src/models/record.dart';
import 'package:ridingpartner_flutter/src/service/firebase_database_service.dart';

class RidingResultProvider with ChangeNotifier {
  final FirebaseDatabaseService _firebaseDb = FirebaseDatabaseService();


  void getRidingData(Record record) {
    _firebaseDb.getRecord(record.date!);
  }
}
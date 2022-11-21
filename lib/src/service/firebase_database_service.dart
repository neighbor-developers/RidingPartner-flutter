import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:ridingpartner_flutter/src/models/record.dart';
import 'package:ridingpartner_flutter/src/service/shared_preference.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer' as developer;

class FirebaseDatabaseService {
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? _uId;

  saveRecordFirebaseDb(Record record) async {
    _uId = _auth.currentUser?.uid;

    DatabaseReference ref = _database.ref("$_uId/${record.date}");
    await ref
        .set({
          "date": record.date,
          "distance": record.distance,
          "timestamp": record.timestamp,
          "kcal": record.kcal
        })
        .then((_) => {developer.log("firebase 기록 저장 성공 $record")})
        .catchError((onError) {
          print(onError.toString());
        });
    PreferenceUtils.saveRecordPref(record);
  }

  Future<Record> getRecord(String ridingDate) async {
    try {
      DatabaseReference ref = _database.ref("$_uId/$ridingDate");
      final DataSnapshot snapshot = await ref.get();
      if (snapshot.exists) {
        return Record.fromDB(snapshot);
      }
      throw Exception("getRecord: snapshot not exist");
    } catch (e) {
      developer.log(e.toString());
      return Record();
    }
  }

  Future<List<Record>?> getAllRecords() async {
    try {
      DatabaseReference ref = _database.ref("$_uId");
      final DataSnapshot snapshot = await ref.get();

      if (!snapshot.exists) {
        Map<dynamic, dynamic> map = snapshot.value as Map<dynamic, dynamic>;
        return map.values.map(Record.fromDB).toList();
      } else {
        return <Record>[];
      }
    } catch (e) {
      developer.log(e.toString());
      return null;
    }
  }
}

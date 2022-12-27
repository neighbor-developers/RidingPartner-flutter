import 'dart:developer' as developer;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:ridingpartner_flutter/src/models/record.dart';
import 'package:ridingpartner_flutter/src/service/shared_preference.dart';

class FirebaseDatabaseService {
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final String? _uId = FirebaseAuth.instance.currentUser?.uid;

  saveRecordFirebaseDb(Record record) async {
    DatabaseReference ref = _database.ref("$_uId/${record.date}");
    await ref
        .set({
          "date": record.date,
          "distance": record.distance,
          "timestamp": record.timestamp,
          "topSpeed": record.topSpeed,
          "memo": record.memo,
          "kcal": record.kcal
        })
        .then((_) => {developer.log("firebase 기록 저장 성공 $record")})
        .catchError((onError) {
          print(onError.toString());
        });
    PreferenceUtils.saveRecordPref(record);
  }

  saveRecordMemoFirebaseDb(Record record) async {
    DatabaseReference ref = _database.ref("$_uId/${record.date}");
    await ref
        .set({"memo": record.memo})
        .then((_) => {print("메모 내용: ${record.memo}")})
        .catchError((onError) {
          print(onError.toString());
        });
    PreferenceUtils.saveRecordMemoPref(record);
  }

  Future<Record> getRecord(String ridingDate) async {
    try {
      DatabaseReference ref = _database.ref("$_uId/$ridingDate");
      final DataSnapshot snapshot = await ref.get();
      if (snapshot.exists) {
        return Record.fromDB(snapshot.value);
      }
      throw Exception("getRecord: snapshot not exist");
    } catch (e) {
      developer.log(e.toString());
      return Record();
    }
  }

  Future<void> delRecord() async {
    DatabaseReference ref = _database.ref("$_uId");
    try {
      return await ref.remove();
    } catch (e) {
      return;
    }
  }

  Future<List<Record>?> getAllRecords() async {
    try {
      List<Record> records = [];
      DatabaseReference ref = _database.ref("$_uId");
      final DataSnapshot snapshot = await ref.get();

      if (snapshot.exists) {
        print("데이터 있음");
        Map<dynamic, dynamic> map = snapshot.value as Map<dynamic, dynamic>;
        // return map.values.map(Record.fromDB).toList();
        records = map.values.map((recordEl) {
          try {
            developer.log('recordEl: $recordEl');
            return Record.fromDB(recordEl);
          } catch (e) {
            developer.log(e.toString());
            return Record();
          }
        }).toList();

        return records.where((record) => record != Record()).toList();
      } else {
        print("데이터 없음");
        return <Record>[];
      }
    } catch (e) {
      print("catch!");
      developer.log(e.toString());
      return null;
    }
  }
}

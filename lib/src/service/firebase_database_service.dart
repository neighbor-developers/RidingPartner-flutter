import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:ridingpartner_flutter/src/models/record.dart';
import 'package:ridingpartner_flutter/src/models/result.dart';
import 'package:ridingpartner_flutter/src/provider/home_record_provider.dart';

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
          "kcal": record.kcal,
          "images": record.images != null ? json.encode(record.images) : null
        })
        .then((_) => {})
        .catchError((onError) {});
    Record.saveRecordPref(record);
  }

  saveRecordMemoFirebaseDb(Record record) async {
    DatabaseReference ref = _database.ref("$_uId/${record.date}");
    await ref
        .set({"memo": record.memo})
        .then((_) => {})
        .catchError((onError) {});
    Record.saveRecordMemoPref(record);
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
      throw Exception("getRecord: snapshot not exist");
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

  Future<List<Record>> getAllRecords() async {
    try {
      DatabaseReference ref = _database.ref("$_uId");
      final DataSnapshot snapshot = await ref.get();

      if (snapshot.exists) {
        Map<dynamic, dynamic> map = snapshot.value as Map<dynamic, dynamic>;
        return map.values.map((recordEl) {
          try {
            return Record.fromDB(recordEl);
          } catch (e) {
            return Record(distance: 0.0, date: '', timestamp: 0, topSpeed: 0.0);
          }
        }).toList();
      } else {
        return [];
      }
    } catch (e) {
      throw Exception("getAllRecords: snapshot not exist");
    }
  }
}

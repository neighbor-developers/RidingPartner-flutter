import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:ridingpartner_flutter/src/models/riding_record.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer' as developer;

class FirebaseDatabaseService {
  FirebaseDatabase _database = FirebaseDatabase.instance;
  FirebaseAuth _auth = FirebaseAuth.instance;
  String? _uId;

  saveRecordFirebaseDb(RidingRecord record) async {
    _uId = _auth.currentUser?.uid;

    DatabaseReference ref = _database.ref("$_uId/${record.date}");
    await ref
        .set(record)
        .then((_) => {developer.log("firebase 기록 저장 성공 $record")})
        .catchError((onError) {
      saveRecordSharedPref(record);
    });
  }

  saveRecordSharedPref(RidingRecord record) async {
    SharedPreferences pref = await SharedPreferences.getInstance();

    pref.setString("${record.date}/date", record.date);
    pref.setDouble("${record.date}/distance", record.distance.toDouble());
    pref.setInt("${record.timestamp}/date", record.timestamp.toInt());
    pref.setString("${record.timestamp}/kcal", record.kcal.toString());
  }

  // Future<RidingRecord> getRecord(String ridingDate) async {
  //   DatabaseReference ref = _database.ref("$_uId/$ridingDate");
  //   final DataSnapshot snapshot = await ref.child("$_uId/$ridingDate").get();

  //   RidingRecord record;

  //   if (snapshot.exists) {
  //     final data = snapshot.value as Map<String, dynamic>;
  //     return data.entries();
  //   }
  // }
}

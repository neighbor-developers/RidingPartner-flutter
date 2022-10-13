import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:ridingpartner_flutter/src/models/route.dart';

import '../models/place.dart';

class FireStoreService {
  final db = FirebaseFirestore.instance;

  // Future<List<Place>> getPlaces(String? title) async {
  //   Map<String, dynamic>? data;
  //   List<Place> places;
  //   await db
  //       .collection("place")
  //       .doc(title)
  //       .get()
  //       .then((value) => {data = value.data()})
  //       .catchError((onError) {
  //     print("가져오기 실패");
  //   });
  //   if (data != null) {}
  // }

  // Future<List<Route>> getRoutes(String? route) async {
  //   final snapshot = await db.collection("routes").get();
  // if (snapshot) {
  //   final data = snapshot.data() as Map<String, dynamic>;
  //   data.map((key, value) => ,)

  // }
  // }
}

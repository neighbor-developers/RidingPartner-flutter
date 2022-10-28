import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ridingpartner_flutter/src/models/route.dart';
import 'dart:developer' as developer;

import '../models/place.dart';

class FireStoreService {
  final db = FirebaseFirestore.instance;

  Future<List<Place>> getPlaces() async {
    try {
      final snapshot = await db.collection("place").get();

      return snapshot.docs
          .where((docs) => docs.exists)
          .map((docs) => Place.fromDB(docs.data()))
          .toList();
    } catch (e) {
      developer.log(e.toString());
      return <Place>[];
    }
  }

  Future<Place> getPlace(String title) async {
    try {
      final snapshot = await db.collection("place").doc(title).get();

      if (snapshot.exists) {
        return Place.fromDB(snapshot.data());
      }
      throw Exception("getPlace: snapshot not exist");
    } catch (e) {
      developer.log(e.toString());
      return Place();
    }
  }

  Future<List<Route>> getRoutes() async {
    try {
      final snapshot = await db.collection("routes").get();

      return snapshot.docs.where((docs) => docs.exists).map((docs) {
        final data = docs.data();

        return Route.fromDB(data);
      }).toList();
    } catch (e) {
      developer.log(e.toString());
      return <Route>[];
    }
  }

  Future<Route> getRoute(String title) async {
    try {
      final snapshot = await db.collection("routes").doc(title).get();

      if (snapshot.exists) {
        return Route.fromDB(snapshot.data());
      }
      throw Exception("getRoute: snapshot not exist");
    } catch (e) {
      developer.log(e.toString());
      return Route();
    }
  }

  Future<String> setRoutes(List<Route> routes) async {
    try {
      // db에 routes 를 저장하기전 정보를 담아두는 곳
      // 여러 작업을 수행할때 실패확률을 줄여주고 에러추적도 쉬움
      final batch = db.batch();
      final routesDB = db.collection("routes");

      for (var route in routes) {
        batch.set(routesDB.doc(route.title), route.toDB());
      }

      // 데이터 쓰기 작업
      await batch.commit();
      return "성공";
    } catch (e) {
      developer.log(e.toString());
      return "실패";
    }
  }
}

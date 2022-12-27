import 'dart:developer' as developer;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ridingpartner_flutter/src/models/route.dart';
import 'package:ridingpartner_flutter/src/service/firebase_storage_service.dart';

import '../models/place.dart';

class FireStoreService {
  final db = FirebaseFirestore.instance;
  final FirebaseStorageService _FirebaseStorageService =
      FirebaseStorageService();

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

  Future<bool> setPlaces(List<Place> places) async {
    try {
      // db에 routes 를 저장하기전 정보를 담아두는 곳
      // 여러 작업을 수행할때 실패확률을 줄여주고 에러추적도 쉬움
      final batch = db.batch();
      final placesDB = db.collection("places");

      for (var place in places) {
        place.imageUrl = await _FirebaseStorageService.uploadImage(
            "/places/${place.imageTitle}", place.imageFile!);
        batch.set(placesDB.doc(place.title), place.toDB());
      }

      // 데이터 쓰기 작업
      await batch.commit();
      // 이미지 업로드 작업

      return true;
    } catch (e) {
      developer.log(e.toString());
      return false;
    }
  }

  Future<List<RidingRoute>> getRoutes() async {
    try {
      final snapshot = await db.collection("routes").get();

      return snapshot.docs.where((docs) => docs.exists).map((docs) {
        final data = docs.data();

        return RidingRoute.fromDB(data);
      }).toList();
    } catch (e) {
      developer.log(e.toString());
      return <RidingRoute>[];
    }
  }

  Future<RidingRoute> getRoute(String title) async {
    try {
      final snapshot = await db.collection("routes").doc(title).get();

      if (snapshot.exists) {
        return RidingRoute.fromDB(snapshot.data());
      }
      throw Exception("getRoute: snapshot not exist");
    } catch (e) {
      developer.log(e.toString());
      return RidingRoute();
    }
  }

  Future<bool> setRoutes(List<RidingRoute> routes) async {
    try {
      // db에 routes 를 저장하기전 정보를 담아두는 곳
      // 여러 작업을 수행할때 실패확률을 줄여주고 에러추적도 쉬움
      final batch = db.batch();
      final routesDB = db.collection("routes");

      for (var route in routes) {
        route.routeImageUrl = await _FirebaseStorageService.uploadImage(
            "/routes/${route.routeImageTitle}", route.routeImageFile!);
        batch.set(routesDB.doc(route.title), route.toDB());
      }

      // 데이터 쓰기 작업
      await batch.commit();
      return true;
    } catch (e) {
      developer.log(e.toString());
      return false;
    }
  }
}

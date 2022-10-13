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

        return Route(
          title: data["title"],
          description: data["description"],
          image: data["image"],
          routeImage: data["routeImage"],
          route: List<String>.from(docs.data()["route"]),
        );
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
}

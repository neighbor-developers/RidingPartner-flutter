import 'dart:math';

import 'package:flutter/services.dart';

import '../models/place.dart';

Future<List<Place>> getRecomendPlace() async {
  final random = Random();

  final placeFromJsonFile =
      await rootBundle.loadString('assets/json/place.json');
  List<Place> places =
      PlaceList.fromJson(placeFromJsonFile).places ?? <Place>[];
  // List<Place> places = await _fireStoreService.getPlaces();
  int num1 = random.nextInt(places.length);
  while (num1 == 14 || num1 == 16) {
    num1 = random.nextInt(places.length);
  }
  int num2 = random.nextInt(places.length);
  while (num2 == 14 || num2 == 16 || num2 == num1) {
    num2 = random.nextInt(places.length);
  }

  return [places[num1], places[num2]];
}

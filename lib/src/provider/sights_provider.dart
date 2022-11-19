import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ridingpartner_flutter/src/models/route.dart';
import 'package:ridingpartner_flutter/src/service/firestore_service.dart';

import '../models/place.dart';
import '../utils/custom_marker.dart';
import 'dart:developer';

enum MarkerListState {
  searching,
  empty,
  placeCompleted,
  markerCompleted,
  click
}

class SightsProvider with ChangeNotifier {
  MarkerListState _state = MarkerListState.searching;
  MarkerListState get state => _state;
  setState(state) {
    _state = state;
    notifyListeners();
  }

  List<Place> _sightList = <Place>[];
  List<Place> get sightList => _sightList;

  FireStoreService fireStore = FireStoreService();

  final List<Marker> _markers = [];
  List<Marker> get markers => _markers;

  Future<void> getPlaceList() async {
    try {
      final routeFromJsonFile =
          await rootBundle.loadString('assets/json/place.json');
      _sightList = PlaceList.fromJson(routeFromJsonFile).places ?? <Place>[];

      if (_sightList.isEmpty) {
        _state = MarkerListState.empty;
      } else {
        _state = MarkerListState.placeCompleted;
      }
      notifyListeners();
    } catch (e) {
      _state = MarkerListState.empty;
    }
  }
}

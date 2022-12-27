import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ridingpartner_flutter/src/service/firestore_service.dart';

import '../models/place.dart';

enum MarkerListState {
  searching, //  place 받기 전
  empty, //  place를 받았지만 비어 있을 때
  placeCompleted, //  place 데이터 정상적으로 다 받음
  markerCompleted, //  place 데이터 이미지로 마커 받기 완료 했을 때
  click //  마커 클릭했을 때
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

import 'package:flutter/material.dart';
import 'package:ridingpartner_flutter/src/models/place.dart';
import '../service/naver_map_service.dart';
import 'dart:developer' as developer;

class MapSearchProvider extends ChangeNotifier {
  List<Place> _startPointSearchResult = [];
  List<Place> get startPointSearchResult => _startPointSearchResult;

  List<Place> _endPointSearchResult = [];
  List<Place> get endPointSearchResult => _endPointSearchResult;

  Place? _startPoint;
  Place? get startPoint => _startPoint;

  Place? _endPoint;
  Place? get endPoint => _endPoint;

  setStartPoint(Place place) {
    _startPoint = place;
    notifyListeners();
  }

  setEndPoint(Place place) {
    _endPoint = place;
    notifyListeners();
  }

  setStartPointSearchResult(String title) async {
    _startPointSearchResult = (await NaverMapService().getPlaces(title)) ?? [];
    notifyListeners();
  }

  setEndPointSearchResult(String title) async {
    _endPointSearchResult = (await NaverMapService().getPlaces(title)) ?? [];
    notifyListeners();
  }

  clearStartPointSearchResult() {
    _startPointSearchResult = [];
    notifyListeners();
  }

  clearEndPointSearchResult() {
    _endPointSearchResult = [];
    notifyListeners();
  }
}

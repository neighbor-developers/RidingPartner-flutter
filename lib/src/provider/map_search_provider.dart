import 'package:flutter/material.dart';
import 'package:ridingpartner_flutter/src/models/place.dart';
import '../service/naver_map_service.dart';
import 'dart:developer' as developer;

class MapSearchProvider extends ChangeNotifier {
  List<Place> _searchResult = [];
  List<Place> get searchResult => _searchResult;
  final List<Place> _tempData = [
    Place(title: '한국공학대학교', latitude: '126.733926', longitude: '37.340370'),
    Place(title: '산본 세종공원', latitude: '126.927293', longitude: '37.358323')
  ];

  setSearchResult(String title) async {
    _searchResult = _tempData;
    developer.log('searchResult: ${_searchResult.length}');
    // _searchResult = (await NaverMapService().getPlaces(title)) ?? [];
    notifyListeners();
  }
}

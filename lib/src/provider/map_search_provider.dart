import 'package:flutter/material.dart';
import 'package:ridingpartner_flutter/src/models/place.dart';
import '../service/naver_map_service.dart';
import 'dart:developer' as developer;

class MapSearchProvider extends ChangeNotifier {
  List<Place> _searchResult = [];
  List<Place> get searchResult => _searchResult;
  List<Place> _searchHistory = [Place(title: 'sdfsdf'), Place(title: 'fdsfsd')];

  setSearchResult(String title) async {
    _searchResult = _searchHistory;
    developer.log('searchResult: ${_searchResult.length}');
    // _searchResult = (await NaverMapService().getPlaces(title)) ?? [];
    notifyListeners();
  }
}

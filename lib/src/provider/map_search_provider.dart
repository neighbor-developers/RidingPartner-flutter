import 'package:flutter/material.dart';
import 'package:ridingpartner_flutter/src/models/place.dart';
import '../service/naver_map_service.dart';

class MapSearchProvider extends ChangeNotifier {
  List<Place> _searchResult = [];
  List<Place> get searchResult => _searchResult;

  void setSearchResult(String title) async {
    _searchResult = (await NaverMapService().getPlaces(title)) ?? [];
    notifyListeners();
  }
}

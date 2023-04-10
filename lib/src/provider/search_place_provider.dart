import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ridingpartner_flutter/src/models/place.dart';
import 'package:ridingpartner_flutter/src/service/naver_map_service.dart';

class SearchPlaceProvider extends StateNotifier<List<Place>> {
  SearchPlaceProvider() : super([]);

  NaverMapService naverMapService = NaverMapService();
  @override
  set state(List<Place> value) {
    // TODO: implement state
    super.state = value;
  }

  void getPlaces(String title) async {
    state = (await naverMapService.getPlaces(title)) ?? [];
  }

  void clearRoute() {
    state = [];
  }
}

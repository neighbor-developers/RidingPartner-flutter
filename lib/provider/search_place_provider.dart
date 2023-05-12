import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/place.dart';
import '../service/naver_map_service.dart';

class SearchPlaceProvider extends StateNotifier<List<Place>> {
  SearchPlaceProvider() : super([]);

  NaverMapService naverMapService = NaverMapService();
  @override
  set state(List<Place> value) {
    super.state = value;
  }

  void getPlaces(String title) async {
    state = (await naverMapService.getPlaces(title));
  }

  void clearPlace() {
    state = [];
  }
}

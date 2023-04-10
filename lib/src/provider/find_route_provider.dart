import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ridingpartner_flutter/src/models/route.dart';

class FindRouteProvider extends StateNotifier<List<Guide>> {
  FindRouteProvider() : super([]);

  @override
  set state(List<Guide> value) {
    // TODO: implement state
    super.state = value;
  }

  void getRoute() {}
}

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:ridingpartner_flutter/src/service/background_location_service.dart';

class PositionProvider extends StateNotifier<Position?> {
  PositionProvider() : super(null);

  StreamSubscription<Position>? _positionStream;

  @override
  void dispose() {
    super.dispose();
    _positionStream?.cancel();
  }

  @override
  set state(Position? value) {
    // TODO: implement state
    super.state = value;
  }

  void getPosition() {
    _positionStream = BackgroundLocationService().position().listen((event) {
      state = event;
    });
  }
}

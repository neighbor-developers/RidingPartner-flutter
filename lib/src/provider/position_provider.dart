import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:ridingpartner_flutter/src/service/background_location_service.dart';

class PositionProvider extends StateNotifier<Position?> {
  PositionProvider() : super(null);

  @override
  set state(Position? value) {
    // TODO: implement state
    super.state = value;
  }

  void getPosition() {
    BackgroundLocationService().position().listen((event) {
      state = event;
    });
  }
}

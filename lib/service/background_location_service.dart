import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

class BackgroundLocationService {
  static final BackgroundLocationService _instance =
      BackgroundLocationService._internal();

  static const int distance = 30;
  static const int duration = 2;

  Stream<Position>? positionStream;

  factory BackgroundLocationService() {
    return _instance;
  }

  BackgroundLocationService._internal() {
    setlocationSettings();
  }

  void setlocationSettings() {
    if (defaultTargetPlatform == TargetPlatform.android) {
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
    } else {}
  }

  setStream() {
    positionStream = Geolocator.getPositionStream().asBroadcastStream();
  }
}

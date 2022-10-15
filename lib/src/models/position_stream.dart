import 'dart:async';

import 'package:geolocator/geolocator.dart';

class PositionStream {
  static final PositionStream _instance = PositionStream._internal();
  static final StreamController<Position> _controller =
      StreamController<Position>.broadcast();

  StreamController<Position> get controller => _controller;

  factory PositionStream() {
    return _instance;
  }

  PositionStream._internal() {
    Geolocator.getPositionStream(desiredAccuracy: LocationAccuracy.high)
        .listen((pos) {
      _controller.add(pos);
    });
  }
}

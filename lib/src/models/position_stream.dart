import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

class PositionStream {
  late LocationSettings locationSettings;
  static final PositionStream _instance = PositionStream._internal();
  late StreamSubscription<Position> _positionStream;
  static StreamController<Position> _controller =
      StreamController<Position>.broadcast();
  static const int DISTANCE = 30;
  static const int DURATION_SECNOD = 2;

  StreamController<Position> get controller => _controller;

  factory PositionStream() {
    _controller = StreamController<Position>.broadcast();
    return _instance;
  }

  //dispose
  void dispose() {
    _controller.close();
    _positionStream.cancel();
  }

  PositionStream._internal() {
    if (defaultTargetPlatform == TargetPlatform.android) {
      locationSettings = AndroidSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: DISTANCE,
          forceLocationManager: true,
          intervalDuration: const Duration(seconds: DURATION_SECNOD),
          //(Optional) Set foreground notification config to keep the app alive
          //when going to the background
          foregroundNotificationConfig: const ForegroundNotificationConfig(
            notificationText: "백그라운드에서 사용자의 위치를 수집중입니다.",
            notificationTitle: "Riding-partner Running in Background",
            enableWakeLock: true,
          ));
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      locationSettings = AppleSettings(
        accuracy: LocationAccuracy.high,
        activityType: ActivityType.fitness,
        distanceFilter: DISTANCE,
        pauseLocationUpdatesAutomatically: true,
        // Only set to true if our app will be started up in the background.
        showBackgroundLocationIndicator: false,
      );
    } else {
      locationSettings = const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: DISTANCE,
      );
    }
    _positionStream =
        Geolocator.getPositionStream(locationSettings: locationSettings)
            .listen((Position? pos) {
      if (pos != null) {
        _controller.add(pos);
      }
    });
  }
}

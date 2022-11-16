import 'dart:async';

import 'package:geolocator/geolocator.dart';
import 'package:geolocator_apple/geolocator_apple.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator_android/geolocator_android.dart';

class PositionStream {
  late LocationSettings locationSettings;
  static final PositionStream _instance = PositionStream._internal();
  static final StreamController<Position> _controller =
      StreamController<Position>.broadcast();
  static final int DISTANCE = 30;
  static final int DURATION_SECNOD = 2;

  StreamController<Position> get controller => _controller;

  factory PositionStream() {
    return _instance;
  }

  PositionStream._internal() {
    if (defaultTargetPlatform == TargetPlatform.android) {
      locationSettings = AndroidSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: DISTANCE,
          forceLocationManager: true,
          intervalDuration: Duration(seconds: DURATION_SECNOD),
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
      locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: DISTANCE,
      );
    }
    StreamSubscription<Position> positionStream =
        Geolocator.getPositionStream(locationSettings: locationSettings)
            .listen((Position? pos) {
      _controller.add(pos!);
    });
  }
}

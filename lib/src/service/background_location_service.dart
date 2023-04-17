import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

class BackgroundLocationService {
  static final BackgroundLocationService _instance =
      BackgroundLocationService._internal();
  StreamController<Position> _controller =
      StreamController<Position>.broadcast();

  late LocationSettings _locationSettings;

  static const int DISTANCE = 30;
  static const int DURATION_SECNOD = 2;

  factory BackgroundLocationService() {
    return _instance;
  }

  BackgroundLocationService._internal() {
    if (defaultTargetPlatform == TargetPlatform.android) {
      _locationSettings = AndroidSettings(
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
      _locationSettings = AppleSettings(
        accuracy: LocationAccuracy.high,
        activityType: ActivityType.fitness,
        distanceFilter: DISTANCE,
        pauseLocationUpdatesAutomatically: true,
        // Only set to true if our app will be started up in the background.
        showBackgroundLocationIndicator: false,
      );
    } else {
      _locationSettings = const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: DISTANCE,
      );
    }
  }

  Stream<Position> position() {
    return Geolocator.getPositionStream();
  }
}

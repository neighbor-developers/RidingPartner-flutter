import 'package:geolocator/geolocator.dart';
import 'dart:developer' as developer;

class MyLocation {
  double latitude = 0.0;
  double longitude = 0.0;

  Future<void> getMyCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      latitude = position.latitude;
      longitude = position.longitude;
    } catch (e) {
      developer.log("API 연결에 문제가 발생했습니다.");
    }
  }
}

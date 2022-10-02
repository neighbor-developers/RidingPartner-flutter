import 'package:geolocator/geolocator.dart';
import 'dart:developer' as developer;

class MyLocation {
  late double? latitude;
  late double? longitude;

  static final MyLocation _instance = MyLocation._internal();
  factory MyLocation() {
    return _instance;
  }

  initLocation() async =>
      {developer.log("위치를 가져오는중"), await getMyCurrentLocation()};

  MyLocation._internal() {
    initLocation();
  }

  Future<void> getMyCurrentLocation() async {
    try {
      // ignore: unrelated_type_equality_checks
      if (Geolocator.checkPermission() == LocationPermission.denied) {
        Geolocator.requestPermission();
      }
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      latitude = position.latitude;
      longitude = position.longitude;
      developer.log("latitude : $latitude , longitude : $longitude");
    } catch (e) {
      developer.log("error : getMyCurrentLocation ${e.toString()}");
      latitude = 37.579871128849334;
      longitude = 126.98935225645432;
    }
  }
}

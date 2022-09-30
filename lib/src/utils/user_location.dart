import 'package:geolocator/geolocator.dart';
import 'dart:developer' as developer;

class MyLocation {
  //위치를 제대로 못 받아올 경우 대비해 기본값으로 서울을 설정
  double latitude = 37.579871128849334;
  double longitude = 126.98935225645432;

  Future<void> getMyCurrentLocation() async {
    try {
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
    }
  }
}

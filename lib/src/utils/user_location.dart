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
      {await _cheakPermission(), await getMyCurrentLocation()};

  MyLocation._internal() {
    initLocation();
  }

  Future<void> _cheakPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permantly denied, we cannot request permissions.');
    }

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        return Future.error(
            'Location permissions are denied (actual value: $permission).');
      }
    }
  }

  Future<void> getMyCurrentLocation() async {
    try {
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

  // Future<dynamic> _cheakPermission() async {
  //   bool serviceEnabled;
  //   LocationPermission permission;
  //   developer.log("안녕");
  //   // Test if location services are enabled.
  //   serviceEnabled = await Geolocator.isLocationServiceEnabled();
  //   if (!serviceEnabled) {
  //     return Future.error('Location services are disabled.');
  //   }

  //   permission = await Geolocator.checkPermission();
  //   if (permission == LocationPermission.denied) {
  //     permission = await Geolocator.requestPermission();
  //     if (permission == LocationPermission.denied) {
  //       return Future.error('Location permissions are denied');
  //     }
  //   }

  //   if (permission == LocationPermission.deniedForever) {
  //     return Future.error(
  //         'Location permissions are permanently denied, we cannot request permissions.');
  //   }
  // }
}

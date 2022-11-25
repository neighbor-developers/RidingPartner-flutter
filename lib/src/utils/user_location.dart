import 'package:geolocator/geolocator.dart';
import 'dart:developer' as developer;

class MyLocation {
  late Position? position;

  static final MyLocation _instance = MyLocation._internal();
  factory MyLocation() {
    return _instance;
  }

  initLocation() async =>
      {await cheakPermission(), await getMyCurrentLocation()};

  MyLocation._internal() {
    initLocation();
  }

  Future<void> cheakPermission() async {
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
      position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      developer.log(
          "latitude : ${position?.latitude} , longitude : ${position?.longitude}");
    } catch (e) {
      developer.log("error : getMyCurrentLocation ${e.toString()}");
      position = await Geolocator.getLastKnownPosition();
    }
    if (position == null) {
      position = Position(
          longitude: 126.98935225645432,
          latitude: 37.579871128849334,
          timestamp: null,
          accuracy: 0.0,
          altitude: 0.0,
          heading: 0.0,
          speed: 0.0,
          speedAccuracy: 0.0);
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

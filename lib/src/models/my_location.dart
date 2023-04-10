
import 'package:geolocator/geolocator.dart';

class MyLocation {
  Position? position;

  static final MyLocation _instance = MyLocation._internal();
  factory MyLocation() {
    return _instance;
  }

  initLocation() async {
    await checkPermission();
  }

  MyLocation._internal() {
    initLocation();
  }

  Future<void> checkPermission() async {
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
    } catch (e) {
      position = await Geolocator.getLastKnownPosition()
          .timeout(Duration(seconds: 3), onTimeout: () => position = null);
    }
  }
}

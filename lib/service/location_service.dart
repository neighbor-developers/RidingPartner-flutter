import 'package:geolocator/geolocator.dart';

class MyLocation {
  Position? position;
  bool _serviceEnabled = false;

  static final MyLocation _instance = MyLocation._internal();
  factory MyLocation() {
    return _instance;
  }

  MyLocation._internal();

  Future<void> checkPermission() async {
    LocationPermission permission;

    _serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!_serviceEnabled) {
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

  Future<Position?> getMyCurrentLocation() async {
    try {
      if (!_serviceEnabled) {
        await checkPermission();
      }

      position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      return position;
    } catch (e) {
      return null;
    }
  }
}

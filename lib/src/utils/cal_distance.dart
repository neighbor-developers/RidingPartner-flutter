import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

double calDistance(Position bef, Position aft) {
  final befP = LatLng(bef.latitude, bef.longitude);
  final aftP = LatLng(aft.latitude, aft.longitude);
  const Distance calDistance = Distance();
  return calDistance.as(LengthUnit.Meter, befP, aftP);
}

double calDistanceForList(List<LatLng> locations) {
  const Distance calDistance = Distance();
  double dis = 0;

  for (var i = 0; i < locations.length - 1; i++) {
    dis += calDistance.as(LengthUnit.Meter, locations[i], locations[i + 1]);
  }

  return dis;
}

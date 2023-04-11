import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

double calDistance(Position bef, Position aft) {
  final befP = LatLng(bef.latitude, bef.longitude);
  final aftP = LatLng(aft.latitude, aft.longitude);
  const Distance calDistance = Distance();
  return calDistance.as(LengthUnit.Meter, befP, aftP);
}

import 'package:latlong2/latlong.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart' as nav;

double calDistance(nav.LatLng bef, nav.LatLng aft) {
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

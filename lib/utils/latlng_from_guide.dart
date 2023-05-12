import 'package:latlong2/latlong.dart';

import '../models/route.dart';

LatLng? latLngFromGuide(Guide? guide) {
  if (guide != null) {
    List<double>? a =
        (guide.turnPoint?.split(','))?.map((p) => double.parse(p)).toList();
    if (a == null) {
      return null;
    } else {
      return LatLng(a.elementAt(1), a.elementAt(0));
    }
  } else {
    return null;
  }
}

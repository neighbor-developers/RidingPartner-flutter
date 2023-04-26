import 'package:flutter_naver_map/flutter_naver_map.dart';

import '../models/place.dart';

List<LatLng> setPolylineData(Place startPlace, Place finalDestination) {
  LatLng start = startPlace.location;
  LatLng end = finalDestination.location;

  if (start.latitude <= end.latitude) {
    LatLng temp = start;
    start = end;
    end = temp;
  }
  LatLng northEast = start;
  LatLng southWest = end;

  double nLat, nLon, sLat, sLon;

  if (southWest.latitude <= northEast.latitude) {
    sLat = southWest.latitude;
    nLat = northEast.latitude;
  } else {
    sLat = northEast.latitude;
    nLat = southWest.latitude;
  }
  if (southWest.longitude <= northEast.longitude) {
    sLon = southWest.longitude;
    nLon = northEast.longitude;
  } else {
    sLon = northEast.longitude;
    nLon = southWest.longitude;
  }

  return [LatLng(nLat, nLon), LatLng(sLat, sLon)];
}

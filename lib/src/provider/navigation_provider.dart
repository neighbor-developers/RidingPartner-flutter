import 'package:flutter/cupertino.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:ridingpartner_flutter/src/models/route.dart';
import 'package:ridingpartner_flutter/src/provider/riding_provider.dart';
import 'package:ridingpartner_flutter/src/service/naver_map_service.dart';

import '../models/place.dart';

class NavigationProvider extends RidingProvider {
  final NaverMapService _naverMapService = NaverMapService();
  List<Guide>? _route;
  List<LatLng> _polylineCoordinates = [];
  List<LatLng> get polylineCoordinates => _polylineCoordinates;

  Future<void> getRoute(
      Place start, Place destination, List<Place>? waypoints) async {
    _route = await _naverMapService.getRoute(start, destination, waypoints);

    polyline(start, destination, waypoints);
  }

  void polyline(Place start, Place destination, List<Place>? waypoints) async {
    List<PolylineWayPoint>? waypoint = waypoints
        ?.map((p) => PolylineWayPoint(location: "${p.latitude},${p.longitude}"))
        .toList();

    PolylinePoints polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        dotenv.env['googleApiKey']!,
        PointLatLng(start.latitude as double, start.longitude as double),
        PointLatLng(
            destination.latitude as double, destination.longitude as double),
        wayPoints: waypoint ?? List.empty());

    if (result.points.isNotEmpty) {
      result.points.forEach((element) =>
          polylineCoordinates.add(LatLng(element.latitude, element.longitude)));
    }
  }
}

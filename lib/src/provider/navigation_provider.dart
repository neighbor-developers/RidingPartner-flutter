import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as google_map;
import 'package:intl/intl.dart';
import 'package:latlong/latlong.dart';

import 'package:ridingpartner_flutter/src/models/route.dart';
import 'package:ridingpartner_flutter/src/provider/riding_provider.dart';
import 'package:ridingpartner_flutter/src/service/naver_map_service.dart';

import '../models/place.dart';

class NavigationProvider with ChangeNotifier {
  final NaverMapService _naverMapService = NaverMapService();
  late Position _position;
  final Distance _calDistance = const Distance();

  late List<Place> _riding_course;
  List<Guide>? _route;
  List<google_map.LatLng> _polylineCoordinates = [];
  List<google_map.LatLng> get polylineCoordinates => _polylineCoordinates;

  late Guide _goal_point;
  late Place _goal_destination;
  late Guide? _next_point;
  late Place? _next_destination;
  late Place _final_destination;
  late Timer _timer;

  Future<void> getRoute(List<Place> course) async {
    _riding_course = course;
    _final_destination = course.last;
    _position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    Place startPlace = Place(
        id: null,
        title: null,
        latitude: _position.latitude.toString(),
        longitude: _position.longitude.toString(),
        jibunAddress: null,
        roadAddress: null);

    _route =
        await _naverMapService.getRoute(startPlace, _final_destination, course);

    polyline();
  }

  Future<void> startRiding(bool re) async {
    Geolocator.getPositionStream(desiredAccuracy: LocationAccuracy.high)
        .listen((pos) {
      _position = pos;
    });
    var time = 0;

    _timer = Timer.periodic(Duration(seconds: 2), ((timer) {
      time++; // 1초마다 noti, 3초마다 데이터 계산
      calToPoint();
      if (time / 30 == 0) {
        calToDestination();
      }
      notifyListeners();
    }));
  }

  void calToPoint() {
    var point = _goal_point.turnPoint?.split(',');
    var next_point = _next_point?.turnPoint?.split(',');

    num distanceToPoint = _calDistance.as(
        LengthUnit.Meter,
        LatLng(_position.latitude, _position.longitude),
        LatLng(point![0] as double, point[1] as double));

    if (next_point != null) {
      num distanceToNextPoint = _calDistance.as(
          LengthUnit.Meter,
          LatLng(_position.latitude, _position.longitude),
          LatLng(next_point[0] as double, next_point[1] as double));

      if (distanceToPoint <= 10 || distanceToPoint > distanceToNextPoint) {
        if (_route!.length == 1) {
          _goal_point = _route!.first; //
          _route!.removeAt(0);
          _next_point = null;
        } else {
          _goal_point = _route!.first; //
          _route!.removeAt(0);
          _next_point = _route!.first;
        }
      }
    } else {
      if (distanceToPoint <= 10) {
        // 도착 !
      }
    }
  }

  void calToDestination() {
    num distanceToDestination = _calDistance.as(
        LengthUnit.Meter,
        LatLng(_position.latitude, _position.longitude),
        LatLng(_goal_destination.latitude as double,
            _goal_destination.longitude as double));

    if (_next_destination != null) {
      num distanceToNextDestination = _calDistance.as(
          LengthUnit.Meter,
          LatLng(_position.latitude, _position.longitude),
          LatLng(_next_destination!.latitude as double,
              _next_destination!.longitude as double));

      if (distanceToDestination < 10) {
        if (_riding_course.length >= 2) {
          _goal_destination = _riding_course[0];
          _riding_course.removeAt(0);
          _next_destination = _riding_course[0];
        } else if (_riding_course.length == 1) {
          _goal_destination = _riding_course[0];
          _riding_course.removeAt(0);
        } else {
          // 도착!
        }
      } else if (distanceToDestination > distanceToNextDestination) {
        getRoute(_riding_course);
      }
    } else {
      if (distanceToDestination <= 10) {
        // 도착 !
      }
    }
  }

  void polyline() async {
    List<PolylineWayPoint>? waypoint = _route
        ?.map((route) => PolylineWayPoint(location: route.turnPoint.toString()))
        .toList();

    PolylinePoints polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        dotenv.env['googleApiKey']!,
        PointLatLng(
            _position.latitude as double, _position.longitude as double),
        PointLatLng(_final_destination.latitude as double,
            _final_destination.longitude as double),
        wayPoints: waypoint ?? List.empty());

    if (result.points.isNotEmpty) {
      result.points.forEach((element) => polylineCoordinates
          .add(google_map.LatLng(element.latitude, element.longitude)));
    }

    notifyListeners();
  }
}

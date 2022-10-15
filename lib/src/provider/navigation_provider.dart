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

class NavigationProvider extends RidingProvider {
  final NaverMapService _naverMapService = NaverMapService();
  //make constructer with one Place type parameter
  NavigationProvider(this.startPoint, this.endPoint);
  Position? _position;
  final Distance _calDistance = const Distance();
  late Place startPoint;
  late Place endPoint;

  late List<Place> _ridingCourse;
  List<Guide>? _route;
  List<google_map.LatLng> _polylineCoordinates = [];
  List<google_map.LatLng> get polylineCoordinates => _polylineCoordinates;

  late Guide _goalPoint;
  late Place _goalDestination;
  late Guide? _nextPoint;
  late Place? _nextDestination;
  late Place _finalDestination;
  late Timer _timer;
  late google_map.GoogleMapController _googleMapController;

  Guide get goalPoint => _goalPoint;
  Position? get position => _position;
  List<Guide>? get route => _route;
  google_map.GoogleMapController get googleCon => _googleMapController;

  Future<void> getRoute(List<Place> course) async {
    _ridingCourse = course;
    _finalDestination = course.last;
    _position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    Place startPlace = Place(
        id: null,
        title: "내 위치",
        latitude: _position!.latitude.toString(),
        longitude: _position!.longitude.toString(),
        jibunAddress: null,
        roadAddress: null);

    _route =
        await _naverMapService.getRoute(startPlace, _finalDestination, course);

    _polyline();
  }

  Future<void> startRiding() async {
    Geolocator.getPositionStream(desiredAccuracy: LocationAccuracy.high)
        .listen((pos) {
      _position = pos;
    });

    _timer = Timer.periodic(Duration(seconds: 1), ((timer) {
      _calToPoint();
      notifyListeners();
    }));
  }

  void _calToPoint() {
    List<double>? point = (_goalPoint.turnPoint?.split(','))
        ?.map((p) => double.parse(p))
        .toList();
    List<double>? nextPoint = (_nextPoint?.turnPoint?.split(','))
        ?.map((p) => double.parse(p))
        .toList();

    num distanceToPoint = _calDistance.as(
        LengthUnit.Meter,
        LatLng(_position!.latitude, _position!.longitude),
        LatLng(point![0], point[1]));

    if (nextPoint != null) {
      // 마지막 지점이 아닐때
      num distanceToNextPoint = _calDistance.as(
          LengthUnit.Meter,
          LatLng(_position!.latitude, _position!.longitude),
          LatLng(nextPoint[0], nextPoint[1]));

      num distancePointToPoint = _calDistance.as(LengthUnit.Meter,
          LatLng(point[0], point[1]), LatLng(nextPoint[0], nextPoint[1]));

      if (distanceToPoint > distancePointToPoint + 10) {
        // 2의 경우
        // c + am
        _calToDestination(); // 다음 경유지 계산해서 만약 다음 경유지가 더 가까우면 사용자 입력 받아서 다음경유지로 안내
        getRoute(_ridingCourse);
      } else {
        if (distanceToPoint <= 10 ||
            distanceToPoint > distanceToNextPoint + 10) {
          // 턴 포인트 도착이거나 a > b일때
          _isDestination(); // 경유지인지 확인
          if (_route!.length == 2) {
            _route!.removeAt(0);
            _goalPoint = _route![0]; //
            _nextPoint = null;
          } else {
            _route!.removeAt(0);
            _goalPoint = _route![0]; //
            _nextPoint = _route![1];
          }
        }
      }
    }
  }

  void _isDestination() {
    num distanceToDestination = _calDistance.as(
        LengthUnit.Meter,
        LatLng(_position!.latitude, _position!.longitude),
        LatLng(double.parse(_goalDestination.latitude!),
            double.parse(_goalDestination.longitude!)));

    if (distanceToDestination < 10) {
      if (_ridingCourse.length == 1) {
        // 최종 목적지 도착!
      } else if (_ridingCourse.length == 2) {
        _ridingCourse.removeAt(0);
        _goalDestination = _ridingCourse[0];
        _nextDestination = null;
      } else {
        _ridingCourse.removeAt(0);
        _goalDestination = _ridingCourse[0];
        _nextDestination = _ridingCourse[1];
      }
    }
  }

  void _calToDestination() {
    num distanceToDestination = _calDistance.as(
        LengthUnit.Meter,
        LatLng(_position!.latitude, _position!.longitude),
        LatLng(double.parse(_goalDestination.latitude!),
            double.parse(_goalDestination.longitude!)));

    num distanceToNextDestination = _calDistance.as(
        LengthUnit.Meter,
        LatLng(_position!.latitude, _position!.longitude),
        LatLng(double.parse(_nextDestination!.latitude!),
            double.parse(_nextDestination!.longitude!)));

    if (distanceToDestination > distanceToNextDestination) {
      // 다음 경유지로 안내할까요?
      // ok ->
      if (true) {
        _ridingCourse.removeAt(0);
      }
    }
  }

  void _polyline() async {
    List<PolylineWayPoint>? waypoint = _route
        ?.map((route) => PolylineWayPoint(location: route.turnPoint.toString()))
        .toList();

    PolylinePoints polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        dotenv.env['googleApiKey']!,
        PointLatLng(
            _position!.latitude as double, _position!.longitude as double),
        PointLatLng(_finalDestination.latitude as double,
            _finalDestination.longitude as double),
        wayPoints: waypoint ?? List.empty());

    if (result.points.isNotEmpty) {
      result.points.forEach((element) => polylineCoordinates
          .add(google_map.LatLng(element.latitude, element.longitude)));
    }

    notifyListeners();
  }
}

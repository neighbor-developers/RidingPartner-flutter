import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as google_map;
import 'package:latlong2/latlong.dart';
import 'package:ridingpartner_flutter/src/models/route.dart';
import 'package:ridingpartner_flutter/src/provider/riding_provider.dart';
import 'package:ridingpartner_flutter/src/service/naver_map_service.dart';

import '../models/place.dart';
import '../models/position_stream.dart';

class NavigationProvider with ChangeNotifier {
  final NaverMapService _naverMapService = NaverMapService();
  //make constructer with one Place type parameter
  NavigationProvider(this._ridingCourse);
  //make constructer without parameter
  NavigationProvider.empty();

  Position? _position;
  final Distance _calDistance = const Distance();
  RidingState _ridingState = RidingState.before;

  final PositionStream _positionStream = PositionStream();

  late List<Place> _ridingCourse;
  List<Guide>? _route;
  List<google_map.LatLng> _polylinePoints = [];
  List<google_map.LatLng> get polylinePoints => _polylinePoints;

  late Guide _goalPoint;
  late Place _goalDestination;
  Guide? _nextPoint;
  Place? _nextDestination;
  late Place _finalDestination;
  Timer? _timer;

  Guide get goalPoint => _goalPoint;
  Position? get position => _position;
  List<Guide>? get route => _route;
  RidingState get ridingState => _ridingState;
  List<Place> get course => _ridingCourse;

  void setState(RidingState state) {
    _ridingState = state;
    if (state == RidingState.pause) {
      _timer?.cancel();
    }
    notifyListeners();
  }

  Future<void> getRoute() async {
    _goalDestination = _ridingCourse.first;
    _finalDestination = _ridingCourse.last;
    _nextDestination = _ridingCourse.elementAt(1);

    _position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    Place startPlace = Place(
        id: null,
        title: "내 위치",
        latitude: _position!.latitude.toString(),
        longitude: _position!.longitude.toString(),
        jibunAddress: null);

    _route = await _naverMapService.getRoute(
        startPlace, _finalDestination, _ridingCourse);

    if (_route != null) {
      print("루트 사이즈 : ${_route!.length.toString()}");
      if (_route!.length == 1) {
        _goalPoint = _route![0];
        _nextPoint = null;
      } else {
        _goalPoint = _route![0];
        _nextPoint = _route![1];
      }
    } else {
      print("루트 : null");
    }
    _polyline();
  }

  Future<void> startNavigation() async {
    setState(RidingState.riding);
    _positionStream.controller.stream.listen((pos) {
      _position = pos;
    });

    _timer = Timer.periodic(Duration(seconds: 1), ((timer) {
      _calToPoint();
      _polyline();
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

    if (nextPoint != null) {
      num distanceToPoint = _calDistance.as(
          LengthUnit.Meter,
          LatLng(_position!.latitude, _position!.longitude),
          LatLng(point![1], point[0]));

      // 마지막 지점이 아닐때
      num distanceToNextPoint = _calDistance.as(
          LengthUnit.Meter,
          LatLng(_position!.latitude, _position!.longitude),
          LatLng(nextPoint[1], nextPoint[0]));

      num distancePointToPoint = _calDistance.as(LengthUnit.Meter,
          LatLng(point[1], point[0]), LatLng(nextPoint[1], nextPoint[0]));

      if (distanceToPoint > distancePointToPoint + 10) {
        // 2의 경우
        // c + am
        _calToDestination(); // 다음 경유지 계산해서 만약 다음 경유지가 더 가까우면 사용자 입력 받아서 다음경유지로 안내
        print("1의 경우");
        getRoute();
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
    print(_position.toString());

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

  void _polyline() {
    List<PolylineWayPoint>? turnPoints = _route
        ?.map((route) => PolylineWayPoint(location: route.turnPoint ?? ""))
        .toList();
    List<google_map.LatLng> pointLatLngs = [];

    turnPoints?.forEach((element) {
      List<String> a = element.location.split(',');
      pointLatLngs
          .add(google_map.LatLng(double.parse(a[1]), double.parse(a[0])));
    });

    _polylinePoints = pointLatLngs;
  }
}

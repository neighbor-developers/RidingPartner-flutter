import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as google_map;
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:ridingpartner_flutter/src/models/record.dart';
import 'package:ridingpartner_flutter/src/service/firebase_database_service.dart';
import 'package:ridingpartner_flutter/src/service/shared_preference.dart';
import '../utils/custom_marker.dart';

import '../models/position_stream.dart';
import 'dart:developer' as developer;

enum RidingState { before, riding, pause, stop }

class RidingProvider with ChangeNotifier {
  final Distance _calDistance = const Distance();
  final PositionStream _positionStream = PositionStream();
  final FirebaseDatabaseService _firebaseDb = FirebaseDatabaseService();

  Position? _position;
  RidingState _ridingState = RidingState.before;

  String _ridingDate = "";
  String get ridingDate => _ridingDate;

  late int _startTime; // 라이딩 시작 타임스탬프
  late int _endTime; // 라이딩 중단 타임스탬프
  late int _restartTime = 0; // 라이딩 시작 타임스탬프
  late int _pauseTime = 0; // 라이딩 시작 타임스탬프

  late LatLng _befLatLng;

  late Timer _timer;
  final Stopwatch _stopwatch = Stopwatch();
  late int _befTime;

  //final 붙여도 되나?
  List<google_map.LatLng> _polylineCoordinates = [];
  List<google_map.LatLng> get polylineCoordinates => _polylineCoordinates;
  PolylinePoints polylinePoints = PolylinePoints();

  num _sumDistance = 0.0; // 총거리
  num _speed = 0.0; // 순간 속도
  Duration _time = Duration.zero; // 라이딩 누적 시간

  num get distance => _sumDistance;
  num get speed => _speed;
  Duration get time => _time;
  RidingState get state => _ridingState;
  Position? get position => _position;

  late Uint8List customIcon;
  google_map.BitmapDescriptor pictureIcon =
      google_map.BitmapDescriptor.defaultMarker;

  setRidingState(RidingState state) {
    _ridingState = state;
    notifyListeners();
  }

  Future<void> startRiding() async {
    _befTime = DateTime.now().millisecondsSinceEpoch; // 이전 시간 저장용
    setRidingState(RidingState.riding);

    if (_ridingState == RidingState.pause) {
      // 재시작일때
      _restartTime = _befTime;
    } else {
      _startTime = _befTime;
      _ridingDate =
          DateFormat('yy/MM/dd - HH:mm:ss').format(DateTime.now()); //format변경
    }

    setCustomMarker();

    _positionStream.controller.stream.listen((pos) {
      if (_position == null) {
        _befLatLng = LatLng(pos.latitude, pos.longitude);
      }
      _position = pos;
      _polylineCoordinates
          .add(google_map.LatLng(_position!.latitude, _position!.longitude));
      //addPolyline();
    });
    _stopwatch.start();

    _timer = Timer.periodic(Duration(milliseconds: 10), ((timer) {
      if (_position != null) {
        _calRecord(_position!);
      }
      notifyListeners();
      _time = _stopwatch.elapsed;
      if (_time.inSeconds / 60 == 0) {
        _saveRecord();
      }
    }));
  }

  void _calRecord(Position position) {
    num distance = _calDistance.as(
        LengthUnit.Kilometer,
        LatLng(_befLatLng.latitude, _befLatLng.longitude),
        LatLng(position.latitude, position.longitude));
    _befLatLng = LatLng(position.latitude, position.longitude); // 거리 계산

    _sumDistance += distance; // km
    _speed = distance / 3 * 3600; // k/h
  }

  void _saveRecord() async {
    Record record = Record(
        distance: _sumDistance.toDouble(),
        date: _ridingDate,
        timestamp: _time.inSeconds,
        kcal: 0);
    _firebaseDb.saveRecordFirebaseDb(record);
    PreferenceUtils.saveRecordPref(record);
  }

  void stopAndSaveRiding() {
    setRidingState(RidingState.stop);
    _stopwatch.stop();
    _timer.cancel();

    Record record = Record(
        distance: _sumDistance.toDouble(),
        date: _ridingDate,
        timestamp: _time.inSeconds,
        kcal: 0);
    developer.log(_ridingDate.toString());
    _firebaseDb.saveRecordFirebaseDb(record);
    PreferenceUtils.saveRecordPref(record);
  }

  void pauseRiding() {
    setRidingState(RidingState.pause);
    _stopwatch.stop();
    _timer.cancel();
    _pauseTime = DateTime.now().millisecondsSinceEpoch;
  }

/*  void addPolyline(){
    google_map.Polyline poliline = google_map.Polyline(
      polylineId: const google_map.PolylineId("poly"),
      color: Colors.blue,
      points: polylineCoordinates
    );
    polylines.add();

    notifyListeners();
  }*/
  void setCustomMarker() async {
    customIcon = await CustomMarker().getBytesFromAsset("path", 130);
  }

  void setPictureMarker() {
    pictureIcon = CustomMarker().getPictuerMarker("");
  }
}

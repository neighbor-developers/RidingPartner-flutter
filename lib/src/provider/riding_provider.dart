import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart' as naver;
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:ridingpartner_flutter/src/models/record.dart';
import 'package:ridingpartner_flutter/src/service/firebase_database_service.dart';
import 'package:ridingpartner_flutter/src/service/shared_preference.dart';
import 'package:ridingpartner_flutter/src/utils/user_location.dart';

import '../models/position_stream.dart';

enum RidingState { before, riding, pause, stop, error }

class RidingProvider with ChangeNotifier {
  final Distance _calDistance = const Distance();
  final PositionStream _positionStream = PositionStream();
  final FirebaseDatabaseService _firebaseDb = FirebaseDatabaseService();

  Position? _position;
  RidingState _ridingState = RidingState.before;

  String _ridingDate = "";
  String get ridingDate => _ridingDate;

  bool isDisposed = false;

  late LatLng _befLatLng;

  late Timer _timer;
  final Stopwatch _stopwatch = Stopwatch();
  bool visivility = false;

  //final 붙여도 되나? -> 안돼요
  List<naver.LatLng> _polylineCoordinates = [];
  List<naver.LatLng> get polylineCoordinates => _polylineCoordinates;
  PolylinePoints polylinePoints = PolylinePoints();

  double _sumDistance = 0.0; // 총거리
  double _speed = 0.0; // 순간 속도
  double _topSpeed = 0.0;
  Duration _time = Duration.zero; // 라이딩 누적 시간

  double get distance => _sumDistance;
  double get speed => _speed;
  Duration get time => _time;
  RidingState get state => _ridingState;
  Position? get position => _position;

  Uint8List? customIcon;

  setRidingState(RidingState state) {
    _ridingState = state;
    notifyListeners();
  }

  setMapComponent() {
    notifyListeners();
  }

  void setVisivility() {
    visivility = !visivility;
    notifyListeners();
  }

  @override
  void dispose() {
    isDisposed = true;
    _positionStream.dispose();
    _stopwatch.stop();
    super.dispose();
  }

  Future<void> getLocation() async {
    _position = MyLocation().position;
    try {
      _befLatLng = LatLng(_position!.latitude, position!.longitude);
    } catch (e) {
      if (_position == null) {
        _ridingState = RidingState.error;
      }
    }
  }

  Future<void> startRiding() async {
    if (_ridingState == RidingState.error) {
      notifyListeners();
      return;
    }
    if (_ridingState == RidingState.before) {
      _ridingDate =
          DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()); //format변경
    }
    setRidingState(RidingState.riding);

    _positionStream.controller.stream.listen((pos) {
      _position = pos;
      _polylineCoordinates
          .add(naver.LatLng(_position!.latitude, _position!.longitude));
      notifyListeners();
    });
    _stopwatch.start();

    _timer = Timer.periodic(Duration(seconds: 1), ((timer) {
      if (_position != null) {
        if (_stopwatch.elapsed.inSeconds % 3 == 0) {
          _calRecord(_position!);
        }
      }
      if (isDisposed) return;
      notifyListeners();
      _time = _stopwatch.elapsed;
      if (_time.inSeconds % 60 == 0) {
        _saveRecord();
      }
    }));
  }

  void _calRecord(Position position) {
    num distance = _calDistance.as(
        LengthUnit.Meter,
        LatLng(_befLatLng.latitude, _befLatLng.longitude),
        LatLng(position.latitude, position.longitude));
    _befLatLng = LatLng(position.latitude, position.longitude); // 거리 계산

    _sumDistance += distance; // m
    _speed = distance / 3 * 3.6; // k/h
    if (_topSpeed < _speed) {
      _topSpeed = _speed;
    }
  }

  void _saveRecord() async {
    Record record = Record(
        distance: _sumDistance.toDouble(),
        date: _ridingDate,
        timestamp: _time.inSeconds,
        topSpeed: _topSpeed);
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
        topSpeed: _topSpeed,
        memo: null,
        kcal: null);
    _firebaseDb.saveRecordFirebaseDb(record);
    PreferenceUtils.saveRecordPref(record);
  }

  void pauseRiding() {
    setRidingState(RidingState.pause);
    _stopwatch.stop();
    _timer.cancel();
  }
}

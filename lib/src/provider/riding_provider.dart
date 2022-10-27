import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:ridingpartner_flutter/src/models/record.dart';
import 'package:ridingpartner_flutter/src/service/firebase_database_service.dart';

import '../models/position_stream.dart';

enum RidingState { before, riding, pause, stop }

class RidingProvider with ChangeNotifier {
  final Distance _calDistance = const Distance();
  final PositionStream _positionStream = PositionStream();
  final FirebaseDatabaseService _firebaseDb = FirebaseDatabaseService();

  Position? _position;
  RidingState _ridingState = RidingState.before;

  String _ridingDate = "";
  late int _startTime; // 라이딩 시작 타임스탬프
  late int _endTime; // 라이딩 중단 타임스탬프
  late int _restartTime = 0; // 라이딩 시작 타임스탬프
  late int _pauseTime = 0; // 라이딩 시작 타임스탬프

  late LatLng _befLatLng;

  Timer? _timer;
  final Stopwatch _stopwatch = Stopwatch();
  late int _befTime;

  num _sumDistance = 0.0; // 총거리
  num _speed = 0.0; // 순간 속도
  Duration _time = Duration.zero; // 라이딩 누적 시간

  num get distance => _sumDistance;
  num get speed => _speed;
  Duration get time => _time;
  RidingState get state => _ridingState;
  Position? get position => _position;

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

    _positionStream.controller.stream.listen((pos) {
      if (_position == null) {
        _befLatLng = LatLng(pos.latitude, pos.longitude);
      }
      _position = pos;
    });
    _stopwatch.start();

    _timer = Timer.periodic(Duration(seconds: 1), ((timer) {
      _calRecord(_position!);
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
        distance: _sumDistance,
        date: _ridingDate,
        timestamp: _time.inSeconds,
        kcal: 0);
    _firebaseDb.saveRecordFirebaseDb(record);
  }

  void stopAndSaveRiding() {
    setRidingState(RidingState.stop);
    _stopwatch.stop();
    _timer?.cancel();

    Record record = Record(
        distance: _sumDistance,
        date: _ridingDate,
        timestamp: _time.inSeconds,
        kcal: 0);
    _firebaseDb.saveRecordFirebaseDb(record);
  }

  void pauseRiding() {
    setRidingState(RidingState.pause);
    _stopwatch.stop();
    _timer?.cancel();
    _pauseTime = DateTime.now().millisecondsSinceEpoch;
  }
}

import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:latlong/latlong.dart';
import 'package:ridingpartner_flutter/src/models/record.dart';
import 'package:ridingpartner_flutter/src/service/firebase_database_service.dart';

enum RidingState { before, riding, pause, stop }

class RidingProvider with ChangeNotifier {
  final Distance _calDistance = const Distance();
  final FirebaseDatabaseService _firebaseDb = FirebaseDatabaseService();
  late Position _position;
  RidingState _ridingState = RidingState.before;

  String _ridingDate = "";
  late int _startTime; // 라이딩 시작 타임스탬프
  late int _endTime; // 라이딩 중단 타임스탬프
  late int _restartTime = 0; // 라이딩 시작 타임스탬프
  late int _pauseTime = 0; // 라이딩 시작 타임스탬프

  late LatLng _befLatLng;

  late Timer _timer;
  late Timer _saveTimer;
  late int _befTime;

  num _sumDistance = 0.0; // 총거리
  num _speed = 0.0; // 순간 속도
  int _time = 0; // 라이딩 누적 시간

  num get distance => _sumDistance;
  num get speed => _speed;
  int get time => _time;
  RidingState get state => _ridingState;

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
    _saveRecord(); //파이어베이스 저장 시작

    Geolocator.getPositionStream(desiredAccuracy: LocationAccuracy.high)
        .listen((pos) {
      _position = pos;
    });
    _befLatLng = LatLng(_position.latitude, _position.longitude);

    _timer = Timer.periodic(Duration(seconds: 1), ((timer) {
      _time++; // 1초마다 noti, 3초마다 데이터 계산
      if (_time / 3 == 0) {
        _calRecord(_position);
      }
      notifyListeners();
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

  Future<void> _saveRecord() async {
    _saveTimer = Timer.periodic(Duration(minutes: 1), ((timer) {
      Record record = Record(
          distance: _sumDistance, date: _ridingDate, timestamp: _time, kcal: 0);
      _firebaseDb.saveRecordFirebaseDb(record);
    }));
  }

  void stopAndSaveRiding() {
    setRidingState(RidingState.stop);
    _timer.cancel();
    _saveTimer.cancel();
    _endTime = DateTime.now().millisecondsSinceEpoch;
    if (_restartTime != 0) {
      _time = _endTime - _startTime;
    } else {
      _time = (_pauseTime - _startTime) + (_endTime - _restartTime);
    }
    Record record = Record(
        distance: _sumDistance, date: _ridingDate, timestamp: _time, kcal: 0);
    _firebaseDb.saveRecordFirebaseDb(record);
  }

  void pauseRiding() {
    setRidingState(RidingState.pause);
    _timer.cancel();
    _saveTimer.cancel();
    _pauseTime = DateTime.now().millisecondsSinceEpoch;
  }
}

import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:latlong/latlong.dart';
import 'package:ridingpartner_flutter/src/service/firebase_database_service.dart';

class RidingProvider with ChangeNotifier {
  final Distance _calDistance = const Distance();
  final FirebaseDatabaseService _firebaseDb = FirebaseDatabaseService();
  late Position _position;

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

  Future<void> startRiding(bool re) async {
    _befTime = DateTime.now().millisecondsSinceEpoch; // 이전 시간 저장용

    if (re) {
      // 재시작일때
      _restartTime = _befTime;
    } else {
      _startTime = _befTime;
      _ridingDate =
          DateFormat('yy/MM/dd - HH:mm:ss').format(DateTime.now()); //format변경
    }
    saveRidingRecord(); //파이어베이스 저장 시작

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    _befLatLng = LatLng(position.latitude, position.longitude); // 시작 위치 선언

    _timer = Timer.periodic(Duration(seconds: 1), ((timer) {
      _time++; // 1초마다 noti, 3초마다 데이터 계산
      if (_time / 3 == 0) {
        Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
            .then((value) => {calRecord(value)});
      }
      notifyListeners();
    }));

    //  Geolocator.getPositionStream(desiredAccuracy: LocationAccuracy.high)
    //     .listen((pos) {
    //   pos = _position;
    // });
    // _befLatLng = LatLng(_position.latitude, _position.longitude);

    // _timer = Timer.periodic(Duration(seconds: 1), ((timer) {
    //   _time++; // 1초마다 noti, 3초마다 데이터 계산
    //   if (_time / 3 == 0) {
    //     calRecord(_position);
    //   }
    //   notifyListeners();
    // }));
  }

  void calRecord(Position position) {
    num distance = _calDistance.as(
        LengthUnit.Kilometer,
        LatLng(_befLatLng.latitude, _befLatLng.longitude),
        LatLng(position.latitude, position.longitude));
    _befLatLng = LatLng(position.latitude, position.longitude); // 거리 계산

    _sumDistance += distance; // km
    _speed = distance / 3 * 3600; // k/h
  }

  Future<void> saveRidingRecord() async {
    _saveTimer = Timer.periodic(Duration(minutes: 1), ((timer) {
      _firebaseDb.saveRealTimeRecord(
          _ridingDate, _time, _sumDistance); //1분마다 실시간 저장
    }));
  }

  void stopAndSaveRiding() {
    _timer.cancel();
    _saveTimer.cancel();
    _endTime = DateTime.now().millisecondsSinceEpoch;
    if (_restartTime != 0) {
      _time = _endTime - _startTime;
    } else {
      _time = (_pauseTime - _startTime) + (_endTime - _restartTime);
    }
    _firebaseDb.saveRealTimeRecord(_ridingDate, _time, _sumDistance);
  }

  void pauseRiding() {
    _timer.cancel();
    _saveTimer.cancel();
    _pauseTime = DateTime.now().millisecondsSinceEpoch;
  }
}

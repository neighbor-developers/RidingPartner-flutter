import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../models/place.dart';
import '../models/route.dart';
import '../service/background_location_service.dart';
import '../service/find_route_service.dart';
import '../service/naver_map_service.dart';
import '../utils/latlng_from_guide.dart';

class NavigationData {
  final SearchRouteState state;
  final List<Guide> guides;
  final int sumDistance;
  final List<int> distances;

  NavigationData(
      {required this.state,
      required this.guides,
      required this.sumDistance,
      required this.distances});
}

enum SearchRouteState { loading, fail, empty, success, locationFail }

final remainDistance = StateProvider((ref) => 0);

class RouteProvider extends StateNotifier<NavigationData> {
  RouteProvider()
      : super(NavigationData(
            state: SearchRouteState.loading,
            guides: [],
            sumDistance: 0,
            distances: []));

  // Position? pos
  final Distance calDistance = const Distance();

  Place? _goalDestination;
  Place? _nextDestination;
  Guide _currentGuide = Guide();

  int _remainedDistance = 0;
  List<Place> _course = [];

  int get remainedDistance => _remainedDistance;
  List<Place> get course => _course;
  Guide get currentGuide => _currentGuide;
  // 위치 정보 스트림
  StreamSubscription<Position>? _positionStream;
  Timer? _timer;

  @override
  set state(NavigationData value) {
    super.state = value;
  }

  setLocationError() {
    state = NavigationData(
        state: SearchRouteState.locationFail,
        guides: [],
        sumDistance: 0,
        distances: []);
  }

  void getRoute(List<Place> places) async {
    _course = places;

    final address = await FindRouteService().getMyLocationAddress();
    List<Place> result = (await NaverMapService().getPlaces(address));

    if (result.isEmpty) {
      setLocationError();
      return;
    }
    Place myLocation = result[0];
    if (places.length == 1) {
      // 명소, 검색
      _goalDestination = places[0];
    } else if (places.length == 2) {
      // 코스
      _goalDestination = places[0];
      _nextDestination = places[1];
    } else {
      _goalDestination = places[0];
      _nextDestination = places[1];
    }

    Map<String, dynamic> response;

    List<Place> list = <Place>[myLocation];
    list.addAll(places);

    response = await NaverMapService().getRoute(list);

    int sum = 0;

    _remainedDistance = response['data']['sumdistance'];
    if (sum < response['data']['sumdistance']) {
      sum = response['data']['sumdistance'];
    } else {
      sum = state.sumDistance;
    }

    NavigationData data = NavigationData(
        state: response['result'],
        guides: response['data']['guides'],
        sumDistance: sum,
        distances: response['data']['distances']);

    state = data;
  }

  startNav() {
    Position? pos;
    _positionStream =
        BackgroundLocationService().positionStream!.listen((event) {
      pos = event;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (pos != null) {
        calToPoint(pos!);
      }
    });
  }

  void calToPoint(Position pos) {
    LatLng? point = latLngFromGuide(state.guides.first);
    LatLng? nextLatLng = latLngFromGuide(state.guides[1]);

    if (nextLatLng != null) {
      num distanceToPoint = calDistance.as(
          LengthUnit.Meter, LatLng(pos.latitude, pos.longitude), point!);

      // 마지막 지점이 아닐때
      num distanceToNextPoint = calDistance.as(
          LengthUnit.Meter, LatLng(pos.latitude, pos.longitude), nextLatLng);

      if (distanceToPoint > distanceToNextPoint) {
        if (_nextDestination != null) {
          _calToDestination(
              pos); // 다음 경유지 계산해서 만약 다음 경유지가 더 가까우면 사용자 입력 받아서 다음경유지로 안내
        }
        getRoute(_course);
      } else {
        List<Guide> guide = [...state.guides];
        List<int> dis = [...state.distances];
        if (distanceToPoint <= 5) {
          // 턴 포인트 도착이거나 a > b일때
          _isDestination(pos); // 경유지인지 확인
          guide.removeAt(0);
          _currentGuide = guide.first;

          _remainedDistance -= dis.last;
          dis.removeLast();
          state = NavigationData(
              state: SearchRouteState.success,
              guides: guide,
              sumDistance: state.sumDistance,
              distances: dis);
        }
      }
    }
  }

  void _isDestination(Position pos) {
    num distanceToDestination = calDistance.as(
        LengthUnit.Meter,
        LatLng(pos.latitude, pos.longitude),
        LatLng(_goalDestination!.location.latitude,
            _goalDestination!.location.longitude));

    if (distanceToDestination < 10) {
      if (_course.length < 2) {
        // 최종 목적지 도착!
      } else if (_course.length == 2) {
        _course.removeAt(0);
        _goalDestination = _course[0];
        _nextDestination = null;
      } else {
        _course.removeAt(0);
        _goalDestination = _course[0];
        _nextDestination = _course[1];
      }
    }
  }

  void _calToDestination(Position pos) {
    num distanceToDestination = calDistance.as(
        LengthUnit.Meter,
        LatLng(pos.latitude, pos.longitude),
        LatLng(_goalDestination!.location.latitude,
            _goalDestination!.location.longitude));

    num distanceToNextDestination = calDistance.as(
        LengthUnit.Meter,
        LatLng(pos.latitude, pos.longitude),
        LatLng(_nextDestination!.location.latitude,
            _nextDestination!.location.longitude));

    if (distanceToDestination > distanceToNextDestination) {
      _course.removeAt(0);
      getRoute(_course);
    }
  }

  stopNav() {
    _timer?.cancel();
    _positionStream?.cancel();
  }

  restartNav() {
    startNav();
  }
}

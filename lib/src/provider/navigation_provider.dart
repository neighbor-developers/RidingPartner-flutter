import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:ridingpartner_flutter/src/provider/position_provider.dart';
import 'package:ridingpartner_flutter/src/service/background_location_service.dart';

import '../models/place.dart';
import '../models/route.dart';
import '../screen/riding_screen.dart';
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
  Place? _finalDestination;
  Place? _nextDestination;

  int _remainedDistance = 0;
  int _totalDistance = 0;
  List<Place> _course = [];
  late Timer timer;

  late Provider posProvider;

  int get remainedDistance => _remainedDistance;
  int get totalDistance => _totalDistance;
  List<Place> get course => _course;
  // 위치 정보 스트림

  @override
  set state(NavigationData value) {
    // TODO: implement state
    super.state = value;
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    timer.cancel();
  }

  void getRoute(List<Place> places) async {
    _course = places;
    final address = await FindRouteService().getMyLocationAddress();
    List<Place> result = (await NaverMapService().getPlaces(address));
    Place myLocation = result[0];

    _goalDestination = places[0];
    if (places.length > 2) {
      _nextDestination = places[1];
    }
    _finalDestination = places.last;

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
    BackgroundLocationService();

    posProvider = Provider((ref) {
      final position = ref.watch(positionProvider);
      if (position != null) {
        calToPoint(position);
      }
      state = state;
    });

    // timer = Timer.periodic(Duration(seconds: 1), (timer) {
    //   state = state;
    // });
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

      num distancePointToPoint =
          calDistance.as(LengthUnit.Meter, point, nextLatLng);

      if (distanceToPoint > distancePointToPoint + 10) {
        // 2의 경우
        // c + am
        if (_nextDestination != null) {
          _calToDestination(
              pos); // 다음 경유지 계산해서 만약 다음 경유지가 더 가까우면 사용자 입력 받아서 다음경유지로 안내
        }
        getRoute(_course);
      } else {
        if (distanceToPoint <= 10 ||
            distanceToPoint > distanceToNextPoint + 50) {
          // 턴 포인트 도착이거나 a > b일때
          _isDestination(pos); // 경유지인지 확인
          if (state.guides.length == 2) {
            state.guides.removeAt(0);

            _remainedDistance -= state.distances.last;
            state.distances.removeLast();
          } else {
            state.guides.removeAt(0);

            _remainedDistance -= state.distances.last;
            state.distances.removeLast();
          }
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
      if (_course.length == 1) {
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
      // 다음 경유지로 안내할까요?
      // ok ->
      if (true) {
        _course.removeAt(0);
      }
    }
  }
}

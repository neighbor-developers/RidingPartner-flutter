import 'dart:convert';
import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as google_map;
import 'package:http/http.dart' as http;
import 'package:ridingpartner_flutter/src/models/place.dart';
import 'package:ridingpartner_flutter/src/utils/user_location.dart';

import '../models/route.dart';
import '../service/naver_map_service.dart';

class MapSearchProvider extends ChangeNotifier {
  var isStartSearching = false;
  var isEndSearching = false;
  var searchBoxVisible = false;

  final NaverMapService _naverMapService = NaverMapService();
  final kakaoKey = dotenv.env['KAKAO_REST_API_KEY'];

  List<Place> _startPointSearchResult = [];
  List<Place> get startPointSearchResult => _startPointSearchResult;

  List<Place> _destinationSearchResult = [];
  List<Place> get destinationSearchResult => _destinationSearchResult;

  Place? _startPoint;
  Place? get startPoint => _startPoint;

  Place? _destination;
  Place? get destination => _destination;

  Position? _myPosition;
  Position? get myPosition => _myPosition;

  List<Guide> route = [];

  List<google_map.LatLng> _polylinePoints = [];
  List<google_map.LatLng> get polylinePoints => _polylinePoints;

  Place? _myLocation;

  String myLocationAddress = "";

  setStartPoint(Place place) {
    _startPoint = place;
    notifyListeners();
  }

  newPage() {
    _startPoint = null;
    _destination = null;
    _startPointSearchResult = [];
    _destinationSearchResult = [];
    _polylinePoints = [];
    route = [];
  }

  setEndPoint(Place place) {
    _destination = place;
    notifyListeners();
  }

  searchPlace(value, type) async {
    if (type == '출발지') {
      setStartPointSearchResult(value);
    } else {
      setEndPointSearchResult(value);
    }
  }

  Future<String> getMyLocationAddress() async {
    final myLocation = MyLocation();
    myLocation.getMyCurrentLocation();
    _myPosition = myLocation.position;
    final lat = myLocation.position!.latitude;
    final lon = myLocation.position!.longitude;
    final url =
        "https://dapi.kakao.com/v2/local/geo/coord2address.json?x=$lon&y=$lat&input_coord=WGS84";
    Map<String, String> requestHeaders = {'Authorization': 'KakaoAK $kakaoKey'};
    final response = await http.get(Uri.parse(url), headers: requestHeaders);
    final address = json.decode(response.body)['documents'][0]['address']
            ['address_name'] ??
        '';
    myLocationAddress = address;
    return address;
  }

  setStartPointSearchResult(String title) async {
    _startPointSearchResult = (await _naverMapService.getPlaces(title)) ?? [];
    if (_startPointSearchResult.isNotEmpty) {
      isStartSearching = true;
    } else {
      isStartSearching = false;
    }
    notifyListeners();
  }

  setEndPointSearchResult(String title) async {
    _destinationSearchResult = (await _naverMapService.getPlaces(title)) ?? [];
    if (_destinationSearchResult.isNotEmpty) {
      isEndSearching = true;
    } else {
      isEndSearching = false;
    }

    notifyListeners();
  }

  removeStartPoint() {
    _startPoint = null;
    notifyListeners();
  }

  removeDestination() {
    _destination = null;
    notifyListeners();
  }

  clearStartPointSearchResult() {
    _startPointSearchResult = [];
    isStartSearching = false;
    notifyListeners();
  }

  clearEndPointSearchResult() {
    _destinationSearchResult = [];
    isEndSearching = false;
    notifyListeners();
  }

  clearPolyLine() {
    _polylinePoints = [];
    notifyListeners();
  }

  setInitalLocation() async {
    developer.log('initial location');
    final address = await getMyLocationAddress();
    setMyLocation(address);
  }

  setMyLocation(address) async {
    List<Place> tmpResult = (await NaverMapService().getPlaces(address)) ?? [];
    _myLocation = tmpResult[0];
    myLocationAddress = _myLocation!.title!;
    _myLocation!.title = "내 위치";
    setStartPoint(_myLocation!);
    notifyListeners();
  }

  void polyline(Place startPlace, Place finalDestination) async {
    List<Place> ridingCourse = [finalDestination];
    Map<String, dynamic> response = await _naverMapService
        .getRoute(startPlace, finalDestination, ridingCourse)
        .catchError((onError) {
      return {'result': 'fail'};
    });

    final result = response['result'];

    if (result != 'fail') {
      response = response['data'];

      route = response['guides'];
      List<PolylineWayPoint>? turnPoints = route
          .map((route) => PolylineWayPoint(location: route.turnPoint ?? ""))
          .toList();
      List<google_map.LatLng> pointLatLngs = [];

      turnPoints.forEach((element) {
        List<String> a = element.location.split(',');
        pointLatLngs
            .add(google_map.LatLng(double.parse(a[1]), double.parse(a[0])));
      });

      _polylinePoints = pointLatLngs;
      notifyListeners();
    }
  }
}

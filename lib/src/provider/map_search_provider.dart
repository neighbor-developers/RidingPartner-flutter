import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:ridingpartner_flutter/src/models/place.dart';
import 'package:ridingpartner_flutter/src/utils/user_location.dart';
import '../service/naver_map_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:developer' as developer;

class MapSearchProvider extends ChangeNotifier {
  var isStartSearching = false;
  var isEndSearching = false;
  final NaverMapService _naverMapService = NaverMapService();
  final kakaoKey = dotenv.env['KAKAO_REST_API_KEY'];

  List<Place> _startPointSearchResult = [];
  List<Place> get startPointSearchResult => _startPointSearchResult;

  List<Place> _endPointSearchResult = [];
  List<Place> get endPointSearchResult => _endPointSearchResult;

  Place? _startPoint;
  Place? get startPoint => _startPoint;

  Place? _endPoint;
  Place? get endPoint => _endPoint;

  Place? _myLocation;
  Position? _myPosition;
  Position? get myPosition => _myPosition;

  setStartPoint(Place place) {
    _startPoint = place;
    notifyListeners();
  }

  setEndPoint(Place place) {
    _endPoint = place;
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
    final lat = myLocation.latitude;
    final lon = myLocation.longitude;
    final url =
        "https://dapi.kakao.com/v2/local/geo/coord2address.json?x=$lon&y=$lat&input_coord=WGS84";
    Map<String, String> requestHeaders = {'Authorization': 'KakaoAK $kakaoKey'};
    final response = await http.get(Uri.parse(url), headers: requestHeaders);
    final address = json.decode(response.body)['documents'][0]['address']
            ['address_name'] ??
        '';
    developer.log(address);
    return address;
  }

  setStartPointSearchResult(String title) async {
    _startPointSearchResult = (await _naverMapService.getPlaces(title)) ?? [];
    if (_startPointSearchResult.isNotEmpty) {
      isStartSearching = true;
      if (_myLocation != null) {
        _startPointSearchResult.insert(0, _myLocation!);
      }
    } else {
      isStartSearching = false;
    }
    notifyListeners();
  }

  setEndPointSearchResult(String title) async {
    _endPointSearchResult = (await _naverMapService.getPlaces(title)) ?? [];
    if (_endPointSearchResult.isNotEmpty) {
      isEndSearching = true;
      if (_myLocation != null) {
        _endPointSearchResult.insert(0, _myLocation!);
      }
    } else {
      isEndSearching = false;
    }
    notifyListeners();
  }

  setMyLocationOnly(type) {
    if (type == '출발지') {
      _startPointSearchResult = [];
      _startPointSearchResult.add(_myLocation!);
      isStartSearching = true;
    } else {
      _endPointSearchResult = [];
      _endPointSearchResult.add(_myLocation!);
      isEndSearching = true;
    }
    notifyListeners();
  }

  setMyLocation(address) async {
    List<Place> tmpResult = (await _naverMapService.getPlaces(address)) ?? [];
    _myLocation = tmpResult[0];
    _myLocation!.title = "내 위치";
    notifyListeners();
  }

  clearStartPointSearchResult() {
    _startPointSearchResult = [];
    isStartSearching = false;
    notifyListeners();
  }

  clearEndPointSearchResult() {
    _endPointSearchResult = [];
    isEndSearching = false;
    notifyListeners();
  }
}

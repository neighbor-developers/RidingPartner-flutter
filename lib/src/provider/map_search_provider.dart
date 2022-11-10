import 'dart:convert';
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
  Place? get myLocation => _myLocation;

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
    _startPointSearchResult = (await NaverMapService().getPlaces(title)) ?? [];
    if (_startPointSearchResult.isNotEmpty) {
      isStartSearching = true;
    } else {
      isStartSearching = false;
    }
    notifyListeners();
  }

  setEndPointSearchResult(String title) async {
    _endPointSearchResult = (await NaverMapService().getPlaces(title)) ?? [];
    if (_endPointSearchResult.isNotEmpty) {
      isEndSearching = true;
    } else {
      isEndSearching = false;
    }
    notifyListeners();
  }

  setMyLocation(address) async {
    List<Place> tmpResult = (await NaverMapService().getPlaces(address)) ?? [];
    _myLocation = tmpResult[0];
    developer.log(tmpResult[2].title.toString());
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

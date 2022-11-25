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

  List<Place> _destinationSearchResult = [];
  List<Place> get destinationSearchResult => _destinationSearchResult;

  Place? _destination;
  Place? get destination => _destination;

  Place? _myLocation;
  Position? _myPosition;
  Position? get myPosition => _myPosition;

  setEndPoint(Place place) {
    _destination = place;
    notifyListeners();
  }

  searchPlace(value, type) async {
    setEndPointSearchResult(value);
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
    developer.log(address);
    return address;
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

  clearEndPointSearchResult() {
    _destinationSearchResult = [];
    isEndSearching = false;
    notifyListeners();
  }
}

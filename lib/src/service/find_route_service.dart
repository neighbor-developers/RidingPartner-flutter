import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:ridingpartner_flutter/src/models/place.dart';
import 'package:ridingpartner_flutter/src/models/route.dart';
import 'package:ridingpartner_flutter/src/service/naver_map_service.dart';

import '../provider/navigation_provider.dart';
import 'location_service.dart';
import 'package:http/http.dart' as http;

class FindRouteService {
  final kakaoKey = dotenv.env['KAKAO_REST_API_KEY'];

  Future<String> getMyLocationAddress() async {
    final myLocation = MyLocation();
    myLocation.getMyCurrentLocation();
    if (myLocation.position == null) return '';
    final lat = myLocation.position!.latitude;
    final lon = myLocation.position!.longitude;
    final url =
        "https://dapi.kakao.com/v2/local/geo/coord2address.json?x=$lon&y=$lat&input_coord=WGS84";
    Map<String, String> requestHeaders = {'Authorization': 'KakaoAK $kakaoKey'};
    final response = await http.get(Uri.parse(url), headers: requestHeaders);
    if (((json.decode(response.body)['documents']) as List).isNotEmpty) {
      return json.decode(response.body)['documents'][0]['address']
              ['address_name'] ??
          '';
    } else {
      return '';
    }
  }

  Future<List<Guide>> getRoute(Place start, Place destination) async {
    final result = await NaverMapService().getRoute([start, destination]);
    if (result['result'] == SearchRouteState.success) {
      return result['data']['guides'];
    } else {
      return [];
    }
  }
}

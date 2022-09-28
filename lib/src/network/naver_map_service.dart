import 'dart:convert';
import 'package:ridingpartner_flutter/src/utils/user_location.dart';
import 'package:http/http.dart' as http;
import 'dart:developer' as developer;
import '../models/place.dart';

class NaverMapService {
  final String naverMapUrl = "map.naver.com";

  Future<List<Place>?> getPlaces(String title) async {
    try {
      var place = [Place()];
      final myLocation = MyLocation(); // 자신의 위치를 기반으로 위치 검색
      final Map<String, String> queryParams = {
        'coords': '${myLocation.longitude},${myLocation.latitude}',
        'query': title,
      };

      final requestUrl =
          Uri.https(naverMapUrl, '/v5/api/instantSearch', queryParams);
      var response = await http.get(requestUrl);
      developer.log(requestUrl.toString());

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        var placeData = NaverPlaceData.fromJson(jsonResponse);
        place = placeData.place!
            .map<Place>((place) => Place(
                id: place.id,
                title: place.title,
                latitude: place.y,
                longitude: place.x,
                jibunAddress: place.jibunAddress,
                roadAddress: place.roadAddress))
            .toList();

        return place;
      } else {
        return place;
      }
    } catch (e) {
      developer.log(e.toString());
      throw Exception(e.toString());
    }
  }
}

import 'dart:convert';
import 'package:ridingpartner_flutter/src/utils/user_location.dart';
import 'package:http/http.dart' as http;
import 'dart:developer' as developer;
import '../models/place.dart';
import '../models/route.dart';

class NaverMapService {
  final String _naverMapUrl = "map.naver.com";

  Future<List<Place>?> getPlaces(String title) async {
    try {
      var place = [Place()];
      final myLocation = MyLocation(); // 자신의 위치를 기반으로 위치 검색
      await myLocation.getMyCurrentLocation();
      final Map<String, String> queryParams = {
        'coords': '${myLocation.latitude},${myLocation.longitude}',
        'query': title,
      };

      final requestUrl =
          Uri.https(_naverMapUrl, '/v5/api/instantSearch', queryParams);

      developer.log("1 ${requestUrl.toString()}");
      var response = await http.get(requestUrl);
      developer.log("2 ${requestUrl.toString()}");

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);

        developer.log("3 ");
        var placeData = NaverPlaceData.fromJson(jsonResponse);

        if (placeData.place != null) {
          developer.log("place called");
          place = placeData.place!
              .map<Place>((place) => Place(
                  id: place.id,
                  title: place.title,
                  latitude: place.y,
                  longitude: place.x,
                  jibunAddress: place.jibunAddress,
                  roadAddress: place.roadAddress))
              .toList();
        }
        if (place.isEmpty) {
          developer.log("else called");
          place = placeData.address!
              .map<Place>((address) => Place(
                  id: address.id,
                  title: address.title,
                  latitude: address.y,
                  longitude: address.x,
                  jibunAddress: address.fullAddress,
                  roadAddress: address.fullAddress))
              .toList();
        }

        return place;
      } else {
        return place;
      }
    } catch (e) {
      developer.log(e.toString());
      throw Exception(e.toString());
    }
  }

  Future<List<Guide>?> getRoute(
      Place start, Place destination, List<Place>? waypoints) async {
    try {
      var guides = [Guide()];

      String placeToParam(Place place) =>
          '${place.longitude},placeid=${place.latitude},name=${place.id}';

      final Map<String, String> queryParams = {
        'start': placeToParam(start),
        'destination': placeToParam(destination),
      };

      if (waypoints!.isNotEmpty) {
        queryParams['waypoints'] = waypoints.map(placeToParam).join('|');
      }

      final requestUrl =
          Uri.https(_naverMapUrl, 'v5/api/dir/findbicycle', queryParams);
      var response = await http.get(requestUrl);
      developer.log(requestUrl.toString());

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        var routeData = NaverRouteData.fromJson(jsonResponse);
        guides = routeData.routes!
            .expand<Legs>((rou) => rou.legs!)
            .expand((leg) => leg.steps!)
            .map((step) => step.guide!)
            .toList();

        return guides;
      } else {
        return guides;
      }
    } catch (e) {
      developer.log(e.toString());
      throw Exception(e.toString());
    }
  }
}

import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:ridingpartner_flutter/src/service/location_service.dart';

import '../models/place.dart';
import '../models/route.dart';
import '../provider/navigation_provider.dart';

class NaverMapService {
  final String _naverMapUrl = "map.naver.com";

  static final NaverMapService _naverMapService = NaverMapService._internal();
  factory NaverMapService() {
    return _naverMapService;
  }
  NaverMapService._internal();

  Future<List<Place>> getPlaces(String title) async {
    try {
      var place = <Place>[];
      final position = MyLocation().position; // 자신의 위치를 기반으로 위치 검색

      final Map<String, String> queryParams = {
        'coords': '${position!.latitude},${position.longitude}',
        'query': title,
      };

      final requestUrl =
          Uri.https(_naverMapUrl, '/v5/api/instantSearch', queryParams);

      var response = await http.get(requestUrl);

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);

        var placeData = NaverPlaceData.fromJson(jsonResponse);

        if (placeData.place != null) {
          place = placeData.place!
              .map<Place>((place) => Place(
                  id: place.id!,
                  title: place.title!,
                  location:
                      LatLng(double.parse(place.y!), double.parse(place.x!)),
                  jibunAddress: place.jibunAddress!,
                  roadAddress: place.roadAddress))
              .toList();
        }
        if (place.isEmpty) {
          place = placeData.address!
              .map<Place>((address) => Place(
                  id: address.id,
                  title: address.title,
                  location:
                      LatLng(double.parse(address.y), double.parse(address.x)),
                  jibunAddress: address.fullAddress!,
                  roadAddress: address.fullAddress))
              .toList();
        }

        return place;
      } else {
        return place;
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<Map<String, dynamic>> getRoute(List<Place> places) async {
    try {
      List<Guide> guides = [];
      List<int> distances = [];
      int sumDistance = 0;

      String placeToParam(Place place) =>
          '${place.location.longitude},${place.location.latitude},placeid=${place.id},name=${place.title}';

      final Map<String, String> queryParams = {
        'start': placeToParam(places[0]),
        'destination': placeToParam(places.last),
      };

      if (places.length > 2) {
        final waypoints = places.sublist(1, places.length - 1);
        queryParams['waypoints'] = waypoints.map(placeToParam).join('|');
      }

      final requestUrl =
          Uri.https(_naverMapUrl, 'v5/api/dir/findbicycle', queryParams);

      var response = await http.get(requestUrl);

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        var routeData = NaverRouteData.fromJson(jsonResponse);
        if (routeData.routes != null && routeData.routes != []) {
          guides = routeData.routes!
              .expand<Legs>((rou) => rou.legs!)
              .expand((leg) => leg.steps!)
              .map((step) => step.guide!)
              .toList();
          distances = routeData.routes!
              .expand<Legs>((rou) => rou.legs!)
              .expand((leg) => leg.steps!)
              .map((step) => step.summary!.distance!)
              .toList();

          sumDistance = routeData.routes![0].summary!.distance!;

          Map<String, dynamic> routes = {
            'sumdistance': sumDistance,
            'guides': guides,
            'distances': distances
          };
          return {'result': SearchRouteState.success, 'data': routes};
        } else {
          return {'result': SearchRouteState.empty};
        }
      } else {
        return {'result': SearchRouteState.fail};
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}

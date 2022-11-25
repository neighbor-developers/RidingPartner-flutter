import 'dart:convert';
import 'package:ridingpartner_flutter/src/utils/user_location.dart';
import 'package:http/http.dart' as http;
import 'dart:developer' as developer;
import '../models/place.dart';
import '../models/route.dart';

class NaverMapService {
  final String _naverMapUrl = "map.naver.com";
  NaverMapService();

  Future<List<Place>?> getPlaces(String title) async {
    try {
      var place = <Place>[];
      final myLocation = MyLocation(); // 자신의 위치를 기반으로 위치 검색
      if (myLocation.position!.latitude == null ||
          myLocation.position!.longitude == null) {
        await myLocation.getMyCurrentLocation();
      }
      final Map<String, String> queryParams = {
        'coords':
            '${myLocation.position!.latitude},${myLocation.position!.longitude}',
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

  Future<Map<String, dynamic>?> getRoute(
      Place start, Place destination, List<Place>? waypoints) async {
    try {
      List<Guide> guides = [];
      List<int> distances = [];
      int sumDistance = 0;

      String placeToParam(Place place) =>
          '${place.longitude},${place.latitude},placeid=${place.id},name=${place.title}';

      final Map<String, String> queryParams = {
        'start': placeToParam(start),
        'destination': placeToParam(destination),
      };

      if (waypoints != null && waypoints.isNotEmpty) {
        queryParams['waypoints'] = waypoints.map(placeToParam).join('|');
      }

      final requestUrl =
          Uri.https(_naverMapUrl, 'v5/api/dir/findbicycle', queryParams);

      developer.log(requestUrl.toString());
      var response = await http.get(requestUrl);

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        var routeData = NaverRouteData.fromJson(jsonResponse);
        if (routeData.routes != null) {
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
        } else {
          print("routeData.routes = null");
        }
        Map<String, dynamic> routes = {
          'sumdistance': sumDistance,
          'guides': guides,
          'distances': distances
        };

        return routes;
      } else {
        print("가이드 잘 안왔음");
        return null;
      }
    } catch (e) {
      developer.log(e.toString());
      throw Exception(e.toString());
    }
  }
}

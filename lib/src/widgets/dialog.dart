import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../pages/bottom_nav.dart';
import '../provider/bottom_navigation_provider.dart';
import '../provider/home_record_provider.dart';
import '../provider/map_search_provider.dart';
import '../provider/place_list_provider.dart';
import '../provider/riding_provider.dart';
import '../provider/route_list_provider.dart';
import '../provider/sights_provider.dart';
import '../provider/weather_provider.dart';

Future<bool> backDialog(BuildContext context, String text) async {
  return await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0)),
            title: Column(children: [Text("뒤로가기")]),
            content: Column(children: [Text(text)]),
            actions: <Widget>[
              TextButton(
                  onPressed: () {
                    Navigator.pop(context, false);
                  },
                  child: Text("취소")),
              TextButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (context) => MultiProvider(providers: [
                                  ChangeNotifierProvider(
                                      create: (context) => SightsProvider()),
                                  ChangeNotifierProvider(
                                      create: (context) => WeatherProvider()),
                                  ChangeNotifierProvider(
                                      create: (context) => RouteListProvider()),
                                  ChangeNotifierProvider(
                                      create: (context) =>
                                          BottomNavigationProvider()),
                                  ChangeNotifierProvider(
                                      create: (context) => MapSearchProvider()),
                                  ChangeNotifierProvider(
                                      create: (context) => RidingProvider()),
                                  ChangeNotifierProvider(
                                      create: (context) => PlaceListProvider()),
                                  ChangeNotifierProvider(
                                      create: (context) => HomeRecordProvider())
                                ], child: BottomNavigation())),
                        (route) => false);
                  },
                  child: Text("확인")),
            ],
          ));
}

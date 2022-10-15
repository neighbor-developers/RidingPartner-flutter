import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ridingpartner_flutter/src/pages/map_page.dart';
import 'package:ridingpartner_flutter/src/pages/navigation_page.dart';
import 'package:ridingpartner_flutter/src/pages/recommended_route_page.dart';
import 'package:ridingpartner_flutter/src/pages/riding_page.dart';
import 'package:ridingpartner_flutter/src/pages/weather_page.dart';
import 'package:ridingpartner_flutter/src/provider/bottom_navigation_provider.dart';

import '../models/place.dart';

class HomePage extends StatelessWidget {
  HomePage({Key? key}) : super(key: key);
  late BottomNavigationProvider _bottomNavigationProvider;

  @override
  Widget build(BuildContext context) {
    _bottomNavigationProvider = Provider.of<BottomNavigationProvider>(context);

    return Scaffold(
      body: SafeArea(
        child: [
          NavigationPage([
            Place(title: "", latitude: "126.7433065", longitude: "37.3400342"),
            Place(latitude: "126.8343379", longitude: "37.3823899")
          ]),
          RecommendedRoutePage(),
          WeatherPage(),
          MapSample(),
          RidingPage(),
        ].elementAt(_bottomNavigationProvider.currentPage),
      ),
      bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.pedal_bike),
              label: '대여소',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.flag),
              label: '추천경로',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: '홈',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.map),
              label: '지도',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: '설정',
            ),
          ],
          currentIndex: _bottomNavigationProvider.currentPage,
          selectedItemColor: Colors.lightGreen,
          onTap: (index) {
            _bottomNavigationProvider.setCurrentPage(index);
          }),
    );
  }
}

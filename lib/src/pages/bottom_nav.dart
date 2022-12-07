import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ridingpartner_flutter/src/pages/map_search_page.dart';
import 'package:ridingpartner_flutter/src/pages/navigation_page.dart';
import 'package:ridingpartner_flutter/src/pages/recommended_route_page.dart';
import 'package:ridingpartner_flutter/src/pages/sights_page.dart';
import 'package:ridingpartner_flutter/src/pages/riding_page.dart';
import 'package:ridingpartner_flutter/src/pages/home_page.dart';
import 'package:ridingpartner_flutter/src/provider/bottom_navigation_provider.dart';
import 'package:ridingpartner_flutter/src/provider/riding_provider.dart';

import '../models/place.dart';

class BottomNavigation extends StatelessWidget {
  BottomNavigation({Key? key}) : super(key: key);
  late BottomNavigationProvider _bottomNavigationProvider;

  @override
  Widget build(BuildContext context) {
    _bottomNavigationProvider = Provider.of<BottomNavigationProvider>(context);

    return Scaffold(
      body: SafeArea(
        child: [
          SightsPage(),
          RecommendedRoutePage(),
          HomePage(),
          MapSearchPage(),
          RidingPage(),
        ].elementAt(_bottomNavigationProvider.currentPage),
      ),
      bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.add_location_sharp),
              label: '명소',
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
              icon: Icon(Icons.pedal_bike),
              label: '라이딩',
            ),
          ],
          currentIndex: _bottomNavigationProvider.currentPage,
          selectedItemColor: Colors.orange[600],
          unselectedItemColor: Colors.grey,
          onTap: (index) {
            if (index == 4) {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => ChangeNotifierProvider(
                        create: (context) => RidingProvider(),
                        child: RidingPage(),
                      )));
            } else {
              _bottomNavigationProvider.setCurrentPage(index);
            }
          }),
    );
  }
}

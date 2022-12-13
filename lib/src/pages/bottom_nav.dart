import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ridingpartner_flutter/src/pages/home_page.dart';
import 'package:ridingpartner_flutter/src/pages/map_search_page.dart';
import 'package:ridingpartner_flutter/src/pages/recommended_route_page.dart';
import 'package:ridingpartner_flutter/src/pages/riding_page.dart';
import 'package:ridingpartner_flutter/src/pages/sights_page.dart';
import 'package:ridingpartner_flutter/src/provider/bottom_navigation_provider.dart';
import 'package:ridingpartner_flutter/src/provider/riding_provider.dart';

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
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Image.asset(
                'assets/icons/bottom_nav_place.png',
                height: 15,
                color: Colors.grey[600],
              ),
              activeIcon: Image.asset(
                'assets/icons/bottom_nav_place.png',
                height: 18,
                color: Colors.black,
              ),
              label: '명소',
            ),
            BottomNavigationBarItem(
              icon: Image.asset(
                'assets/icons/bottom_nav_route.png',
                height: 15,
                color: Colors.grey[600],
              ),
              activeIcon: Image.asset(
                'assets/icons/bottom_nav_route.png',
                height: 18,
                color: Colors.black,
              ),
              label: '추천경로',
            ),
            BottomNavigationBarItem(
              icon: Image.asset(
                'assets/icons/bottom_nav_home.png',
                height: 15,
                color: Colors.grey[600],
              ),
              activeIcon: Image.asset(
                'assets/icons/bottom_nav_home.png',
                color: Colors.black,
                height: 18,
              ),
              label: '홈',
            ),
            BottomNavigationBarItem(
              icon: Image.asset(
                'assets/icons/bottom_nav_search.png',
                height: 15,
                color: Colors.grey[600],
              ),
              activeIcon: Image.asset(
                'assets/icons/bottom_nav_search.png',
                color: Colors.black,
                height: 18,
              ),
              label: '경로검색',
            ),
            BottomNavigationBarItem(
              icon: Image.asset(
                'assets/icons/bottom_nav_riding.png',
                height: 15,
                color: Colors.grey[600],
              ),
              activeIcon: Image.asset(
                'assets/icons/bottom_nav_riding.png',
                color: Colors.black,
                height: 18,
              ),
              label: '라이딩',
            ),
          ],
          currentIndex: _bottomNavigationProvider.currentPage,
          selectedItemColor: Colors.black,
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

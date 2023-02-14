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
    const Color selected = Color.fromRGBO(63, 66, 72, 1);
    const Color unSelected = Color.fromRGBO(204, 210, 223, 1);
    const EdgeInsets itemPadding = EdgeInsets.fromLTRB(0, 8, 0, 5);

    return Scaffold(
      appBar: AppBar(
        shadowColor: const Color.fromRGBO(255, 255, 255, 0.5),
        backgroundColor: Colors.white,
        title: SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Image.asset(
              'assets/icons/logo.png',
              height: 25,
            )),
        elevation: 10,
      ),
      body: SafeArea(
        child: [
          SightsPage(),
          const RecommendedRoutePage(),
          const HomePage(),
          const MapSearchPage(),
          const RidingPage(),
        ].elementAt(_bottomNavigationProvider.currentPage),
      ),
      bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Container(
                  padding: itemPadding,
                  child: Image.asset(
                    'assets/icons/bottom_nav_place.png',
                    height: 20,
                    width: 23,
                    color: unSelected,
                  )),
              activeIcon: Container(
                  padding: itemPadding,
                  child: Image.asset(
                    'assets/icons/bottom_nav_place.png',
                    height: 20,
                    width: 23,
                    color: selected,
                  )),
              label: '명소',
            ),
            BottomNavigationBarItem(
              icon: Container(
                  padding: itemPadding,
                  child: Image.asset('assets/icons/bottom_nav_route.png',
                      height: 20, width: 20, color: unSelected)),
              activeIcon: Container(
                  padding: itemPadding,
                  child: Image.asset(
                    'assets/icons/bottom_nav_route.png',
                    height: 20,
                    width: 20,
                    color: selected,
                  )),
              label: '추천경로',
            ),
            BottomNavigationBarItem(
              icon: Container(
                  padding: itemPadding,
                  child: Image.asset('assets/icons/bottom_nav_home.png',
                      height: 20, width: 23, color: unSelected)),
              activeIcon: Container(
                  padding: itemPadding,
                  child: Image.asset(
                    'assets/icons/bottom_nav_home.png',
                    color: selected,
                    height: 20,
                    width: 23,
                  )),
              label: '홈',
            ),
            BottomNavigationBarItem(
              icon: Container(
                  padding: itemPadding,
                  child: Image.asset('assets/icons/bottom_nav_search.png',
                      height: 20, width: 20, color: unSelected)),
              activeIcon: Container(
                  padding: itemPadding,
                  child: Image.asset(
                    'assets/icons/bottom_nav_search.png',
                    color: selected,
                    height: 20,
                    width: 20,
                  )),
              label: '경로검색',
            ),
            BottomNavigationBarItem(
              icon: Container(
                  padding: itemPadding,
                  child: Image.asset('assets/icons/bottom_nav_riding.png',
                      height: 20, width: 25, color: unSelected)),
              activeIcon: Container(
                  padding: itemPadding,
                  child: Image.asset(
                    'assets/icons/bottom_nav_riding.png',
                    color: selected,
                    height: 20,
                    width: 25,
                  )),
              label: '라이딩',
            ),
          ],
          currentIndex: _bottomNavigationProvider.currentPage,
          selectedItemColor: selected,
          unselectedItemColor: unSelected,
          onTap: (index) {
            if (index == 4) {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => ChangeNotifierProvider(
                        create: (context) => RidingProvider(),
                        child: const RidingPage(),
                      )));
            } else {
              _bottomNavigationProvider.setCurrentPage(index);
            }
          }),
    );
  }
}

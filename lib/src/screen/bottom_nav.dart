import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ridingpartner_flutter/src/pages/home_page.dart';
import 'package:ridingpartner_flutter/src/pages/map_search_page.dart';
import 'package:ridingpartner_flutter/src/pages/recommended_route_page.dart';
import 'package:ridingpartner_flutter/src/pages/riding_page.dart';
import 'package:ridingpartner_flutter/src/pages/sights_page.dart';
import 'package:ridingpartner_flutter/src/style/palette.dart';

final bottomNavigationProvider = StateProvider<int>((ref) => 0);

class BottomNavigation extends ConsumerWidget {
  const BottomNavigation({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bottomState = ref.watch(bottomNavigationProvider);
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
        ].elementAt(bottomState),
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
                    color: Palette.bottomNavUnSelecterColor,
                  )),
              activeIcon: Container(
                  padding: itemPadding,
                  child: Image.asset(
                    'assets/icons/bottom_nav_place.png',
                    height: 20,
                    width: 23,
                    color: Palette.bottomNavSelecterColor,
                  )),
              label: '명소',
            ),
            BottomNavigationBarItem(
              icon: Container(
                  padding: itemPadding,
                  child: Image.asset('assets/icons/bottom_nav_route.png',
                      height: 20,
                      width: 20,
                      color: Palette.bottomNavUnSelecterColor)),
              activeIcon: Container(
                  padding: itemPadding,
                  child: Image.asset(
                    'assets/icons/bottom_nav_route.png',
                    height: 20,
                    width: 20,
                    color: Palette.bottomNavSelecterColor,
                  )),
              label: '추천경로',
            ),
            BottomNavigationBarItem(
              icon: Container(
                  padding: itemPadding,
                  child: Image.asset('assets/icons/bottom_nav_home.png',
                      height: 20,
                      width: 23,
                      color: Palette.bottomNavUnSelecterColor)),
              activeIcon: Container(
                  padding: itemPadding,
                  child: Image.asset(
                    'assets/icons/bottom_nav_home.png',
                    color: Palette.bottomNavSelecterColor,
                    height: 20,
                    width: 23,
                  )),
              label: '홈',
            ),
            BottomNavigationBarItem(
              icon: Container(
                  padding: itemPadding,
                  child: Image.asset('assets/icons/bottom_nav_search.png',
                      height: 20,
                      width: 20,
                      color: Palette.bottomNavSelecterColor)),
              activeIcon: Container(
                  padding: itemPadding,
                  child: Image.asset(
                    'assets/icons/bottom_nav_search.png',
                    color: Palette.bottomNavSelecterColor,
                    height: 20,
                    width: 20,
                  )),
              label: '경로검색',
            ),
            BottomNavigationBarItem(
              icon: Container(
                  padding: itemPadding,
                  child: Image.asset('assets/icons/bottom_nav_riding.png',
                      height: 20,
                      width: 25,
                      color: Palette.bottomNavUnSelecterColor)),
              activeIcon: Container(
                  padding: itemPadding,
                  child: Image.asset(
                    'assets/icons/bottom_nav_riding.png',
                    color: Palette.bottomNavSelecterColor,
                    height: 20,
                    width: 25,
                  )),
              label: '라이딩',
            ),
          ],
          currentIndex: bottomState,
          selectedItemColor: Palette.bottomNavSelecterColor,
          unselectedItemColor: Palette.bottomNavUnSelecterColor,
          onTap: (index) {
            if (index == 4) {
              // Navigator.of(context).push(MaterialPageRoute(
              //     builder: (context) => ChangeNotifierProvider(
              //           create: (context) => RidingProvider(),
              //           child: const RidingPage(),
              //         )));
            } else {
              ref.read(bottomNavigationProvider.notifier).state = index;
            }
          }),
    );
  }
}

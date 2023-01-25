import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:ridingpartner_flutter/src/pages/bottom_nav.dart';
import 'package:ridingpartner_flutter/src/provider/auth_provider.dart';
import 'package:ridingpartner_flutter/src/provider/bottom_navigation_provider.dart';
import 'package:ridingpartner_flutter/src/provider/home_record_provider.dart';
import 'package:ridingpartner_flutter/src/provider/map_search_provider.dart';
import 'package:ridingpartner_flutter/src/provider/place_list_provider.dart';
import 'package:ridingpartner_flutter/src/provider/record_list_provider.dart';
import 'package:ridingpartner_flutter/src/provider/route_list_provider.dart';
import 'package:ridingpartner_flutter/src/provider/setting_provider.dart';
import 'package:ridingpartner_flutter/src/provider/sights_provider.dart';
import 'package:ridingpartner_flutter/src/provider/weather_provider.dart';

class LodingPage extends StatefulWidget {
  const LodingPage({super.key});

  @override
  State<LodingPage> createState() => _LodingPageState();
}

class _LodingPageState extends State<LodingPage> {
  late ConnectivityResult connectivityResult;
  late AuthProvider _authProvider;

  @override
  void initState() {
    super.initState();

    // 인터넷 검사
    Connectivity()
        .checkConnectivity()
        .then((value) => connectivityResult = value);

    // 유저 초기 설정
    Provider.of<AuthProvider>(context, listen: false).prepareUser();
  }

  // 로딩페이지와 동시에 사용
  @override
  Widget build(BuildContext context) {
    _authProvider = Provider.of<AuthProvider>(context);

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (_authProvider.user != null) {
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
                          create: (context) => BottomNavigationProvider()),
                      ChangeNotifierProvider(
                          create: (context) => MapSearchProvider()),
                      ChangeNotifierProvider(
                          create: (context) => PlaceListProvider()),
                      ChangeNotifierProvider(
                          create: (context) => HomeRecordProvider()),
                      ChangeNotifierProvider(
                          create: (context) => RecordListProvider()),
                      ChangeNotifierProvider(
                          create: (context) => SettingProvider())
                    ], child: BottomNavigation())),
            (route) => false);
      } else {
        if (connectivityResult == ConnectivityResult.none) {
          Fluttertoast.showToast(
              msg: "wifi 상태를 확인해주세요", toastLength: Toast.LENGTH_SHORT);
        }
      }
    });

    return Container(
        width: double.infinity,
        height: double.infinity,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          image: DecorationImage(
              image: AssetImage('assets/images/img_loading.png'),
              fit: BoxFit.cover),
        ),
        child: Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: FractionalOffset.topCenter,
                    end: FractionalOffset.bottomCenter,
                    colors: [
                  Colors.black.withOpacity(0.0),
                  Colors.white.withOpacity(1.0),
                ])),
            child: Container(
                margin: const EdgeInsets.fromLTRB(40.0, 0.0, 40.0, 20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                        width: 140.0,
                        height: 100.0,
                        decoration: const BoxDecoration(
                            image: DecorationImage(
                                image:
                                    AssetImage('assets/icons/logo_white.png')),
                            color: Colors.transparent)),
                    const SizedBox(
                      height: 20,
                    ),
                    _kakaoLoginButton(),
                    _naverLoginButton(),
                    _googleLoginButton(),
                    _appleLoginButton(),
                    Container(
                        alignment: Alignment.center,
                        margin: const EdgeInsets.fromLTRB(0.0, 20.0, 0, 0.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                                width: 70.0,
                                height: 70.0,
                                decoration: const BoxDecoration(
                                  image: DecorationImage(
                                      image: AssetImage(
                                          'assets/icons/logo_siheung.png')),
                                ),
                                child: const Scaffold(
                                  backgroundColor: Colors.transparent,
                                )),
                            const SizedBox(
                              width: 30,
                            ),
                            Container(
                                width: 125.0,
                                height: 100.0,
                                decoration: const BoxDecoration(
                                  image: DecorationImage(
                                      image: AssetImage(
                                          'assets/icons/logo_tuk.png')),
                                ),
                                child: const Scaffold(
                                  backgroundColor: Colors.transparent,
                                )),
                          ],
                        ))
                  ],
                ))));
  }

  Widget _naverLoginButton() {
    return SizedBox(
        width: MediaQuery.of(context).size.width,
        height: 70.0,
        child: Visibility(
            visible: _authProvider.user == null,
            child: Card(
                elevation: 0,
                color: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
                margin: const EdgeInsets.only(top: 10),
                child: InkWell(
                    onTap: () {
                      _authProvider.signInWithNaver();
                    },
                    child: Ink.image(
                      fit: BoxFit.fitHeight,
                      image:
                          const AssetImage("assets/icons/btn_naver_login.png"),
                    )))));
  }

  Widget _kakaoLoginButton() {
    return SizedBox(
        width: MediaQuery.of(context).size.width - 60,
        height: 70.0,
        child: Visibility(
            visible: _authProvider.user == null,
            child: Card(
                elevation: 0,
                color: Colors.transparent,
                margin: const EdgeInsets.only(top: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                child: InkWell(
                    onTap: () {
                      _authProvider.signInWithKakao();
                    },
                    child: Ink.image(
                      fit: BoxFit.fitHeight,
                      image:
                          const AssetImage("assets/icons/btn_kakao_login.png"),
                    )))));
    ;
  }

  Widget _googleLoginButton() {
    return SizedBox(
        width: MediaQuery.of(context).size.width,
        height: 70.0,
        child: Visibility(
            visible: _authProvider.user == null,
            child: Card(
                elevation: 0,
                color: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                margin: const EdgeInsets.only(top: 10),
                child: InkWell(
                    onTap: () {
                      _authProvider.signInWithGoogle();
                    },
                    child: Ink.image(
                      fit: BoxFit.fitHeight,
                      image:
                          const AssetImage("assets/icons/btn_google_login.png"),
                    )))));
  }

  Widget _appleLoginButton() {
    if (Platform.isIOS) {
      return SizedBox(
          width: MediaQuery.of(context).size.width,
          height: 70.0,
          child: Visibility(
              visible: _authProvider.user == null,
              child: Card(
                  elevation: 0,
                  color: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  margin: const EdgeInsets.only(top: 10),
                  child: InkWell(
                      onTap: () {
                        _authProvider.signInWithApple();
                      },
                      child: Ink.image(
                        fit: BoxFit.fitHeight,
                        image: const AssetImage(
                            "assets/icons/btn_apple_login.png"),
                      )))));
    } else {
      return Column();
    }
  }
}

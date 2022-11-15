import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:ridingpartner_flutter/src/pages/bottom_nav.dart';
import 'package:ridingpartner_flutter/src/provider/auth_provider.dart';
import 'package:ridingpartner_flutter/src/provider/bottom_navigation_provider.dart';
import 'package:ridingpartner_flutter/src/provider/home_record_provider.dart';
import 'package:ridingpartner_flutter/src/provider/map_search_provider.dart';
import 'package:ridingpartner_flutter/src/provider/navigation_provider.dart';
import 'package:ridingpartner_flutter/src/provider/place_list_provider.dart';
import 'package:ridingpartner_flutter/src/provider/riding_provider.dart';
import 'package:ridingpartner_flutter/src/provider/route_list_provider.dart';
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
                          create: (context) => RidingProvider()),
                      ChangeNotifierProvider(
                          create: (context) => PlaceListProvider()),
                      ChangeNotifierProvider(
                          create: (context) => HomeRecordProvider())
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
              image: AssetImage('assets/images/loading_background.png'),
              fit: BoxFit.cover),
        ),
        child: Container(
            margin: const EdgeInsets.symmetric(vertical: 30.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  "RIDING PARTNER\nIN SIHEUNG",
                  style: TextStyle(
                      backgroundColor: null,
                      color: Color.fromARGB(255, 0, 0, 0),
                      fontSize: 30),
                  textAlign: TextAlign.center,
                ),
                _kakaoLoginButton(),
                _naverLoginButton(),
                _googleLoginButton(),
                _appleLoginButton()
              ],
            )));
  }

  Widget _naverLoginButton() {
    return SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Visibility(
            visible: _authProvider.user == null,
            child: CupertinoButton(
                onPressed: () {
                  _authProvider.signInWithNaver();
                },
                color: Color.fromRGBO(62, 200, 76, 1),
                child: Text('네이버 로그인',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.black87,
                    )))));
  }

  Widget _kakaoLoginButton() {
    return SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Visibility(
            visible: _authProvider.user == null,
            child: CupertinoButton(
                onPressed: () {
                  _authProvider.signInWithKakao();
                },
                color: Colors.yellow,
                // ignore: prefer_const_constructors
                child: Text('카카오 로그인',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.black87,
                    )))));
  }

  Widget _googleLoginButton() {
    return SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Visibility(
            visible: _authProvider.user == null,
            child: CupertinoButton(
                onPressed: () {
                  _authProvider.signInWithGoogle();
                },
                color: Color.fromARGB(255, 255, 255, 255),
                child: Text('구글 로그인',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.black87,
                    )))));
  }

  Widget _appleLoginButton() {
    if (Platform.isIOS) {
      return SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Visibility(
              visible: _authProvider.user == null,
              child: CupertinoButton(
                  onPressed: () {
                    _authProvider.signInWithApple();
                  },
                  color: Color.fromARGB(255, 2, 2, 2),
                  child: Text('애플 로그인',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.white,
                      )))));
    } else {
      return Column();
    }
  }
}

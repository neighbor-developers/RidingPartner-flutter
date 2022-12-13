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

    Future.delayed(const Duration(milliseconds: 500), () {
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
              image: AssetImage('assets/images/img_loading.png'),
              fit: BoxFit.cover),
        ),
        child: Container(
            margin: const EdgeInsets.fromLTRB(40.0, 20.0, 40.0, 0.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
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
        height: 55.0,
        child: Container(
            margin: const EdgeInsets.only(top: 10.0),
            child: Visibility(
                visible: _authProvider.user == null,
                child: ElevatedButton(
                  onPressed: () {
                    _authProvider.signInWithNaver();
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromRGBO(62, 200, 76, 1)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Icon(
                        Icons.messenger,
                        color: Colors.white,
                        size: 22.0,
                      ),
                      Text('네이버 로그인',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 15,
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                      Icon(
                        Icons.arrow_forward_ios_outlined,
                        color: Colors.brown,
                        size: 14.0,
                      )
                    ],
                  ),
                ))));
  }

  Widget _kakaoLoginButton() {
    return SizedBox(
        width: MediaQuery.of(context).size.width,
        height: 65.0,
        child: Container(
            margin: const EdgeInsets.only(top: 20),
            child: Visibility(
                visible: _authProvider.user == null,
                child: ElevatedButton(
                    onPressed: () {
                      _authProvider.signInWithKakao();
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.yellow),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Icon(
                          Icons.messenger,
                          color: Colors.brown,
                          size: 22.0,
                        ),
                        // ignore: prefer_const_constructors
                        Text('카카오 로그인',
                            style: TextStyle(
                                fontSize: 15,
                                color: Colors.black87,
                                fontWeight: FontWeight.bold)),
                        Icon(
                          Icons.arrow_forward_ios_outlined,
                          color: Colors.brown,
                          size: 14.0,
                        )
                      ],
                    )))));
  }

  Widget _googleLoginButton() {
    return SizedBox(
        width: MediaQuery.of(context).size.width,
        height: 55.0,
        child: Container(
            margin: const EdgeInsets.only(top: 10.0),
            child: Visibility(
                visible: _authProvider.user == null,
                child: ElevatedButton(
                    onPressed: () {
                      _authProvider.signInWithGoogle();
                    },
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.white),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Icon(
                          Icons.messenger,
                          color: Colors.brown,
                          size: 22.0,
                        ),
                        Text('구글 로그인',
                            style: TextStyle(
                                fontSize: 15,
                                color: Color.fromARGB(150, 40, 40, 40),
                                fontWeight: FontWeight.bold)),
                        Icon(
                          Icons.arrow_forward_ios_outlined,
                          color: Colors.brown,
                          size: 14.0,
                        )
                      ],
                    )))));
  }

  Widget _appleLoginButton() {
    if (Platform.isIOS) {
      return SizedBox(
          width: MediaQuery.of(context).size.width,
          height: 55.0,
          child: Container(
              margin: const EdgeInsets.only(top: 10.0),
              child: Visibility(
                  visible: _authProvider.user == null,
                  child: ElevatedButton(
                      onPressed: () {
                        _authProvider.signInWithApple();
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 2, 2, 2)),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Icon(
                              Icons.messenger,
                              color: Colors.brown,
                              size: 22.0,
                            ),
                            Text('애플 로그인',
                                style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)),
                            Icon(
                              Icons.arrow_forward_ios_outlined,
                              color: Colors.brown,
                              size: 14.0,
                            )
                          ])))));
    } else {
      return Column();
    }
  }
}

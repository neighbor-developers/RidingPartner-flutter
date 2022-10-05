import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:ridingpartner_flutter/src/pages/main_route_page.dart';
import 'package:ridingpartner_flutter/src/provider/auth_provider.dart';

class LodingPage extends StatefulWidget {
  const LodingPage({super.key});

  @override
  State<LodingPage> createState() => _LodingPageState();
}

class _LodingPageState extends State<LodingPage> {
  late var connectivityResult;
  late var _authProvider;
  @override
  void initState() {
    super.initState();
    connectivityResult = Connectivity().checkConnectivity();
  }

  // 로딩페이지와 동시에 사용할까 생각중
  @override
  Widget build(BuildContext context) {
    _authProvider = Provider.of<AuthProvider>(context);
    _authProvider.prepareUser();
    User? _user = _authProvider.user;
    Future.delayed(Duration(milliseconds: 2500), () {
      if (_user != null) {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => MainRoute()),
            (route) => false);
      } else {
        if (connectivityResult == ConnectivityResult.none) {
          Fluttertoast.showToast(
              msg: "wifi 상태를 확인해주세요", toastLength: Toast.LENGTH_SHORT);
        } else {}
      }
    });

    return Scaffold(
      body: Column(children: [
        _kakaoLoginButton(),
        _naverLoginButton(),
        _googleLoginButton(),
      ]),
      appBar: AppBar(backgroundColor: Color.fromARGB(255, 25, 245, 83)),
    );
  }

  Widget _naverLoginButton() {
    return SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Visibility(
            visible: _authProvider.userIsNull,
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
            visible: _authProvider.userIsNull,
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
            visible: _authProvider.userIsNull,
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
}

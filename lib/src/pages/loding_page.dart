import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:provider/provider.dart';
import 'package:ridingpartner_flutter/src/pages/main_route_page.dart';
import 'package:ridingpartner_flutter/src/provider/auth_provider.dart';
import 'dart:developer' as developer;

class LodingPage extends StatelessWidget {
  const LodingPage({super.key});

  // 로딩페이지와 동시에 사용할까 생각중
  // 페이지 들어오는 순간 2초로딩과 provider를 통한 유저 확인.
  // 2초 로딩, 유저 확인 둘다 ok 해야 화면 넘어감
  // 유저 없다고 판단시 false 이므로 조건 불충분으로 화면 안넘어감
  // 로그인 버튼들 보이기
  // 로그인 하는 순간 auth 생기고 provider를 통해 auth 관찰중이므로 조건 만족으로 로딩페이지 넘어감

  @override
  Widget build(BuildContext context) {
    final _authProvider = Provider.of<AuthProvider>(context);
    _authProvider.prepareUser();
    User? _user = _authProvider.user;

    Future.delayed(Duration(milliseconds: 2500), () {
      if (_user != null) {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => MainRoute()),
            (route) => false);
      }
    });

    return Scaffold(
      body: Column(children: [
        CupertinoButton(
            child: Visibility(
              visible: true,
              child: Text('카카오 로그인'),
            ),
            color: Color.fromARGB(255, 213, 239, 15),
            onPressed: () {
              _authProvider.signInWithKakao();
            }),
        CupertinoButton(
            child: Visibility(
              visible: true,
              child: Text('네이버 로그인'),
            ),
            color: Color.fromARGB(255, 64, 218, 79),
            onPressed: () {
              _authProvider.signInWithNaver();
            }),
        CupertinoButton(
            child: Visibility(
              visible: true,
              child: Text('구글 로그인'),
            ),
            color: Color.fromARGB(255, 89, 59, 237),
            onPressed: () {
              _authProvider.signInWithGoogle();
            })
      ]),
      appBar: AppBar(backgroundColor: Color.fromARGB(255, 25, 245, 83)),
    );
  }
}

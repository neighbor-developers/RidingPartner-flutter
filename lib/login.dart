import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart'
    hide EmailAuthProvider, PhoneAuthProvider;
import 'package:firebase_core/firebase_core.dart';
import 'package:ridingpartner_flutter/src/network/wether_service.dart';
import 'firebase_options.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart' as kakao_flutter;
import 'package:flutter_naver_login/flutter_naver_login.dart' as naver_flutter;

enum LoginPlatform { google, kakao, naver }

class UserData {
  final String name;
  final String email;

  UserData(this.name, this.email);
}

class Login extends StatelessWidget {
  const Login({super.key});

  @override
  Widget build(BuildContext context) {
    kakao_flutter.KakaoSdk.init(
        nativeAppKey: 'b50ae09d3f49b62c4fba3b875e1b3458');
    return Scaffold(
      body: Column(children: [KakaoLogin(), NaverLogin()]),
      appBar: AppBar(backgroundColor: Color.fromARGB(255, 25, 245, 83)),
    );
  }
}

class KakaoLogin extends StatefulWidget {
  @override
  State<KakaoLogin> createState() => _KakaoLoginState();
}

class _KakaoLoginState extends State<KakaoLogin> {
  get_user() async {
    try {
      kakao_flutter.User user = await kakao_flutter.UserApi.instance.me();
    } catch (error) {
      print('카카오톡 로그인 실패: $error');
    }
  }

  Future<void> signInWithKaao() async {
    if (await kakao_flutter.isKakaoTalkInstalled()) {
      try {
        await kakao_flutter.UserApi.instance.loginWithKakaoTalk();
        get_user();
      } catch (error) {
        print('카카오톡 로그인 실패 $error');

        try {
          await kakao_flutter.UserApi.instance.loginWithKakaoAccount();
          get_user();
        } catch (error) {
          print('카카오톡 로그인 실패 $error');
        }
      }
    } else {
      try {
        await kakao_flutter.UserApi.instance.loginWithKakaoAccount();
        get_user();
      } catch (error) {
        print('카카오톡 로그인 실패 $error');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: CupertinoButton(
          child: Text('카카오 로그인'),
          color: Color.fromARGB(255, 213, 239, 15),
          onPressed: signInWithKaao),
    );
  }
}

class NaverLogin extends StatefulWidget {
  const NaverLogin({super.key});

  @override
  State<NaverLogin> createState() => _NaverLoginState();
}

class _NaverLoginState extends State<NaverLogin> {
  Future<void> signInWithNaver() async {
    naver_flutter.NaverLoginResult result =
        await naver_flutter.FlutterNaverLogin.logIn();
    naver_flutter.NaverAccessToken tokenRes =
        await naver_flutter.FlutterNaverLogin.currentAccessToken;
    setState(() {
      // accesToken = tokenRes.accessToken;
      // id = result.account.id;
      // email = result.account.email;
      // token = result.accessToken;
      // name = result.account.name;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: CupertinoButton(
          child: Text('네이버 로그인'),
          color: Color.fromARGB(255, 12, 239, 72),
          onPressed: signInWithNaver),
    );
    ;
  }
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart' as firebase
    hide EmailAuthProvider, PhoneAuthProvider;
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'firebase_options.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart' as kakao_login;
import 'package:flutter_naver_login/flutter_naver_login.dart' as naver_login;

enum LoginPlatform { google, kakao, naver }

class Login extends StatelessWidget {
  const Login({super.key});

  @override
  Widget build(BuildContext context) {
    kakao_login.KakaoSdk.init(nativeAppKey: 'b50ae09d3f49b62c4fba3b875e1b3458');
    return Scaffold(
      body: Column(children: [KakaoLogin(), NaverLogin(), GoogleLogin()]),
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
      kakao_login.User user = await kakao_login.UserApi.instance.me();
    } catch (error) {
      print('카카오톡 로그인 실패: $error');
    }
  }

  Future<void> signInWithKaao() async {
    if (await kakao_login.isKakaoTalkInstalled()) {
      try {
        await kakao_login.UserApi.instance.loginWithKakaoTalk();
        get_user();
      } catch (error) {
        print('카카오톡 로그인 실패 $error');

        try {
          await kakao_login.UserApi.instance.loginWithKakaoAccount();
          get_user();
        } catch (error) {
          print('카카오톡 로그인 실패 $error');
        }
      }
    } else {
      try {
        await kakao_login.UserApi.instance.loginWithKakaoAccount();
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
    naver_login.NaverLoginResult result =
        await naver_login.FlutterNaverLogin.logIn();
    naver_login.NaverAccessToken tokenRes =
        await naver_login.FlutterNaverLogin.currentAccessToken;
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

class GoogleLogin extends StatefulWidget {
  const GoogleLogin({super.key});

  @override
  State<GoogleLogin> createState() => _GoogleLoginState();
}

class _GoogleLoginState extends State<GoogleLogin> {
  final firebase.FirebaseAuth _auth = firebase.FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();

  Future<firebase.UserCredential> siginInwithGoogle() async {
    final GoogleSignInAccount googleUser = await GoogleSignIn().signIn();
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final firebase.OAuthCredential credential =
        firebase.GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    return await firebase.FirebaseAuth.instance
        .signInWithCredential(credential);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: CupertinoButton(
          child: Text('구글 로그인'),
          color: Color.fromARGB(255, 12, 239, 72),
          onPressed: siginInwithGoogle),
    );
    ;
  }
}

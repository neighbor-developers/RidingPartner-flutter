import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart' as firebase
    hide EmailAuthProvider, PhoneAuthProvider;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:ridingpartner_flutter/src/service/firebase_auth_social_login.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart' as kakao_flutter;
import 'package:flutter_naver_login/flutter_naver_login.dart' as naver_flutter;

class Login extends StatelessWidget {
  const Login({super.key});

  @override
  Widget build(BuildContext context) {
    kakao_flutter.KakaoSdk.init(
        nativeAppKey: 'b50ae09d3f49b62c4fba3b875e1b3458');
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
  final _firebaseAuthSocialLogin = FirebaseAuthSocialLogin();

  Future<bool> signInWithKakao() async {
    if (await kakao_flutter.isKakaoTalkInstalled()) {
      try {
        await kakao_flutter.UserApi.instance.loginWithKakaoTalk();
        return true;
      } catch (error) {
        print('카카오톡 로그인 실패 $error');
        try {
          await kakao_flutter.UserApi.instance.loginWithKakaoAccount();
          return true;
        } catch (error) {
          print('카카오톡 로그인 실패 $error');
          return false;
        }
      }
    } else {
      try {
        await kakao_flutter.UserApi.instance.loginWithKakaoAccount();
        return true;
      } catch (error) {
        return false;
      }
    }
  }

  Future<void> loginWithCustomToken() async {
    bool isLogin = await signInWithKakao();
    if (isLogin) {
      // 카카오는 uId로 인증하는듯??
      kakao_flutter.User user = await kakao_flutter.UserApi.instance.me();
      final customToken = await _firebaseAuthSocialLogin.createCustomToken({
        'platform': 'naver',
        'uId': user.id.toString(),
        'name': user.kakaoAccount!.name,
        'email': user.kakaoAccount!.email,
      });

      await firebase.FirebaseAuth.instance.signInWithCustomToken(customToken);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        child: CupertinoButton(
            child: Text('카카오 로그인'),
            color: Color.fromARGB(255, 213, 239, 15),
            onPressed: () {
              loginWithCustomToken();
            }));
  }
}

class NaverLogin extends StatefulWidget {
  const NaverLogin({super.key});

  @override
  State<NaverLogin> createState() => _NaverLoginState();
}

class _NaverLoginState extends State<NaverLogin> {
  final _firebaseAuthSocialLogin = FirebaseAuthSocialLogin();

  Future<void> signInWithNaver() async {
    naver_flutter.NaverLoginResult result =
        await naver_flutter.FlutterNaverLogin.logIn();
    naver_flutter.NaverAccessToken tokenRes =
        await naver_flutter.FlutterNaverLogin.currentAccessToken;

    // 네이버 로그인은 accessToken으로 인증
    final customToken = await _firebaseAuthSocialLogin.createCustomToken({
      'platform': 'kakao',
      'uId': result.account.id.toString(),
      'name': result.account.name,
      'email': result.account.email,
      'token': tokenRes
    });
    await firebase.FirebaseAuth.instance.signInWithCustomToken(customToken);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: CupertinoButton(
          child: Text('네이버 로그인'),
          color: Color.fromARGB(255, 12, 239, 72),
          onPressed: () {
            signInWithNaver();
          }),
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
  Future<firebase.UserCredential> siginInwithGoogle() async {
    final GoogleSignInAccount googleUser =
        GoogleSignIn().signIn() as GoogleSignInAccount;
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
      onPressed: () {
        siginInwithGoogle();
      },
    ));
  }
}

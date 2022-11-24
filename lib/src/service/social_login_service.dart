import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart' as kakao_flutter;
import 'package:flutter_naver_login/flutter_naver_login.dart' as naver_flutter;
import 'package:ridingpartner_flutter/src/network/network_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import 'dart:developer' as developer;

import 'firebase_database_service.dart';

class SocialLoginService {
  // kakao
  Future<User?> signInWithKakao() async {
    kakao_flutter.KakaoSdk.init(
        nativeAppKey: dotenv.env['KAKAO_NATIVE_APP_KEY']!);

    if (await kakao_flutter.isKakaoTalkInstalled()) {
      try {
        await kakao_flutter.UserApi.instance.loginWithKakaoTalk();
        kakao_flutter.User kakaoUser =
            await kakao_flutter.UserApi.instance.me();
        User user = await loginWithUser({
          'platform': 'kakao',
          'uId': kakaoUser.id.toString(),
          'name': kakaoUser.kakaoAccount!.name,
          'email': kakaoUser.kakaoAccount!.email,
        });
        saveUserInfo(user);
      } catch (error) {
        print('카카오톡 로그인 실패 $error');
        try {
          await kakao_flutter.UserApi.instance.loginWithKakaoAccount();
          kakao_flutter.User kakaoUser =
              await kakao_flutter.UserApi.instance.me();
          User user = await loginWithUser({
            'platform': 'kakao',
            'uId': kakaoUser.id.toString(),
            'name': kakaoUser.kakaoAccount!.name,
            'email': kakaoUser.kakaoAccount!.email,
          });
          saveUserInfo(user);
        } catch (error) {
          print('카카오톡 로그인 실패 $error');
          return null;
        }
      }
    } else {
      try {
        await kakao_flutter.UserApi.instance.loginWithKakaoAccount();
        kakao_flutter.User kakaoUser =
            await kakao_flutter.UserApi.instance.me();
        User user = await loginWithUser({
          'platform': 'kakao',
          'uId': kakaoUser.id.toString(),
          'name': kakaoUser.kakaoAccount!.name,
          'email': kakaoUser.kakaoAccount!.email,
        });
        saveUserInfo(user);
      } catch (error) {
        return null;
      }
    }
  }

  // naver
  Future<User?> signInWithNaver() async {
    try {
      naver_flutter.NaverLoginResult result =
          await naver_flutter.FlutterNaverLogin.logIn();
      naver_flutter.NaverAccessToken tokenRes =
          await naver_flutter.FlutterNaverLogin.currentAccessToken;

      User user = await loginWithUser({'platform': 'naver', 'token': tokenRes});
      saveUserInfo(user);
    } catch (error) {
      null;
    }
    return null;
  }

  Future<User> loginWithUser(Map<String, dynamic> user) async {
    // 카카오는 uId로 인증하는듯??
    final customToken = await NetworkHelper().post("", user);
    var credencial =
        await FirebaseAuth.instance.signInWithCustomToken(customToken);
    return credencial.user!;
  }

  Future<User?> siginInwithGoogle() async {
    final googleUser = await GoogleSignIn().signIn();
    final GoogleSignInAuthentication googleAuth =
        await googleUser!.authentication;

    final OAuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    UserCredential result =
        await FirebaseAuth.instance.signInWithCredential(credential);
    if (result.user != null) {
      developer.log(result.user.toString());
      saveUserInfo(result.user!);
      return result.user;
    } else {
      return null;
    }
  }

  Future<User?> siginInwithApple() async {
    final appleAuthCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName
        ]);

    final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleAuthCredential.identityToken,
        accessToken: appleAuthCredential.authorizationCode);
    UserCredential result =
        await FirebaseAuth.instance.signInWithCredential(oauthCredential);

    if (result.user != null) {
      developer.log(result.user.toString());
      saveUserInfo(result.user!);
      return result.user;
    } else {
      return null;
    }
  }

  Future<void> saveUserInfo(User user) async {
    final prefs = await SharedPreferences.getInstance();

    prefs.setString('name', user.displayName.toString());
    prefs.setString('email', user.email.toString());
    prefs.setString('token', user.getIdToken().toString());
    prefs.setString("uId", user.uid);
  }

  final FirebaseAuth fAuth = FirebaseAuth.instance;
  final FirebaseDatabaseService _databaseService = FirebaseDatabaseService();

  Future<bool> withdrawal() async {
    while (true) {
      _databaseService.delRecord();
      try {
        await fAuth.currentUser?.delete();
        fAuth.signOut();
        break;
      } catch (e) {
        print('계정탈퇴에 실패했습니다.');
      }
      Future.delayed(Duration(seconds: 3));
    }
    return true;
  }

  Future<bool> signOut() async {
    try {
      await fAuth.signOut();
      return true;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }
}

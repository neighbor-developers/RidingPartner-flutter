import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart' as kakao_flutter;
import 'package:flutter_naver_login/flutter_naver_login.dart' as naver_flutter;

import 'firebase_auth_social_login.dart';

class SocialLogin {
  final _firebaseAuthSocialLogin = FirebaseAuthSocialLogin();

  // kakao
  Future<User?> signInWithKakao() async {
    if (await kakao_flutter.isKakaoTalkInstalled()) {
      try {
        await kakao_flutter.UserApi.instance.loginWithKakaoTalk();
        kakao_flutter.User user = await kakao_flutter.UserApi.instance.me();
        return await loginWithUser({
          'platform': 'kakao',
          'uId': user.id.toString(),
          'name': user.kakaoAccount!.name,
          'email': user.kakaoAccount!.email,
        });
      } catch (error) {
        print('카카오톡 로그인 실패 $error');
        try {
          await kakao_flutter.UserApi.instance.loginWithKakaoAccount();
          kakao_flutter.User user = await kakao_flutter.UserApi.instance.me();
          return await loginWithUser({
            'platform': 'kakao',
            'uId': user.id.toString(),
            'name': user.kakaoAccount!.name,
            'email': user.kakaoAccount!.email,
          });
        } catch (error) {
          print('카카오톡 로그인 실패 $error');
          return null;
        }
      }
    } else {
      try {
        await kakao_flutter.UserApi.instance.loginWithKakaoAccount();
        kakao_flutter.User user = await kakao_flutter.UserApi.instance.me();
        return await loginWithUser({
          'platform': 'kakao',
          'uId': user.id.toString(),
          'name': user.kakaoAccount!.name,
          'email': user.kakaoAccount!.email,
        });
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
      return loginWithUser({'platform': 'naver', 'token': tokenRes});
    } catch (error) {
      null;
    }
    return null;
  }

  Future<User> loginWithUser(Map<String, dynamic> user) async {
    // 카카오는 uId로 인증하는듯??

    final customToken = await _firebaseAuthSocialLogin.createCustomToken(user);
    var credencial =
        await FirebaseAuth.instance.signInWithCustomToken(customToken);
    return credencial.user!;
  }

  Future<User?> siginInwithGoogle() async {
    final GoogleSignInAccount googleUser =
        GoogleSignIn().signIn() as GoogleSignInAccount;
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final OAuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    UserCredential result =
        await FirebaseAuth.instance.signInWithCredential(credential);
    if (result.user != null) {
      return result.user;
    } else {
      return null;
    }
  }
}

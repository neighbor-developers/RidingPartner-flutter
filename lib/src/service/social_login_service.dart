import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_naver_login/flutter_naver_login.dart' as naver_flutter;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart' as kakao_flutter;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import 'firebase_database_service.dart';

class SocialLoginService {
  static final SocialLoginService _socialLoginService =
      SocialLoginService._internal();
  factory SocialLoginService() {
    return _socialLoginService;
  }
  SocialLoginService._internal();
  // kakao
  Future<User?> signInWithKakao() async {
    kakao_flutter.KakaoSdk.init(
        nativeAppKey: dotenv.env['KAKAO_NATIVE_APP_KEY']!);

    if (await kakao_flutter.isKakaoTalkInstalled()) {
      try {
        await kakao_flutter.UserApi.instance.loginWithKakaoTalk();
        kakao_flutter.User kakaoUser =
            await kakao_flutter.UserApi.instance.me();
        UserCredential user = await loginWithUser({
          'platform': 'kakao',
          'uId': kakaoUser.id.toString(),
          'name': kakaoUser.kakaoAccount!.name,
          'email': kakaoUser.kakaoAccount!.email,
        });
        saveUserInfo(user.user!);
        return user.user!;
      } catch (error) {
        showEmailCheckToast();
        return null;
      }
    } else {
      try {
        await kakao_flutter.UserApi.instance.loginWithKakaoAccount();
        kakao_flutter.User kakaoUser =
            await kakao_flutter.UserApi.instance.me();
        UserCredential user = await loginWithUser({
          'platform': 'kakao',
          'uId': kakaoUser.id.toString(),
          'name': kakaoUser.kakaoAccount!.profile!.nickname,
          'email': kakaoUser.kakaoAccount!.email,
        });
        saveUserInfo(user.user!);
        return user.user;
      } catch (error) {
        showEmailCheckToast();
        return null;
      }
    }
  }

  // naver
  Future<User?> signInWithNaver() async {
    try {
      await naver_flutter.FlutterNaverLogin.logIn();
      naver_flutter.NaverAccountResult naverUser =
          await naver_flutter.FlutterNaverLogin.currentAccount();
      UserCredential user = await loginWithUser({
        'platform': 'kakao',
        'uId': naverUser.id.toString(),
        'name': naverUser.name,
        'email': naverUser.email
      });

      saveUserInfo(user.user!);
      return user.user;
    } catch (error) {
      showEmailCheckToast();
      null;
    }
    return null;
  }

  Future<UserCredential> loginWithUser(Map<String, dynamic> user) async {
    // 카카오는 uId로 인증하는듯??
    UserCredential credencial;
    try {
      credencial = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: user['email'], password: user['uId']);
    } finally {
      credencial = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: user['email'], password: user['uId']);
      credencial.user!.updateDisplayName(user['name']);
    }
    return credencial;
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
    _databaseService.delRecord();
    try {
      await fAuth.currentUser?.delete();
      fAuth.signOut();
    } catch (e) {
      return false;
    }
    Future.delayed(const Duration(seconds: 3));

    return true;
  }

  Future<bool> signOut() async {
    try {
      await fAuth.signOut();
      return true;
    } catch (e) {
      return false;
    }
  }

  void showEmailCheckToast() => Fluttertoast.showToast(
      msg: "error: 해당 계정의 이메일이 카카오톡 혹은 구글 로그인으로 이미 등록된 이메일인지 확인해주세요.",
      toastLength: Toast.LENGTH_LONG);
}

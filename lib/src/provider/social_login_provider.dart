import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../service/social_login_service.dart';

class SignInAuthProvider with ChangeNotifier {
  final socialLogin = SocialLogin();

  final FirebaseAuth fAuth = FirebaseAuth.instance;
  User? _user;

  User? get user => _user;

  void _setUser(User? user) {
    _user = user;
    notifyListeners();
  }

  void prepareUser() {
    _user = fAuth.currentUser;
  }

  signInWithSocialLogin(String platform) async {
    if (platform == 'kakao') {
      User? user = await socialLogin.signInWithKakao();
      _setUser(user);
    } else if (platform == 'naver') {
      User? user = await socialLogin.signInWithNaver();
      _setUser(user);
    } else {
      User? user = await socialLogin.siginInwithGoogle();
      _setUser(user);
    }
  }

  signOut() async {
    await fAuth.signOut();
    _setUser(null);
  }
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

import '../service/social_login_service.dart';

class AuthProvider with ChangeNotifier {
  final socialLogin = SocialLoginService();

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

  signInWithKakao() async {
    User? user = await socialLogin.signInWithKakao();
    _setUser(user);
  }

  signInWithNaver() async {
    User? user = await socialLogin.signInWithNaver();
    _setUser(user);
  }

  signInWithGoogle() async {
    User? user = await socialLogin.siginInwithGoogle();
    _setUser(user);
  }

  signInWithApple() async {
    User? user = await socialLogin.siginInwithApple();
    _setUser(user);
  }
}

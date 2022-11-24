import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../service/social_login_service.dart';
import 'dart:developer' as developer;

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
    developer.log(user.toString());
    _setUser(user);
  }

  signInWithApple() async {
    User? user = await socialLogin.siginInwithApple();
    developer.log(user.toString());
    _setUser(user);
  }
}

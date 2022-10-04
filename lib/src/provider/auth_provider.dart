import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../service/social_login_service.dart';
import 'dart:developer' as developer;

class AuthProvider with ChangeNotifier {
  final socialLogin = SocialLogin();

  final FirebaseAuth fAuth = FirebaseAuth.instance;
  User? _user;
  bool _userIsNull = false;

  User? get user => _user;
  bool get userIsNull => _userIsNull;

  void _setUser(User? user) {
    _user = user;
    notifyListeners();
  }

  void prepareUser() {
    _user = fAuth.currentUser;
    _setUserIsNull();
  }

  void _setUserIsNull() {
    if (_user == null) {
      _userIsNull = false;
    } else {
      _userIsNull = true;
    }
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

  signOut() async {
    await fAuth.signOut();
    _setUser(null);
  }
}

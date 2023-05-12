import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../service/social_login_service.dart';

class AuthProvider extends StateNotifier<User?> {
  AuthProvider() : super(FirebaseAuth.instance.currentUser);
  final socialLogin = SocialLoginService();

  @override
  set state(User? value) {
    //
    super.state = value;
  }

  signInWithKakao() async {
    state = await socialLogin.signInWithKakao();
  }

  signInWithNaver() async {
    state = await socialLogin.signInWithNaver();
  }

  signInWithGoogle() async {
    state = await socialLogin.siginInwithGoogle();
  }

  signInWithApple() async {
    state = await socialLogin.siginInwithApple();
  }
}

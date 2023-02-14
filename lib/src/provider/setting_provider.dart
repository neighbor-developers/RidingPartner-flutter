import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:ridingpartner_flutter/src/service/social_login_service.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SettingProvider with ChangeNotifier {
  final SocialLoginService _socialLoginService = SocialLoginService();


  User? _user;
  User? get user => _user;

  String? _version;
  String? get version => _version;

  Future<void> Version() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    _version = packageInfo.version;
    notifyListeners();
  }

  Future<bool> signOut() async => await _socialLoginService.signOut();

  // getVersion() async {
  //   PackageInfo packageInfo = await PackageInfo.fromPlatform();
  //   _version = packageInfo.version;
  //   notifyListeners();
  // }

  Future withdrawal() async => await _socialLoginService.withdrawal();
}

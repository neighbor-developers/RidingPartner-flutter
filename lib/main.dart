import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ridingpartner_flutter/src/network/network_helper.dart';
import 'package:ridingpartner_flutter/src/screen/splash_screen.dart';
import 'package:ridingpartner_flutter/src/service/shared_preference.dart';
import 'package:ridingpartner_flutter/src/utils/http_override.dart';

import 'firebase_options.dart';

void main() async {
  // 테스트 환경에서만 사용 실제 출시때는 삭제
  HttpOverrides.global = NoCheckCertificateHttpOverrides();

  await dotenv.load(fileName: "assets/config/.env");
  // MyLocation();
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await PreferenceUtils.init();
  NetworkHelper();

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: SplashScreen());
  }
}

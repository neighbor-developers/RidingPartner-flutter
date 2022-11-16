import 'dart:developer' as developer;
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:ridingpartner_flutter/src/pages/loding_page.dart';
import 'package:ridingpartner_flutter/src/provider/auth_provider.dart';
import 'package:ridingpartner_flutter/src/service/shared_preference.dart';
import 'package:ridingpartner_flutter/src/utils/http_override.dart';
import 'package:ridingpartner_flutter/src/utils/user_location.dart';

import 'firebase_options.dart';

void main() async {
  developer.log("시작은 되니?");

  // 테스트 환경에서만 사용 실제 출시때는 삭제
  HttpOverrides.global = NoCheckCertificateHttpOverrides();

  await dotenv.load(fileName: "assets/config/.env");
  await MyLocation().getMyCurrentLocation();
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await PreferenceUtils.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (context) => AuthProvider(),
        child: const MaterialApp(home: LodingPage()));
  }
}

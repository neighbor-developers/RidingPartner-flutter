import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:ridingpartner_flutter/src/network/naver_map_service.dart';
import 'firebase_options.dart';
import 'login.dart';
import 'src/network/wether_service.dart';
import 'dart:developer' as developer;

void main() async {
  developer.log("시작은 되니?");
  await dotenv.load(fileName: "assets/config/.env");
  var myNetwork = Network();
  myNetwork.getWeatherData();
  var naverMapService = NaverMapService();
  var places = await naverMapService.getPlaces("Crocodile");
  developer.log(places.toString());

  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            titleTextStyle: TextStyle(color: Colors.black),
          ),
        ),
        // initialBinding: InitBinding(),
        // home: const Root(),
        home: const Login());
  }
}

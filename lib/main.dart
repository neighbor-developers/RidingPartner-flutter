import 'dart:async';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:naver_map_plugin/naver_map_plugin.dart';
import 'package:ridingpartner_flutter/src/service/naver_map_service.dart';
import 'package:ridingpartner_flutter/src/service/wether_service.dart';
import 'package:ridingpartner_flutter/src/utils/http_override.dart';

import 'firebase_options.dart';
import 'login.dart';

void main() async {
  developer.log("시작은 되니?");
  HttpOverrides.global = NoCheckCertificateHttpOverrides();
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
    return MaterialApp(
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
        home: NaverMapTest());
  }
}

class NaverMapTest extends StatefulWidget {
  const NaverMapTest({super.key});

  @override
  _NaverMapTestState createState() => _NaverMapTestState();
}

class _NaverMapTestState extends State<NaverMapTest> {
  Completer<NaverMapController> _controller = Completer();
  MapType _mapType = MapType.Basic;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('NaverMap Test')),
      body: Container(
        child: NaverMap(
          onMapCreated: onMapCreated,
          mapType: _mapType,
        ),
      ),
    );
  }

  void onMapCreated(NaverMapController controller) {
    if (_controller.isCompleted) _controller = Completer();
    _controller.complete(controller);
  }
}

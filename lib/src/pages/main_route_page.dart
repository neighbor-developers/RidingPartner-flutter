import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ridingpartner_flutter/src/pages/loding_page.dart';
import '../provider/weather_provider.dart';
import 'map_page.dart';
import 'weather_page.dart';

class MainRoute extends StatelessWidget {
  const MainRoute({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('메인 라우트 페이지'),
      ),
      body: Column(
        children: [
          TextButton(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ChangeNotifierProvider(
                          create: (context) => WeatherProvider(),
                          child: WeatherPage())));
            },
            child: const Text('날씨 페이지'),
          ),
          TextButton(
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => MapSample()));
            },
            child: const Text('map 페이지'),
          ),
          TextButton(
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => WeatherPage()));
            },
            child: const Text('네비게이션 페이지'),
          ),
          TextButton(
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => WeatherPage()));
            },
            child: const Text('라이딩 페이지'),
          ),
          TextButton(
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => WeatherPage()));
            },
            child: const Text('추천경로 페이지'),
          ),
          TextButton(
            onPressed: () {
              FirebaseAuth.instance.signOut();
              print('로그아웃');
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => LodingPage()));
            },
            child: const Text('로그아웃 및 재로그인'),
          )
        ],
      ),
    );
  }
}
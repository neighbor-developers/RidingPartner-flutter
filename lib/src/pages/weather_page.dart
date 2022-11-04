import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ridingpartner_flutter/src/pages/loding_page.dart';
import 'package:ridingpartner_flutter/src/provider/auth_provider.dart';
import 'package:ridingpartner_flutter/src/provider/weather_provider.dart';
import 'dart:developer' as developer;

class WeatherPage extends StatefulWidget {
  const WeatherPage() : super();

  @override
  _WeatherPage createState() => _WeatherPage();
}

class _WeatherPage extends State<WeatherPage> {
  @override
  void initState() {
    super.initState();
    Provider.of<WeatherProvider>(context, listen: false).getWeather();
  }

  @override
  Widget build(BuildContext context) {
    final weather = Provider.of<WeatherProvider>(context).weather;
    developer.log('weather build');

    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(weather.skyType ?? '날씨를 불러오고 있습니다.'),
            Text(weather.temperature ?? ''),
            Text(weather.humidity ?? ''),
            Text(weather.rainType ?? ''),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Go back!'),
            ),
            TextButton(
              onPressed: () {
                FirebaseAuth.instance.signOut();
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ChangeNotifierProvider(
                            create: (context) => AuthProvider(),
                            child: const MaterialApp(home: LodingPage()))));
              },
              child: const Text('logOut'),
            ),
          ],
        ),
      ),
    );
  }
}

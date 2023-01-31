import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:ridingpartner_flutter/src/models/result.dart';
import 'package:ridingpartner_flutter/src/network/network_helper.dart';
import 'package:ridingpartner_flutter/src/utils/user_location.dart';

class OpenWeatherService {
  final String _apiKey = dotenv.env['openWeatherApiKey']!;
  final String _baseUrl = dotenv.env['openWeatherApiBaseUrl']!;

  Future<Result> getWeather() async {
    MyLocation myLocation = MyLocation();

    try {
      await myLocation.getMyCurrentLocation().timeout(Duration(seconds: 3));
    } catch (e) {}

    final result = await NetworkHelper().getData(
        '$_baseUrl?lat=${myLocation.position?.latitude}&lon=${myLocation.position?.longitude}&appid=$_apiKey&units=metric');
    return result;
  }
}

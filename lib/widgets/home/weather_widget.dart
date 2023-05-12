import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ridingpartner_flutter/style/textstyle.dart';

import '../../models/weather.dart';
import '../../service/wether_service.dart';

final weatherProvider = FutureProvider<Weather>((ref) async {
  return await OpenWeatherService().getWeather();
});

class WeatherWidget extends ConsumerStatefulWidget {
  const WeatherWidget({super.key});

  @override
  WeatherWidgetState createState() => WeatherWidgetState();
}

class WeatherWidgetState extends ConsumerState<WeatherWidget> {
  @override
  void dispose() {
    ref.invalidate(weatherProvider);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final weather = ref.watch(weatherProvider);

    return weather.when(
        data: (weather) => Container(
            width: MediaQuery.of(context).size.width,
            color: Colors.white,
            child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    width: 0.7,
                    color: const Color.fromRGBO(234, 234, 234, 1),
                  ),
                ),
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Image.asset(
                      weather.icon ?? 'assets/icons/weather_cloud.png',
                      width: 17,
                      height: 17,
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Text(
                        '오늘의 온도 : ${weather.temp}°C   습도 : ${weather.humidity}%',
                        style: TextStyles.weatherTextStyle)
                  ],
                ))),
        loading: () => Container(
            width: MediaQuery.of(context).size.width,
            color: Colors.white,
            child: Container(
                padding: const EdgeInsets.all(12),
                child: const Text(
                  '날씨를 검색중입니다',
                  style: TextStyles.weatherTextStyle,
                ))),
        error: (error, stack) => Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                width: 1,
                color: Colors.grey[200]!,
              ),
            ),
            width: MediaQuery.of(context).size.width,
            child: Container(
                padding: const EdgeInsets.all(12),
                child: const Text(
                  '날씨를 불러오지 못했습니다.',
                  style: TextStyles.weatherTextStyle,
                ))));
  }
}

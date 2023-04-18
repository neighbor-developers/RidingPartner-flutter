import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../style/textstyle.dart';

Widget lottiWidget(String lotti, String text) => Container(
    height: double.infinity,
    color: Colors.white,
    child: Center(
        child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        LottieBuilder.asset(
          lotti,
          width: 120,
        ),
        Text(text,
            style: TextStyles.descriptionTextStyle, textAlign: TextAlign.center)
      ],
    )));

Widget loadingBackground(String text) =>
    lottiWidget('assets/json/lottie_loading.json', text);

Widget errorBackground(String text) =>
    lottiWidget('assets/json/lottie_error.json', text);

Widget routefailBackground(String text) =>
    lottiWidget('assets/json/lottie_route_fail.json', text);

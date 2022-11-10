// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ridingpartner_flutter/src/provider/map_search_provider.dart';
import 'package:ridingpartner_flutter/main.dart';
import 'package:ridingpartner_flutter/src/utils/user_location.dart';

void main() {
  test('address length sholud be bigger than 1', () async {
    final address =
        await MapSearchProvider().getMyLocationAddress(126.9784147, 37.5666805);

    final length = address.toString();

    expect(length, '서울 중구 태평로1가 31');
  });
}

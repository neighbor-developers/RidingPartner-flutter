import 'package:flutter/material.dart';
import 'dart:developer' as developer;

class RecommendedRoutePage extends StatelessWidget {
  const RecommendedRoutePage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> entries = <String>['A', 'B', 'C'];
    final List<int> colorCodes = <int>[600, 500, 100];

    developer.log('recommend build');
    return Scaffold(
        appBar: AppBar(
          title: const Text('추천 경로'),
        ),
        body: ListView.separated(
          padding: const EdgeInsets.all(8),
          itemCount: entries.length,
          itemBuilder: (BuildContext context, int index) {
            return Container(
              height: 50,
              color: Colors.amber[colorCodes[index]],
              child: Center(child: Text('Entry ${entries[index]}')),
            );
          },
          separatorBuilder: (BuildContext context, int index) =>
              const Divider(),
        ));
  }
}

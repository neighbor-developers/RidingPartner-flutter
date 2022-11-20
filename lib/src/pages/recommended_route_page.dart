import 'dart:math';

import 'package:flutter/material.dart';
import 'dart:developer' as developer;

import 'package:provider/provider.dart';
import 'package:ridingpartner_flutter/src/models/route.dart';
import 'package:ridingpartner_flutter/src/pages/navigation_page.dart';
import 'package:ridingpartner_flutter/src/provider/navigation_provider.dart';
import 'package:ridingpartner_flutter/src/provider/riding_provider.dart';
import 'package:ridingpartner_flutter/src/provider/route_list_provider.dart';

class RecommendedRoutePage extends StatefulWidget {
  const RecommendedRoutePage({super.key});

  @override
  State<StatefulWidget> createState() => RecommendedRoutePageState();
}

class RecommendedRoutePageState extends State<StatefulWidget> {
  @override
  Widget build(BuildContext context) {
    const NUMBER_OF_COLUMNS = 2;
    final routeListProvider = Provider.of<RouteListProvider>(context);
    final state = routeListProvider.state;

    if (state == RouteListState.searching) {
      routeListProvider.getRouteList();
    }

    Widget imageBox(image) => Container(
        padding: const EdgeInsets.only(right: 20),
        width: 80,
        child: Image.asset(image));

    void routeDialog(RidingRoute route) => showDialog(
        context: context,
        //barrierDismissible - Dialog를 제외한 다른 화면 터치 x
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0)),
            //Dialog Main Title
            title: Text(route.title!),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Image.asset(route.image!),
                Text(route.description!),
              ],
            ),
            actions: <Widget>[
              ElevatedButton(
                child: const Text("안내 시작"),
                onPressed: () async {
                  final placeList =
                      await routeListProvider.getPlaceList(route.route!);
                  if (!mounted) return;
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => MultiProvider(
                                providers: [
                                  ChangeNotifierProvider(
                                      create: (context) =>
                                          NavigationProvider(placeList)),
                                  ChangeNotifierProvider(
                                      create: (context) => RidingProvider())
                                ],
                                child: NavigationPage(),
                              )));
                },
              ),
              ElevatedButton(
                child: const Text("뒤로"),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          );
        });

    Widget messageWidget(String message) => Container(
          height: 100,
          alignment: Alignment.center,
          child: Text(
            message,
            style: TextStyle(fontSize: 30),
          ),
        );

    Widget listBox(RidingRoute route) => Container(
          height: 200,
          decoration: BoxDecoration(
              border: Border.all(color: Colors.white),
              color:
                  Colors.primaries[Random().nextInt(Colors.primaries.length)]),
          child: Image.asset(
            route.image!,
            fit: BoxFit.cover,
          ),
        );

    Widget listCard(RidingRoute route) => Container(
        height: 150,
        margin: const EdgeInsets.all(10),
        child: Card(
            semanticContainer: true,
            clipBehavior: Clip.antiAliasWithSaveLayer,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: InkWell(
              onTap: () {
                routeDialog(route);
              },
              child: Image.asset(
                route.image!,
                fit: BoxFit.fill,
              ),
            )));

    Widget routeListWidget() {
      if (state == RouteListState.searching) {
        return messageWidget("Loading");
      } else if (state == RouteListState.empty) {
        return messageWidget("Loading");
      } else {
        final routeList = routeListProvider.routeList;
        return SingleChildScrollView(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(
              NUMBER_OF_COLUMNS,
              (index) => Expanded(
                child: Column(
                  children: List.generate(
                          routeList.length ~/ NUMBER_OF_COLUMNS,
                          (jndex) => listCard(
                              routeList[jndex * NUMBER_OF_COLUMNS + index]))
                      .toList(),
                ),
              ),
            ).toList(),
          ),
        );
      }
    }

    return Scaffold(
        body: Column(
      children: <Widget>[
        Container(
          height: 100,
          alignment: Alignment.center,
          child: const Text(
            '# 추천 경로',
            style: TextStyle(fontSize: 30),
          ),
        ),
        routeListWidget(),
      ],
    ));
  }
}

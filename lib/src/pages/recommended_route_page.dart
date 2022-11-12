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

    Widget routeListWidget2() {
      if (state == RouteListState.searching) {
        return Container(
          height: 100,
          alignment: Alignment.center,
          child: const Text(
            'Loding',
            style: TextStyle(fontSize: 30),
          ),
        );
      } else if (state == RouteListState.empty) {
        return Container(
          height: 100,
          alignment: Alignment.center,
          child: const Text(
            'Empty',
            style: TextStyle(fontSize: 30),
          ),
        );
      } else {
        final routeList = routeListProvider.routeList;
        return Flexible(
          fit: FlexFit.tight,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
            itemCount: routeList.length,
            itemBuilder: (BuildContext context, int index) => InkWell(
                onTap: () {
                  routeDialog(routeList[index]);
                },
                child: SizedBox(
                  height: 50,
                  child: Row(children: [
                    imageBox(routeList[index].image!),
                    Text(routeList[index].title!,
                        style: const TextStyle(fontSize: 17))
                  ]),
                )),
            separatorBuilder: (BuildContext context, int index) =>
                const Divider(),
          ),
        );
      }
    }

    Widget routeListWidget() {
      if (state == RouteListState.searching) {
        return Container(
          height: 100,
          alignment: Alignment.center,
          child: const Text(
            'Loding',
            style: TextStyle(fontSize: 30),
          ),
        );
      } else if (state == RouteListState.empty) {
        return Container(
          height: 100,
          alignment: Alignment.center,
          child: const Text(
            'Empty',
            style: TextStyle(fontSize: 30),
          ),
        );
      } else {
        final routeList = routeListProvider.routeList;
        return SingleChildScrollView(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(
              2,
              (index) => Expanded(
                child: Column(
                  children: List.generate(
                    routeList.length ~/ 2,
                    (jndex) => Container(
                      height: 200,
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.white),
                          color: Colors.primaries[
                              Random().nextInt(Colors.primaries.length)]),
                      child: Image.asset(
                        routeList[jndex * 2 + index].image!,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ).toList(),
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

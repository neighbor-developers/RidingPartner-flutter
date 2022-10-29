import 'package:flutter/material.dart';
import 'dart:developer' as developer;

import 'package:provider/provider.dart';
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

    Widget imageContainer(image) => Container(
        margin: const EdgeInsets.all(5.0),
        width: 50,
        child: Image.network(image));

    Widget textContainer(text) =>
        Container(margin: const EdgeInsets.all(5.0), child: Text(text));

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
        return Flexible(
          fit: FlexFit.tight,
          child: ListView.separated(
            padding: const EdgeInsets.all(8),
            itemCount: routeList.length,
            itemBuilder: (BuildContext context, int index) {
              return SizedBox(
                height: 50,
                child: Row(children: [
                  imageContainer(routeList[index].image!),
                  textContainer(routeList[index].title!)
                ]),
              );
            },
            separatorBuilder: (BuildContext context, int index) =>
                const Divider(),
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

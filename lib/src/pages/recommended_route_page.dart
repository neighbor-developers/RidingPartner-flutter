import 'package:flutter/material.dart';
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

    void routeDialog(RidingRoute route) => showModalBottomSheet<void>(
        context: context,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15.0),
                topRight: Radius.circular(15.0))),
        builder: (BuildContext context) => Container(
              padding: const EdgeInsets.fromLTRB(20, 30, 20, 0),
              height: 500,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    route.title!,
                    style:
                        TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    route.description!,
                  ),
                  Text(
                    route.route!.join(' > '),
                    style: TextStyle(color: Colors.grey),
                  ),
                  Divider(color: Colors.grey, thickness: 1.0),
                  Image.asset(route.image!),
                  Text(route.description!),
                  InkWell(
                    onTap: () async {
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
                    child: Container(
                        width: double.infinity,
                        height: 60,
                        color: Colors.cyan,
                        child: const Text("안내 시작")),
                  )
                ],
              ),
            )
        // return AlertDialog(
        //   shape: RoundedRectangleBorder(
        //       borderRadius: BorderRadius.circular(10.0)),
        //   //Dialog Main Title
        //   title: Text(route.title!),
        //   content: Column(
        //     mainAxisSize: MainAxisSize.min,
        //     crossAxisAlignment: CrossAxisAlignment.start,
        //     children: <Widget>[
        //       Image.asset(route.image!),
        //       Text(route.description!),
        //     ],
        //   ),
        //   actions: <Widget>[
        //     ElevatedButton(
        //       child: const Text("안내 시작"),
        //       onPressed: () async {
        //         final placeList =
        //             await routeListProvider.getPlaceList(route.route!);
        //         if (!mounted) return;
        //         Navigator.push(
        //             context,
        //             MaterialPageRoute(
        //                 builder: (context) => MultiProvider(
        //                       providers: [
        //                         ChangeNotifierProvider(
        //                             create: (context) =>
        //                                 NavigationProvider(placeList)),
        //                         ChangeNotifierProvider(
        //                             create: (context) => RidingProvider())
        //                       ],
        //                       child: NavigationPage(),
        //                     )));
        //       },
        //     ),
        //     ElevatedButton(
        //       child: const Text("뒤로"),
        //       onPressed: () {
        //         Navigator.pop(context);
        //       },
        //     ),
        //   ],
        // );
        );

    Widget messageWidget(String message) => Container(
          height: 100,
          alignment: Alignment.center,
          child: Text(
            message,
            style: TextStyle(fontSize: 30),
          ),
        );

    Widget listCard(RidingRoute route) => Container(
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
                child: Stack(fit: StackFit.expand, children: <Widget>[
                  Image.asset(
                    route.image!,
                    fit: BoxFit.fill,
                  ),
                  Align(
                      alignment: Alignment.bottomRight,
                      child: Text(
                        route.title! + "  ",
                        style: TextStyle(color: Colors.white),
                      )),
                ]))));

    Widget routeListWidget() {
      if (state == RouteListState.searching) {
        return messageWidget("Loading");
      } else if (state == RouteListState.empty) {
        return messageWidget("Loading");
      } else {
        final routeList = routeListProvider.routeList;
        return Expanded(
            child: GridView.builder(
                scrollDirection: Axis.vertical,
                padding: const EdgeInsets.all(10),
                itemCount: routeList.length,
                itemBuilder: (BuildContext context, index) =>
                    listCard(routeList[index]),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 4 / 3,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10)));
      }
    }

    return Scaffold(
        body: Column(
      children: <Widget>[
        routeListWidget(),
      ],
    ));
  }
}

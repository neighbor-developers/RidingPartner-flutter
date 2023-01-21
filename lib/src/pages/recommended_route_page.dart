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
  late RouteListState state;
  late RouteListProvider routeListProvider;
  @override
  Widget build(BuildContext context) {
    routeListProvider = Provider.of<RouteListProvider>(context);
    state = routeListProvider.state;

    if (state == RouteListState.searching) {
      routeListProvider.getRouteList();
    }

    return Scaffold(
        body: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                recommendTitleWidget(),
                routeListWidget(),
              ],
            )));
  }

  Widget messageWidget(String message) => Container(
        height: 100,
        alignment: Alignment.center,
        child: Text(
          message,
          style: const TextStyle(fontSize: 30),
        ),
      );

  void routeDialog(RidingRoute route) => showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(15.0), topRight: Radius.circular(15.0))),
      builder: (BuildContext context) => Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                  padding: const EdgeInsets.fromLTRB(24, 38, 24, 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        route.title!,
                        style: const TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 24,
                            fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Text(
                        route.description!,
                        style: const TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 14,
                            fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Text(
                        route.route!.join(' > '),
                        style: const TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: Color.fromRGBO(51, 51, 51, 0.5)),
                      ),
                      const SizedBox(height: 16.0),
                      const Divider(
                        color: Color.fromRGBO(233, 236, 239, 1),
                        thickness: 1.0,
                      ),
                      const SizedBox(height: 16.0),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.asset(
                          route.image!,
                          height: 160.0,
                          width: MediaQuery.of(context).size.width,
                          fit: BoxFit.fill,
                        ),
                      ),
                    ],
                  )),
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
                                  child: const NavigationPage(),
                                )));
                  },
                  child: Container(
                      alignment: Alignment.center,
                      width: MediaQuery.of(context).size.width,
                      height: 60,
                      color: const Color.fromRGBO(240, 120, 5, 1),
                      child: const Text('안내 시작',
                          style: TextStyle(
                              fontFamily: 'Pretendard',
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w700))))
            ],
          ));

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

  Widget listCard(RidingRoute route) => Card(
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
            Container(
                alignment: Alignment.bottomRight,
                padding: const EdgeInsets.all(7),
                child: Text("${route.title!}  ",
                    style: const TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w600))),
          ])));

  Widget recommendTitleWidget() => Container(
        margin: const EdgeInsets.fromLTRB(0, 32, 0, 24),
        child: const Text("라이딩파트너와 함께\n오늘도 달려볼까요?",
            style: TextStyle(
                height: 1.4,
                fontFamily: 'Pretendard',
                fontSize: 24,
                fontWeight: FontWeight.w800)),
      );
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ridingpartner_flutter/src/models/route.dart';
import 'package:ridingpartner_flutter/src/screen/navigation_screen.dart';
import 'package:ridingpartner_flutter/src/style/textstyle.dart';
import 'package:ridingpartner_flutter/src/widgets/bottom_modal/route_bottom_modal.dart';

import '../models/place.dart';

// 저장된 라이딩 경로 리스트를 가져오는 Provider
final routeListProvider = FutureProvider((ref) async {
  final routeFromJsonFile =
      await rootBundle.loadString('assets/json/route.json');
  return RouteList.fromJson(routeFromJsonFile).routes ?? <RidingRoute>[];
});

class RecommendedRouteScreen extends ConsumerStatefulWidget {
  const RecommendedRouteScreen({super.key});

  @override
  RecommendedRouteScreenState createState() => RecommendedRouteScreenState();
}

class RecommendedRouteScreenState
    extends ConsumerState<RecommendedRouteScreen> {
  @override
  Widget build(BuildContext context) {
    final routeList = ref.watch(routeListProvider);

    return routeList.when(
      data: (data) => Scaffold(
          body: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  recommendTitleWidget(),
                  RouteGridWidget(
                    routeList: data,
                  ),
                ],
              ))),
      loading: () => Container(
        height: 100,
        alignment: Alignment.center,
        child: const Text(
          'Loading...',
          style: const TextStyle(fontSize: 30),
        ),
      ),
      error: (e, s) => Container(
        height: 100,
        alignment: Alignment.center,
        child: const Text(
          'Error!',
          style: const TextStyle(fontSize: 30),
        ),
      ),
    );
  }

  Widget recommendTitleWidget() => Container(
        margin: const EdgeInsets.fromLTRB(0, 32, 0, 24),
        child: const Text("라이딩파트너와 함께\n오늘도 달려볼까요?",
            style: TextStyles.recommendTitleTextStyle),
      );
}

// 라이딩 경로 리스트를 그리는 위젯
class RouteGridWidget extends ConsumerStatefulWidget {
  const RouteGridWidget({super.key, required this.routeList});

  final List<RidingRoute> routeList;

  @override
  RouteGridWidgetState createState() => RouteGridWidgetState();
}

class RouteGridWidgetState extends ConsumerState<RouteGridWidget> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: GridView.builder(
            scrollDirection: Axis.vertical,
            itemCount: widget.routeList.length,
            itemBuilder: (BuildContext context, index) =>
                listCard(widget.routeList[index]),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 4 / 3,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10)));
  }

  Widget listCard(RidingRoute route) => Card(
      semanticContainer: true,
      clipBehavior: Clip.antiAliasWithSaveLayer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: InkWell(
          onTap: () {
            // 라이딩 경로를 클릭하면 경로 상세 정보를 보여주는 모달을 띄움
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
                    style: TextStyles.recommendCardTextStyle)),
          ])));

  // 경로 상세 정보를 보여주는 모달
  void routeDialog(RidingRoute route) => showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(15.0), topRight: Radius.circular(15.0))),
      builder: (BuildContext context) =>
          RouteBottomModal(route: route, onTap: () => onTapDialog(route)));

  // 경로 상세 정보를 보여주는 모달에서 라이딩 경로를 클릭시 네비게이션 화면으로 이동
  void onTapDialog(RidingRoute route) async {
    final placeStringFromJsonFile =
        await rootBundle.loadString('assets/json/place.json');
    final placeListFromJsonFile =
        PlaceList.fromJson(placeStringFromJsonFile).places ?? <Place>[];
    final placeList = placeListFromJsonFile
        .where((place) => route.route!.contains(place.title))
        .toList();

    if (!mounted) return;
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => NavigationScreen(
            places: placeList,
          ),
        ));
  }
}

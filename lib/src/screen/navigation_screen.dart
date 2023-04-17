import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:ridingpartner_flutter/src/provider/marker_provider.dart';
import 'package:ridingpartner_flutter/src/provider/navigation_provider.dart';
import 'package:ridingpartner_flutter/src/screen/riding_screen.dart';
import 'package:ridingpartner_flutter/src/utils/navigation_icon.dart';
import 'package:wakelock/wakelock.dart';

import '../models/place.dart';
import '../models/record.dart';
import '../service/location_service.dart';
import '../style/palette.dart';
import '../style/textstyle.dart';
import '../widgets/dialog/riding_cancel_dialog.dart';

final navigationProvider = StateNotifierProvider<RouteProvider, NavigationData>(
    (ref) => RouteProvider());
final markerProvider = StateNotifierProvider<MarkerProvider, List<Marker>>(
    (ref) => MarkerProvider());

final polylineCoordinatesProvider = StateProvider<List<LatLng>>((ref) {
  final point = ref.watch(navigationProvider);
  List<PolylineWayPoint>? turnPoints = point.guides
      .map((route) => PolylineWayPoint(location: route.turnPoint ?? ""))
      .toList();
  List<LatLng> pointLatLngs = [];

  for (var element in turnPoints) {
    List<String> latlng = element.location.split(',');
    pointLatLngs.add(LatLng(double.parse(latlng[1]), double.parse(latlng[0])));
  }

  return pointLatLngs;
});

class NavigationScreen extends ConsumerStatefulWidget {
  const NavigationScreen({super.key, required this.places});

  final List<Place> places;

  @override
  NavigationScreenState createState() => NavigationScreenState(); //1
}

class NavigationScreenState extends ConsumerState<NavigationScreen> {
  LocationTrackingMode _locationTrackingMode = LocationTrackingMode.None;
  Completer<NaverMapController> _controller = Completer();
  LatLng initCameraPosition = const LatLng(37.37731944, 126.8050778);
  late String? userProfile;
  double floatingBtnPosition = 140;

  @override
  void initState() {
    ref.refresh(ridingStateProvider);
    ref.refresh(timerProvider);
    ref.refresh(polylineCoordinatesProvider);
    ref.refresh(distanceProvider);
    ref.refresh(recordProvider);
    ref.refresh(pointProvider);
    ref.refresh(calProvider);
    ref.refresh(navigationProvider);
    ref.refresh(markerProvider);

    super.initState();

    try {
      setPosition();
    } catch (e) {
      ref.read(ridingStateProvider.notifier).state = RidingState.error;
      setPosition();
    }

    screenKeepOn();
  }

  Future<void> setPosition() async {
    try {
      MyLocation().getMyCurrentLocation();
      Position? position = MyLocation().position;
      if (position != null) {
        setMapComponent();
      } else {
        throw Exception('위치 정보를 가져올 수 없습니다.');
      }
    } catch (e) {
      rethrow;
    }
  }

  setMapComponent() async {
    ref.read(navigationProvider.notifier).getRoute(widget.places);
    ref.read(markerProvider.notifier).addMarker(widget.places);
  }

  int polylineWidth = 7;

  @override
  Widget build(BuildContext context) {
    final position = ref.watch(positionProvider);
    final ridingState = ref.watch(ridingStateProvider);
    final navigation = ref.watch(navigationProvider);
    final markers = ref.watch(markerProvider);
    final polylinePoints = ref.watch(polylineCoordinatesProvider);

    switch (navigation.state) {
      case SearchRouteState.success:
        return WillPopScope(
            child: Scaffold(
                appBar: appBar(ridingState),
                body: position != null
                    ? Stack(
                        alignment: Alignment.bottomCenter,
                        children: <Widget>[
                          NaverMap(
                            initialCameraPosition: CameraPosition(
                                target: initCameraPosition, zoom: 10),
                            onMapCreated: onMapCreated,
                            pathOverlays: polylinePoints.length > 1
                                ? {
                                    PathOverlay(
                                        PathOverlayId('path'), polylinePoints,
                                        width: polylineWidth,
                                        outlineWidth: 0,
                                        color: const Color.fromARGB(
                                            0xFF, 0xFB, 0x95, 0x32))
                                  }
                                : {},
                            mapType: MapType.Basic,
                            initLocationTrackingMode: _locationTrackingMode,
                            locationButtonEnable: true,
                            markers: markers,
                          ),
                          Positioned(top: 0, child: guideWidget()),
                          if (ridingState == RidingState.before) ...[
                            Positioned(
                                bottom: 0,
                                child: InkWell(
                                  onTap: () async {
                                    try {
                                      ref
                                          .read(ridingStateProvider.notifier)
                                          .state = RidingState.riding;
                                      ref.read(timerProvider.notifier).start();

                                      final controller =
                                          await _controller.future;
                                      await controller.moveCamera(
                                          CameraUpdate.toCameraPosition(
                                              CameraPosition(
                                                  target: LatLng(
                                                      position.latitude,
                                                      position.longitude),
                                                  zoom: 18)));
                                      controller.setLocationTrackingMode(
                                          LocationTrackingMode.Face);
                                    } catch (e) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text('주행을 시작하는 데에 실패했습니다'),
                                        ),
                                      );
                                    }
                                  },
                                  child: Container(
                                    color: Palette.appColor,
                                    alignment: Alignment.center,
                                    width: MediaQuery.of(context).size.width,
                                    height: 61,
                                    child: const Text(
                                      '주행 시작',
                                      style: TextStyles.modalButtonTextStyle,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ))
                          ] else ...[
                            Positioned(
                                bottom: 0,
                                child: RecordBoxWidget(
                                    distanceRecord: recordText('남은거리',
                                        "${((ref.watch(navigationProvider.notifier).remainedDistance / 100).roundToDouble()) / 10}km"))),
                          ],

                          Positioned(
                            bottom: floatingBtnPosition,
                            left: 20,
                            child: FloatingActionButton(
                              heroTag: 'mypos2',
                              backgroundColor: Colors.white,
                              child: const ImageIcon(
                                  AssetImage(
                                      'assets/icons/search_myLocation_button.png'),
                                  color: Color.fromRGBO(240, 120, 5, 1)),
                              onPressed: () async {
                                final controller = await _controller.future;
                                await controller.moveCamera(
                                    CameraUpdate.toCameraPosition(
                                        CameraPosition(
                                            target: LatLng(position.latitude,
                                                position.longitude),
                                            zoom: 18)));
                                controller.setLocationTrackingMode(
                                    LocationTrackingMode.Face);
                              },
                            ),
                          ),
                          // changeButton(_navigationProvider.ridingState)
                        ],
                      )
                    : Container(
                        child: Center(
                          child: Text('위치를 로드할 수 없습니다.'),
                        ),
                      )),
            onWillPop: () async {
              if (ridingState == RidingState.before) {
                Navigator.pop(context);
                return true;
              } else {
                return backDialog('안내를 중단하시겠습니까?\n', '안내종료');
              }
            });
      case SearchRouteState.loading:
        return textContainer('경로를 검색중입니다');
      case SearchRouteState.empty:
        return textContainer('원하는 경로가 없어요!\n다시 검색해주세요');
      case SearchRouteState.fail:
        return textContainer('경로를 불러오는데에 실패했습니다\n네트워크 상태를 체크해주세요');
      case SearchRouteState.locationFail:
        return textContainer('GPS 상태가 원활하지 않습니다.');

      default:
        return textContainer('loading...');
    }
  }

  Widget textContainer(String text) => Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      color: Colors.white,
      child: Center(
          child: Text(text,
              style: TextStyles.descriptionTextStyle,
              textAlign: TextAlign.center)));

  Future<bool> backDialog(String text, String btnText) async {
    return await showDialog(
        context: context,
        barrierDismissible: false,
        useRootNavigator: false,
        builder: (BuildContext context) => RidingCancelDialog(
            text: text,
            btnText: btnText,
            onOkClicked: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            onCancelClicked: () {
              Navigator.pop(context);
            }));
  }

  AppBar appBar(RidingState state) => AppBar(
        shadowColor: const Color.fromRGBO(255, 255, 255, 0.5),
        backgroundColor: Colors.white,
        title: Container(
            padding: const EdgeInsets.fromLTRB(0, 0, 50, 0),
            width: MediaQuery.of(context).size.width,
            alignment: Alignment.center,
            child: Image.asset(
              'assets/icons/logo.png',
              height: 25,
            )),
        leadingWidth: 50,
        leading: IconButton(
          onPressed: () {
            if (state == RidingState.before) {
              Navigator.pop(context);
            } else {
              backDialog('안내를 중단하시겠습니까?\n', '안내종료');
            }
          },
          icon: const Icon(Icons.arrow_back),
          color: const Color.fromRGBO(240, 120, 5, 1),
        ),
        elevation: 10,
      );

  void onMapCreated(NaverMapController controller) {
    if (_controller.isCompleted) _controller = Completer();
    _controller.complete(controller);

    setCamera();
  }

  Widget guideWidget() {
    final route = ref.watch(navigationProvider);
    String iconRoute = turnIcon[route.guides[0].turn] ??
        'assets/icons/navigation_straight.png';

    return route.guides.first.turn != 41 && route.guides.first.turn != 48
        // _ridingProvider.state == RidingState.riding
        ? Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              boxShadow: [
                BoxShadow(
                    spreadRadius: 3,
                    blurRadius: 3,
                    offset: Offset(1, 1),
                    color: Color.fromRGBO(0, 41, 135, 0.047))
              ],
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(15)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(iconRoute,
                    width: 55, height: 55, fit: BoxFit.cover),
                const SizedBox(
                  width: 10,
                ),
                Text(
                  route.guides.first.content ?? "-",
                  style: const TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 32,
                      fontWeight: FontWeight.w600),
                )
              ],
            ))
        : const SizedBox(
            width: 0,
            height: 0,
          );
  }

  Widget ridingProgress() {
    final navigation = ref.watch(navigationProvider.notifier);

    double percent = (navigation.totalDistance - navigation.remainedDistance) /
        navigation.totalDistance;
    return SizedBox(
        width: MediaQuery.of(context).size.width - 80,
        height: 40,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: MediaQuery.of(context).size.width - 80,
              alignment: FractionalOffset(percent, 1 - percent),
              child: FractionallySizedBox(
                  child: Image.asset('assets/icons/riding_character.png',
                      width: 17, height: 17, fit: BoxFit.contain)),
            ),
            LinearPercentIndicator(
              padding: EdgeInsets.zero,
              percent: percent,
              lineHeight: 5,
              barRadius: const Radius.circular(15.0),
              backgroundColor: const Color.fromRGBO(241, 243, 245, 1),
              progressColor: const Color.fromRGBO(240, 120, 5, 1),
              width: MediaQuery.of(context).size.width - 80,
            )
          ],
        ));
  }

  void setCamera() async {
    final route = ref.watch(navigationProvider.notifier);
    final position = ref.watch(positionProvider);
    final controller = await _controller.future;
    LatLng start;
    LatLng end;
    if (route.course.length > 1) {
      start = route.course[0].location;
      end = route.course.last.location;
    } else {
      start = LatLng(
        position!.latitude,
        position!.longitude,
      );
      end = route.course.last.location;
    }
    if (start.latitude <= end.latitude) {
      LatLng temp = start;
      start = end;
      end = temp;
    }
    LatLng northEast = start;
    LatLng southWest = end;

    var nLat, nLon, sLat, sLon;

    if (southWest.latitude <= northEast.latitude) {
      sLat = southWest.latitude;
      nLat = northEast.latitude;
    } else {
      sLat = northEast.latitude;
      nLat = southWest.latitude;
    }
    if (southWest.longitude <= northEast.longitude) {
      sLon = southWest.longitude;
      nLon = northEast.longitude;
    } else {
      sLon = northEast.longitude;
      nLon = southWest.longitude;
    }
    controller.moveCamera(
      CameraUpdate.fitBounds(
        LatLngBounds(
          northeast: LatLng(nLat, nLon),
          southwest: LatLng(sLat, sLon),
        ),
        padding: 48,
      ),
    );
  }

  void screenKeepOn() async {
    if (!(await Wakelock.enabled)) {
      Wakelock.enable();
    }
  }

  void screenKeepOff() async {
    if (await Wakelock.enabled) {
      Wakelock.disable();
    }
  }
}

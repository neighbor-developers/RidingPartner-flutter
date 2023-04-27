import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ridingpartner_flutter/src/provider/marker_provider.dart';
import 'package:ridingpartner_flutter/src/provider/navigation_provider.dart';
import 'package:ridingpartner_flutter/src/screen/riding_screen.dart';
import 'package:ridingpartner_flutter/src/service/location_service.dart';
import 'package:ridingpartner_flutter/src/utils/navigation_icon.dart';
import 'package:wakelock/wakelock.dart';
import 'package:latlong2/latlong.dart' as cal;

import '../models/place.dart';
import '../models/record.dart';
import '../style/palette.dart';
import '../style/textstyle.dart';
import '../utils/cal_distance.dart';
import '../widgets/dialog/riding_cancel_dialog.dart';
import '../widgets/text_background.dart';

final navigationProvider = StateNotifierProvider<RouteProvider, NavigationData>(
    (ref) => RouteProvider());

final markerProvider = StateNotifierProvider<MarkerProvider, List<Marker>>(
    (ref) => MarkerProvider());

final polylineCoordinatesProvider = StateProvider<List<LatLng>>((ref) {
  final point = ref.watch(navigationProvider);
  List<PolylineWayPoint>? turnPoints = point.guides
      .map((route) => PolylineWayPoint(location: route.turnPoint ?? ""))
      .toList();
  final position = ref.read(positionProvider);
  List<LatLng> pointLatLngs =
      position == null ? [] : [LatLng(position.latitude, position!.longitude)];
  for (var element in turnPoints) {
    List<String> latlng = element.location.split(',');
    pointLatLngs.add(LatLng(double.parse(latlng[1]), double.parse(latlng[0])));
  }

  return pointLatLngs;
});

final remainDistanceProvider = StateProvider<double>((ref) => 0.0);

class NavigationScreen extends ConsumerStatefulWidget {
  const NavigationScreen({super.key, required this.places});

  final List<Place> places;

  @override
  NavigationScreenState createState() => NavigationScreenState(); //1
}

class NavigationScreenState extends ConsumerState<NavigationScreen> {
  Completer<NaverMapController> _controller = Completer();
  LatLng initCameraPosition = const LatLng(37.37731944, 126.8050778);
  late String? userProfile;
  double floatingBtnPosition = 140;
  final List<cal.LatLng> _calPoints = [];
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.refresh(timerProvider);
      ref.refresh(ridingStateProvider);
      ref.refresh(recordProvider);
      ref.refresh(distanceProvider);
    });
    ref.read(positionProvider.notifier).getPosition();

    setMapComponent();

    super.initState();
  }

  @override
  void dispose() {
    ref.refresh(markerProvider);
    super.dispose();
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

    if (ridingState == RidingState.riding && position != null) {
      _calPoints.add(cal.LatLng(position.latitude, position.longitude));
      WidgetsBinding.instance.addPostFrameCallback((_) {
        int sumDistance = ref.read(navigationProvider).sumDistance;
        ref.read(remainDistanceProvider.notifier).state =
            sumDistance - calDistanceForList(_calPoints);
        ref.read(distanceProvider.notifier).state =
            calDistanceForList(_calPoints);
      });
    }

    switch (navigation.state) {
      case SearchRouteState.success:
        return WillPopScope(
            child: Scaffold(
                key: _scaffoldKey,
                appBar: appBar(ridingState),
                body: Stack(
                  alignment: Alignment.bottomCenter,
                  children: <Widget>[
                    NaverMap(
                      initialCameraPosition:
                          CameraPosition(target: initCameraPosition, zoom: 10),
                      onMapCreated: onMapCreated,
                      pathOverlays: polylinePoints.length > 1
                          ? {
                              PathOverlay(PathOverlayId('path'), polylinePoints,
                                  width: polylineWidth,
                                  outlineWidth: 0,
                                  color: const Color.fromARGB(
                                      0xFF, 0xFB, 0x95, 0x32))
                            }
                          : {},
                      mapType: MapType.Basic,
                      initLocationTrackingMode: LocationTrackingMode.None,
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
                                screenKeepOn();
                                ref.read(ridingStateProvider.notifier).state =
                                    RidingState.riding;
                                ref.read(timerProvider.notifier).start();
                                ref
                                    .read(navigationProvider.notifier)
                                    .startNav();

                                final controller = await _controller.future;

                                await controller.moveCamera(
                                    CameraUpdate.toCameraPosition(
                                        CameraPosition(
                                            target: LatLng(position!.latitude,
                                                position.longitude),
                                            zoom: 18)));

                                controller.setLocationTrackingMode(
                                    LocationTrackingMode.Face);
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
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
                            type: 1,
                            onStop: () {
                              ref.read(navigationProvider.notifier).stopNav();
                            },
                            onResume: () {
                              ref.read(navigationProvider.notifier).startNav();
                            },
                          )),
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
                          controller.setLocationTrackingMode(
                              LocationTrackingMode.Face);
                        },
                      ),
                    ),
                    // changeButton(_navigationProvider.ridingState)
                  ],
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
        return loadingBackground('경로 검색중');
      case SearchRouteState.empty:
        return errorBackground('원하는 경로가 없어요!\n다시 검색해주세요');
      case SearchRouteState.fail:
        return errorBackground('경로를 불러오는데에 실패했습니다\n네트워크 상태를 체크해주세요');
      case SearchRouteState.locationFail:
        return errorBackground('GPS 상태가 원활하지 않습니다.');

      default:
        return loadingBackground('경로 검색중');
    }
  }

  Future<bool> backDialog(String text, String btnText) async {
    return await showDialog(
        context: _scaffoldKey.currentContext!,
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
            height: MediaQuery.of(context).size.height * 0.1,
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
                    width: MediaQuery.of(context).size.height * 0.1 - 34,
                    height: MediaQuery.of(context).size.height * 0.1 - 34,
                    fit: BoxFit.fitHeight),
                const SizedBox(
                  width: 10,
                ),
                Text(
                  route.guides.first.content == null ||
                          route.guides.first.content == ''
                      ? "dsadasdasdasd"
                      : route.guides.first.content!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 28,
                      color: Colors.black87,
                      fontWeight: FontWeight.w600),
                )
              ],
            ))
        : const SizedBox(
            width: 0,
            height: 0,
          );
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
        position.longitude,
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

    double nLat, nLon, sLat, sLon;

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

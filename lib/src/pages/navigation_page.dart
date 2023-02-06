import 'dart:async';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:ridingpartner_flutter/src/pages/record_page.dart';
import 'package:ridingpartner_flutter/src/provider/navigation_provider.dart';
import 'package:ridingpartner_flutter/src/provider/riding_provider.dart';
import 'package:ridingpartner_flutter/src/provider/riding_result_provider.dart';
import 'package:ridingpartner_flutter/src/utils/navigation_icon.dart';
import 'package:ridingpartner_flutter/src/utils/timestampToText.dart';
import 'package:ridingpartner_flutter/src/widgets/dialog.dart';
import 'package:wakelock/wakelock.dart';

class NavigationPage extends StatefulWidget {
  const NavigationPage({super.key});

  @override
  State<NavigationPage> createState() => _NavigationPageState(); //1
}

class _NavigationPageState extends State<NavigationPage> {
  late NavigationProvider _navigationProvider;
  late RidingProvider _ridingProvider;

  LocationTrackingMode _locationTrackingMode = LocationTrackingMode.NoFollow;
  late List<Marker> _markers = [];
  late OverlayImage _markerIcon;
  Completer<NaverMapController> _controller = Completer();
  LatLng initCameraPosition = const LatLng(37.37731944, 126.8050778);
  late String? userProfile;
  double bearing = 180;

  @override
  void initState() {
    super.initState();
    _navigationProvider =
        Provider.of<NavigationProvider>(context, listen: false);

    setMapComponent();
  }

  setMapComponent() async {
    await _navigationProvider.getRoute();
    setRouteMarkers();

    if (_navigationProvider.position != null) {
      initCameraPosition = LatLng(
          (_navigationProvider.position!.latitude +
                  double.parse(_navigationProvider.course.last.latitude!)) /
              2,
          ((_navigationProvider.position!.longitude) +
                  double.parse(_navigationProvider.course.last.longitude!)) /
              2);
      _markerIcon = await OverlayImage.fromAssetImage(
          assetName: 'assets/icons/my_location.png');

      _markers.add(Marker(
        icon: _markerIcon,
        width: 45,
        height: 45,
        markerId: "currentPosition",
        position: LatLng(_navigationProvider.position!.latitude,
            _navigationProvider.position!.longitude),
      ));
    } else {
      initCameraPosition = const LatLng(37.37731944, 126.8050778);
    }
  }

  Future setRouteMarkers() async {
    final OverlayImage turnMarkerIcon = await OverlayImage.fromAssetImage(
        assetName: 'assets/icons/marker_orange.png');
    final OverlayImage startMarkerIcon = await OverlayImage.fromAssetImage(
        assetName: 'assets/icons/marker_start.png');
    final OverlayImage destinationMarkerIcon =
        await OverlayImage.fromAssetImage(
            assetName: 'assets/icons/marker_destination.png');

    _markers = _navigationProvider.course
        .map((course) => Marker(
            width: 30,
            height: 40,
            icon: turnMarkerIcon,
            markerId: course.title ?? "",
            position: LatLng(double.parse(course.latitude!),
                double.parse(course.longitude!))))
        .toList();

    _markers[0] = Marker(
        icon: startMarkerIcon,
        width: 30,
        height: 50,
        markerId: _navigationProvider.course[0].title ?? "",
        position: LatLng(double.parse(_navigationProvider.course[0].latitude!),
            double.parse(_navigationProvider.course[0].longitude!)));

    _markers.last = Marker(
        icon: destinationMarkerIcon,
        width: 30,
        height: 50,
        markerId: _navigationProvider.course.last.title ?? "",
        position: LatLng(
            double.parse(_navigationProvider.course.last.latitude!),
            double.parse(_navigationProvider.course[0].longitude!)));
  }

  int polylineWidth = 6;
  TextStyle plainStyle = const TextStyle(
      fontSize: 12,
      fontFamily: 'Pretendard',
      fontWeight: FontWeight.w500,
      color: Color.fromRGBO(17, 17, 17, 1));

  @override
  Widget build(BuildContext context) {
    _navigationProvider = Provider.of<NavigationProvider>(context);
    _ridingProvider = Provider.of<RidingProvider>(context);
    Position? position = _navigationProvider.position;

    if (_ridingProvider.state == RidingState.riding) {
      if (position != null) {
        _markers = [
          Marker(
              anchor: AnchorPoint(0.5, 0.5),
              markerId: "currentLocation",
              width: 45,
              height: 45,
              icon: _markerIcon,
              position: LatLng(position.latitude, position.longitude))
        ];
      }
      if (_locationTrackingMode != LocationTrackingMode.Face) {
        _locationTrackingMode = LocationTrackingMode.Face;
      }
    }

    Widget failMessageWidget() {
      switch (_navigationProvider.searchRouteState) {
        case SearchRouteState.loading:
          return const Center(
            child: CircularProgressIndicator(
                color: Color.fromARGB(0xFF, 0xFB, 0x95, 0x32)),
          );
        case SearchRouteState.empty:
          return Center(
              child: Text("원하는 경로가 없어요!\n다시 검색해주세요",
                  style: plainStyle, textAlign: TextAlign.center));
        case SearchRouteState.fail:
          return Center(
              child: Text("경로를 불러오는데에 실패했습니다\n네트워크 상태를 체크해주세요",
                  style: plainStyle, textAlign: TextAlign.center));
        case SearchRouteState.locationFail:
          return Center(
              child: Text("GPS 상태가 원활하지 않습니다.",
                  style: plainStyle, textAlign: TextAlign.center));
        default:
          return Center(
              child: Text("같은 에러가 반복되면 문의해주세요",
                  style: plainStyle, textAlign: TextAlign.center));
      }
    }

    return WillPopScope(
        child: Scaffold(
            appBar: AppBar(
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
                  if (_navigationProvider.ridingState == RidingState.before) {
                    Navigator.pop(context);
                  } else {
                    backDialog(context, 2);
                  }
                },
                icon: const Icon(Icons.arrow_back),
                color: const Color.fromRGBO(240, 120, 5, 1),
              ),
              elevation: 10,
            ),
            body:
                _navigationProvider.searchRouteState == SearchRouteState.success
                    ? Stack(
                        alignment: Alignment.bottomCenter,
                        children: <Widget>[
                          NaverMap(
                            onMapCreated: onMapCreated,
                            initialCameraPosition:
                                CameraPosition(target: initCameraPosition),
                            pathOverlays:
                                _navigationProvider.polylinePoints.length > 1
                                    ? {
                                        PathOverlay(PathOverlayId('path'),
                                            _navigationProvider.polylinePoints,
                                            width: polylineWidth,
                                            outlineWidth: 0,
                                            color: const Color.fromARGB(
                                                0xFF, 0xFB, 0x95, 0x32))
                                      }
                                    : {},
                            mapType: MapType.Basic,
                            initLocationTrackingMode: _locationTrackingMode,
                            locationButtonEnable: false,
                            markers: _markers,
                          ),
                          Positioned(top: 0, child: guideWidget()),
                          Positioned(
                              bottom: 0, child: record(_ridingProvider.state))
                          // changeButton(_navigationProvider.ridingState)
                        ],
                      )
                    : failMessageWidget()),
        onWillPop: () async {
          if (_navigationProvider.ridingState == RidingState.before) {
            Navigator.pop(context);
            return true;
          } else {
            return backDialog(context, 2);
          }
        });
  }

  void onMapCreated(NaverMapController controller) {
    if (_controller.isCompleted) _controller = Completer();
    _controller.complete(controller);
    if (_navigationProvider.course.length > 1) {
      LatLng start = LatLng(
          double.parse(_navigationProvider.course[0].latitude!),
          double.parse(_navigationProvider.course[0].longitude!));
      LatLng end = LatLng(
          double.parse(_navigationProvider.course.last.latitude!),
          double.parse(_navigationProvider.course.last.longitude!));
      // try {
      //   controller.moveCamera(CameraUpdate.fitBounds(
      //     LatLngBounds(southwest: start, northeast: end),
      //     padding: 48,
      //   ));
      // } catch (e) {
      //   controller.moveCamera(CameraUpdate.fitBounds(
      //     LatLngBounds(southwest: start, northeast: end),
      //     padding: 48,
      //   ));
      // }
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
  }

  Widget guideWidget() {
    String iconRoute = turnIcon[_navigationProvider.goalPoint.turn] ??
        'assets/icons/navigation_straight.png';

    return _navigationProvider.goalPoint.turn != 41 &&
            _navigationProvider.goalPoint.turn != 48 &&
            _ridingProvider.state == RidingState.riding
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
                  _navigationProvider.goalPoint.content ?? "-",
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

  Widget record(RidingState state) {
    const TextStyle titleStyle = TextStyle(
        fontFamily: 'Pretendard',
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: Color.fromRGBO(134, 142, 150, 1));
    const TextStyle dataStyle = TextStyle(
        fontFamily: 'Pretendard',
        fontSize: 18,
        fontWeight: FontWeight.w400,
        color: Color.fromRGBO(52, 58, 64, 1));

    if (state == RidingState.before) {
      return InkWell(
        child: Container(
          color: const Color.fromRGBO(240, 120, 5, 1),
          alignment: Alignment.center,
          width: MediaQuery.of(context).size.width,
          height: 61,
          child: const Text(
            '안내 시작',
            style: TextStyle(
                color: Colors.white,
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.w700,
                fontSize: 18),
            textAlign: TextAlign.center,
          ),
        ),
        onTap: () {
          _ridingProvider.startRiding();
          _navigationProvider.startNavigation();
          screenKeepOn();
          polylineWidth = 8;
        },
      );
    } else {
      return Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              AnimatedContainer(
                curve: Curves.fastOutSlowIn,
                duration: const Duration(milliseconds: 300),
                transform: Matrix4.translationValues(
                    0, _navigationProvider.visivility ? 0 : 140, 0),
                child: buttons(state),
              ),
              Container(
                height: 140,
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                        spreadRadius: 1,
                        blurRadius: 3,
                        offset: Offset(1, 1),
                        color: Color.fromRGBO(0, 41, 135, 0.047))
                  ],
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ridingProgress(),
                    Container(
                        width: MediaQuery.of(context).size.width - 80,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Text('남은거리', style: titleStyle),
                                Text(
                                  ("${(((_navigationProvider.remainedDistance) / 100).roundToDouble()) / 10}km")
                                      .toString(),
                                  style: dataStyle,
                                )
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Text(
                                  '주행 속도',
                                  style: titleStyle,
                                ),
                                Text(
                                  "${_ridingProvider.speed.roundToDouble()}km/h",
                                  style: dataStyle,
                                )
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Text(
                                  '주행 시간',
                                  style: titleStyle,
                                ),
                                Text(
                                  timestampToText(
                                      _ridingProvider.time.inSeconds),
                                  style: dataStyle,
                                )
                              ],
                            ),
                            InkWell(
                              onTap: () {
                                _navigationProvider.setVisivility();
                              },
                              child: SizedBox(
                                width: 18,
                                child: Image.asset('assets/icons/menu_bar.png',
                                    fit: BoxFit.fitWidth),
                              ),
                            )
                          ],
                        ))
                  ],
                ),
              )
            ],
          ));
    }
  }

  Widget ridingProgress() {
    double distance = (_ridingProvider.distance ~/ 100) / 10;
    double percent = (_navigationProvider.totalDistance -
            _navigationProvider.remainedDistance) /
        _navigationProvider.totalDistance;
    return SizedBox(
        width: MediaQuery.of(context).size.width - 80,
        height: 40,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
                width: MediaQuery.of(context).size.width - 80,
                alignment: FractionalOffset(percent, 1 - percent),
                child: Column(
                  children: [
                    FractionallySizedBox(
                        child: Image.asset('assets/icons/riding_character.png',
                            width: 17, height: 17, fit: BoxFit.contain)),
                    Text(
                      '${distance}km',
                      style: const TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 10,
                          fontWeight: FontWeight.w400),
                    ),
                  ],
                )),
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

  Widget buttons(RidingState state) {
    String text = "일시정지";
    const TextStyle testStyle = TextStyle(
        color: Color.fromRGBO(52, 58, 64, 1),
        fontFamily: 'Pretended',
        fontWeight: FontWeight.w600,
        fontSize: 16);

    switch (state) {
      case RidingState.riding:
        {
          text = "일시중지";
          break;
        }
      case RidingState.pause:
        {
          text = "이어서 시작";
          break;
        }
      default:
    }
    if (state != RidingState.before) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          InkWell(
              onTap: () {
                _navigationProvider.setVisivility();
                if (state == RidingState.riding) {
                  _ridingProvider.pauseRiding();
                  _navigationProvider.setState(RidingState.pause);
                } else {
                  _ridingProvider.startRiding();
                  _navigationProvider.setState(RidingState.riding);
                }
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: const BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                        spreadRadius: 1,
                        blurRadius: 3,
                        offset: Offset(1, 1),
                        color: Color.fromRGBO(0, 41, 135, 0.047))
                  ],
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(7)),
                ),
                child: Text(text, style: testStyle),
              )),
          InkWell(
            onTap: () {
              screenKeepOff();
              _ridingProvider.stopAndSaveRiding();
              _navigationProvider.setState(RidingState.stop);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ChangeNotifierProvider(
                            create: (context) => RidingResultProvider(
                                _ridingProvider.ridingDate),
                            child: RecordPage(),
                          )));
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              margin: const EdgeInsets.symmetric(vertical: 15),
              decoration: const BoxDecoration(
                boxShadow: [
                  BoxShadow(
                      spreadRadius: 1,
                      blurRadius: 3,
                      offset: Offset(1, 1),
                      color: Color.fromRGBO(0, 41, 135, 0.047))
                ],
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(7)),
              ),
              child: const Text('종료', style: testStyle),
            ),
          )
        ],
      );
    } else {
      return const SizedBox(
        height: 0,
        width: 0,
      );
    }
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

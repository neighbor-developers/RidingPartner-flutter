import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
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

  Completer<GoogleMapController> _controller = Completer();
  LatLng initCameraPosition = const LatLng(37.37731944, 126.8050778);
  Set<Marker> markers = {};
  late String? userProfile;
  double bearing = 180;
  late BitmapDescriptor myPositionIcon;

  @override
  void initState() {
    super.initState();
    FirebaseAuth auth = FirebaseAuth.instance;
    userProfile = auth.currentUser?.photoURL;

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
      final Uint8List markerIcon = await _navigationProvider.getBytesFromAsset(
          'assets/icons/my_location.png', 200);

      myPositionIcon = BitmapDescriptor.fromBytes(markerIcon);

      markers.add(Marker(
        anchor: const Offset(0, 0),
        icon: BitmapDescriptor.fromBytes(markerIcon),
        markerId: const MarkerId("currentPosition"),
        position: LatLng(_navigationProvider.position!.latitude,
            _navigationProvider.position!.longitude),
      ));
    } else {
      initCameraPosition = const LatLng(37.37731944, 126.8050778);
    }
  }

  Future setRouteMarkers() async {
    final Uint8List turnMarkerIcon = await _navigationProvider
        .getBytesFromAsset('assets/icons/marker_orange.png', 80);
    final Uint8List startMarkerIcon = await _navigationProvider
        .getBytesFromAsset('assets/icons/marker_start.png', 80);
    final Uint8List destinationMarkerIcon = await _navigationProvider
        .getBytesFromAsset('assets/icons/marker_destination.png', 80);

    List<Marker> markerList = _navigationProvider.course
        .map((course) => Marker(
            icon: BitmapDescriptor.fromBytes(turnMarkerIcon),
            markerId: MarkerId(course.title ?? ""),
            position: LatLng(double.parse(course.latitude!),
                double.parse(course.longitude!))))
        .toList();

    markerList[0] = Marker(
        icon: BitmapDescriptor.fromBytes(startMarkerIcon),
        markerId: MarkerId(_navigationProvider.course[0].title ?? ""),
        position: LatLng(double.parse(_navigationProvider.course[0].latitude!),
            double.parse(_navigationProvider.course[0].longitude!)));

    markerList.last = Marker(
        icon: BitmapDescriptor.fromBytes(destinationMarkerIcon),
        markerId: MarkerId(_navigationProvider.course.last.title ?? ""),
        position: LatLng(
            double.parse(_navigationProvider.course.last.latitude!),
            double.parse(_navigationProvider.course[0].longitude!)));

    markers = markerList.toSet();
  }

  String floatBtnLabel = "일시중지";
  IconData floatBtnIcon = Icons.pause;
  int polylineWidth = 5;
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

    void setController() async {
      GoogleMapController googleMapController = await _controller.future;
      if (position != null) {
        if (_navigationProvider.bearingPoint != null) {
          bearing = Geolocator.bearingBetween(
              position.latitude,
              position.longitude,
              _navigationProvider.bearingPoint!.latitude,
              _navigationProvider.bearingPoint!.longitude);
        }
        googleMapController.animateCamera(CameraUpdate.newCameraPosition(
            CameraPosition(
                target: LatLng(position.latitude, position.longitude),
                zoom: 19,
                bearing: bearing)));

        markers.removeWhere((element) => element.markerId == "currentPosition");
        markers.add(Marker(
            icon: myPositionIcon,
            markerId: const MarkerId("currentPosition"),
            position: LatLng(position.latitude, position.longitude)));
      }
    }

    if (_ridingProvider.state == RidingState.riding) {
      setController();
    }

    return WillPopScope(
        child: Scaffold(
            appBar: AppBar(
              shadowColor: const Color.fromRGBO(255, 255, 255, 0.5),
              backgroundColor: Colors.white,
              title: Image.asset(
                'assets/icons/logo.png',
                width: 100,
              ),
              elevation: 10,
              leading: IconButton(
                onPressed: () {
                  if (_navigationProvider.ridingState == RidingState.before) {
                    Navigator.pop(context);
                  } else {
                    backDialog(context, "안내를 중단하시겠습니까?");
                  }
                },
                icon: const Icon(Icons.arrow_back),
                color: const Color.fromRGBO(240, 120, 5, 1),
              ),
            ),
            floatingActionButton: floatingButtons(_ridingProvider.state),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.miniEndFloat,
            body: _navigationProvider.searchRouteState ==
                    SearchRouteState.loading
                ? const Center(
                    child: CircularProgressIndicator(
                        color: Color.fromARGB(0xFF, 0xFB, 0x95, 0x32)),
                  )
                : _navigationProvider.searchRouteState == SearchRouteState.empty
                    ? Center(
                        child: Text("원하는 경로가 없어요!\n다시 검색해주세요",
                            style: plainStyle, textAlign: TextAlign.center))
                    : _navigationProvider.searchRouteState ==
                            SearchRouteState.fail
                        ? Center(
                            child: Text("경로를 불러오는데에 실패했습니다\n네트워크 상태를 체크해주세요",
                                style: plainStyle, textAlign: TextAlign.center))
                        : _navigationProvider.searchRouteState ==
                                SearchRouteState.locationFail
                            ? Center(
                                child: Text("GPS 상태가 원활하지 않습니다.",
                                    style: plainStyle,
                                    textAlign: TextAlign.center))
                            : Stack(
                                alignment: Alignment.bottomCenter,
                                children: <Widget>[
                                  GoogleMap(
                                    mapType: MapType.normal,
                                    initialCameraPosition: CameraPosition(
                                        target: initCameraPosition, zoom: 13),
                                    polylines: {
                                      Polyline(
                                          polylineId: const PolylineId("route"),
                                          color: const Color.fromARGB(
                                              0xFF, 0xFB, 0x95, 0x32),
                                          width: polylineWidth,
                                          startCap: Cap.roundCap,
                                          endCap: Cap.roundCap,
                                          points: _navigationProvider
                                              .polylinePoints)
                                    },
                                    onMapCreated:
                                        (GoogleMapController controller) {
                                      _controller.complete(controller);
                                    },
                                    myLocationButtonEnabled: false,
                                    myLocationEnabled: false,
                                    markers: markers,
                                    compassEnabled: false,
                                  ),
                                  Positioned(top: 0, child: guideWidget()),
                                  Positioned(
                                      bottom: 0,
                                      child: record(_ridingProvider.state))
                                  // changeButton(_navigationProvider.ridingState)
                                ],
                              )),
        onWillPop: () {
          return backDialog(context, "안내를 중단하시겠습니까?");
        });
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
        : SizedBox(
            width: 0,
            height: 0,
          );
  }

  Widget record(RidingState state) {
    if (state == RidingState.before) {
      return InkWell(
        child: Container(
          color: Color.fromRGBO(240, 120, 5, 1),
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
          alignment: Alignment.center,
          height: 140,
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
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
          child: ridingRecord());
    }
  }

  Widget ridingRecord() {
    return Column(
      children: [
        ridingProgress(),
        Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text('남은거리'),
                Text(((((_navigationProvider.remainedDistance) / 100)
                            .roundToDouble()) /
                        10)
                    .toString())
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text('주행 속도'),
                Text(_ridingProvider.speed.roundToDouble().toString())
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text('주행 시간'),
                Text(timestampToText(_ridingProvider.time.inSeconds))
              ],
            )
          ],
        )
      ],
    );
  }

  Widget ridingProgress() {
    double distance = (_ridingProvider.distance ~/ 100) / 10;
    double percent = (_navigationProvider.totalDistance -
            _navigationProvider.remainedDistance) /
        _navigationProvider.totalDistance;
    return Column(
      children: [
        Container(
            width: MediaQuery.of(context).size.width,
            alignment: FractionalOffset(percent, 1 - percent),
            child: Column(
              children: [
                FractionallySizedBox(
                    child: Image.asset('assets/icons/riding_character.png',
                        width: 17, height: 17, fit: BoxFit.fitHeight)),
                Text('${distance}km'),
              ],
            )),
        LinearPercentIndicator(
          padding: EdgeInsets.zero,
          percent: percent,
          lineHeight: 10,
          linearStrokeCap: LinearStrokeCap.round,
          backgroundColor: const Color.fromRGBO(241, 243, 245, 1),
          progressColor: const Color.fromRGBO(240, 120, 5, 1),
          width: MediaQuery.of(context).size.width,
        )
      ],
    );
  }

  Widget? floatingButtons(RidingState state) {
    switch (state) {
      case RidingState.riding:
        {
          floatBtnLabel = "일시중지";
          floatBtnIcon = Icons.pause;
          break;
        }
      case RidingState.pause:
        {
          floatBtnLabel = "재시작";
          floatBtnIcon = Icons.restart_alt;
          break;
        }
      default:
    }
    if (state != RidingState.before) {
      return SpeedDial(
        animatedIcon: AnimatedIcons.menu_close,
        visible: true,
        curve: Curves.bounceIn,
        backgroundColor: const Color.fromARGB(0xFF, 0xFB, 0x95, 0x32),
        children: [
          SpeedDialChild(
              child: Icon(floatBtnIcon, color: Colors.white),
              label: floatBtnLabel,
              labelStyle: const TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                  fontSize: 13.0),
              backgroundColor: const Color.fromARGB(0xFF, 0xFB, 0x95, 0x32),
              labelBackgroundColor:
                  const Color.fromARGB(0xFF, 0xFB, 0x95, 0x32),
              onTap: () {
                if (state == RidingState.riding) {
                  _ridingProvider.pauseRiding();
                  _navigationProvider.setState(RidingState.pause);
                } else {
                  _ridingProvider.startRiding();
                  _navigationProvider.setState(RidingState.riding);
                }
              }),
          SpeedDialChild(
            child: const Icon(
              Icons.stop,
              color: Colors.white,
            ),
            label: "종료",
            backgroundColor: const Color.fromARGB(0xFF, 0xFB, 0x95, 0x32),
            labelBackgroundColor: const Color.fromARGB(0xFF, 0xFB, 0x95, 0x32),
            labelStyle: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.white,
                fontSize: 13.0),
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
          )
        ],
      );
    } else {
      return null;
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

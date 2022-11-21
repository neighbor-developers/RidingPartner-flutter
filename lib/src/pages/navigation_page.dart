import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk_share.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:ridingpartner_flutter/src/provider/navigation_provider.dart';
import 'package:ridingpartner_flutter/src/provider/riding_provider.dart';
import 'package:ridingpartner_flutter/src/widgets/dialog.dart';

class NavigationPage extends StatefulWidget {
  const NavigationPage({super.key});

  @override
  State<NavigationPage> createState() => _NavigationPageState(); //1
}

class _NavigationPageState extends State<NavigationPage> {
  late NavigationProvider _navigationProvider;
  late RidingProvider _ridingProvider;

  Completer<GoogleMapController> _controller = Completer();
  late LatLng initCameraPosition;
  late Set<Marker> markers;
  late String? userProfile;
  double bearing = 180;
  late BitmapDescriptor myPositionIcon;

  @override
  void initState() {
    FirebaseAuth auth = FirebaseAuth.instance;
    userProfile = auth.currentUser?.photoURL;

    _navigationProvider =
        Provider.of<NavigationProvider>(context, listen: false);

    setMapComponent();
    super.initState();
  }

  setMapComponent() async {
    await _navigationProvider.getRoute();

    markers = _navigationProvider.course
        .map((course) => Marker(
            markerId: MarkerId(course.title ?? ""),
            position: LatLng(double.parse(course.latitude!),
                double.parse(course.longitude!))))
        .toSet();

    if (_navigationProvider.position != null) {
      initCameraPosition = LatLng(
          (_navigationProvider.position!.latitude +
                  double.parse(_navigationProvider.course.last.latitude!)) /
              2,
          ((_navigationProvider.position!.longitude) +
                  double.parse(_navigationProvider.course.last.longitude!)) /
              2);
      myPositionIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(),
        'assets/icons/cycling_person.png',
      ).catchError((e) {
        print(e.toString());
      });

      markers.add(Marker(
          icon: myPositionIcon,
          markerId: MarkerId("currentPosition"),
          position: LatLng(_navigationProvider.position!.latitude,
              _navigationProvider.position!.longitude)));
    } else {
      initCameraPosition = LatLng(37.339985, 126.733378);
    }
  }

  String floatBtnLabel = "일시중지";
  IconData floatBtnIcon = Icons.pause;

  @override
  Widget build(BuildContext context) {
    _navigationProvider = Provider.of<NavigationProvider>(context);
    _ridingProvider = Provider.of<RidingProvider>(context);

    Position? position = _navigationProvider.position;

    void _setController() async {
      GoogleMapController _googleMapController = await _controller.future;
      if (position != null) {
        if (_navigationProvider.nextLatLng != null) {
          bearing = Geolocator.bearingBetween(
              position.latitude,
              position.longitude,
              _navigationProvider.nextLatLng!.latitude,
              _navigationProvider.nextLatLng!.longitude);
        }
        _googleMapController.animateCamera(CameraUpdate.newCameraPosition(
            CameraPosition(
                target: LatLng(position.latitude, position.longitude),
                zoom: 19,
                bearing: bearing)));

        markers.removeWhere((element) => element.markerId == "currentPosition");
        markers.add(Marker(
            icon: myPositionIcon,
            markerId: MarkerId("currentPosition"),
            position: LatLng(position.latitude, position.longitude)));
      }
    }

    if (_navigationProvider.ridingState != RidingState.before) {
      _setController();
    }

    return WillPopScope(
        child: Scaffold(
            extendBodyBehindAppBar: true,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                onPressed: () {
                  backDialog(context, "안내를 중단하시겠습니까?");
                },
                icon: Icon(Icons.arrow_back),
                color: Colors.indigo.shade900,
              ),
            ),
            floatingActionButton: floatingButtons(_ridingProvider.state),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.miniEndFloat,
            body: _navigationProvider.route == null
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : Stack(
                    alignment: Alignment.bottomCenter,
                    children: <Widget>[
                      GoogleMap(
                        mapType: MapType.normal,
                        initialCameraPosition: CameraPosition(
                            target: initCameraPosition, zoom: 13),
                        polylines: {
                          Polyline(
                              polylineId: PolylineId("route"),
                              width: 5,
                              points: _navigationProvider.polylinePoints)
                        },
                        onMapCreated: (GoogleMapController controller) {
                          _controller.complete(controller);
                        },
                        myLocationButtonEnabled: false,
                        myLocationEnabled: false,
                        markers: markers,
                        compassEnabled: false,
                      ),
                      Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Column(children: [
                            startButton(_ridingProvider.state),
                            record(),
                            // changeButton(_navigationProvider.ridingState)
                          ])),
                      Positioned(top: 0, child: guideWidget())
                    ],
                  )),
        onWillPop: () {
          return backDialog(context, "안내를 중단하시겠습니까?");
        });
  }

  Widget guideWidget() {
    return Container(
        color: Color.fromARGB(178, 194, 194, 194),
        padding: EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/icons/icon_right.png',
                width: 30, height: 30, fit: BoxFit.cover),
            Text(
              _navigationProvider.route?.first.content ?? "",
              style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            )
          ],
        ));
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
        backgroundColor: Colors.indigo.shade900,
        children: [
          SpeedDialChild(
              child: Icon(floatBtnIcon, color: Colors.white),
              label: floatBtnLabel,
              labelStyle: const TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                  fontSize: 13.0),
              backgroundColor: Colors.indigo.shade900,
              labelBackgroundColor: Colors.indigo.shade900,
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
            child: Icon(
              Icons.stop,
              color: Colors.white,
            ),
            label: "종료",
            backgroundColor: Colors.indigo.shade900,
            labelBackgroundColor: Colors.indigo.shade900,
            labelStyle: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.white,
                fontSize: 13.0),
            onTap: () {
              _ridingProvider.stopAndSaveRiding();
              _navigationProvider.setState(RidingState.stop);
            },
          )
        ],
      );
    } else {
      return null;
    }
  }

  Widget startButton(RidingState state) {
    if (state == RidingState.before) {
      return Container(
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        ElevatedButton(
          onPressed: () {
            _ridingProvider.startRiding();
            _navigationProvider.startNavigation();
          },
          child: Text('시작'),
        ),
      ]));
    } else {
      return Container();
    }
  }

  Widget record() {
    return Column(
      children: [
        ridingProgress(),
        Container(
          height: 100,
          color: Colors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "남은거리 : ${((((_navigationProvider.remainedDistance) / 100).roundToDouble()) / 10).toString()}, 속도 : ${_ridingProvider.speed.toString()}",
                style: TextStyle(fontSize: 20, color: Colors.indigo.shade900),
              )
            ],
          ),
        )
      ],
    );
  }

  Widget ridingProgress() {
    double percent = (_navigationProvider.totalDistance -
            _navigationProvider.remainedDistance) /
        _navigationProvider.totalDistance;
    return Column(
      children: [
        Container(
          alignment: FractionalOffset(percent, 1 - percent),
          child: FractionallySizedBox(
              child: Image.asset('assets/icons/cycling_person.png',
                  width: 30, height: 30, fit: BoxFit.cover)),
        ),
        LinearPercentIndicator(
          padding: EdgeInsets.zero,
          percent: percent,
          lineHeight: 10,
          backgroundColor: Colors.black38,
          progressColor: Colors.indigo.shade900,
          width: MediaQuery.of(context).size.width,
        )
      ],
    );
  }
}

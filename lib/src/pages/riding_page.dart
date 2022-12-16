import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:ridingpartner_flutter/src/pages/record_page.dart';
import 'package:ridingpartner_flutter/src/provider/riding_provider.dart';
import 'package:wakelock/wakelock.dart';

import '../provider/riding_result_provider.dart';
import '../utils/user_location.dart';
import '../widgets/dialog.dart';

// https://funncy.github.io/flutter/2020/07/21/flutter-google-map-marker/

class RidingPage extends StatefulWidget {
  const RidingPage({super.key});

  @override
  State<RidingPage> createState() => _RidingPageState();
}

class _RidingPageState extends State<RidingPage> {
  late Completer<GoogleMapController> _controller = Completer();
  late RidingProvider _ridingProvider;

  final myLocation = MyLocation();

  String floatBtnLabel = "일시중지";
  IconData floatBtnIcon = Icons.pause;

  @override
  Widget build(BuildContext context) {
    _ridingProvider = Provider.of<RidingProvider>(context);
    Position? position = _ridingProvider.position;

    void _setController() async {
      GoogleMapController googleMapController = await _controller.future;
      if (position != null) {
        googleMapController.animateCamera(CameraUpdate.newCameraPosition(
            CameraPosition(
                zoom: 19,
                target: LatLng(position.latitude, position.longitude))));
      }
    }

    if (_ridingProvider.state != RidingState.before) {
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
            body: Stack(
              children: <Widget>[
                GoogleMap(
                  mapType: MapType.normal,
                  initialCameraPosition: CameraPosition(
                    target: LatLng(myLocation.position?.latitude ?? 37.0,
                        myLocation.position?.longitude ?? 126.0),
                    zoom: 12.6,
                  ),
                  onMapCreated: (GoogleMapController controller) {
                    _controller.complete(controller);
                  },
                  myLocationButtonEnabled: true,
                  myLocationEnabled: true,
                  polylines: {
                    Polyline(
                        polylineId: PolylineId("poly"),
                        width: 5,
                        points: _ridingProvider.polylineCoordinates),
                  },
                  markers: {
                    // Marker(
                    //     markerId: const MarkerId("currentLocation"),
                    //     icon: BitmapDescriptor.fromBytes(),
                    //     position: LatLng(
                    //         _ridingProvider.position?.latitude ?? 37.343991285297,
                    //         _ridingProvider.position?.longitude ?? 126.74729588817))
                  },
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
                Positioned(
                  // 위치 지정하기
                  child: FractionallySizedBox(
                      alignment: Alignment.bottomLeft,
                      widthFactor: 0.5,
                      heightFactor: 0.23,
                      child: Container(
                        color: Colors.white,
                        child: Column(
                          children: <Widget>[
                            Row(children: <Widget>[
                              Padding(
                                  padding: const EdgeInsets.all(5),
                                  child: SizedBox(
                                      child: Text("${_ridingProvider.speed}",
                                          style:
                                              const TextStyle(fontSize: 23)))),
                              //Spacer(flex: ),
                              const Text("속도")
                            ]),
                            Row(children: <Widget>[
                              Padding(
                                  padding: const EdgeInsets.all(5),
                                  child: SizedBox(
                                      child: Text(
                                          "${_ridingProvider.distance}km",
                                          style:
                                              const TextStyle(fontSize: 23)))),
                              const Text("거리")
                            ]),
                            Row(children: <Widget>[
                              Padding(
                                  padding: const EdgeInsets.all(5),
                                  child: SizedBox(
                                      child: Text(
                                          "${_ridingProvider.speed}km/h",
                                          style:
                                              const TextStyle(fontSize: 23)))),
                              const Text("평균속도")
                            ]),
                            Row(children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.all(5),
                                child: SizedBox(
                                    child: Text(
                                        "${_ridingProvider.time}"
                                            .substring(0, 7),
                                        style: const TextStyle(fontSize: 23))),
                              ),
                              const Text("시간")
                            ])
                          ],
                        ),
                      )),
                ),
              ],
            )),
        onWillPop: () {
          return backDialog(context, "라이딩를 중단하시겠습니까?");
        });
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
                } else {
                  _ridingProvider.startRiding();
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
              screenKeepOff();
              _ridingProvider.stopAndSaveRiding();
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

  Widget startButton(RidingState state) {
    if (state == RidingState.before) {
      return Container(
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        ElevatedButton(
          onPressed: () {
            _ridingProvider.startRiding();
            screenKeepOn();
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
                "남은거리 : , 속도 : ${_ridingProvider.speed.toString()}",
                style: TextStyle(fontSize: 20, color: Colors.indigo.shade900),
              )
            ],
          ),
        )
      ],
    );
  }

  Widget ridingProgress() {
    double percent = _ridingProvider.distance / 10000;
    return Column(
      children: [
        Container(
          alignment: FractionalOffset(percent, 1 - percent),
          child: FractionallySizedBox(
              child: Image.asset('assets/icons/riding_character.png',
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

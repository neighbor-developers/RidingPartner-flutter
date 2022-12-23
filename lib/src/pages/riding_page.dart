import 'dart:async';
import 'dart:typed_data';

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
import '../utils/bytesFromAsset.dart';
import '../utils/timestampToText.dart';
import '../utils/user_location.dart';
import '../widgets/dialog.dart';

// https://funncy.github.io/flutter/2020/07/21/flutter-google-map-marker/

class RidingPage extends StatefulWidget {
  const RidingPage({super.key});

  @override
  State<RidingPage> createState() => _RidingPageState();
}

class _RidingPageState extends State<RidingPage> {
  late Completer<GoogleMapController> _controller;
  late RidingProvider _ridingProvider;
  LatLng initCameraPosition = const LatLng(37.37731944, 126.8050778);
  Set<Marker> myPositionMarker = {};
  late BitmapDescriptor myPositionIcon;

  @override
  void initState() {
    super.initState();
    setMapComponent();
  }

  setMapComponent() async {
    await Provider.of<RidingProvider>(context, listen: false).getLocation();

    if (_ridingProvider.position != null) {
      initCameraPosition = LatLng(_ridingProvider.position!.latitude,
          _ridingProvider.position!.longitude);
      final Uint8List markerIcon =
          await getBytesFromAsset('assets/icons/my_location.png', 200);
      myPositionIcon = BitmapDescriptor.fromBytes(markerIcon);

      myPositionMarker.add(Marker(
          markerId: const MarkerId("currentLocation"),
          icon: BitmapDescriptor.fromBytes(markerIcon),
          position: LatLng(_ridingProvider.position!.latitude,
              _ridingProvider.position!.longitude)));
      _ridingProvider.setMapComponent();
    } else {
      initCameraPosition = const LatLng(37.37731944, 126.8050778);
    }
  }

  final myLocation = MyLocation();

  String floatBtnLabel = "일시중지";
  IconData floatBtnIcon = Icons.pause;
  double bearing = 180;

  @override
  Widget build(BuildContext context) {
    _ridingProvider = Provider.of<RidingProvider>(context);
    Position? position = _ridingProvider.position;

    void setController() async {
      GoogleMapController googleMapController = await _controller.future;
      if (position != null) {
        if (_ridingProvider.bearingPoint != null) {
          bearing = Geolocator.bearingBetween(
              position.latitude,
              position.longitude,
              _ridingProvider.bearingPoint!.latitude,
              _ridingProvider.bearingPoint!.longitude);
        }
        googleMapController.animateCamera(CameraUpdate.newCameraPosition(
            CameraPosition(
                target: LatLng(position.latitude, position.longitude),
                zoom: 19,
                bearing: bearing)));

        myPositionMarker = {
          Marker(
              markerId: const MarkerId("currentLocation"),
              icon: myPositionIcon,
              position: LatLng(_ridingProvider.position!.latitude,
                  _ridingProvider.position!.longitude))
        };
      }
    }

    if (_ridingProvider.state != RidingState.before) {
      setController();
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
                  if (_ridingProvider.state == RidingState.before) {
                    Navigator.pop(context);
                  } else {
                    backDialog(context, "라이딩을 중단하시겠습니까?\n기록은 삭제됩니다");
                  }
                },
                icon: const Icon(Icons.arrow_back),
                color: const Color.fromRGBO(240, 120, 5, 1),
              ),
              elevation: 10,
            ),
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
                  polylines: {
                    Polyline(
                        polylineId: PolylineId("poly"),
                        width: 5,
                        points: _ridingProvider.polylineCoordinates),
                  },
                  markers: myPositionMarker,
                ),
                Positioned(bottom: 0, child: record(_ridingProvider.state))
              ],
            )),
        onWillPop: () async {
          if (_ridingProvider.state == RidingState.before) {
            Navigator.pop(context);
            return true;
          } else {
            return backDialog(context, "라이딩을 중단하시겠습니까?\n기록은 삭제됩니다");
          }
        });
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
          screenKeepOn();
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
                  0, _ridingProvider.visivility ? 0 : 140, 0),
              child: buttons(state),
            ),
            Container(
                alignment: Alignment.center,
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
                child: Container(
                    width: MediaQuery.of(context).size.width - 80,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text('거리', style: titleStyle),
                            Text("${_ridingProvider.distance}km",
                                style: dataStyle)
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
                              timestampToText(_ridingProvider.time.inSeconds),
                              style: dataStyle,
                            )
                          ],
                        ),
                        InkWell(
                          onTap: () {
                            _ridingProvider.setVisivility();
                          },
                          child: Container(
                            width: 18,
                            child: Image.asset('assets/icons/menu_bar.png',
                                fit: BoxFit.fitWidth),
                          ),
                        )
                      ],
                    )))
          ],
        ),
      );
    }
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
                _ridingProvider.setVisivility();
                if (state == RidingState.riding) {
                  _ridingProvider.pauseRiding();
                } else {
                  _ridingProvider.startRiding();
                }
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              margin: EdgeInsets.symmetric(vertical: 15),
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
              child: Text('종료', style: testStyle),
            ),
          )
        ],
      );
    } else {
      return SizedBox(
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

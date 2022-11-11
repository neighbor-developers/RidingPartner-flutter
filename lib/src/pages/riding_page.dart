import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:ridingpartner_flutter/src/pages/record_page.dart';
import 'package:ridingpartner_flutter/src/provider/riding_provider.dart';
import 'package:ridingpartner_flutter/src/utils/user_location.dart';

import '../provider/riding_result_provider.dart';
import '../utils/custom_marker.dart';
import 'dart:developer' as developer;




// https://funncy.github.io/flutter/2020/07/21/flutter-google-map-marker/

class RidingPage extends StatelessWidget {
  RidingPage({super.key});

  late Completer<GoogleMapController> _controller = Completer();
  late RidingProvider _ridingProvider;

  String ridingButtonText = "";
  ButtonStyle ridingButtonStyle = ElevatedButton.styleFrom(
    primary: Colors.red,
    onPrimary: Colors.white,
  );

  @override
  Widget build(BuildContext context) {
    var initLocation = CameraPosition(
      target: LatLng(MyLocation().latitude!!, MyLocation().longitude!!),
      zoom: 12.6,
    );

    _ridingProvider = Provider.of<RidingProvider>(context);
    Position? position = _ridingProvider.position;


    void _setController() async {
      GoogleMapController googleMapController = await _controller.future;
      if (position != null) {
        googleMapController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
                target: LatLng(position.latitude, position.longitude))));
      }
    }

    if (_ridingProvider.state != RidingState.before) {
      _setController();
    }

    return Scaffold(
        body: Stack(
        children: <Widget>[
        GoogleMap(
          mapType: MapType.normal,
          initialCameraPosition: CameraPosition(
            target:
                LatLng(position?.latitude ?? 37.343991285297, position?.longitude ?? 126.74729588817),
            zoom: 12.6,
          ),
          onMapCreated: (GoogleMapController controller) {
            _controller.complete(controller);
          },
          myLocationButtonEnabled: true,
          myLocationEnabled: true,
          polylines: { Polyline(
              polylineId: PolylineId("poly"),
              width: 5,
              points: _ridingProvider.polylineCoordinates),
          },
          markers: {
            Marker(
                markerId: const MarkerId("currentLocation"),
                icon: BitmapDescriptor.fromBytes(RidingProvider().customIcon),
                position: LatLng(_ridingProvider.position?.latitude ?? 37.343991285297, _ridingProvider.position?.longitude ?? 126.74729588817)
            )
          },
        ),
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
                                  style: const TextStyle(fontSize: 23)))),
                      //Spacer(flex: ),
                      const Text("속도")
                    ]),
                    Row(children: <Widget>[
                      Padding(
                          padding: const EdgeInsets.all(5),
                          child: SizedBox(
                              child: Text("${_ridingProvider.distance}km",
                                  style: const TextStyle(fontSize: 23)))),
                      const Text("거리")
                    ]),
                    Row(children: <Widget>[
                      Padding(
                          padding: const EdgeInsets.all(5),
                          child: SizedBox(
                              child: Text("${_ridingProvider.speed}km/h",
                                  style: const TextStyle(fontSize: 23)))),
                      const Text("평균속도")
                    ]),
                    Row(children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(5),
                        child: SizedBox(
                            child: Text("${_ridingProvider.time}".substring(0, 7),
                                style: const TextStyle(fontSize: 23))),
                      ),
                      const Text("시간")
                    ])
                  ],
                ),
              )),
        ),
        Positioned(
            bottom: 10,
            child: Row(
              children: [
                changeButton(_ridingProvider.state, _ridingProvider.ridingDate, context),
              ],
            ))
      ],
    ));
  }

  Widget changeButton(RidingState state, String ridingDate, BuildContext context) {
    switch (state) {
      case RidingState.before:
        {
          ridingButtonText = "라이딩 시작하기";
          ridingButtonStyle = ElevatedButton.styleFrom(
            primary: Colors.blue,
            onPrimary: Colors.white,
          );
          break;
        }
      case RidingState.riding:
        {
          ridingButtonText = "라이딩 중단";
          ridingButtonStyle = ElevatedButton.styleFrom(
            primary: Colors.blue,
            onPrimary: Colors.white,
          );
          break;
        }

      case RidingState.pause:
        {
          ridingButtonText = "이어서 진행";
          ridingButtonStyle = ElevatedButton.styleFrom(
            primary: Colors.blue,
            onPrimary: Colors.white,
          );
          break;
        }
      default:
        ridingButtonText = "";
    }

    return Row(children: [
      ElevatedButton(
        style: ridingButtonStyle,
        onPressed: () {
          if (state == RidingState.before || state == RidingState.pause) {
            _ridingProvider.startRiding();
          } else if (state == RidingState.riding) {
            _ridingProvider.pauseRiding();
          }
        },
        child: Text(ridingButtonText),
      ),
      saveButton(state, ridingDate, context)
    ]);
  }

  Widget saveButton(RidingState state, String ridingDate, BuildContext context) {
    if (state == RidingState.pause) {
      // ridingDate 널체크 필요? 일단 미란이 만들고 확인해보기
      return ElevatedButton(
        style: ridingButtonStyle,
        onPressed: () {
          _ridingProvider.stopAndSaveRiding();
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      ChangeNotifierProvider(
                          create: (context) =>
                              RidingResultProvider(),
                          child: RecordPage(ridingDate)),
                  ));
        },
        child: const Text("라이딩 완료"),
      );
    } else {
      return Column();
    }
  }
}

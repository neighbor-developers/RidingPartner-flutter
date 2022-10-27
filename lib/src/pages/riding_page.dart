import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:ridingpartner_flutter/src/pages/navigation_page.dart';
import 'package:ridingpartner_flutter/src/provider/riding_provider.dart';
import 'package:ridingpartner_flutter/src/utils/user_location.dart';

// https://funncy.github.io/flutter/2020/07/21/flutter-google-map-marker/

class RidingPage extends StatelessWidget {
  RidingPage({super.key});

  final Completer<GoogleMapController> _controller = Completer();
  late RidingProvider _ridingProvider;

  String ridingButtonText = "";
  ButtonStyle ridingButtonStyle = ElevatedButton.styleFrom(
    primary: Colors.red,
    onPrimary: Colors.white,
  );
  var init = false;
  // 이건 왜 에러가 뜰까? RidingState state = _ridingProvider.ridingState;
  @override
  Widget build(BuildContext context) {
    var _initLocation = _ridingProvider = Provider.of<RidingProvider>(context);
    Position? position = _ridingProvider.position;

    return Scaffold(
        body: Stack(
      //textDirection: ,
      children: <Widget>[
        GoogleMap(
          mapType: MapType.normal,
          //markers: Set.from(_markers),
          initialCameraPosition: CameraPosition(
            target:
                LatLng(position?.latitude ?? 0.0, position?.longitude ?? 0.0),
            zoom: 12.6,
          ),
          onMapCreated: (GoogleMapController controller) {
            _controller.complete(controller);
          },
          myLocationButtonEnabled: true,
          myLocationEnabled: true,
          markers: {
            Marker(
                markerId: MarkerId("myPosition"),
                position: LatLng(
                    position?.latitude ?? 0.0, position?.longitude ?? 0.0))
          },
        ),
        Positioned(
          // 위치 지정하기
          child: FractionallySizedBox(
              alignment: Alignment.bottomLeft,
              widthFactor: 0.4,
              heightFactor: 0.2,
              child: Container(
                color: Colors.white,
                child: Column(
                  children: <Widget>[
                    Row(children: <Widget>[
                      Padding(
                          padding: EdgeInsets.all(5),
                          child: SizedBox(
                              child: Text("${_ridingProvider.speed}",
                                  style: TextStyle(fontSize: 23)))),
                      //Spacer(flex: ),
                      const Text("속도")
                    ]),
                    Row(children: <Widget>[
                      Padding(
                          padding: EdgeInsets.all(5),
                          child: SizedBox(
                              child: Text("${_ridingProvider.distance}km",
                                  style: TextStyle(fontSize: 23)))),
                      Text("거리")
                    ]),
                    Row(children: <Widget>[
                      Padding(
                          padding: EdgeInsets.all(5),
                          child: SizedBox(
                              child: Text("${_ridingProvider.speed}km/h",
                                  style: TextStyle(fontSize: 23)))),
                      Text("평균속도")
                    ]),
                    Row(children: <Widget>[
                      Padding(
                        padding: EdgeInsets.all(5),
                        child: SizedBox(
                            child: Text("${_ridingProvider.time}",
                                style: TextStyle(fontSize: 23))),
                      ),
                      Text("시간")
                    ])
                  ],
                ),
              )),
        ),
        Positioned(
            bottom: 10,
            child: Row(
              children: [
                changeButton(_ridingProvider.state),
              ],
            ))
      ],
    ));
  }

  Widget changeButton(RidingState state) {
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
      saveButton(state)
    ]);
  }

  Widget saveButton(RidingState state) {
    if (state == RidingState.pause) {
      return ElevatedButton(
        style: ridingButtonStyle,
        onPressed: () {
          _ridingProvider.stopAndSaveRiding();
        },
        child: Text("라이딩 완료"),
      );
    } else {
      return Spacer(flex: 0);
    }
  }
}

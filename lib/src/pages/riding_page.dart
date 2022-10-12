import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:ridingpartner_flutter/src/provider/riding_provider.dart';
import 'package:ridingpartner_flutter/src/utils/user_location.dart';
import 'map_page.dart';

// https://funncy.github.io/flutter/2020/07/21/flutter-google-map-marker/

class RidingPage extends StatelessWidget {
  RidingPage({super.key});

  final Completer<GoogleMapController> _controller = Completer();
  late RidingProvider _ridingProvider;

 // 이건 왜 에러가 뜰까? RidingState state = _ridingProvider.ridingState;
  @override
  Widget build(BuildContext context) {
    var _initLocation = CameraPosition(
      target: LatLng(MyLocation().latitude!!, MyLocation().longitude!!),
      zoom: 12.6,
    );

    _ridingProvider = Provider.of<RidingProvider>(context);

    RidingState state = Provider.of<RidingProvider>(context).state;

    return Scaffold(
        body: Stack(
      //textDirection: ,
      children: <Widget>[
        GoogleMap(
          mapType: MapType.normal,
          //markers: Set.from(_markers),
          initialCameraPosition: _initLocation,
          onMapCreated: (GoogleMapController controller) {
            _controller.complete(controller);
          },
          myLocationButtonEnabled: true,
          myLocationEnabled: true,
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

        Positioned.fill(
            bottom: 10,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: changeButton(state)
            )
        )

      ],
    ));
  }

  Widget changeButton(RidingState state) {
    if (state == RidingState.before) {
      return ElevatedButton(
        style: ElevatedButton.styleFrom(
        primary: Colors.red,
        onPrimary: Colors.white,
        ),
        onPressed: () {
          _ridingProvider.startRiding();
        },
        child: Text("라이딩 시작하기"),
      );
    }
    else if(state == RidingState.riding){
      return ElevatedButton(
        style: ElevatedButton.styleFrom(
        primary: Colors.blue,
        onPrimary: Colors.white,
        ),
        onPressed: () {
            _ridingProvider.pauseRiding();
        },
        child: Text("라이딩 중단"),
      );
    }
   else{
      return Row(
        children:[
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              primary: Colors.blue,
              onPrimary: Colors.white,
            ),
            onPressed: () {
              _ridingProvider.startRiding();
            },
            child: Text("이어서 라이딩하기"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              primary: Colors.blue,
              onPrimary: Colors.white,
            ),
            onPressed: () {
              _ridingProvider.stopAndSaveRiding();
            },
            child: Text("저장"),
          )
        ]
      );
    }
  }
}

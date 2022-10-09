

import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ridingpartner_flutter/src/provider/riding_provider.dart';
import 'package:ridingpartner_flutter/src/utils/user_location.dart';
import 'map_page.dart';

// https://funncy.github.io/flutter/2020/07/21/flutter-google-map-marker/

class RidingMap extends StatefulWidget{
  const RidingMap ({super.key});

  @override
  State<RidingMap> createState() => RidingMapState();
}


class RidingMapState extends State<RidingMap>{
  final Completer<GoogleMapController> _controller = Completer();
  var text ="라이딩 시작하기";
  var init = false;
  var style = ElevatedButton.styleFrom(
    primary: Colors.red,
    onPrimary: Colors.white,
  );

  var provider = RidingProvider();
  @override
  Widget build(BuildContext context) {
    var _initLocation = CameraPosition(
      target: LatLng(MyLocation().latitude!!, MyLocation().longitude!!),
      zoom: 12.6,
    );

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
                color: Colors. white,
                child: Column(
                  children: <Widget>[
                    Row(
                        children: <Widget> [
                          Padding(
                              padding: EdgeInsets.all(5),
                              child: SizedBox(
                                  child: Text(
                                      "${provider.speed}",
                                      style: TextStyle(fontSize: 23)
                                  )
                              )),
                          //Spacer(flex: ),
                          const Text("속도")]
                    ),
                    Row(
                        children: <Widget> [
                          Padding(
                              padding: EdgeInsets.all(5),
                              child: SizedBox(
                                  child: Text(
                                      "${provider.distance}km",
                                      style: TextStyle(fontSize: 23)
                                  )
                              )),
                          Text(
                              "거리"
                          )]
                    ),
                    Row(
                        children: <Widget> [
                          Padding(
                              padding: EdgeInsets.all(5),
                              child: SizedBox(
                                  child: Text(
                                      "${provider.speed}km/h",
                                      style: TextStyle(fontSize: 23)
                                  )
                              )),
                          Text(
                              "평균속도"
                          )]
                    ),
                    Row(
                        children: <Widget> [
                          Padding(
                            padding: EdgeInsets.all(5),
                            child: SizedBox(
                                child: Text(
                                    "${provider.time}",
                                    style: TextStyle(fontSize: 23)
                                )
                            ),
                          ),
                          Text("시간")
                        ]
                    )

                  ],
                ),
              )
          ),

          ),
          Positioned(
              bottom: 10,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Colors.red,
                  onPrimary: Colors.white,
                ),
                onPressed: (){
                  changeButton(init);
                },
                child: Text(text),
            )
          ),
          Positioned(
            bottom: 10,
            child: Row(
            children: [

          ],
          )
          )
        ],
      )
    );
  }

  void changeButton(bool state){
    if(state == false){
      RidingProvider().startRiding(state);
      init == true;
      text = "라이딩 중단";
      style = ElevatedButton.styleFrom(
        primary: Colors.red,
        onPrimary: Colors.white,
      );
    }
    else{
      RidingProvider().startRiding(true);
      style = ElevatedButton.styleFrom(
        primary: Colors.blue,
        onPrimary: Colors.white,
      );
    }
  }
}
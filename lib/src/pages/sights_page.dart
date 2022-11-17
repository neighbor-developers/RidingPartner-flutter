import 'dart:async';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:ridingpartner_flutter/src/provider/sights_provider.dart';



class SightsPage extends StatelessWidget{
  final Completer<GoogleMapController> _controller = Completer();

  // List<MarkerInfo> location = [
  //   MarkerInfo("정왕 자전거 대여소", LatLng(37.343991285297, 126.74729588817),
  //       "월 ~ 금\n(07시 ~ 21시)\n토요일, 일요일, 공휴일 휴무\n☎ 031-433-0101"),
  //   MarkerInfo("월곧 자전거 대여소", LatLng(37.3917953, 126.742692),
  //       "수 ~ 일\n(09시 ~ 20시)\n월요일, 화요일, 공휴일 휴무\n☎ 031-433-0101")
  // ];




    // @override
    // void initState(){
    //   super.initState();
    //   _markers.add(Marker(
    //       markerId: MarkerId("1"),
    //       draggable: true,
    //       onTap: () => print("Marker!"),
    //       position: const LatLng(37.343991285297, 126.74729588817)
    //   ));
    // }


  @override
  Widget build(BuildContext context) {
    final sightsProvider = Provider.of<SightsProvider>(context);

    final state = sightsProvider.state;

    if (state == MarkerListState.searching) {
      sightsProvider.getRouteList();
    }

    return Scaffold(
        body: GoogleMap(
          mapType: MapType.normal,
          markers: Set.from(sightsProvider.markers),
          initialCameraPosition: const CameraPosition(
              target: LatLng(37.349741467772, 126.76182486561),
              zoom: 12.9
          ),
          onMapCreated: (GoogleMapController controller) {
            _controller.complete(controller);
          },
          myLocationButtonEnabled: true,
          myLocationEnabled: true,
          //onCameraMove: ,
        )
    );
  }
}


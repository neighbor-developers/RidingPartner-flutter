import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:ridingpartner_flutter/src/provider/sights_provider.dart';
import 'package:ridingpartner_flutter/src/utils/custom_marker.dart';

import '../models/place.dart';
import '../provider/navigation_provider.dart';
import '../provider/riding_provider.dart';
import 'navigation_page.dart';

class SightsPage extends StatelessWidget {
  final Completer<GoogleMapController> _controller = Completer();
  late Set<Marker> markers;

  @override
  Widget build(BuildContext context) {
    final sightsProvider = Provider.of<SightsProvider>(context);

    final state = sightsProvider.state;

    void routeDialog(Place place) => showDialog(
        context: context,
        //barrierDismissible - Dialog를 제외한 다른 화면 터치 x
        barrierDismissible: false,
        builder: (BuildContext context) {
          double height = MediaQuery.of(context).size.height;
          double width = MediaQuery.of(context).size.width;

          return Container(
              height: height * 0.5,
              width: width * 0.9,
              child: AlertDialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0)),
                //Dialog Main Title
                title: Text(style: TextStyle(), place.title!),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                        //mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Text(place.roadAddress ?? "위치 로드에 실패하였습니다. 재접속해주세요",
                              style: const TextStyle(
                                color: Color(0xFFE9E9E9),
                              )),
                          //Text(sightsProvider.distance+"km")
                        ]),
                    Image.asset(place.image!),
                  ],
                ),
                actions: <Widget>[
                  ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(
                          const Color(0xFFE9E9E9)),
                      //maximumSize: Size(),
                    ),
                    child: const Text(
                        style: TextStyle(color: Color(0xFF666666)), "취소"),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  ElevatedButton(
                    style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                            Colors.orange[600]!)),
                    child: const Text("안내 시작",
                        style: TextStyle(color: Colors.white)),
                    onPressed: () async {
                      final placeList = <Place>[place];

                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => MultiProvider(
                                    providers: [
                                      ChangeNotifierProvider(
                                          create: (context) =>
                                              NavigationProvider(placeList)),
                                      ChangeNotifierProvider(
                                          create: (context) => RidingProvider())
                                    ],
                                    child: NavigationPage(),
                                  )));
                    },
                  ),
                ],
              ));
        });

    if (state == MarkerListState.searching) {
      sightsProvider.getPlaceList();
      markers = <Marker>{};
    }

    Future<void> setCustomMarker() async {
      try {
        await Future.forEach(sightsProvider.sightList, (place) async {
          final customIcon =
              await CustomMarker().getPictuerMarker(place.image!);
          markers.add(Marker(
              markerId: MarkerId(place.title ?? "marker"),
              icon: customIcon,
              onTap: () => {routeDialog(place)},
              position: LatLng(double.parse(place.latitude ?? ""),
                  double.parse(place.longitude ?? "")) //예외처리해주기
              ));
        });
        sightsProvider.setState(MarkerListState.markerCompleted);
      } catch (e) {
        sightsProvider.setState(MarkerListState.empty);
      }
    }

    if (state == MarkerListState.placeCompleted) {
      setCustomMarker();
    }

    return Scaffold(
        body: GoogleMap(
      mapType: MapType.normal,
      markers: Set.from(markers),
      initialCameraPosition: const CameraPosition(
          target: LatLng(37.349741467772, 126.76182486561), zoom: 12.9),
      onMapCreated: (GoogleMapController controller) {
        _controller.complete(controller);
      },
      myLocationButtonEnabled: true,
      myLocationEnabled: true,
      //onCameraMove: ,
    ));
  }
}


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

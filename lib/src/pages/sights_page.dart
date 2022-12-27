import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter/src/painting/rounded_rectangle_border.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:ridingpartner_flutter/src/provider/sights_provider.dart';
import 'package:ridingpartner_flutter/src/utils/custom_marker.dart';

import '../models/place.dart';
import '../provider/navigation_provider.dart';
import '../provider/riding_provider.dart';
import 'home_page.dart';
import 'navigation_page.dart';

class SightsPage extends StatelessWidget {
  final Completer<GoogleMapController> _controller = Completer();
  late Set<Marker> markers;

  @override
  Widget build(BuildContext context) {
    final sightsProvider = Provider.of<SightsProvider>(context);

    final state = sightsProvider.state;

    void routeDialog(Place place) => showModalBottomSheet<void>(
        context: context,
        //barrierDismissible - Dialog를 제외한 다른 화면 터치 x
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15.0),
                topRight: Radius.circular(15.0))),
        builder: (BuildContext context) {
          double height = MediaQuery.of(context).size.height;
          double width = MediaQuery.of(context).size.width;
          developer.log("높이: $height");
          developer.log("넓이 : $width");

          return Column(
            children: [
              Container(
                  height: height * 0.5 - height * 0.07,
                  padding: const EdgeInsets.fromLTRB(20, 30, 20, 0),
                  child: Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //padding: const EdgeInsets.fromLTRB(20, 30, 20, 0),
                      children: [
                        Text(
                            style: const TextStyle(
                                fontSize: mainFontSize,
                                color: Color.fromRGBO(51, 51, 51, 1),
                                fontFamily: "Pretendard",
                                height: 1.3,
                                letterSpacing: 0.02,
                                fontWeight: FontWeight.w800),
                            place.title!),
                        // Column(
                        //   mainAxisSize: MainAxisSize.min,
                        //   crossAxisAlignment: CrossAxisAlignment.start,
                        //   children: <Widget>[
                        //     Row(
                        //       //mainAxisAlignment: MainAxisAlignment.start,
                        //         children: <Widget>[
                        //           Text(place.roadAddress ?? "위치 로드에 실패하였습니다. 재접속해주세요",
                        //               style: const TextStyle(
                        //                 color: Color(0xFFE9E9E9),
                        //               )),
                        //           //Text(sightsProvider.distance+"km")
                        //         ]),
                        //     Image.asset(place.image!),
                        //   ],
                        Text(place.roadAddress ?? "위치 로드에 실패하였습니다. 재접속해주세요",
                            style: const TextStyle(
                              fontSize: recordFontSize,
                              color: Color(0xFF999999),
                            )),
                        const Divider(color: Colors.grey, thickness: 1.0),
                        Card(
                            semanticContainer: true,
                            clipBehavior: Clip.antiAliasWithSaveLayer,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0)),
                            child: Image.asset(place.image!))

                        // ),]
                        /*          ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(const Color(0xFFE9E9E9)),
                  //maximumSize: Size(),
                ),
                child: const Text(style: TextStyle(color: Color(0xFF666666)), "취소"),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),*/
                      ])),
              SizedBox(
                  height: height * 0.07,
                  width: width,
                  child: ElevatedButton(
                    style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                            Color.fromARGB(0xFF, 0xFB, 0x95, 0x32))),
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
                  )),
            ],
          );
        });

    if (state == MarkerListState.searching) {
      sightsProvider.getPlaceList();
      markers = <Marker>{};
    }

    Future<void> setCustomMarker() async {
      try {
        await Future.forEach(sightsProvider.sightList, (place) async {
          final customIcon =
              await CustomMarker().getPictuerMarker(place.marker!);
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

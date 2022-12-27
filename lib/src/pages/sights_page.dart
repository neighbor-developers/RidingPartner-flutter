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

class SightsPage extends StatefulWidget {
  @override
  State<SightsPage> createState() => _SightsPageState();
}

class _SightsPageState extends State<SightsPage> {
  final Completer<GoogleMapController> _controller = Completer();

  Set<Marker> markers = {};
  late SightsProvider _sightsProvider;

  @override
  void initState() {
    Provider.of<SightsProvider>(context, listen: false).getPlaceList();
  }

  @override
  Widget build(BuildContext context) {
    _sightsProvider = Provider.of<SightsProvider>(context);
    final state = _sightsProvider.state;

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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                  padding: const EdgeInsets.fromLTRB(24, 38, 24, 30),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                            style: const TextStyle(
                                fontFamily: 'Pretendard',
                                fontSize: 24,
                                fontWeight: FontWeight.w700),
                            place.title!),
                        const SizedBox(
                          height: 8,
                        ),
                        Text(place.roadAddress ?? "",
                            style: const TextStyle(
                                fontFamily: 'Pretendard',
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: Color.fromRGBO(51, 51, 51, 0.5))),
                        const SizedBox(
                          height: 8,
                        ),
                        const Divider(
                          color: Color.fromRGBO(233, 236, 239, 1),
                          thickness: 1.0,
                        ),
                        const SizedBox(height: 16.0),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Image.asset(
                            place.imageUrl!,
                            height: 160.0,
                            width: MediaQuery.of(context).size.width,
                            fit: BoxFit.fill,
                          ),
                        )
                      ])),
              InkWell(
                  onTap: () async {
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
                                  child: const NavigationPage(),
                                )));
                  },
                  child: Container(
                      alignment: Alignment.center,
                      width: MediaQuery.of(context).size.width,
                      height: 60,
                      color: const Color.fromRGBO(240, 120, 5, 1),
                      child: const Text('안내 시작',
                          style: TextStyle(
                              fontFamily: 'Pretendard',
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w700))))
            ],
          );
        });

    Future<void> setCustomMarker() async {
      try {
        await Future.forEach(_sightsProvider.sightList, (place) async {
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
        _sightsProvider.setState(MarkerListState.markerCompleted);
      } catch (e) {
        _sightsProvider.setState(MarkerListState.empty);
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

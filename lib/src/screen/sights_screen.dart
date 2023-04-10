import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';
import 'package:ridingpartner_flutter/src/provider/sights_provider.dart';
import '../models/place.dart';
import '../provider/navigation_provider.dart';
import '../provider/riding_provider.dart';
import 'navigation_screen.dart';

class SightsScreen extends StatefulWidget {
  @override
  State<SightsScreen> createState() => _SightsScreenState();
}

class _SightsScreenState extends State<SightsScreen> {
  late List<Marker> _markers = [];
  Completer<NaverMapController> _controller = Completer();
  late SightsProvider _sightsProvider;
  var logger = Logger('Logger');

  @override
  void initState() {
    setCustomMarker();
  }

  void setCustomMarker() async {
    await Provider.of<SightsProvider>(context, listen: false).getPlaceList();
    try {
      await Future.forEach(_sightsProvider.sightList, (place) async {
        OverlayImage icon =
            await OverlayImage.fromAssetImage(assetName: place.marker!);
        _markers.add(Marker(
            width: 30,
            height: 40,
            markerId: place.title ?? "marker",
            icon: icon,
            onMarkerTab: _onMarkerTap,
            position: LatLng(double.parse(place.latitude ?? ""),
                double.parse(place.longitude ?? "")) //예외처리해주기
            ));
      });
      _sightsProvider.setState(MarkerListState.markerCompleted);
    } catch (e) {
      _sightsProvider.setState(MarkerListState.empty);
    }
  }

  @override
  Widget build(BuildContext context) {
    _sightsProvider = Provider.of<SightsProvider>(context);

    return Scaffold(
      body: NaverMap(
        onMapCreated: onMapCreated,
        initialCameraPosition: const CameraPosition(
            target: LatLng(37.349741467772, 126.76182486561), zoom: 11),
        mapType: MapType.Basic,
        initLocationTrackingMode: LocationTrackingMode.None,
        locationButtonEnable: true,
        markers: _markers,
      ),
    );
  }

  void routeDialog(Place place) => showModalBottomSheet<void>(
      context: context,
      //barrierDismissible - Dialog를 제외한 다른 화면 터치 x
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(15.0), topRight: Radius.circular(15.0))),
      builder: (BuildContext context) {
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
                      if (place.roadAddress == null ||
                          place.roadAddress == "") ...[
                        Text(
                          place.jibunAddress!,
                          style: const TextStyle(
                              fontFamily: 'Pretendard',
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: Color.fromRGBO(51, 51, 51, 0.5)),
                        )
                      ] else ...[
                        Text(
                          place.roadAddress!,
                          style: const TextStyle(
                              fontFamily: 'Pretendard',
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: Color.fromRGBO(51, 51, 51, 0.5)),
                        )
                      ],
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
                          place.image!,
                          height: 160.0,
                          width: MediaQuery.of(context).size.width,
                          fit: BoxFit.fill,
                        ),
                      )
                    ])),
            InkWell(
                onTap: () async {
                  logger.fine("placeList : $place");
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => MultiProvider(
                                providers: [
                                  ChangeNotifierProvider(
                                      create: (context) =>
                                          NavigationProvider([place])),
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

  void onMapCreated(NaverMapController controller) {
    if (_controller.isCompleted) _controller = Completer();
    _controller.complete(controller);
  }

  void _onMarkerTap(Marker? marker, Map<String, int?> iconSize) {
    Place place = _sightsProvider.sightList
        .where((p) => marker?.markerId == p.title)
        .toList()
        .first;
    routeDialog(place);
  }
}

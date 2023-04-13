import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:ridingpartner_flutter/src/models/place.dart';
import 'package:ridingpartner_flutter/src/models/route.dart';
import 'package:ridingpartner_flutter/src/provider/search_place_provider.dart';
import 'package:ridingpartner_flutter/src/screen/navigation_screen.dart';
import 'package:ridingpartner_flutter/src/service/find_route_service.dart';
import 'package:ridingpartner_flutter/src/service/naver_map_service.dart';
import 'package:ridingpartner_flutter/src/style/palette.dart';
import 'package:ridingpartner_flutter/src/utils/set_polyline_data.dart';

import '../models/my_location.dart';
import '../widgets/map_search/search_box.dart';
import '../widgets/map_search/search_list.dart';

enum SearchType { start, destination }

final visibilityProvider = StateProvider.autoDispose<bool>((ref) => true);

final startPlaceProvider = StateProvider.autoDispose<Place?>((ref) => null);

final destinationPlaceProvider =
    StateProvider.autoDispose<Place?>((ref) => null);

// 검색된 경로를 저장하는 Provider
final routeProvider = FutureProvider.autoDispose<List<Guide>>((ref) async {
  final startPlace = ref.watch(startPlaceProvider);
  final destinationPlace = ref.watch(destinationPlaceProvider);
  if (startPlace != null && destinationPlace != null) {
    return await FindRouteService().getRoute(startPlace, destinationPlace);
  } else {
    return [];
  }
});

// 검색된 장소들을 저장하는 Provider
final searchStartPlaceProvider =
    StateNotifierProvider.autoDispose<SearchPlaceProvider, List<Place>>(
        (ref) => SearchPlaceProvider());
final searchDestinationPlaceProvider =
    StateNotifierProvider.autoDispose<SearchPlaceProvider, List<Place>>(
        (ref) => SearchPlaceProvider());

// 검색된 경로의 polyline을 저장하는 Provider
final polylineProvider = StateProvider.autoDispose<List<LatLng>>((ref) {
  final route = ref.watch(routeProvider);

  return route.when(
      data: (route) {
        List<PolylineWayPoint>? turnPoints = route
            .map((route) => PolylineWayPoint(location: route.turnPoint ?? ""))
            .toList();
        List<LatLng> pointLatLngs = [];

        turnPoints.forEach((element) {
          List<String> a = element.location.split(',');
          pointLatLngs.add(LatLng(double.parse(a[1]), double.parse(a[0])));
        });

        return pointLatLngs;
      },
      loading: () => [],
      error: (e, s) => []);
});

class MapSearchScreen extends ConsumerStatefulWidget {
  const MapSearchScreen({super.key});

  @override
  MapSearchScreenState createState() => MapSearchScreenState();
}

class MapSearchScreenState extends ConsumerState<MapSearchScreen> {
  final _destinationTextController = TextEditingController();
  final _startTextController = TextEditingController();
  Completer<NaverMapController> _controller = Completer();
  final LocationTrackingMode _locationTrackingMode = LocationTrackingMode.None;

  Marker? _startMarkers;
  Marker? _endMarkers;
  final int polylineWidth = 8;
  int buttonsPositionAlpha = 0;
  CameraPosition? initLocation;

  @override
  void initState() {
    super.initState();

    setStartPlaceMyLocation();
  }

  void setStartPlaceMyLocation() async {
    final address = await FindRouteService().getMyLocationAddress();
    List<Place> result = (await NaverMapService().getPlaces(address));
    Place myLocation = result[0];
    ref.read(startPlaceProvider.notifier).state = myLocation;
    _startTextController.text = "현재 위치: ${myLocation.title}";
  }

  @override
  void dispose() {
    super.dispose();
    _destinationTextController.clear();
    _startTextController.clear();
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final polylinePoint = ref.watch(polylineProvider);
    final startPlaceList = ref.watch(searchStartPlaceProvider);
    final destinationPlaceList = ref.watch(searchDestinationPlaceProvider);
    final searchboxVisible = ref.watch(visibilityProvider);

    return Scaffold(
      key: _scaffoldKey,
      body: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
            ref.read(searchDestinationPlaceProvider.notifier).clearPlace();
            ref.read(searchStartPlaceProvider.notifier).clearPlace();
          },
          child: Stack(
            children: <Widget>[
              NaverMap(
                onMapCreated: onMapCreated,
                mapType: MapType.Basic,
                locationButtonEnable: false,
                initialCameraPosition: MyLocation().position == null
                    ? const CameraPosition(
                        target: LatLng(37.5666102, 126.9783881), zoom: 15)
                    : CameraPosition(
                        target: LatLng(MyLocation().position!.latitude,
                            MyLocation().position!.longitude),
                        zoom: 15),
                initLocationTrackingMode: _locationTrackingMode,
                markers: [
                  if (_startMarkers != null) _startMarkers!,
                  if (_endMarkers != null) _endMarkers!,
                ],
                onMapTap: (latLng) {
                  FocusScope.of(context).unfocus();
                  ref
                      .read(searchDestinationPlaceProvider.notifier)
                      .clearPlace();
                  ref.read(searchStartPlaceProvider.notifier).clearPlace();
                },
                pathOverlays: polylinePoint.length > 1
                    ? {
                        PathOverlay(PathOverlayId('path'), polylinePoint,
                            width: polylineWidth,
                            outlineWidth: 0,
                            color: const Color.fromARGB(0xFF, 0xFB, 0x95, 0x32))
                      }
                    : {},
              ),
              // 검색창
              Visibility(
                  visible: searchboxVisible,
                  child: SearchBoxWidget(
                    textControllerForStart: _startTextController,
                    textControllerForEnd: _destinationTextController,
                    onClickClear: (SearchType type) => onClickClear(type),
                  )),
              // 검색된 장소 리스트
              Container(
                  alignment: Alignment.topLeft,
                  width: MediaQuery.of(context).size.width - 40,
                  margin:
                      const EdgeInsets.only(top: 109.3, left: 35, right: 35),
                  child: Visibility(
                    visible: startPlaceList.isNotEmpty,
                    child: Column(children: [
                      SearchListWidget(
                          list: startPlaceList,
                          type: SearchType.start,
                          textController: _startTextController,
                          onPlaceItemTab: onPlaceItemTab),
                    ]),
                  )),
              // 검색된 장소 리스트
              Container(
                  alignment: Alignment.topLeft,
                  width: MediaQuery.of(context).size.width - 40,
                  margin:
                      const EdgeInsets.only(top: 189.5, left: 35, right: 35),
                  child: Visibility(
                    visible: destinationPlaceList.isNotEmpty,
                    child: Column(children: [
                      SearchListWidget(
                          list: destinationPlaceList,
                          type: SearchType.destination,
                          textController: _destinationTextController,
                          onPlaceItemTab: onPlaceItemTab),
                    ]),
                  )),
              // 내 위치 버튼
              Positioned(
                bottom: buttonsPositionAlpha + 50,
                left: 20,
                child: FloatingActionButton(
                  heroTag: 'mypos',
                  backgroundColor: Colors.white,
                  child: const ImageIcon(
                      AssetImage('assets/icons/search_myLocation_button.png'),
                      color: Palette.orangeColor),
                  onPressed: () {
                    _initLoaction();
                  },
                ),
              ),
              // 검색 버튼
              Positioned(
                bottom: buttonsPositionAlpha + 120,
                left: 20,
                child: FloatingActionButton(
                  backgroundColor: Colors.white,
                  child: const ImageIcon(AssetImage('assets/icons/search.png'),
                      color: Palette.orangeColor),
                  onPressed: () {
                    Place? destinationPoint =
                        ref.read(destinationPlaceProvider.notifier).state;
                    if (destinationPoint == null) {
                      showToastMessage("출발지와 도착지를 입력해주세요");
                      return;
                    } else {
                      ref.read(visibilityProvider.notifier).state =
                          !ref.read(visibilityProvider);
                      FocusScope.of(context).unfocus();
                    }
                  },
                ),
              ),
              // 안내시작 버튼
              Visibility(
                  visible: !searchboxVisible,
                  child: Positioned(bottom: 0, child: startNavButton()))
            ],
          )),
    );
  }

  void showToastMessage(String message) =>
      Fluttertoast.showToast(msg: message, toastLength: Toast.LENGTH_SHORT);

  // 선택되어있는 장소 제거
  void onClickClear(SearchType type) {
    if (type == SearchType.start) {
      _startTextController.clear();
      ref.read(startPlaceProvider.notifier).state = null;
      ref.read(searchStartPlaceProvider.notifier).clearPlace();
      _startMarkers = null;
    } else {
      _destinationTextController.clear();
      ref.read(destinationPlaceProvider.notifier).state = null;
      ref.read(searchDestinationPlaceProvider.notifier).clearPlace();
      _endMarkers = null;
    }
  }

  void onMapCreated(NaverMapController controller) {
    if (_controller.isCompleted) _controller = Completer();
    _controller.complete(controller);
  }

  // 안내 시작 버튼
  Widget startNavButton() {
    return SizedBox(
        width: MediaQuery.of(context).size.width,
        height: 60,
        child: FloatingActionButton.extended(
            label: const Text('안내 시작',
                style: TextStyle(
                    fontFamily: 'Pretendard',
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700)),
            shape:
                const BeveledRectangleBorder(borderRadius: BorderRadius.zero),
            elevation: 10,
            onPressed: () {
              final des = ref.read(destinationPlaceProvider);
              if (des == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('목적지를 입력해주세요.'),
                  ),
                );
                return;
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => NavigationScreen(places: [des])),
                );
              }
            },
            materialTapTargetSize: MaterialTapTargetSize.padded,
            backgroundColor: Palette.orangeColor));
  }

  // 검색된 장소 리스트에서 장소 선택
  void onPlaceItemTab(
      TextEditingController textController, Place item, SearchType type) async {
    final NaverMapController controller = await _controller.future;
    textController.text = item.title;
    controller.moveCamera(
      CameraUpdate.toCameraPosition(CameraPosition(
        target: item.location,
      )),
    );
    FocusScope.of(context).unfocus();

    updateMarkerPosition(item, type); // 마커 업데이트
    if (type == SearchType.start) {
      // 출발지 선택 및 리스트 비우기
      ref.read(startPlaceProvider.notifier).state = item;
      ref.read(searchStartPlaceProvider.notifier).clearPlace();
    } else {
      // 도착지 선택 및 리스트 비우기
      ref.read(destinationPlaceProvider.notifier).state = item;
      ref.read(searchDestinationPlaceProvider.notifier).clearPlace();
    }

    Place? startPoint = ref.read(startPlaceProvider);
    Place? destinationPoint = ref.read(destinationPlaceProvider);

    if (startPoint != null && destinationPoint != null) {
      ref.read(visibilityProvider.notifier).state = false;

      // 출발지, 도착지 모두 선택되어있을 경우 경로 그리기
      _drawPolyline(
        startPoint,
        destinationPoint,
      );
    }
  }

  // 마커 업데이트(출발지, 목적지)
  Future<void> updateMarkerPosition(Place position, SearchType type) async {
    final customIcon = await OverlayImage.fromAssetImage(
        assetName: 'assets/icons/search_riding_marker.png');
    if (type == SearchType.start) {
      setState(() {
        _startMarkers = Marker(
          width: 30,
          height: 40,
          icon: customIcon,
          markerId:
              '${position.location.latitude}${position.location.longitude}',
          position: position.location,
        );
      });
    } else {
      setState(() {
        _endMarkers = Marker(
          width: 30,
          height: 40,
          icon: customIcon,
          markerId:
              '${position.location.latitude}${position.location.longitude}',
          position: position.location,
        );
      });
    }
  }

  // 출발지, 도착지 사이의 경로를 그림
  void _drawPolyline(Place startPlace, Place finalDestination) async {
    final NaverMapController controller = await _controller.future;
    final List<LatLng> points = setPolylineData(startPlace, finalDestination);
    controller.moveCamera(
      CameraUpdate.fitBounds(
        LatLngBounds(
          northeast: points[0],
          southwest: points[1],
        ),
        padding: 48,
      ),
    );
  }

  // 내 위치로 포커스 이동
  void _initLoaction() async {
    final NaverMapController controller = await _controller.future;

    controller.moveCamera(CameraUpdate.toCameraPosition(CameraPosition(
      target: LatLng(
          MyLocation().position!.latitude, MyLocation().position!.longitude),
      zoom: 14.4746,
    )));
  }
}

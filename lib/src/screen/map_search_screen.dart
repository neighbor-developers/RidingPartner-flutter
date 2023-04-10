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
import 'package:ridingpartner_flutter/src/utils/user_location.dart';

import '../style/textstyle.dart';
import '../widgets/place/highlight_text.dart';

enum SearchType { start, destination }

// 선택된 장소를 저장하는 Provider
final startPlaceProvider = StateProvider<Place?>((ref) => null);
final destinationPlaceProvider = StateProvider<Place?>((ref) => null);

// 검색된 경로를 저장하는 Provider
final routeProvider = FutureProvider<List<Guide>>((ref) async {
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
    StateNotifierProvider<SearchPlaceProvider, List<Place>>(
        (ref) => SearchPlaceProvider());
final searchDestinationPlaceProvider =
    StateNotifierProvider<SearchPlaceProvider, List<Place>>(
        (ref) => SearchPlaceProvider());

// 검색된 경로의 polyline을 저장하는 Provider
final polylineProvider = StateProvider<List<LatLng>>((ref) {
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
  bool searchboxVisible = true;
  int startMarkerId = 0;
  int endMarkerId = 0;
  int buttonsPositionAlpha = 0;
  final FocusNode _startFocusNode = FocusNode();
  final FocusNode _destinationFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    setStartPlaceMyLocation();
  }

  void setStartPlaceMyLocation() async {
    final address = await FindRouteService().getMyLocationAddress();
    List<Place> result = (await NaverMapService().getPlaces(address)) ?? [];
    Place myLocation = result[0];
    ref.read(startPlaceProvider.notifier).state = myLocation;
    _startTextController.text = "현재 위치: ${myLocation.title}";
  }

  @override
  void dispose() {
    super.dispose();
    _destinationTextController.clear();
    _startTextController.clear();
    _startFocusNode.dispose();
    _destinationFocusNode.dispose();
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final polylinePoint = ref.watch(polylineProvider);
    final startPlaceList = ref.watch(searchStartPlaceProvider);
    final destinationPlaceList = ref.watch(searchDestinationPlaceProvider);
    return Scaffold(
      key: _scaffoldKey,
      body: Stack(
        children: <Widget>[
          NaverMap(
            onMapCreated: onMapCreated,
            mapType: MapType.Basic,
            locationButtonEnable: false,
            initLocationTrackingMode: _locationTrackingMode,
            markers: [
              if (_startMarkers != null) _startMarkers!,
              if (_endMarkers != null) _endMarkers!,
            ],
            onMapTap: (latLng) {
              _startFocusNode.unfocus();
              _destinationFocusNode.unfocus();
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
          Visibility(
              visible: searchboxVisible,
              child: SearchBoxWidget(
                textControllerForStart: _startTextController,
                textControllerForEnd: _destinationTextController,
                startFocusNode: _startFocusNode,
                destinationFocusNode: _destinationFocusNode,
                onClickClear: (SearchType type) => onClickClear(type),
              )),
          Container(
              alignment: Alignment.topLeft,
              width: MediaQuery.of(context).size.width - 40,
              margin: const EdgeInsets.only(top: 109.3, left: 35, right: 35),
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
          Container(
              alignment: Alignment.topLeft,
              width: MediaQuery.of(context).size.width - 40,
              margin: const EdgeInsets.only(top: 189.5, left: 35, right: 35),
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
                  setState(() {
                    searchboxVisible = !searchboxVisible;
                  });
                }
              },
            ),
          ),
          Visibility(
              visible: !searchboxVisible,
              child: Positioned(bottom: 0, child: startNavButton()))
        ],
      ),
    );
  }

  void showToastMessage(String message) =>
      Fluttertoast.showToast(msg: message, toastLength: Toast.LENGTH_SHORT);

  void onClickClear(SearchType type) {
    if (type == SearchType.start) {
      _startTextController.clear();
      ref.read(startPlaceProvider.notifier).state = null;
      ref.read(searchStartPlaceProvider.notifier).clearRoute();
      _startMarkers = null;
    } else {
      _destinationTextController.clear();
      ref.read(destinationPlaceProvider.notifier).state = null;
      ref.read(searchDestinationPlaceProvider.notifier).clearRoute();
      _endMarkers = null;
    }
  }

  void onMapCreated(NaverMapController controller) {
    if (_controller.isCompleted) _controller = Completer();
    _controller.complete(controller);
  }

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

  void onPlaceItemTab(
      TextEditingController textController, Place item, SearchType type) async {
    final NaverMapController controller = await _controller.future;
    textController.text = item.title!;
    controller.moveCamera(
      CameraUpdate.toCameraPosition(CameraPosition(
        target:
            LatLng(double.parse(item.latitude!), double.parse(item.longitude!)),
      )),
    );
    Place? startPoint = ref.read(startPlaceProvider.notifier).state;
    Place? destinationPoint = ref.read(destinationPlaceProvider.notifier).state;

    updateMarkerPosition(item, type);
    if (type == SearchType.start) {
      ref.read(startPlaceProvider.notifier).state = item;
      ref.read(searchStartPlaceProvider.notifier).clearRoute();
    } else {
      ref.read(destinationPlaceProvider.notifier).state = item;
      ref.read(searchDestinationPlaceProvider.notifier).clearRoute();
    }

    if (startPoint != null && destinationPoint != null) {
      setState(() {
        !searchboxVisible;
      });
      _drawPolyline(
        startPoint,
        destinationPoint,
      );
    }
  }

  Future<void> updateMarkerPosition(Place position, SearchType type) async {
    final customIcon = await OverlayImage.fromAssetImage(
        assetName: 'assets/icons/search_riding_marker.png');
    if (type == SearchType.start) {
      setState(() {
        _startMarkers = Marker(
          width: 30,
          height: 40,
          icon: customIcon,
          markerId: '${position.latitude!}${position.longitude!}',
          position: LatLng(double.parse(position.latitude!),
              double.parse(position.longitude!)),
        );
      });
    } else {
      setState(() {
        _endMarkers = Marker(
          width: 30,
          height: 40,
          icon: customIcon,
          markerId: '${position.latitude!}${position.longitude!}',
          position: LatLng(double.parse(position.latitude!),
              double.parse(position.longitude!)),
        );
      });
    }
  }

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

  void _initLoaction() async {
    final NaverMapController controller = await _controller.future;

    controller.moveCamera(CameraUpdate.toCameraPosition(CameraPosition(
      target: LatLng(
          MyLocation().position!.latitude, MyLocation().position!.longitude),
      zoom: 14.4746,
    )));
  }
}

class SearchBoxWidget extends ConsumerStatefulWidget {
  const SearchBoxWidget(
      {super.key,
      required this.textControllerForStart,
      required this.textControllerForEnd,
      required this.startFocusNode,
      required this.destinationFocusNode,
      required this.onClickClear});

  final TextEditingController textControllerForStart;
  final TextEditingController textControllerForEnd;
  final FocusNode startFocusNode;
  final FocusNode destinationFocusNode;
  final Function(SearchType) onClickClear;

  @override
  SearchBoxWidgetState createState() => SearchBoxWidgetState();
}

class SearchBoxWidgetState extends ConsumerState<SearchBoxWidget> {
  @override
  void initState() {
    super.initState();
    widget.destinationFocusNode.addListener(() {
      if (!widget.destinationFocusNode.hasFocus) {
        ref.read(searchDestinationPlaceProvider.notifier).clearRoute();
      }
    });
    widget.startFocusNode.addListener(() {
      if (!widget.startFocusNode.hasFocus) {
        ref.read(searchStartPlaceProvider.notifier).clearRoute();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 40, horizontal: 35),
      alignment: Alignment.topLeft,
      padding: const EdgeInsets.only(left: 0, right: 0, top: 0, bottom: 0),
      child: Column(
        children: <Widget>[
          searchBox(SearchType.start, widget.textControllerForStart),
          searchBox(SearchType.destination, widget.textControllerForEnd),
        ],
      ),
    );
  }

  Widget searchBox(SearchType type, TextEditingController textController) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: const BoxDecoration(boxShadow: [
        BoxShadow(
            spreadRadius: 5,
            blurRadius: 10,
            color: Color.fromRGBO(0, 0, 0, 0.07))
      ]),
      width: MediaQuery.of(context).size.width - 60,
      height: 60,
      child: TextField(
        style: TextStyles.searchBoxTextStyle,
        focusNode: type == SearchType.start
            ? widget.startFocusNode
            : widget.destinationFocusNode,
        onChanged: (value) {
          if (value != "") {
            if (type == SearchType.start) {
              ref.read(searchStartPlaceProvider.notifier).getPlaces(value);
            } else {
              ref
                  .read(searchDestinationPlaceProvider.notifier)
                  .getPlaces(value);
            }
          }
        },
        controller: textController,
        decoration: InputDecoration(
          hintStyle: TextStyles.hintTextStyle,
          hintText: type == SearchType.start ? "출발지를 입력해주세요" : "도착지를 입력해주세요",
          prefixIcon: const Icon(Icons.search),
          suffixIcon: IconButton(
              icon: Image.asset(
                'assets/icons/xmark.png',
                scale: 3.5,
              ),
              onPressed: () {
                textController.clear();
                widget.onClickClear(type);
              }),
          filled: true,
          fillColor: Palette.searchBoxColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}

class SearchListWidget extends ConsumerStatefulWidget {
  const SearchListWidget(
      {super.key,
      required this.list,
      required this.textController,
      required this.type,
      required this.onPlaceItemTab});

  final List<Place> list;
  final TextEditingController textController;
  final SearchType type;
  final Function(TextEditingController, Place, SearchType) onPlaceItemTab;

  @override
  SearchListWidgetState createState() => SearchListWidgetState();
}

class SearchListWidgetState extends ConsumerState<SearchListWidget> {
  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: ListView.builder(
        itemCount: widget.list.length,
        itemBuilder: (BuildContext context, int index) {
          return Card(
              borderOnForeground: true,
              margin: const EdgeInsets.symmetric(vertical: 0.3),
              child: ListTile(
                  title: Row(
                    children: [
                      const ImageIcon(
                          AssetImage('assets/icons/search_marker.png'),
                          size: 18),
                      highlightedText("  ${widget.list[index].title!}",
                          widget.textController.text, "title"),
                    ],
                  ),
                  subtitle: highlightedText(
                      widget.list[index].jibunAddress ?? '',
                      widget.textController.text,
                      "subtitle"),
                  textColor: Colors.black,
                  tileColor: Palette.searchBoxColor,
                  onTap: () => widget.onPlaceItemTab(
                      widget.textController, widget.list[index], widget.type)));
        },
      ),
    );
  }
}

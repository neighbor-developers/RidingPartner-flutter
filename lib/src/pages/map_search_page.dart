import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:provider/provider.dart';
import 'package:ridingpartner_flutter/src/models/place.dart';
import 'package:ridingpartner_flutter/src/pages/navigation_page.dart';
import 'package:ridingpartner_flutter/src/provider/navigation_provider.dart';
import 'package:ridingpartner_flutter/src/utils/user_location.dart';

import '../provider/map_search_provider.dart';
import '../provider/riding_provider.dart';

class MapSearchPage extends StatefulWidget {
  const MapSearchPage({super.key});

  @override
  State<MapSearchPage> createState() => MapSampleState();
}

class MapSampleState extends State<MapSearchPage> {
  final FocusNode _destinationFocusNode = FocusNode();
  final FocusNode _startFocusNode = FocusNode();
  final _destinationTextController = TextEditingController();
  final _startTextController = TextEditingController();
  Completer<NaverMapController> _controller = Completer();
  LocationTrackingMode _locationTrackingMode = LocationTrackingMode.None;
  late List<Marker> _markers = [];
  final int polylineWidth = 5;
  bool searchboxVisible = true;
  int startMarkerId = 0;
  int endMarkerId = 0;
  int buttonsPositionAlpha = 0;

  final Color _searchBoxColor = const Color.fromRGBO(245, 246, 249, 1);
  final Color _orangeColor = const Color.fromRGBO(240, 120, 5, 1);
  final TextStyle _searchBoxTextStyle = const TextStyle(
      fontFamily: 'Pretendard',
      color: Color.fromARGB(255, 80, 80, 80),
      fontSize: 16,
      fontWeight: FontWeight.w500);
  final TextStyle _searchBoxHighlightStyle = const TextStyle(
      fontFamily: 'Pretendard',
      color: Color.fromRGBO(240, 120, 5, 1),
      fontSize: 16,
      fontWeight: FontWeight.w500);
  final TextStyle _hintTextStyle = const TextStyle(
      fontFamily: 'Pretendard',
      color: Color.fromRGBO(153, 153, 153, 1),
      fontSize: 16,
      fontWeight: FontWeight.w400);
  final TextStyle _subTextStyle = const TextStyle(
      fontFamily: 'Pretendard',
      color: Color.fromRGBO(102, 102, 102, 1),
      fontSize: 12,
      fontWeight: FontWeight.w200);

  final TextStyle _subHighlightStyle = const TextStyle(
      fontFamily: 'Pretendard',
      color: Color.fromRGBO(240, 120, 5, 1),
      fontSize: 12,
      fontWeight: FontWeight.w200);

  // var _initLocation = CameraPosition(
  //   target: LatLng(
  //       MyLocation().position!.latitude, MyLocation().position!.longitude),
  //   zoom: 14.4746,
  // );
  @override
  void initState() {
    super.initState();
    Provider.of<MapSearchProvider>(context, listen: false).newPage();
    _destinationFocusNode.addListener(() {
      if (!_destinationFocusNode.hasFocus) {
        Provider.of<MapSearchProvider>(context, listen: false)
            .clearEndPointSearchResult();
      }
    });
    _startFocusNode.addListener(() {
      if (!_startFocusNode.hasFocus) {
        Provider.of<MapSearchProvider>(context, listen: false)
            .clearStartPointSearchResult();
      }
    });
    Provider.of<MapSearchProvider>(context, listen: false)
        .setInitalLocation()
        .then((value) {
      _startTextController.text =
          "현재 위치: ${Provider.of<MapSearchProvider>(context, listen: false).myLocationAddress}";

      _markers.clear();
    });
  }

  @override
  void dispose() {
    super.dispose();
    _startFocusNode.dispose();
    _destinationFocusNode.dispose();
    _startTextController.dispose();
    _destinationTextController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mapSearchProvider = Provider.of<MapSearchProvider>(context);
    return Scaffold(
      body: Stack(
        children: <Widget>[
          NaverMap(
            onMapCreated: onMapCreated,
            mapType: MapType.Basic,
            locationButtonEnable: false,
            initLocationTrackingMode: _locationTrackingMode,
            markers: _markers,
            onMapTap: (latLng) {
              _startFocusNode.unfocus();
              _destinationFocusNode.unfocus();
            },
            pathOverlays: mapSearchProvider.polylinePoints.length > 1
                ? {
                    PathOverlay(
                        PathOverlayId('path'), mapSearchProvider.polylinePoints,
                        width: polylineWidth,
                        outlineWidth: 0,
                        color: const Color.fromARGB(0xFF, 0xFB, 0x95, 0x32))
                  }
                : {},
          ),
          Visibility(
            visible: searchboxVisible,
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 40, horizontal: 35),
              alignment: Alignment.topLeft,
              padding:
                  const EdgeInsets.only(left: 0, right: 0, top: 0, bottom: 0),
              child: Column(
                children: <Widget>[
                  searchBox(mapSearchProvider, "출발지", _startTextController,
                      _startFocusNode),
                  searchBox(mapSearchProvider, "도착지",
                      _destinationTextController, _destinationFocusNode),
                ],
              ),
            ),
          ),
          Container(
              alignment: Alignment.topLeft,
              width: MediaQuery.of(context).size.width - 40,
              margin: const EdgeInsets.only(top: 109.3, left: 35, right: 35),
              child: Visibility(
                visible: mapSearchProvider.isStartSearching,
                child: Column(children: [
                  placeList(
                      mapSearchProvider,
                      "출발지",
                      mapSearchProvider.startPointSearchResult,
                      _startTextController)
                ]),
              )),
          Container(
              alignment: Alignment.topLeft,
              width: MediaQuery.of(context).size.width - 40,
              margin: const EdgeInsets.only(top: 189.5, left: 35, right: 35),
              child: Visibility(
                visible: mapSearchProvider.isEndSearching,
                child: Column(children: [
                  placeList(
                      mapSearchProvider,
                      "도착지",
                      mapSearchProvider.destinationSearchResult,
                      _destinationTextController)
                ]),
              )),
          Positioned(
            bottom: buttonsPositionAlpha + 50,
            left: 20,
            child: FloatingActionButton(
              heroTag: 'mypos',
              backgroundColor: Colors.white,
              child: ImageIcon(
                  const AssetImage('assets/icons/search_myLocation_button.png'),
                  color: _orangeColor),
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
              child: ImageIcon(const AssetImage('assets/icons/search.png'),
                  color: _orangeColor),
              onPressed: () {
                _changeSearchBoxVisibility(mapSearchProvider);
              },
            ),
          ),
          Visibility(
              visible: !searchboxVisible,
              child: Positioned(bottom: 0, child: startNav(mapSearchProvider)))
        ],
      ),
    );
  }

  void onMapCreated(NaverMapController controller) {
    if (_controller.isCompleted) _controller = Completer();
    _controller.complete(controller);
  }

  Widget placeList(MapSearchProvider mapSearchProvider, String type,
      List<Place> list, TextEditingController textController) {
    return Flexible(
      child: ListView.builder(
        itemCount: list.length,
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
                      highlightedText("  ${list[index].title!}",
                          textController.text, "title"),
                    ],
                  ),
                  subtitle: highlightedText(list[index].jibunAddress ?? '',
                      textController.text, "subtitle"),
                  textColor: Colors.black,
                  tileColor: _searchBoxColor,
                  onTap: () async {
                    final NaverMapController controller =
                        await _controller.future;

                    // if (index == 0) {
                    //   textController.text =
                    //       '${list[index].title!}: ${list[index].jibunAddress!}';
                    // } else {
                    textController.text = list[index].title!;
                    // }
                    if (type == "출발지") {
                      FocusScope.of(context)
                          .requestFocus(_destinationFocusNode);
                    } else {
                      FocusManager.instance.primaryFocus?.unfocus();
                    }
                    controller.moveCamera(
                      CameraUpdate.toCameraPosition(CameraPosition(
                        target: LatLng(double.parse(list[index].latitude!),
                            double.parse(list[index].longitude!)),
                      )),
                    );

                    _updatePosition(list[index], type, mapSearchProvider);
                    if (type == "출발지") {
                      mapSearchProvider.setStartPoint(list[index]);
                      mapSearchProvider.clearStartPointSearchResult();
                    } else {
                      mapSearchProvider.setEndPoint(list[index]);
                      mapSearchProvider.clearEndPointSearchResult();
                    }

                    if (mapSearchProvider.startPoint != null &&
                        mapSearchProvider.destination != null) {
                      _changeSearchBoxVisibility(mapSearchProvider);
                      _drawPolyline(
                          mapSearchProvider,
                          mapSearchProvider.startPoint!,
                          mapSearchProvider.destination!);
                    }
                  }));
        },
      ),
    );
  }

  Widget highlightedText(String text, String highlight, String type) {
    highlight = highlight.replaceAll(" ", "");
    final List<String> splitText = text.split(highlight);
    final List<TextSpan> children = [];
    if (type == "title") {
      for (int i = 0; i < splitText.length; i++) {
        children.add(TextSpan(text: splitText[i], style: _searchBoxTextStyle));
        if (i != splitText.length - 1) {
          children.add(TextSpan(
            text: highlight,
            style: _searchBoxHighlightStyle,
          ));
        }
      }
    }
    if (type == "subtitle") {
      for (int i = 0; i < splitText.length; i++) {
        children.add(TextSpan(text: splitText[i], style: _subTextStyle));
        if (i != splitText.length - 1) {
          children.add(TextSpan(
            text: highlight,
            style: _subHighlightStyle,
          ));
        }
      }
    }
    return Text.rich(TextSpan(children: children), textAlign: TextAlign.start);
  }

  Widget searchBox(MapSearchProvider mapSearchProvider, String type,
      TextEditingController textController, FocusNode focusNode) {
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
        style: _searchBoxTextStyle,
        focusNode: focusNode,
        onChanged: (value) => mapSearchProvider.searchPlace(value, type),
        controller: textController,
        decoration: InputDecoration(
          hintStyle: _hintTextStyle,
          hintText: "$type를 입력해주세요",
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _xMarkBtn(mapSearchProvider, type, textController),
          filled: true,
          fillColor: _searchBoxColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _xMarkBtn(MapSearchProvider mapSearchProvider, String type,
      TextEditingController textController) {
    return IconButton(
        icon: Image.asset(
          'assets/icons/xmark.png',
          scale: 3.5,
        ),
        onPressed: () => _clearText(textController, type, mapSearchProvider));
  }

  Widget startNav(MapSearchProvider mapSearchProvider) {
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
              if (mapSearchProvider.destination == null) {
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
                      builder: (context) => MultiProvider(
                            providers: [
                              ChangeNotifierProvider(
                                  create: (context) => NavigationProvider(
                                      [mapSearchProvider.destination!])),
                              ChangeNotifierProvider(
                                  create: (context) => RidingProvider())
                            ],
                            child: const NavigationPage(),
                          )),
                );
              }
            },
            materialTapTargetSize: MaterialTapTargetSize.padded,
            backgroundColor: _orangeColor));
  }

  void clearMarker(String type, MapSearchProvider mapSearchProvider) {
    if (type == "출발지" &&
        mapSearchProvider.startPoint != null &&
        _markers.length > 1) {
      _markers.removeAt(0);
    } else if (type == "도착지" && mapSearchProvider.destination != null) {
      _markers.removeAt(_markers.length - 1);
    }
  }

  Future<void> _updatePosition(
      Place position, String type, MapSearchProvider mapSearchProvider) async {
    final customIcon = await OverlayImage.fromAssetImage(
        assetName: 'assets/icons/search_riding_marker.png');
    int index;
    if (type == "출발지") {
      index = 0;
    } else {
      index = 1;
    }

    if (index == 0) {
      _markers.insert(
          index,
          Marker(
            width: 30,
            height: 40,
            icon: customIcon,
            markerId: '${position.latitude!}${position.longitude!}',
            position: LatLng(double.parse(position.latitude!),
                double.parse(position.longitude!)),
          ));
      if (_markers.length > 2) {
        _markers.removeAt(1);
      }
      setState(() {});
      return;
    }
    if (_markers.length == 2) {
      _markers.removeAt(index);
    } else if (mapSearchProvider.startPoint == null) {
      _markers.clear();
    }
    _markers.add(
        // 출발지와 도착지 마커를 구분하기 위해 index를 사용
        Marker(
      icon: customIcon,
      width: 30,
      height: 40,
      markerId: '${position.latitude!}${position.longitude!}',
      position: LatLng(
          double.parse(position.latitude!), double.parse(position.longitude!)),
    ));

    setState(() {});
  }

  void _clearText(TextEditingController textController, String type,
      MapSearchProvider mapSearchProvider) {
    clearMarker(type, mapSearchProvider);
    mapSearchProvider.clearPolyLine();
    if (type == "출발지") {
      mapSearchProvider.clearStartPointSearchResult();
      mapSearchProvider.removeStartPoint();
    } else {
      mapSearchProvider.clearEndPointSearchResult();
      mapSearchProvider.removeDestination();
    }
    textController.clear();
  }

  void _changeSearchBoxVisibility(MapSearchProvider mapSearchProvider) {
    setState(() {
      if (searchboxVisible) {
        buttonsPositionAlpha = 50;
        mapSearchProvider.isEndSearching = false;
        mapSearchProvider.isStartSearching = false;
      } else {
        buttonsPositionAlpha = 0;
      }
      searchboxVisible = !searchboxVisible;
    });
  }

  void _drawPolyline(MapSearchProvider mapSearchProvider, Place startPlace,
      Place finalDestination) async {
    final NaverMapController controller = await _controller.future;
    mapSearchProvider.polyline(startPlace, finalDestination);
    LatLng start = LatLng(double.parse(startPlace.latitude!),
        double.parse(startPlace.longitude!));
    LatLng end = LatLng(double.parse(finalDestination.latitude!),
        double.parse(finalDestination.longitude!));

    if (start.latitude <= end.latitude) {
      LatLng temp = start;
      start = end;
      end = temp;
    }
    LatLng northEast = start;
    LatLng southWest = end;

    var nLat, nLon, sLat, sLon;

    if (southWest.latitude <= northEast.latitude) {
      sLat = southWest.latitude;
      nLat = northEast.latitude;
    } else {
      sLat = northEast.latitude;
      nLat = southWest.latitude;
    }
    if (southWest.longitude <= northEast.longitude) {
      sLon = southWest.longitude;
      nLon = northEast.longitude;
    } else {
      sLon = northEast.longitude;
      nLon = southWest.longitude;
    }
    controller.moveCamera(
      CameraUpdate.fitBounds(
        LatLngBounds(
          northeast: LatLng(nLat, nLon),
          southwest: LatLng(sLat, sLon),
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

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
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
  final Completer<GoogleMapController> _controller = Completer();
  final FocusNode _destinationFocusNode = FocusNode();
  final FocusNode _startFocusNode = FocusNode();
  final _destinationTextController = TextEditingController();
  final _startTextController = TextEditingController();
  final Color _searchBoxColor = const Color(0xffF5F6F9);
  final Color _orangeColor = const Color(0xffF07805);
  final TextStyle _searchBoxTextStyle = const TextStyle(
      fontFamily: 'Pretended',
      color: Color(0xff666666),
      fontSize: 16,
      fontWeight: FontWeight.normal);
  final TextStyle _hintTextStyle = const TextStyle(
      fontFamily: 'Pretended',
      color: Color(0xff666666),
      fontSize: 16,
      fontWeight: FontWeight.w200);

  var _initLocation = CameraPosition(
    target: LatLng(
        MyLocation().position!.latitude, MyLocation().position!.longitude),
    zoom: 14.4746,
  );
  final List<Marker> _markers = [];

  @override
  void initState() {
    super.initState();
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
    _initLoaction();
  }

  @override
  void dispose() {
    _destinationTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mapSearchProvider = Provider.of<MapSearchProvider>(context);

    return Scaffold(
      body: Stack(
        children: <Widget>[
          GoogleMap(
            mapType: MapType.normal,
            onTap: (latlng) {
              _startFocusNode.unfocus();
              _destinationFocusNode.unfocus();
            },
            markers: Set.from(_markers),
            initialCameraPosition: _initLocation,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
            myLocationButtonEnabled: true,
            myLocationEnabled: true,
          ),
          Container(
            margin: const EdgeInsets.only(top: 40, left: 35),
            alignment: Alignment.topLeft,
            padding:
                const EdgeInsets.only(left: 0, right: 0, top: 0, bottom: 0),
            child: Column(
              children: <Widget>[
                searchBox(mapSearchProvider, "출발지", _startTextController,
                    _startFocusNode),
                SizedBox(
                  height: 15,
                ),
                searchBox(mapSearchProvider, "도착지", _destinationTextController,
                    _destinationFocusNode),
              ],
            ),
          ),
          Container(
              alignment: Alignment.topLeft,
              width: MediaQuery.of(context).size.width - 40,
              margin: const EdgeInsets.only(top: 100, left: 25),
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
              margin: const EdgeInsets.only(top: 175, left: 25),
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
            bottom: 100,
            left: 20,
            child: FloatingActionButton(
              backgroundColor: Colors.white,
              child: const ImageIcon(
                  AssetImage('assets/icons/search_myLocation_button.png'),
                  color: Colors.orange),
              onPressed: () {
                _initLoaction();
              },
            ),
          ),
          Positioned(bottom: 0, child: startNav(mapSearchProvider))
        ],
      ),
    );
  }

  Widget placeList(MapSearchProvider mapSearchProvider, String type,
      List<Place> list, TextEditingController textController) {
    return Flexible(
      child: ListView.builder(
        itemCount: list.length,
        itemBuilder: (BuildContext context, int index) {
          return Card(
              borderOnForeground: true,
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 0.3),
              child: ListTile(
                  title: Row(
                    children: [
                      const ImageIcon(
                          AssetImage('assets/icons/search_marker.png'),
                          size: 18),
                      Text("  ${list[index].title!}",
                          style: _searchBoxTextStyle),
                    ],
                  ),
                  // subtitle: Text(list[index].jibunAddress ?? ''),
                  textColor: Colors.black,
                  tileColor: _searchBoxColor,
                  onTap: () async {
                    final GoogleMapController controller =
                        await _controller.future;

                    if (index == 0) {
                      textController.text =
                          '${list[index].title!}: ${list[index].jibunAddress!}';
                    } else {
                      textController.text = list[index].title!;
                    }
                    if (type == "출발지") {
                      FocusScope.of(context)
                          .requestFocus(_destinationFocusNode);
                    } else {
                      FocusManager.instance.primaryFocus?.unfocus();
                    }
                    controller.animateCamera(CameraUpdate.newCameraPosition(
                      CameraPosition(
                        target: LatLng(double.parse(list[index].latitude!),
                            double.parse(list[index].longitude!)),
                        zoom: 20,
                      ),
                    ));
                    _updatePosition(list[index]);
                    if (type == "출발지") {
                      mapSearchProvider.setStartPoint(list[index]);
                      mapSearchProvider.clearStartPointSearchResult();
                    } else {
                      mapSearchProvider.setEndPoint(list[index]);
                      mapSearchProvider.clearEndPointSearchResult();
                    }
                  }));
        },
      ),
    );
  }

  Widget searchBox(MapSearchProvider mapSearchProvider, String type,
      TextEditingController textController, FocusNode focusNode) {
    return Column(children: [
      Material(
        elevation: 5,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: MediaQuery.of(context).size.width - 60,
          height: 60,
          child: TextField(
            style: _searchBoxTextStyle,
            focusNode: focusNode,
            onChanged: (value) => mapSearchProvider.searchPlace(value, type),
            controller: textController,
            decoration: InputDecoration(
              hintStyle: _hintTextStyle,
              hintText: type + "를 입력해주세요",
              prefixIcon: Icon(Icons.search),
              suffixIcon: _xMarkBtn(mapSearchProvider, type, textController),
              filled: true,
              fillColor: _searchBoxColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
      ),
    ]);
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
            label: Text('안내 시작',
                style: TextStyle(
                    fontFamily: 'Pretended',
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold)),
            shape: BeveledRectangleBorder(borderRadius: BorderRadius.zero),
            elevation: 10,
            heroTag: 'navigateStartBtn',
            onPressed: () {
              if (mapSearchProvider.destination == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('목적지를 입력해주세요.'),
                  ),
                );
                return;
              } else {
                Navigator.pushAndRemoveUntil(
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
                              child: NavigationPage(),
                            )),
                    (route) => false);
              }
            },
            materialTapTargetSize: MaterialTapTargetSize.padded,
            backgroundColor: _orangeColor));
  }

  void _updatePosition(Place position) {
    _markers.clear();
    _markers.add(
      Marker(
        markerId: const MarkerId('1'),
        position: LatLng(double.parse(position.latitude!),
            double.parse(position.longitude!)),
        draggable: true,
      ),
    );
    setState(() {});
  }

  void _clearText(TextEditingController textController, String type,
      MapSearchProvider mapSearchProvider) {
    if (type == "출발지") {
      mapSearchProvider.clearStartPointSearchResult();
    } else {
      mapSearchProvider.clearEndPointSearchResult();
    }
    textController.clear();
  }

  void _initLoaction() async {
    final GoogleMapController controller = await _controller.future;
    final myLocation = MyLocation();
    await myLocation.getMyCurrentLocation();
    _initLocation = CameraPosition(
      target:
          LatLng(myLocation.position!.latitude, myLocation.position!.longitude),
      zoom: 14.4746,
    );
    controller.animateCamera(CameraUpdate.newCameraPosition(_initLocation));
  }
}

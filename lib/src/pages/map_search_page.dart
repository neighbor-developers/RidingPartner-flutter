import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:ridingpartner_flutter/src/models/place.dart';
import 'package:ridingpartner_flutter/src/pages/navigation_page.dart';
import 'package:ridingpartner_flutter/src/provider/navigation_provider.dart';
import 'package:ridingpartner_flutter/src/utils/user_location.dart';
import 'dart:developer' as developer;
import '../provider/map_search_provider.dart';
import '../provider/riding_provider.dart';

class MapSearchPage extends StatefulWidget {
  const MapSearchPage({super.key});

  @override
  State<MapSearchPage> createState() => MapSampleState();
}

class MapSampleState extends State<MapSearchPage> {
  final Completer<GoogleMapController> _controller = Completer();
  FocusNode _destinationFocusNode = FocusNode();
  final _destinationTextController = TextEditingController();
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
            margin: const EdgeInsets.only(top: 60, left: 60),
            alignment: Alignment.topLeft,
            child: Column(
              children: <Widget>[
                searchBox(mapSearchProvider, "도착지", _destinationTextController,
                    _destinationFocusNode),
                GestureDetector(
                  onTap: () {
                    _destinationFocusNode.unfocus();
                  },
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height * 0.5,
                  ),
                ),
                startNav(mapSearchProvider),
              ],
            ),
          ),
          Container(
              alignment: Alignment.topLeft,
              width: MediaQuery.of(context).size.width - 80,
              margin: const EdgeInsets.only(top: 120, left: 50),
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
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
              child: ListTile(
                  title: Text(list[index].title!),
                  subtitle: Text(list[index].jibunAddress ?? ''),
                  textColor: Colors.black,
                  onTap: () async {
                    final GoogleMapController controller =
                        await _controller.future;
                    textController.text = list[index].title!;
                    FocusManager.instance.primaryFocus?.unfocus();
                    controller.animateCamera(CameraUpdate.newCameraPosition(
                      CameraPosition(
                        target: LatLng(double.parse(list[index].latitude!),
                            double.parse(list[index].longitude!)),
                        zoom: 20,
                      ),
                    ));
                    _updatePosition(list[index]);
                    mapSearchProvider.setEndPoint(list[index]);
                    mapSearchProvider.clearEndPointSearchResult();
                  }));
        },
      ),
    );
  }

  Widget searchBox(MapSearchProvider mapSearchProvider, String type,
      TextEditingController textController, FocusNode focusNode) {
    return Column(children: [
      SizedBox(
        height: 70,
        width: MediaQuery.of(context).size.width - 100,
        child: TextField(
          focusNode: focusNode,
          onChanged: (value) => mapSearchProvider.searchPlace(value, type),
          controller: textController,
          decoration: const InputDecoration(
            hintText: "목적지",
            border: OutlineInputBorder(),
          ),
        ),
      ),
    ]);
  }

  Widget startNav(MapSearchProvider mapSearchProvider) {
    return FloatingActionButton.extended(
        label: const Text('안내시작'),
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
            developer.log("안내시작");
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
        backgroundColor: Colors.green);
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

  void _initLoaction() async {
    final myLocation = MyLocation();
    await myLocation.getMyCurrentLocation();
    _initLocation = CameraPosition(
      target:
          LatLng(myLocation.position!.latitude, myLocation.position!.longitude),
      zoom: 14.4746,
    );
    _markers.add(Marker(
        markerId: const MarkerId("1"),
        draggable: true,
        onTap: () => {},
        position: LatLng(
            myLocation.position!.latitude, myLocation.position!.longitude)));
  }
}

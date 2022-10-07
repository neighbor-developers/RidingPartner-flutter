import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:ridingpartner_flutter/src/models/place.dart';
import 'package:ridingpartner_flutter/src/utils/user_location.dart';
import 'dart:developer' as developer;
import '../provider/map_search_provider.dart';

class MapSample extends StatefulWidget {
  const MapSample({super.key});

  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> {
  final Completer<GoogleMapController> _controller = Completer();
  var _initLocation = const CameraPosition(
    target: LatLng(37.5665, 126.9780),
    zoom: 14.4746,
  );
  List<Marker> _markers = [];
  @override
  void initState() {
    super.initState();
    _initLoaction();
  }

  @override
  Widget build(BuildContext context) {
    final mapSearchProvider = Provider.of<MapSearchProvider>(context);

    return Scaffold(
      body: Stack(
        children: <Widget>[
          GoogleMap(
            mapType: MapType.normal,
            markers: Set.from(_markers),
            initialCameraPosition: _initLocation,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
            myLocationButtonEnabled: true,
            myLocationEnabled: true,
          ),
          Container(
            margin: const EdgeInsets.only(top: 60, right: 10),
            alignment: Alignment.topRight,
            child: Column(
              children: <Widget>[
                FloatingActionButton.extended(
                  heroTag: 'backBtn',
                  onPressed: _goBackToMain,
                  label: const Text('돌아가기'),
                  icon: const Icon(Icons.directions_boat),
                ),
                Row(children: [
                  const SizedBox(
                    width: 300,
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: '출발지',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 100,
                    child: FloatingActionButton.extended(
                      heroTag: 'searchBtn',
                      onPressed: () async {
                        await mapSearchProvider.setSearchResult("시청");
                      },
                      label: const Text('검색'),
                      icon: const Icon(Icons.search),
                    ),
                  ),
                ]),
                Row(children: [
                  const SizedBox(
                    width: 300,
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: '도착지',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 100,
                    child: FloatingActionButton.extended(
                      heroTag: 'searchBtn2',
                      onPressed: () {
                        // code for search destination and set visibility true
                      },
                      label: const Text('검색'),
                      icon: const Icon(Icons.search),
                    ),
                  ),
                ]),
                Flexible(
                  child: ListView.builder(
                    itemCount: mapSearchProvider.searchResult.length,
                    itemBuilder: (BuildContext context, int index) {
                      return ListTile(
                          title: Text(
                              mapSearchProvider.searchResult[index].title!),
                          onTap: () async {
                            final GoogleMapController controller =
                                await _controller.future;
                            controller
                                .animateCamera(CameraUpdate.newCameraPosition(
                              CameraPosition(
                                target: LatLng(
                                    double.parse(mapSearchProvider
                                        .searchResult[index].longitude!),
                                    double.parse(mapSearchProvider
                                        .searchResult[index].latitude!)),
                                zoom: 20,
                              ),
                            ));
                            _updatePosition(
                                mapSearchProvider.searchResult[index]);
                          });
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _updatePosition(Place position) {
    if (_markers[0] != null) {
      _markers.removeAt(0);
    }
    _markers.add(
      Marker(
        markerId: MarkerId('1'),
        position: LatLng(double.parse(position.latitude!),
            double.parse(position.longitude!)),
        draggable: true,
      ),
    );
    setState(() {});
  }

  Future<void> _goBackToMain() async {
    Navigator.pop(context);
  }

  void _initLoaction() async {
    final myLocation = MyLocation();
    await myLocation.getMyCurrentLocation();
    _initLocation = CameraPosition(
      target: LatLng(myLocation.latitude!, myLocation.longitude!),
      zoom: 14.4746,
    );
    _markers.add(Marker(
        markerId: const MarkerId("1"),
        draggable: true,
        onTap: () => print("Marker!"),
        position: LatLng(myLocation.latitude!, myLocation.longitude!)));
    developer.log("init Location called");
  }
}

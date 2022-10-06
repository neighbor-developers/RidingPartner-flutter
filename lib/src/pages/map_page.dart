import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'dart:developer' as developer;
import '../provider/map_search_provider.dart';

class MapSample extends StatefulWidget {
  const MapSample({super.key});

  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> {
  final Completer<GoogleMapController> _controller = Completer();
  var _myController;
  static final CameraPosition _initLocation = CameraPosition(
    target: LatLng(37.5665, 126.9780),
    zoom: 14.4746,
  );

  // static final CameraPosition _kLake =  CameraPosition(
  //     bearing: 192.8334901395799,
  //     target: LatLng(37.43296265331129, -122.08832357078792),
  //     tilt: 59.440717697143555,
  //     zoom: 19.151926040649414);

  @override
  Widget build(BuildContext context) {
    final mapSearchProvider = Provider.of<MapSearchProvider>(context);
    bool _visibility = false;

    return Scaffold(
      body: Stack(
        children: <Widget>[
          GoogleMap(
            mapType: MapType.normal,
            initialCameraPosition: _initLocation,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
              _myController = controller;
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
                        final GoogleMapController controller =
                            await _controller.future;
                        controller.animateCamera(CameraUpdate.newCameraPosition(
                          const CameraPosition(
                            target: LatLng(37.4, 126.7),
                            zoom: 14.4746,
                          ),
                        ));
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
                          onTap: () {
                            developer.log('tap$index');
                            // code for set destination
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

  Future<void> _goBackToMain() async {
    Navigator.pop(context);
  }
}

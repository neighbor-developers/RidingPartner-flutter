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
import 'riding_page.dart';

class MapSample extends StatefulWidget {
  const MapSample({super.key});

  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> {
  final Completer<GoogleMapController> _controller = Completer();
  final _startPointTextController = TextEditingController();
  final _endPointTextController = TextEditingController();
  var _initLocation = CameraPosition(
    target: LatLng(MyLocation().latitude!, MyLocation().longitude!),
    zoom: 14.4746,
  );
  final List<Marker> _markers = [];
  @override
  void initState() {
    super.initState();
    _initLoaction();
  }

  @override
  void dispose() {
    _startPointTextController.dispose();
    _endPointTextController.dispose();
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
                    label: const Text('안내시작'),
                    heroTag: 'navigateStartBtn',
                    onPressed: () {
                      if (mapSearchProvider.startPoint == null ||
                          mapSearchProvider.endPoint == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('출발지와 도착지를 입력해주세요.'),
                          ),
                        );
                        return;
                      } else {
                        developer.log("안내시작");
                        final returnList = [
                          mapSearchProvider.endPoint!,
                          mapSearchProvider.startPoint!
                        ];
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    ChangeNotifierProxyProvider<
                                        MapSearchProvider, NavigationProvider>(
                                      create: (_) => NavigationProvider(),
                                      update: (_, mapSearchProvider,
                                          navigationProvider) {
                                        navigationProvider!.startPoint =
                                            mapSearchProvider.startPoint!;
                                        navigationProvider.endPoint =
                                            mapSearchProvider.endPoint!;
                                        return navigationProvider;
                                      },
                                      child: NavigationPage(returnList),
                                    )));
                      }
                    },
                    materialTapTargetSize: MaterialTapTargetSize.padded,
                    backgroundColor: Colors.green),
                FloatingActionButton.extended(
                  heroTag: 'backBtn',
                  onPressed: _goBackToMain,
                  label: const Text('돌아가기'),
                  icon: const Icon(Icons.directions_boat),
                ),
                Row(children: [
                  SizedBox(
                    width: 300,
                    child: TextField(
                      controller: _startPointTextController,
                      decoration: const InputDecoration(
                        hintText: '출발지',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 100,
                    child: FloatingActionButton.extended(
                      heroTag: 'startPointSearchBtn',
                      onPressed: () async {
                        if (_startPointTextController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('출발지를 입력해주세요.'),
                            ),
                          );
                          return;
                        } else {
                          await mapSearchProvider.setStartPointSearchResult(
                              _startPointTextController.text);
                        }
                      },
                      label: const Text('검색'),
                      icon: const Icon(Icons.search),
                    ),
                  ),
                ]),
                Row(children: [
                  SizedBox(
                    width: 300,
                    child: TextField(
                      controller: _endPointTextController,
                      decoration: const InputDecoration(
                        hintText: '도착지',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 100,
                    child: FloatingActionButton.extended(
                      heroTag: 'endPointSearchBtn',
                      onPressed: () async {
                        if (_endPointTextController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('도착지를 입력해주세요.'),
                            ),
                          );
                          return;
                        } else {
                          await mapSearchProvider.setEndPointSearchResult(
                              _endPointTextController.text);
                        }
                      },
                      label: const Text('검색'),
                      icon: const Icon(Icons.search),
                    ),
                  ),
                ]),
                Flexible(
                  child: ListView.builder(
                    itemCount: mapSearchProvider.startPointSearchResult.length,
                    itemBuilder: (BuildContext context, int index) {
                      return ListTile(
                          title: Text(mapSearchProvider
                              .startPointSearchResult[index].title!),
                          onTap: () async {
                            final GoogleMapController controller =
                                await _controller.future;
                            _startPointTextController.text = mapSearchProvider
                                .startPointSearchResult[index].title!;
                            controller
                                .animateCamera(CameraUpdate.newCameraPosition(
                              CameraPosition(
                                target: LatLng(
                                    double.parse(mapSearchProvider
                                        .startPointSearchResult[index]
                                        .latitude!),
                                    double.parse(mapSearchProvider
                                        .startPointSearchResult[index]
                                        .longitude!)),
                                zoom: 20,
                              ),
                            ));
                            _updatePosition(mapSearchProvider
                                .startPointSearchResult[index]);
                            mapSearchProvider.setStartPoint(mapSearchProvider
                                .startPointSearchResult[index]);
                            mapSearchProvider.clearStartPointSearchResult();
                          });
                    },
                  ),
                ),
                Flexible(
                  child: ListView.builder(
                    itemCount: mapSearchProvider.endPointSearchResult.length,
                    itemBuilder: (BuildContext context, int index) {
                      return ListTile(
                          title: Text(mapSearchProvider
                              .endPointSearchResult[index].title!),
                          onTap: () async {
                            final GoogleMapController controller =
                                await _controller.future;
                            _endPointTextController.text = mapSearchProvider
                                .endPointSearchResult[index].title!;
                            controller
                                .animateCamera(CameraUpdate.newCameraPosition(
                              CameraPosition(
                                target: LatLng(
                                    double.parse(mapSearchProvider
                                        .endPointSearchResult[index].latitude!),
                                    double.parse(mapSearchProvider
                                        .endPointSearchResult[index]
                                        .longitude!)),
                                zoom: 20,
                              ),
                            ));
                            _updatePosition(
                                mapSearchProvider.endPointSearchResult[index]);
                            mapSearchProvider.setEndPoint(
                                mapSearchProvider.endPointSearchResult[index]);
                            mapSearchProvider.clearEndPointSearchResult();
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

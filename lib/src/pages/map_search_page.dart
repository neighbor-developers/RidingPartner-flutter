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

class MapSearchPage extends StatefulWidget {
  const MapSearchPage({super.key});

  @override
  State<MapSearchPage> createState() => MapSampleState();
}

class MapSampleState extends State<MapSearchPage> {
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
                startNav(mapSearchProvider),
                FloatingActionButton.extended(
                  heroTag: 'backBtn',
                  onPressed: _goBackToMain,
                  label: const Text('돌아가기'),
                  icon: const Icon(Icons.directions_boat),
                ),
                searchBox(mapSearchProvider, "출발지", _startPointTextController),
                searchBox(mapSearchProvider, "도착지", _endPointTextController),
                placeList(
                    mapSearchProvider,
                    "출발지",
                    mapSearchProvider.startPointSearchResult,
                    _startPointTextController),
                placeList(
                    mapSearchProvider,
                    "도착지",
                    mapSearchProvider.endPointSearchResult,
                    _endPointTextController),
              ],
            ),
          ),
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
          return ListTile(
              title: Text(list[index].title!),
              onTap: () async {
                final GoogleMapController controller = await _controller.future;
                textController.text = list[index].title!;
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
              });
        },
      ),
    );
  }

  Widget searchBox(MapSearchProvider mapSearchProvider, String type,
      TextEditingController textController) {
    return Row(children: [
      SizedBox(
        width: 300,
        child: TextField(
          controller: textController,
          decoration: InputDecoration(
            hintText: type,
            border: OutlineInputBorder(),
          ),
        ),
      ),
      SizedBox(
        width: 100,
        child: FloatingActionButton.extended(
          heroTag: '${type}placeSearchBtn',
          onPressed: () async {
            if (textController.text.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('$type를 입력해주세요.'),
                ),
              );
              return;
            } else {
              if (type == "출발지") {
                await mapSearchProvider
                    .setStartPointSearchResult(textController.text);
              } else {
                await mapSearchProvider
                    .setEndPointSearchResult(textController.text);
              }
            }
          },
          label: const Text('검색'),
          icon: const Icon(Icons.search),
        ),
      ),
    ]);
  }

  Widget startNav(MapSearchProvider mapSearchProvider) {
    return FloatingActionButton.extended(
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
                    builder: (context) => MultiProvider(
                          providers: [
                            ChangeNotifierProvider(
                                create: (context) => NavigationProvider([
                                      mapSearchProvider.startPoint!,
                                      mapSearchProvider.endPoint!
                                    ])),
                            ChangeNotifierProvider(
                                create: (context) => RidingProvider())
                          ],
                          child: NavigationPage(),
                        )));
          }
        },
        materialTapTargetSize: MaterialTapTargetSize.padded,
        backgroundColor: Colors.green);
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

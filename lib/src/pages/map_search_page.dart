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
            margin: const EdgeInsets.only(top: 60, left: 60),
            alignment: Alignment.topLeft,
            child: Column(
              children: <Widget>[
                searchBox(mapSearchProvider, "출발지", _startPointTextController),
                searchBox(mapSearchProvider, "도착지", _endPointTextController),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.5,
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
                  visible: mapSearchProvider.isStartSearching,
                  child: Column(children: [
                    placeList(
                        mapSearchProvider,
                        "출발지",
                        mapSearchProvider.startPointSearchResult,
                        _startPointTextController)
                  ]))),
          Container(
              alignment: Alignment.topLeft,
              width: MediaQuery.of(context).size.width - 80,
              margin: const EdgeInsets.only(top: 190, left: 50),
              child: Visibility(
                visible: mapSearchProvider.isEndSearching,
                child: Column(children: [
                  placeList(
                      mapSearchProvider,
                      "도착지",
                      mapSearchProvider.endPointSearchResult,
                      _endPointTextController)
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
                  onTap: () async {
                    final GoogleMapController controller =
                        await _controller.future;
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
                  }));
        },
      ),
    );
  }

  Widget searchBox(MapSearchProvider mapSearchProvider, String type,
      TextEditingController textController) {
    return Column(children: [
      SizedBox(
        height: 70,
        width: MediaQuery.of(context).size.width - 100,
        child: TextField(
          onChanged: (value) => mapSearchProvider.searchPlace(value, type),
          controller: textController,
          decoration: InputDecoration(
            hintText: type,
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
      target: LatLng(myLocation.latitude!, myLocation.longitude!),
      zoom: 14.4746,
    );
    _markers.add(Marker(
        markerId: const MarkerId("1"),
        draggable: true,
        onTap: () => {},
        position: LatLng(myLocation.latitude!, myLocation.longitude!)));
  }
}

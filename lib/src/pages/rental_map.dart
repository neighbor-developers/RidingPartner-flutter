import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:ridingpartner_flutter/src/provider/place_list_provider.dart';

import '../models/place.dart';

class RentalMap extends StatefulWidget {
  const RentalMap({super.key});
  @override
  State<StatefulWidget> createState() => RentalMapState();
}

class RentalMapState extends State<RentalMap> {
  final Completer<GoogleMapController> _controller = Completer();
  List<Marker> _markers = <Marker>[];

  void initState() {
    super.initState();
    Provider.of<PlaceListProvider>(context, listen: false).getPlaceList();
  }

  @override
  Widget build(BuildContext context) {
    List<Place> _placeList = Provider.of<PlaceListProvider>(context).placeList;
    _markers = _placeList
        .map((place) => Marker(
            markerId: MarkerId(place.title!),
            position: LatLng(
                double.parse(place.latitude!), double.parse(place.longitude!))))
        .toList();

    return Scaffold(
        body: GoogleMap(
      mapType: MapType.normal,
      markers: Set.from(_markers),
      initialCameraPosition: const CameraPosition(
          target: LatLng(37.349741467772, 126.76182486561), zoom: 12.9),
      onMapCreated: (GoogleMapController controller) {
        _controller.complete(controller);
      },
      myLocationButtonEnabled: true,
      myLocationEnabled: true,
      //onCameraMove: ,
    ));
  }
}

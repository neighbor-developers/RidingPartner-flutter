import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:ridingpartner_flutter/src/provider/navigation_provider.dart';

import '../models/place.dart';

class NavigationPage extends StatefulWidget {
  final List<Place> course;

  const NavigationPage(this.course, {super.key});

  @override
  State<NavigationPage> createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage> {
  late NavigationProvider _navigationProvider;
  Completer<GoogleMapController> _controller = Completer();

  @override
  void initState() {
    super.initState();
    _navigationProvider =
        Provider.of<NavigationProvider>(context, listen: false);
    _navigationProvider.getRoute(widget.course);
  }

  @override
  Widget build(BuildContext context) {
    Position? position = _navigationProvider.position;
    LatLng initCameraPosition = LatLng(
        position?.latitude ??
            0 + double.parse(widget.course.last.latitude!) / 2,
        (position?.latitude ??
            0 + double.parse(widget.course.last.longitude!) / 2));

    Set<Marker> markers = widget.course
        .map((course) => Marker(
            markerId: MarkerId(course.title ?? ""),
            position:
                LatLng(course.latitude as double, course.longitude as double)))
        .toSet();

    void _setController() async {
      GoogleMapController _googleMapController = await _controller.future;
      _navigationProvider.addListener(() {
        _googleMapController.animateCamera(CameraUpdate.newCameraPosition(
            CameraPosition(
                target: LatLng(position!.latitude, position.longitude))));
      });
      markers.add(Marker(
          markerId: MarkerId("currentPosition"),
          position: LatLng(position!.latitude, position.longitude)));
    }

    return Scaffold(
        appBar: AppBar(),
        body: _navigationProvider.position == null
            ? const Center(
                child: Text('Loading'),
              )
            : Stack(
                children: <Widget>[
                  GoogleMap(
                      mapType: MapType.normal,
                      initialCameraPosition:
                          CameraPosition(target: initCameraPosition),
                      polylines: {
                        Polyline(
                            polylineId: PolylineId("route"),
                            points: _navigationProvider.polylineCoordinates)
                      },
                      onMapCreated: (GoogleMapController controller) {
                        _controller.complete(controller);
                      },
                      myLocationButtonEnabled: true,
                      myLocationEnabled: true,
                      markers: markers),
                  Container()
                ],
              ));
  }
}

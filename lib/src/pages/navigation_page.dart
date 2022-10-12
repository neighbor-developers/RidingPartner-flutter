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
import 'package:ridingpartner_flutter/src/provider/riding_provider.dart';

import '../models/place.dart';

class NavigationPage extends StatefulWidget {
  final List<Place> course;

  const NavigationPage(this.course, {super.key});

  @override
  State<NavigationPage> createState() => _NavigationPageState(); //1
}

class _NavigationPageState extends State<NavigationPage> {
  late NavigationProvider _navigationProvider;
  Completer<GoogleMapController> _controller = Completer();
  late LatLng initCameraPosition;
  late Set<Marker> markers;

  @override
  void initState() {
    _navigationProvider = NavigationProvider(); //2
    setMapComponent();

    super.initState();
  }

  setMapComponent() async {
    await _navigationProvider.getRoute(widget.course);
    initCameraPosition = LatLng(
        _navigationProvider.position!.latitude +
            double.parse(widget.course.last.latitude!) / 2,
        (_navigationProvider.position!.latitude +
            double.parse(widget.course.last.longitude!) / 2));

    markers = widget.course
        .map((course) => Marker(
            markerId: MarkerId(course.title ?? ""),
            position: LatLng(double.parse(course.latitude!),
                double.parse(course.longitude!))))
        .toSet();

    markers.add(Marker(
        markerId: MarkerId("currentPosition"),
        position: LatLng(_navigationProvider.position!.latitude,
            _navigationProvider.position!.longitude)));
  }

  @override
  Widget build(BuildContext context) {
    Position? position = _navigationProvider.position;
    RidingProvider _ridingProvider = RidingProvider(); //3

    void _setController() async {
      GoogleMapController _googleMapController = await _controller.future;

      if (_ridingProvider.state != "before") {
        _googleMapController.animateCamera(CameraUpdate.newCameraPosition(
            CameraPosition(
                target: LatLng(position!.latitude, position.longitude))));
        markers.removeWhere((element) => element.markerId == "currentPosition");
        markers.add(Marker(
            markerId: MarkerId("currentPosition"),
            position: LatLng(position.latitude, position.longitude)));
      }
    }

    _setController();

    return Scaffold(
        appBar: AppBar(),
        body: _navigationProvider.route == null
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

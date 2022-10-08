import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:ridingpartner_flutter/src/provider/navigation_provider.dart';

import '../models/place.dart';

class NavigationPage extends StatefulWidget {
  final Place start;
  final Place destination;
  final List<Place>? waypoints;

  const NavigationPage(this.start, this.destination, this.waypoints,
      {super.key});

  @override
  State<NavigationPage> createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage> {
  late LatLng initCameraPosition;
  late NavigationProvider _navigationProvider;

  @override
  void initState() {
    super.initState();
    _navigationProvider = Provider.of<NavigationProvider>(context);
    _navigationProvider.getRoute(
        widget.start, widget.destination, widget.waypoints);
    _navigationProvider.polyline(
        widget.start, widget.destination, widget.waypoints);

    initCameraPosition = LatLng(
        ((widget.start.latitude as double) +
                (widget.destination.latitude as double)) /
            2,
        ((widget.start.longitude as double) +
                (widget.destination.latitude as double)) /
            2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(target: initCameraPosition),
        polylines: {
          Polyline(
              polylineId: PolylineId("route"),
              points: _navigationProvider.polylineCoordinates)
        },
      ),
    );
  }
}

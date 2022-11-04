import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:ridingpartner_flutter/src/provider/navigation_provider.dart';
import 'package:ridingpartner_flutter/src/provider/riding_provider.dart';
import 'package:ridingpartner_flutter/src/widgets/dialog.dart';

class NavigationPage extends StatefulWidget {
  const NavigationPage({super.key});

  @override
  State<NavigationPage> createState() => _NavigationPageState(); //1
}

class _NavigationPageState extends State<NavigationPage> {
  late NavigationProvider _navigationProvider;
  late RidingProvider _ridingProvider;

  Completer<GoogleMapController> _controller = Completer();
  late LatLng initCameraPosition;
  late Set<Marker> markers;

  @override
  void initState() {
    _navigationProvider =
        Provider.of<NavigationProvider>(context, listen: false);

    setMapComponent();
    super.initState();
  }

  setMapComponent() async {
    await _navigationProvider.getRoute();

    markers = _navigationProvider.course
        .map((course) => Marker(
            markerId: MarkerId(course.title ?? ""),
            position: LatLng(double.parse(course.latitude!),
                double.parse(course.longitude!))))
        .toSet();

    if (_navigationProvider.position != null) {
      initCameraPosition = LatLng(
          (_navigationProvider.position!.latitude +
                  double.parse(_navigationProvider.course.last.latitude!)) /
              2,
          ((_navigationProvider.position!.longitude) +
                  double.parse(_navigationProvider.course.last.longitude!)) /
              2);

      markers.add(Marker(
          markerId: MarkerId("currentPosition"),
          position: LatLng(_navigationProvider.position!.latitude,
              _navigationProvider.position!.longitude)));
    } else {
      initCameraPosition = LatLng(37.339985, 126.733378);
    }
    print(initCameraPosition);
  }

  String ridingButtonText = "";
  ButtonStyle ridingButtonStyle = ElevatedButton.styleFrom(
    primary: Colors.red,
    onPrimary: Colors.white,
  );

  @override
  Widget build(BuildContext context) {
    _navigationProvider = Provider.of<NavigationProvider>(context);
    _ridingProvider = Provider.of<RidingProvider>(context);

    Position? position = _navigationProvider.position;

    void _setController() async {
      GoogleMapController _googleMapController = await _controller.future;
      print("hello");
      if (position != null) {
        _googleMapController.animateCamera(CameraUpdate.newCameraPosition(
            CameraPosition(
                target: LatLng(position.latitude, position.longitude),
                zoom: 19)));
        markers.removeWhere((element) => element.markerId == "currentPosition");
        markers.add(Marker(
            markerId: MarkerId("currentPosition"),
            position: LatLng(position.latitude, position.longitude)));
      }
    }

    if (_navigationProvider.ridingState != RidingState.before) {
      _setController();
    }

    return WillPopScope(
        child: Scaffold(
            appBar: AppBar(
              leading: IconButton(
                  onPressed: () {
                    backDialog(context, "안내를 중단하시겠습니까?");
                  },
                  icon: Icon(Icons.arrow_back)),
            ),
            body: _navigationProvider.route == null
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : Stack(
                    children: <Widget>[
                      GoogleMap(
                          mapType: MapType.normal,
                          initialCameraPosition: CameraPosition(
                              target: initCameraPosition, zoom: 13),
                          polylines: {
                            Polyline(
                                polylineId: PolylineId("route"),
                                width: 5,
                                points: _navigationProvider.polylinePoints)
                          },
                          onMapCreated: (GoogleMapController controller) {
                            _controller.complete(controller);
                          },
                          myLocationButtonEnabled: true,
                          myLocationEnabled: true,
                          markers: markers),
                      changeButton(_navigationProvider.ridingState),
                      guideWidget()
                    ],
                  )),
        onWillPop: () {
          return backDialog(context, "안내를 중단하시겠습니까?");
        });
  }

  Widget guideWidget() {
    return Text(_navigationProvider.route?.first.content ?? "");
  }

  Widget changeButton(RidingState state) {
    switch (_ridingProvider.state) {
      case RidingState.before:
        {
          ridingButtonText = "안내 시작하기";
          ridingButtonStyle = ElevatedButton.styleFrom(
            primary: Colors.blue,
            onPrimary: Colors.white,
          );
          break;
        }
      case RidingState.riding:
        {
          ridingButtonText = "안내 중단";
          ridingButtonStyle = ElevatedButton.styleFrom(
            primary: Colors.blue,
            onPrimary: Colors.white,
          );
          break;
        }

      case RidingState.pause:
        {
          ridingButtonText = "이어서 진행";
          ridingButtonStyle = ElevatedButton.styleFrom(
            primary: Colors.blue,
            onPrimary: Colors.white,
          );
          break;
        }
      default:
        ridingButtonText = "";
    }
    return Row(children: [
      ElevatedButton(
        style: ridingButtonStyle,
        onPressed: () {
          if (state == RidingState.before || state == RidingState.pause) {
            _ridingProvider.startRiding();
            _navigationProvider.startNavigation();
          } else if (state == RidingState.riding) {
            _ridingProvider.pauseRiding();
            _navigationProvider.setState(RidingState.pause);
          }
        },
        child: Text(ridingButtonText),
      ),
      saveButton(state)
    ]);
  }

  Widget saveButton(RidingState state) {
    if (state == RidingState.pause) {
      return ElevatedButton(
        style: ridingButtonStyle,
        onPressed: () {
          _ridingProvider.stopAndSaveRiding();
          _navigationProvider.setState(RidingState.pause);
        },
        child: Text("라이딩 완료"),
      );
    } else {
      return Spacer(flex: 1);
    }
  }
}

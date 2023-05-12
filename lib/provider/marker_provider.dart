import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';

import '../models/place.dart';
import '../service/location_service.dart';

class MarkerProvider extends StateNotifier<List<Marker>> {
  MarkerProvider() : super([]);

  @override
  set state(List<Marker> value) {
    super.state = value;
  }

  void addMarker(List<Place> places) {
    // addMyLocationMarker();

    if (places.length > 2) {
      places.removeLast();
      for (var element in places) {
        addWayPointMarker(element);
      }
    }

    if (places.length == 1) {
      addDestinationMarker(places[0]);
      return;
    } else {
      addStartMarker(places.first);
      addDestinationMarker(places.last);
    }
  }

  void addMyLocationMarker() async {
    final mylocationIcon = await OverlayImage.fromAssetImage(
        assetName: 'assets/icons/my_location.png');

    state = [
      ...state,
      Marker(
        icon: mylocationIcon,
        width: 30,
        height: 30,
        markerId: "myLocation",
        position: LatLng(
            MyLocation().position!.latitude, MyLocation().position!.longitude),
      )
    ];
  }

  void addStartMarker(Place place) async {
    final OverlayImage startMarkerIcon = await OverlayImage.fromAssetImage(
        assetName: 'assets/icons/marker_start.png');

    state = [
      ...state,
      Marker(
        icon: startMarkerIcon,
        width: 30,
        height: 50,
        markerId: "startPosition",
        position: place.location,
      )
    ];
  }

  void addDestinationMarker(Place place) async {
    final OverlayImage destinationMarkerIcon =
        await OverlayImage.fromAssetImage(
            assetName: 'assets/icons/marker_destination.png');

    state = [
      ...state,
      Marker(
        icon: destinationMarkerIcon,
        width: 30,
        height: 50,
        markerId: "endPosition",
        position: place.location,
      )
    ];
  }

  void addWayPointMarker(Place place) async {
    final OverlayImage wayPointMarkerIcon = await OverlayImage.fromAssetImage(
        assetName: 'assets/icons/marker_orange.png');

    state = [
      ...state,
      Marker(
        icon: wayPointMarkerIcon,
        width: 30,
        height: 40,
        markerId: "wayPoint",
        position: place.location,
      )
    ];
  }
}

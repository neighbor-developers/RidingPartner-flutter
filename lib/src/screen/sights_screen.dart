import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:ridingpartner_flutter/src/widgets/bottom_modal/place_bottom_modal.dart';
import '../models/place.dart';

final placeListProvider = FutureProvider.autoDispose<List<Place>>((ref) async {
  final routeFromJsonFile =
      await rootBundle.loadString('assets/json/place.json');
  final list = PlaceList.fromJson(routeFromJsonFile).places ?? <Place>[];
  return list.where((element) => element.marker != "").toList();
});

final markerListProvider = FutureProvider.autoDispose<List<Marker>>((ref) {
  final placeList = ref.watch(placeListProvider);
  List<Marker> markers = [];
  return placeList.when(
      data: (data) {
        Future.forEach(data, (place) async {
          markers.add(Marker(
              width: 30,
              height: 40,
              markerId: place.title,
              icon: await OverlayImage.fromAssetImage(assetName: place.marker!),
              position: place.location //예외처리해주기
              ));
        });
        return markers;
      },
      loading: () => [],
      error: (e, s) => []);
});

class SightsScreen extends ConsumerStatefulWidget {
  const SightsScreen({Key? key}) : super(key: key);
  @override
  SightsScreenState createState() => SightsScreenState();
}

class SightsScreenState extends ConsumerState<SightsScreen> {
  Completer<NaverMapController> _controller = Completer();
  var logger = Logger('Logger');

  @override
  Widget build(BuildContext context) {
    final markers = ref.watch(markerListProvider);

    return markers.when(
        data: (data) {
          final markerData = data
              .map((e) => Marker(
                  markerId: e.markerId,
                  position: e.position,
                  icon: e.icon,
                  width: e.width,
                  height: e.height,
                  onMarkerTab: (marker, iconSize) => _onMarkerTap(
                      marker, ref.watch(placeListProvider).asData!.value)))
              .toList();
          return Scaffold(
            body: NaverMap(
              onMapCreated: onMapCreated,
              initialCameraPosition: const CameraPosition(
                  target: LatLng(37.349741467772, 126.76182486561), zoom: 11),
              mapType: MapType.Basic,
              initLocationTrackingMode: LocationTrackingMode.None,
              locationButtonEnable: true,
              markers: markerData,
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => const Center(child: Text("error")));
  }

  void routeDialog(Place place) => showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(15.0), topRight: Radius.circular(15.0))),
      builder: (BuildContext context) => PlaceBottomModal(place: place));

  void onMapCreated(NaverMapController controller) {
    if (_controller.isCompleted) _controller = Completer();
    _controller.complete(controller);
  }

  void _onMarkerTap(Marker? marker, List<Place> placeList) {
    Place place =
        placeList.where((p) => marker?.markerId == p.title).toList().first;
    routeDialog(place);
  }
}

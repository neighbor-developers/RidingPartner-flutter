import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ridingpartner_flutter/src/models/route.dart';
import 'package:ridingpartner_flutter/src/service/firestore_service.dart';

import '../models/place.dart';
import '../utils/custom_marker.dart';
import 'dart:developer';


enum MarkerListState { searching, empty, completed, click }


class SightsProvider with ChangeNotifier {
  MarkerListState _state = MarkerListState.searching;
  MarkerListState get state => _state;

  List<Place> _sightList = <Place> [];
  List<Place> get sightList => _sightList;


  FireStoreService fireStore = FireStoreService();

  final List<Marker> _markers = [];
  List<Marker> get markers => _markers;

  late Uint8List customIcon;
  BitmapDescriptor pictureIcon = BitmapDescriptor.defaultMarker;




  Future<void> getRouteList() async {
    try {
      if (_state == MarkerListState.searching) {
        final routeFromJsonFile = await rootBundle.loadString('assets/json/place.json');
        _sightList = PlaceList.fromJson(routeFromJsonFile).places ?? <Place>[];

        //log(_sightList.toString()); //잘 받아짐

        getSightMarkerList();

        if (_sightList.isEmpty) {
          _state = MarkerListState.empty;
        } else {
          _state = MarkerListState.completed;
        }
      }
      notifyListeners();
    } catch (e) {
      _state = MarkerListState.empty;
    }
  }

  void setCustomMarker(String place) async {
    pictureIcon = CustomMarker().getPictuerMarker(place);

    //customIcon = await CustomMarker().getBytesFromAsset(place, 70);
  }


  void getSightMarkerList(){

    sightList.forEach((place) {
      setCustomMarker("assets/images/places/example.png");
      markers.add(Marker(
          markerId: MarkerId(place.title??"marker"),
          icon: pictureIcon,// BitmapDescriptor.fromBytes(customIcon)
          onTap: () => {
          },
          position: LatLng(double.parse(place.latitude??""), double.parse(place.longitude??""))//예외처리해주기

      ));
    });
  }

  Future<List<Place>> getPlaceList(List<String> placeList) =>
      Future.wait(placeList.map((place) => fireStore.getPlace(place)));
}

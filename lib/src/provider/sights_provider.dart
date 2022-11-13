import 'package:flutter/material.dart';
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

  late final List<Place> _sightList;
  List<Place> get sightList => _sightList;

  FireStoreService fireStore = FireStoreService();

  final List<Marker> _markers = [];
  List<Marker> get markers => _markers;


  Future<void> getRouteList() async {
    try {
      if (_state == MarkerListState.searching) {
        _sightList = await FireStoreService().getPlaces();
        // log(_sightList.toString()); 잘 받아짐


        if (_sightList.isEmpty) {
          _state = MarkerListState.empty;
        } else {
          _state = MarkerListState.completed;
        }
      }
      getSightMarkerList();

      notifyListeners();
    } catch (e) {
      _state = MarkerListState.empty;
    }
  }

  void getSightMarkerList(){
    sightList.forEach((place) {
      markers.add(Marker(
          markerId: MarkerId(place.title??"marker"),
          icon: CustomMarker().getPictuerMarker(place.image??""),
          onTap: () => {
          },
          position: LatLng(double.parse(place.latitude??""), double.parse(place.longitude??""))//예외처리해주기

      ));
      // log(place.image!); 잘 들어감, 사진은 링크 형태
    });

  }

  Future<List<Place>> getPlaceList(List<String> placeList) =>
      Future.wait(placeList.map((place) => fireStore.getPlace(place)));
}

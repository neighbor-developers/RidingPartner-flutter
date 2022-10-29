import 'package:flutter/material.dart';
import 'package:ridingpartner_flutter/src/models/route.dart';
import 'package:ridingpartner_flutter/src/service/firestore_service.dart';

enum RouteListState { searching, empty, completed, click }

class RouteListProvider with ChangeNotifier {
  RouteListState _state = RouteListState.searching;
  RouteListState get state => _state;

  late final List<RidingRoute> _routeList;
  List<RidingRoute> get routeList => _routeList;

  Future<void> getRouteList() async {
    try {
      if (_state == RouteListState.searching) {
        _routeList = await FireStoreService().getRoutes();

        if (_routeList.isEmpty) {
          _state = RouteListState.empty;
        } else {
          _state = RouteListState.completed;
        }
      }
      notifyListeners();
    } catch (e) {
      _state = RouteListState.empty;
    }
  }
}

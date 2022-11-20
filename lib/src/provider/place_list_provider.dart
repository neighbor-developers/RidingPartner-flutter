import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:ridingpartner_flutter/src/models/place.dart';

class PlaceListProvider with ChangeNotifier {
  List<Place> _placeList = <Place>[];
  List<Place> get placeList => _placeList;

  Future<void> getPlaceList() async {
    final placeFromJsonFile =
        await rootBundle.loadString('assets/json/place.json');
    _placeList = PlaceList.fromJson(placeFromJsonFile).places ?? <Place>[];
    notifyListeners();
  }
}

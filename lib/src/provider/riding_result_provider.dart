import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ridingpartner_flutter/src/models/record.dart';
import 'package:ridingpartner_flutter/src/provider/home_record_provider.dart';
import 'package:ridingpartner_flutter/src/service/firebase_database_service.dart';

enum ImageStatus { init, success, fail }

class RidingResultProvider with ChangeNotifier {
  final FirebaseDatabaseService _firebaseDb = FirebaseDatabaseService();

  RidingResultProvider(this._ridingDate);
  final String _ridingDate;

  final picker = ImagePicker();

  RecordState _recordState = RecordState.loading;
  RecordState get recordState => _recordState;

  ImageStatus _imageStatus = ImageStatus.init;
  ImageStatus get imageStatus => _imageStatus;

  late final Record _record;
  Record get record => _record;

  late final File _image;
  File get image => _image;


  Future<void> getRidingData() async {
    _record = await _firebaseDb.getRecord(_ridingDate);

    if (_record != Record() && _record.date != null) {
      _recordState = RecordState.success;
    } else {
      _recordState = RecordState.fail;
    }

    notifyListeners();
  }

  // 비동기 처리를 통해 카메라와 갤러리에서 이미지를 가져온다.
  Future<void> getImage(ImageSource imageSource) async {
    final imageXFile = await picker.pickImage(source: imageSource);
    File imageFile = File(imageXFile!.path); // 가져온 이미지를 _image에 저장

    if (imageFile != null) {
      _image = imageFile;
      _imageStatus = ImageStatus.success;
    } else {
      _imageStatus = ImageStatus.fail;
    }

    notifyListeners();
  }
}

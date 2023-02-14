import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ridingpartner_flutter/src/models/record.dart';
import 'package:ridingpartner_flutter/src/provider/home_record_provider.dart';
import 'package:ridingpartner_flutter/src/service/firebase_database_service.dart';
import 'package:ridingpartner_flutter/src/service/shared_preference.dart';

import '../models/result.dart';

enum ImageStatus { init, permissionFail, imageSuccess, imageFail }

class RidingResultProvider with ChangeNotifier {
  final FirebaseDatabaseService _firebaseDb = FirebaseDatabaseService();

  RidingResultProvider(this._ridingDate);

  final String _ridingDate;

  final picker = ImagePicker();

  RecordState _recordState = RecordState.loading;

  RecordState get recordState => _recordState;

  ImageStatus _imageStatus = ImageStatus.init;

  ImageStatus get imageStatus => _imageStatus;

  late Record _record;

  Record get record => _record;

  List<XFile?> _images = [];
  List<XFile?> get images => _images;

  Future<void> getRidingData() async {
    Result result = await _firebaseDb.getRecord(_ridingDate);
    if (result.isSuccess) {
      _recordState = RecordState.success;
      _record = result.response;
    } else {
      _recordState = RecordState.fail;
    }
    notifyListeners();
  }

  saveOtherRecord(String str, double cal) async {
    Record record = Record(
        distance: _record.distance.toDouble(),
        date: _record.date,
        topSpeed: _record.topSpeed,
        timestamp: _record.timestamp,
        memo: str,
        kcal: cal);
    _firebaseDb.saveRecordFirebaseDb(record);
    PreferenceUtils.saveRecordMemoPref(record);
  }

  Future<void> getImage(ImageSource imageSource) async {
    try {
      final List<XFile> imageXFiles = await picker.pickMultiImage();
      // picker의 사진은 최대 4장까지 선택
      if (imageXFiles.length <= 4) {
        if (_imageStatus == ImageStatus.init) {
          if (imageXFiles.isNotEmpty) {
            _images = imageXFiles;
            _imageStatus = ImageStatus.imageSuccess;
          } else {
            _imageStatus = ImageStatus.init;
          }
        } else if (imageXFiles.isNotEmpty && imageStatus != ImageStatus.init) {
          if (_images.isEmpty) {
            _images.addAll(imageXFiles);
            _imageStatus = ImageStatus.imageSuccess;
          } else {
            _images.clear();
          }
        } else {
          _images.clear();
        }
      } else {
        _imageStatus = ImageStatus.imageFail;
      }
      notifyListeners();
    } catch (e) {}
  }

  Future<void> confirmPermissionGranted() async {
    // storage와  camera의 권한을 요청
    Map<Permission, PermissionStatus> statuses = await [
      Permission.storage,
      Permission.camera,
    ].request();

    bool permitted = true;

    statuses.forEach((key, value) {
      if (!value.isGranted) {
        permitted = false;
      }
    });

    if (!permitted) {
      _imageStatus = ImageStatus.permissionFail;
      notifyListeners();
    }
  }
}

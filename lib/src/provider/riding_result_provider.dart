import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ridingpartner_flutter/src/models/record.dart';
import 'package:ridingpartner_flutter/src/provider/home_record_provider.dart';
import 'package:ridingpartner_flutter/src/service/firebase_database_service.dart';
import 'package:ridingpartner_flutter/src/service/shared_preference.dart';

import '../models/result.dart';
import '../service/firebase_storage_service.dart';

enum ImageStatus { init, permissionFail, imageSuccess, imageFail }

class RidingResultProvider with ChangeNotifier {
  final FirebaseDatabaseService _firebaseDb = FirebaseDatabaseService();
  final FirebaseStorageService _firebaseStorage = FirebaseStorageService();

  RidingResultProvider(this._ridingDate);

  final String _ridingDate;
  final picker = ImagePicker();

  RecordState _recordState = RecordState.loading;
  RecordState get recordState => _recordState;
  ImageStatus _imageStatus = ImageStatus.init;
  ImageStatus get imageStatus => _imageStatus;

  late Record _record;
  Record get record => _record;

  late final List<XFile?> _images;
  List<XFile?> get images => _images;

  List<String>? _downloadImages;

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
    if (_images.isNotEmpty) {
      _downloadImages = await Future.wait(_images.map(
          (img) => _firebaseStorage.uploadImage(img!.name, File(img.path))));
    }

    Record record = Record(
        distance: _record.distance.toDouble(),
        date: _record.date,
        topSpeed: _record.topSpeed,
        timestamp: _record.timestamp,
        memo: str,
        kcal: cal,
        images: _downloadImages);
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
          _imageStatus = ImageStatus.imageFail;
        }
      } else {
        Fluttertoast.showToast(msg: "사진은 최대 4장까지 선택 가능합니다.");
      }
      notifyListeners();
    } catch (e) {}
  }

  Future<void> confirmPermissionGranted() async {
    // storage와  camera의 권한을 요청
    PermissionStatus storageStatus = await Permission.storage.request();
    PermissionStatus cameraStatus = await Permission.camera.request();

    bool permitted = false;
    if (storageStatus.isGranted && cameraStatus.isGranted) {
      permitted = true;
    }

    if (!permitted) {
      _imageStatus = ImageStatus.permissionFail;
      notifyListeners();
    }
  }
}

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ridingpartner_flutter/src/models/place.dart';

import '../models/record.dart';
import '../service/firestore_service.dart';

enum ImageStatus { init, permissionFail, imageSuccess, imageFail }

class AdminProvider with ChangeNotifier {
  FireStoreService fireStoreService = FireStoreService();
  final picker = ImagePicker();

  late final Record _record;
  Record get record => _record;

  late final File? _image;
  File? get image => _image;

  ImageStatus _imageStatus = ImageStatus.init;
  ImageStatus get imageStatus => _imageStatus;

  Future<void> registerPlaces(String jsonData) async {
    PlaceList.fromJson(jsonData);
    // fireStoreService.setPlaces(places);
  }

  Future<void> getImage(ImageSource imageSource) async {
    final imageXFile = await picker.pickImage(source: imageSource);
    File imageFile = File(imageXFile!.path); // 가져온 이미지를 _image에 저장

    if (imageFile != null) {
      _image = imageFile;
      _imageStatus = ImageStatus.imageSuccess;
    } else {
      _imageStatus = ImageStatus.imageFail;
    }

    notifyListeners();
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

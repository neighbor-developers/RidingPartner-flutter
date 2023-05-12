import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:logger/logger.dart';
import 'package:permission_handler/permission_handler.dart';

class ImagePickerService {
  static final ImagePickerService _imagePickerService =
      ImagePickerService._internal();
  factory ImagePickerService() {
    return _imagePickerService;
  }
  ImagePickerService._internal();

  final FilePicker _filePicker = FilePicker.platform;
  Future<List<File>> pickImage() async {
    confirmPermissionGranted();
    try {
      final pickedFile = await _filePicker.pickFiles(
        type: FileType.image,
        allowMultiple: true,
      );
      if (pickedFile != null) {
        return pickedFile.files.map((e) => File(e.path!)).toList();
      } else {
        return [];
      }
    } catch (e) {
      final logger = Logger();
      logger.d('ImagePickerService: $e');
      return [];
    }
  }

  Future<String?> pickSingleImage() async {
    try {
      confirmPermissionGranted();
      final pickedFile = await _filePicker.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );
      if (pickedFile != null) {
        return pickedFile.files.first.path;
      } else {
        return null;
      }
    } catch (e) {
      final logger = Logger();
      logger.d('ImagePickerService: $e');
      return null;
    }
  }

  Future<void> confirmPermissionGranted() async {
    // storage와  camera의 권한을 요청
    PermissionStatus storageStatus = await Permission.storage.request();
    PermissionStatus cameraStatus = await Permission.camera.request();

    if (!storageStatus.isGranted || !cameraStatus.isGranted) {
      Fluttertoast.showToast(msg: "권한을 허용해주세요");
      return;
    }
  }
}

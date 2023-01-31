import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

class FirebaseStorageService {
  final _imageRef = FirebaseStorage.instance.ref().child("images");

  Future<String> uploadImage(String path, File file) async {
    try {
      final pathRef = _imageRef.child(path);
      UploadTask task = pathRef.putFile(file);

      await task.whenComplete(() => null);
      String downloadUrl = await pathRef.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      return "err";
    }
  }
}

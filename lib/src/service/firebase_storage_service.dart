import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseStorageService {
  final _imageRef = FirebaseStorage.instance.ref().child("images");

  Future<List<String>> saveImage(
    Map<String, File> images,
  ) async {
    List<String> imgUrl = [];
    for (var element in images.entries) {
      var a = await uploadImage(element.key, element.value);
      imgUrl.add(a);
    }
    return imgUrl;
  }

  Future<String> uploadImage(String name, File file) async {
    try {
      final pathRef = _imageRef.child(name);
      UploadTask task = pathRef.putFile(file);

      await task.whenComplete(() => print("upload complete"));
      return await pathRef.getDownloadURL();
    } catch (e) {
      return "err";
    }
  }
}

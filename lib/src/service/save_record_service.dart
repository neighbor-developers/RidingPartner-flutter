import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:ridingpartner_flutter/src/service/firebase_database_service.dart';
import 'package:ridingpartner_flutter/src/service/firebase_storage_service.dart';

import '../models/record.dart';

class SaveRecordService {
  saveRecord(Record record, List<File> img) async {
    record.images = await getImgUrl(img, record.date);
    FirebaseDatabaseService().saveRecordFirebaseDb(record);
  }

  getImgUrl(List<File> image, String date) async {
    final String? _uId = FirebaseAuth.instance.currentUser?.uid;

    Map<String, File> img = image
        .map((e) => {'${date}/$_uId${image.indexOf(e)}}': e})
        .reduce((value, element) => value..addAll(element));

    return await FirebaseStorageService().saveImage(img);
  }
}

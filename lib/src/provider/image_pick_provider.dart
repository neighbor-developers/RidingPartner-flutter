import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../service/image_picker_service.dart';

class ImageState extends StateNotifier<List<File>> {
  ImageState() : super(<File>[]);
  final ImagePickerService picker = ImagePickerService();

  @override
  set state(List<File> value) {
    super.state = value;
  }

  delImage(File image) {
    var list = [...super.state];
    list.remove(image);
    state = list;
  }

  void addImage(List<File> value) {
    var list = [...super.state];
    if (list.isEmpty) {
      state = value;
    } else {
      list.addAll(value);
      list.toSet().toList();
      state = list;
    }
    if (super.state.length > 4) {
      state = super.state.sublist(0, 4);
      Fluttertoast.showToast(msg: 'You can only upload 5 images');
    }
  }

  Future getImage() async {
    picker.pickImage().then((value) {
      addImage(value);
    }).catchError((onError) {
      Fluttertoast.showToast(msg: 'failed to get image');
    });
  }
}

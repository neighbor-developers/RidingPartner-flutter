
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;

import 'package:google_maps_flutter/google_maps_flutter.dart';

class CustomMarker{


  // 마커 asset 아이콘으로 넣기, width로 사이즈 조절
  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  // 마커 사진으로 넣기
  BitmapDescriptor getPictuerMarker(String path){
    BitmapDescriptor pictureIcon = BitmapDescriptor.defaultMarker ;
    BitmapDescriptor.fromAssetImage(ImageConfiguration.empty, path)
        .then((icon){
        pictureIcon = icon;
      },
    );

    return pictureIcon;
  }

  // 마커 링크 사진으로 넣기
}
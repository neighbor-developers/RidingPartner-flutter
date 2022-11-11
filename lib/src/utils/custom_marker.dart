
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;

import 'package:google_maps_flutter/google_maps_flutter.dart';

class CustomMarker{


  // width로 사이즈 조절
  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  BitmapDescriptor getPictuerMarker(String path){
    BitmapDescriptor pictureIcon = BitmapDescriptor.defaultMarker ;
    BitmapDescriptor.fromAssetImage(ImageConfiguration.empty, path)
        .then((icon){
        pictureIcon = icon;
      },
    );

    return pictureIcon;
  }
}
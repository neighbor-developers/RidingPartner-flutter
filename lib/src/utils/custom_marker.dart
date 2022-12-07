import 'dart:developer';
import 'dart:typed_data';
import 'dart:ui';

import 'package:file/src/interface/file.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';

class CustomMarker {
  // 마커 asset 아이콘으로 넣기, width로 사이즈 조절
  Future<Uint8List> getBytesFromAsset(String path) async {
    ByteData data = await rootBundle.load(path);
    Codec codec = await instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: 100);
    FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  Future<BitmapDescriptor> getPictuerMarker(String path) async {
    Uint8List makerIconBytes = await getBytesFromAsset(path);
    return BitmapDescriptor.fromBytes(makerIconBytes);
  }
}

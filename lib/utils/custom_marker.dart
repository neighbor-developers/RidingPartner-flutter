import 'dart:ui';

import 'package:flutter/services.dart';

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
}

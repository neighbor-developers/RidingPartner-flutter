import 'dart:developer';
import 'dart:typed_data';
import 'dart:ui';

import 'package:file/src/interface/file.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class CustomMarker {
  // 마커 asset 아이콘으로 넣기, width로 사이즈 조절
  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    Codec codec = await instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  Future<BitmapDescriptor> getPictuerMarker(String path) =>
      BitmapDescriptor.fromAssetImage(ImageConfiguration.empty, path);

  // 마커 링크 사진으로 넣기
  Future<BitmapDescriptor> getUrlMarker(String path, int width) async {
    final File markerImageFile =
        await DefaultCacheManager().getSingleFile(path);
    final Uint8List markerImageBytes = await markerImageFile.readAsBytes();
    log(markerImageBytes.toString());
    final Codec markerImageCodec = await instantiateImageCodec(
      markerImageBytes,
      targetWidth: width,
    );
    log(markerImageCodec.toString());
    final FrameInfo frameInfo = await markerImageCodec.getNextFrame();
    final ByteData? byteData = await frameInfo.image.toByteData(
      format: ImageByteFormat.png,
    );
    final Uint8List? resizedMarkerImageBytes = byteData?.buffer.asUint8List();

    return BitmapDescriptor.fromBytes(resizedMarkerImageBytes!);
  }
}

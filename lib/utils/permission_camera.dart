import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ridingpartner_flutter/utils/get_camera.dart';

void startCamera(BuildContext context) async {
  // ignore: use_build_context_synchronously
  if (await confirmPermissionGranted(context)) {
    //Navigator.of(context).pushNamed("/camera");
    const CameraExample();
  } else {
    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: const Text("사진, 파일, 마이크 접근을 허용 해주셔야 카메라 사용이 가능합니다."),
      action: SnackBarAction(
        label: "OK",
        onPressed: () {
          AppSettings.openAppSettings();
        },
      ),
    ));
  }
}

Future<bool> confirmPermissionGranted(BuildContext context) async {
  // storage와  camera의 권한을 요청
  Map<Permission, PermissionStatus> statuses = await [
    Permission.storage,
    Permission.camera,
  ].request();

  bool permitted = true;

  statuses.forEach((key, value) {
    if (!value.isGranted) {
      permitted = false;
    }
  });
  return permitted;
}

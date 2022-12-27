import 'dart:io';

import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:ridingpartner_flutter/src/provider/Admin_provider.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  late AdminProvider _adminProvider;
  String jsonData = "";

  @override
  Widget build(BuildContext context) {
    _adminProvider = Provider.of<AdminProvider>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('관리자 설정'),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back),
          color: Colors.indigo.shade900,
        ),
      ),
      body: Column(
        children: [
          adminBox('명소 설정'),
          ImageWidget(),
          placeRegisterJson(),
          adminBox('루트 설정'),
        ],
      ),
    );
  }

  Widget adminBox(String item) {
    return Container(
      padding: EdgeInsets.only(left: 10),
      child: Text(item),
      color: Colors.black26,
      width: MediaQuery.of(context).size.width,
      height: 25,
      alignment: Alignment.centerLeft,
    );
  }

  Widget placeRegisterJson() => Container(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              TextFormField(
                decoration: InputDecoration(labelText: 'json'),
                onSaved: (input) => jsonData = input!,
              ),
              ElevatedButton(
                child: Text(
                  "신청",
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () {
                  Provider.of<AdminProvider>(context).registerPlaces(jsonData);
                },
              )
            ]),
      );

  // 이미지를 보여주는 위젯
  Widget showImage() {
    if (_adminProvider.imageStatus == ImageStatus.init) {
      return const Text(
        "이미지를\n선택해주세요.",
        style: TextStyle(
          fontSize: 14.0,
          color: Color.fromARGB(0xFF, 0xDE, 0xE2, 0xE6),
        ),
        textAlign: TextAlign.center,
      );
    } else if (_adminProvider.imageStatus == ImageStatus.imageSuccess) {
      return Container(
          width: 64.0,
          height: 64.0,
          padding: const EdgeInsets.all(4.0),
          decoration: BoxDecoration(
              border: Border.all(
                  color: const Color.fromARGB(0xFF, 0xFD, 0xD3, 0xAB),
                  width: 2.0),
              borderRadius: BorderRadius.circular(3.5),
              color: Colors.transparent),
          child: Center(
              child: _adminProvider.image == null
                  ? const Text(
                      '이미지 없음',
                      style: TextStyle(
                        fontSize: 13.0,
                        color: Color.fromARGB(0xFF, 0xDE, 0xE2, 0xE6),
                      ),
                      textAlign: TextAlign.center,
                    )
                  : Image.file(File(_adminProvider.image!.path))));
    } else {
      return const Text(
        "업로드 실패",
        style: TextStyle(
          fontSize: 13.0,
          color: Color.fromARGB(0xFF, 0xDE, 0xE2, 0xE6),
        ),
        textAlign: TextAlign.center,
      );
    }
  }

  Widget ImageWidget() => Row(
        children: [
          Container(
              width: 64.0,
              height: 64.0,
              margin: const EdgeInsets.only(right: 20.0),
              child: OutlinedButton(
                  onPressed: () {
                    if (_adminProvider.imageStatus == ImageStatus.init) {
                      _adminProvider.confirmPermissionGranted().then(
                          (_) => _adminProvider.getImage(ImageSource.gallery));
                    } else if (_adminProvider.imageStatus ==
                        ImageStatus.permissionFail) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: const Text(
                            "사진, 파일, 마이크 접근을 허용 해주셔야 카메라 사용이 가능합니다."),
                        action: SnackBarAction(
                          label: "OK",
                          onPressed: () {
                            AppSettings.openAppSettings();
                          },
                        ),
                      ));
                    }
                  },
                  style: ButtonStyle(
                    side: MaterialStateProperty.all(const BorderSide(
                      color: Color.fromARGB(0xFF, 0xFD, 0xD3, 0xAB),
                      width: 2.0,
                    )),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Image(
                        image: AssetImage('assets/icons/add_image.png'),
                        color: Color.fromARGB(255, 255, 255, 255),
                      ),
                      Text(
                        "사진",
                        style: TextStyle(
                            color: Color.fromARGB(0xFF, 0xDE, 0xE2, 0xE6),
                            fontSize: 12.0),
                      )
                    ],
                  ))),
          SizedBox(width: 64.0, height: 64.0, child: showImage())
        ],
      );

  // Widget placeRegisterForm() => Form(
  //     key: _formKey,
  //     child: Column(
  //       children: <Widget>[
  //         Container(
  //           width: 350,
  //           child: TextFormField(
  //             validator: (value) {
  //               if (value!.isEmpty) {
  //                 return '입력해주세요';
  //               } else {
  //                 return null;
  //               }
  //             },
  //             keyboardType: TextInputType.name,
  //             decoration: InputDecoration(
  //               border: OutlineInputBorder(),
  //               hintText: '명소 이름',
  //             ),
  //           ),
  //         ),
  //         Container(
  //           width: 200,
  //           child: TextFormField(
  //             validator: (value) {
  //               if (value!.isEmpty) {
  //                 return '입력해주세요';
  //               } else {
  //                 return null;
  //               }
  //             },
  //             obscureText: true,
  //             decoration: InputDecoration(
  //               border: OutlineInputBorder(),
  //               hintText: '명소 설명',
  //             ),
  //           ),
  //         ),
  //         ElevatedButton(
  //           onPressed: () {
  //             if (_formKey.currentState!.validate()) {
  //               ScaffoldMessenger.of(context).showSnackBar(
  //                 const SnackBar(
  //                   content: Text('Processing Data'),
  //                 ),
  //               );
  //             }
  //           },
  //           child: Text('submit'),
  //         )
  //       ],
  //     ));
}

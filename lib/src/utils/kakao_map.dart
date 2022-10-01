// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:naver_map_plugin/naver_map_plugin.dart';
// import 'com.kakao.sdk.common.util.Utility';
//
// // https://pub.dev/packages/flutter_kakao_map
// // 카카오 맵은 AVD에서 확인 불가능
//
// class KakaoMap extends StatefulWidget {
//   @override
//   _KakaoMapState createState() => _KakaoMapState();
// }
//
// class _KakaoMapState extends State<KakaoMap>{
//   KakaoMapController mapController;
//   MapPoint _visibleRegion = MapPoint(37, 127);
//   CameraPosition _kIntialPosition = CameraPosition(target: LatLng(37.349741467772, 126.76182486561), zoom: 5);
//
//   @override
//   Widget build(BuildContext context){
//     return Scaffold(
//       appBar: const CupertinoNavigationBar(middle: Text('KakaoMap Test')),
//       body: Column(
//         children: [
//           Center(
//             child: SizedBox(
//               width: 300.0,
//               height: 200.0,
//               child: KakaoMap(
//                 onMapCreated: onMapCreated,
//                 initialCameraPosition: _kInitialPosition
//               )
//             )
//           )
//         ],
//       ),
//     );
//   }
// }
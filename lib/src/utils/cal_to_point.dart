// import 'package:latlong2/latlong.dart';

// import '../models/route.dart';
// import 'latlng_from_guide.dart';

// void calToPoint(Guide start, Guide end, LatLng position) async {
//   const Distance calDistance = Distance();

//   LatLng? point = latLngFromGuide(start);
//   LatLng? nextLatLng = latLngFromGuide(end);

//   _bearingPoint = point;

//   if (nextLatLng != null) {
//     num distanceToPoint = calDistance.as(LengthUnit.Meter, position, point!);

//     // 마지막 지점이 아닐때
//     num distanceToNextPoint =
//         calDistance.as(LengthUnit.Meter, position, nextLatLng);

//     num distancePointToPoint =
//         calDistance.as(LengthUnit.Meter, point, nextLatLng);

//     if (distanceToPoint > distancePointToPoint + 10) {
//       // 2의 경우
//       // c + am
//       if (_nextDestination != null) {
//         _calToDestination(); // 다음 경유지 계산해서 만약 다음 경유지가 더 가까우면 사용자 입력 받아서 다음경유지로 안내
//       }
//       getRoute();
//     } else {
//       if (distanceToPoint <= 10 || distanceToPoint > distanceToNextPoint + 50) {
//         // 턴 포인트 도착이거나 a > b일때
//         _isDestination(); // 경유지인지 확인
//         if (_route.length == 2) {
//           _route.removeAt(0);
//           _goalPoint = _route[0]; //
//           _nextPoint = null;
//           if (isFirst) {
//             // _polylinePoints.removeAt(0);
//             isFirst = false;
//           }
//           _remainedDistance -= _distances.last;
//           _distances.removeLast();
//         } else {
//           _route.removeAt(0);
//           _goalPoint = _route[0]; //
//           _nextPoint = _route[1];
//           if (isFirst) {
//             isFirst = false;
//           } else {
//             // _polylinePoints.removeAt(0);
//           }
//           _remainedDistance -= _distances.last;
//           _distances.removeLast();
//         }
//       }
//     }
//   }
// }

// void _calToDestination() {
//   const Distance calDistance = Distance();

//   num distanceToDestination = calDistance.as(
//       LengthUnit.Meter,
//       LatLng(_position!.latitude, _position!.longitude),
//       LatLng(_goalDestination.location.latitude,
//           _goalDestination.location.longitude));

//   num distanceToNextDestination = calDistance.as(
//       LengthUnit.Meter,
//       LatLng(_position!.latitude, _position!.longitude),
//       LatLng(_nextDestination!.location.latitude,
//           _nextDestination!.location.longitude));

//   if (distanceToDestination > distanceToNextDestination) {
//     // 다음 경유지로 안내할까요?
//     // ok ->
//     if (true) {
//       _ridingCourse.removeAt(0);
//     }
//   }
// }

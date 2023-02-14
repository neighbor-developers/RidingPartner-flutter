import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:ridingpartner_flutter/src/pages/record_page.dart';
import 'package:ridingpartner_flutter/src/provider/riding_provider.dart';
import 'package:wakelock/wakelock.dart';
import '../provider/riding_result_provider.dart';
import '../utils/timestampToText.dart';
import '../utils/user_location.dart';
import '../widgets/dialog.dart';

class RidingPage extends StatefulWidget {
  const RidingPage({super.key});

  @override
  State<RidingPage> createState() => _RidingPageState();
}

class _RidingPageState extends State<RidingPage> {
  late RidingProvider _ridingProvider;
  LocationTrackingMode _locationTrackingMode = LocationTrackingMode.Face;
  late List<Marker> _markers = [];
  late OverlayImage _markerIcon;
  Completer<NaverMapController> _controller = Completer();
  double floatingBtnPosition = 80;

  @override
  void initState() {
    super.initState();
    setMapComponent();
  }

  setMapComponent() async {
    await Provider.of<RidingProvider>(context, listen: false).getLocation();

    if (_ridingProvider.position != null) {
      _markerIcon = await OverlayImage.fromAssetImage(
          assetName: 'assets/icons/my_location.png');
      _ridingProvider.setMapComponent();

      _markers = [
        // Marker(
        //     anchor: AnchorPoint(0.5, 0.5),
        //     markerId: "currentLocation",
        //     width: 65,
        //     height: 65,
        //     icon: _markerIcon,
        //     position: LatLng(_ridingProvider.position!.latitude,
        //         _ridingProvider.position!.longitude))
      ];
    }
  }

  int polylineWidth = 7;

  @override
  Widget build(BuildContext context) {
    _ridingProvider = Provider.of<RidingProvider>(context);
    Position? position = _ridingProvider.position;

    if (_ridingProvider.state == RidingState.error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('사용자 위치를 불러올 수 없습니다.'),
        ),
      );
    }

    // if (_ridingProvider.state != RidingState.before) {
    //   if (position != null) {
    //     _markers = [
    //       Marker(
    //           anchor: AnchorPoint(0.5, 0.5),
    //           markerId: "currentLocation",
    //           width: 65,
    //           height: 65,
    //           icon: _markerIcon,
    //           position: LatLng(_ridingProvider.position!.latitude,
    //               _ridingProvider.position!.longitude))
    //     ];
    //   }
    // }

    return WillPopScope(
        child: Scaffold(
            appBar: AppBar(
              shadowColor: const Color.fromRGBO(255, 255, 255, 0.5),
              backgroundColor: Colors.white,
              title: Container(
                  padding: const EdgeInsets.fromLTRB(0, 0, 50, 0),
                  width: MediaQuery.of(context).size.width,
                  alignment: Alignment.center,
                  child: Image.asset(
                    'assets/icons/logo.png',
                    height: 25,
                  )),
              leadingWidth: 50,
              leading: IconButton(
                onPressed: () {
                  if (_ridingProvider.state == RidingState.before) {
                    Navigator.pop(context);
                  } else {
                    backDialog(context, 1);
                  }
                },
                icon: const Icon(Icons.arrow_back),
                color: const Color.fromRGBO(240, 120, 5, 1),
              ),
              elevation: 10,
            ),
            body: Stack(
              children: <Widget>[
                NaverMap(
                  onMapCreated: onMapCreated,
                  pathOverlays: _ridingProvider.polylineCoordinates.length > 1
                      ? {
                          PathOverlay(PathOverlayId('path'),
                              _ridingProvider.polylineCoordinates,
                              width: polylineWidth,
                              outlineWidth: 0,
                              color:
                                  const Color.fromARGB(0xFF, 0xFB, 0x95, 0x32))
                        }
                      : {},
                  mapType: MapType.Basic,
                  initLocationTrackingMode: LocationTrackingMode.Face,
                  initialCameraPosition: CameraPosition(
                      target: LatLng(position!.latitude, position.longitude),
                      zoom: 14),
                  locationButtonEnable: false,
                  markers: _markers,
                ),
                Positioned(
                  bottom: floatingBtnPosition,
                  left: 20,
                  child: FloatingActionButton(
                    heroTag: 'mypos',
                    backgroundColor: Colors.white,
                    child: const ImageIcon(
                        AssetImage('assets/icons/search_myLocation_button.png'),
                        color: Color.fromRGBO(240, 120, 5, 1)),
                    onPressed: () async {
                      final controller = await _controller.future;
                      await controller.moveCamera(CameraUpdate.toCameraPosition(
                          CameraPosition(
                              target: LatLng(_ridingProvider.position!.latitude,
                                  _ridingProvider.position!.longitude),
                              zoom: 18)));
                      controller
                          .setLocationTrackingMode(LocationTrackingMode.Face);
                    },
                  ),
                ),
                Positioned(bottom: 0, child: record(_ridingProvider.state))
              ],
            )),
        onWillPop: () async {
          if (_ridingProvider.state == RidingState.before) {
            Navigator.pop(context);
            return true;
          } else {
            return backDialog(context, 1);
          }
        });
  }

  void onMapCreated(NaverMapController controller) {
    if (_controller.isCompleted) _controller = Completer();
    _controller.complete(controller);
  }

  Widget record(RidingState state) {
    const TextStyle titleStyle = TextStyle(
        fontFamily: 'Pretendard',
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: Color.fromRGBO(134, 142, 150, 1));
    const TextStyle dataStyle = TextStyle(
        fontFamily: 'Pretendard',
        fontSize: 18,
        fontWeight: FontWeight.w400,
        color: Color.fromRGBO(52, 58, 64, 1));

    if (state == RidingState.before || state == RidingState.error) {
      return InkWell(
          child: Container(
            color: const Color.fromRGBO(240, 120, 5, 1),
            alignment: Alignment.center,
            width: MediaQuery.of(context).size.width,
            height: 61,
            child: const Text(
              '주행 시작',
              style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w700,
                  fontSize: 18),
              textAlign: TextAlign.center,
            ),
          ),
          onTap: () async {
            try {
              floatingBtnPosition = 130;
              _ridingProvider.startRiding();
              screenKeepOn();
              final controller = await _controller.future;
              await controller.moveCamera(CameraUpdate.toCameraPosition(
                  CameraPosition(
                      target: LatLng(_ridingProvider.position!.latitude,
                          _ridingProvider.position!.longitude),
                      zoom: 18)));
              controller.setLocationTrackingMode(LocationTrackingMode.Face);
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('주행을 시작하는 데에 실패했습니다'),
                ),
              );
            }
          });
    } else {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            buttons(state),
            Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                        spreadRadius: 1,
                        blurRadius: 3,
                        offset: Offset(1, 1),
                        color: Color.fromRGBO(0, 41, 135, 0.047))
                  ],
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                child: Container(
                    width: MediaQuery.of(context).size.width - 80,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text('거리', style: titleStyle),
                            Text(
                                "${((_ridingProvider.distance / 10000).roundToDouble()) * 10}km",
                                style: dataStyle)
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text(
                              '주행 속도',
                              style: titleStyle,
                            ),
                            Text(
                              "${_ridingProvider.speed.toStringAsFixed(1)}km/h",
                              style: dataStyle,
                            )
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text(
                              '주행 시간',
                              style: titleStyle,
                            ),
                            Text(
                              timestampToText(_ridingProvider.time.inSeconds),
                              style: dataStyle,
                            )
                          ],
                        ),
                        InkWell(
                          onTap: () {
                            _ridingProvider.setVisivility();
                          },
                          child: Container(
                            width: 18,
                            child: Image.asset('assets/icons/menu_bar.png',
                                fit: BoxFit.fitWidth),
                          ),
                        )
                      ],
                    )))
          ],
        ),
      );
    }
  }

  Widget buttons(RidingState state) {
    String text = "일시정지";
    const TextStyle testStyle = TextStyle(
        color: Color.fromRGBO(52, 58, 64, 1),
        fontFamily: 'Pretended',
        fontWeight: FontWeight.w600,
        fontSize: 16);

    switch (state) {
      case RidingState.riding:
        {
          text = "일시중지";
          break;
        }
      case RidingState.pause:
        {
          text = "이어서 시작";
          break;
        }
      default:
    }
    if (state != RidingState.before) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Visibility(
            visible: _ridingProvider.visivility,
            child: InkWell(
                onTap: () {
                  _ridingProvider.setVisivility();
                  if (state == RidingState.riding) {
                    _ridingProvider.pauseRiding();
                  } else {
                    _ridingProvider.startRiding();
                  }
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: const BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                          spreadRadius: 1,
                          blurRadius: 3,
                          offset: Offset(1, 1),
                          color: Color.fromRGBO(0, 41, 135, 0.047))
                    ],
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(7)),
                  ),
                  child: Text(text, style: testStyle),
                )),
          ),
          Visibility(
              maintainState: true,
              maintainAnimation: true,
              visible: _ridingProvider.visivility,
              child: InkWell(
                onTap: () {
                  screenKeepOff();
                  _ridingProvider.stopAndSaveRiding();
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ChangeNotifierProvider(
                                create: (context) => RidingResultProvider(
                                    _ridingProvider.ridingDate),
                                child: RecordPage(),
                              )));
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  margin: const EdgeInsets.symmetric(vertical: 15),
                  decoration: const BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                          spreadRadius: 1,
                          blurRadius: 3,
                          offset: Offset(1, 1),
                          color: Color.fromRGBO(0, 41, 135, 0.047))
                    ],
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(7)),
                  ),
                  child: const Text('종료', style: testStyle),
                ),
              ))
        ],
      );
    } else {
      return const SizedBox(
        height: 0,
        width: 0,
      );
    }
  }

  void screenKeepOn() async {
    if (!(await Wakelock.enabled)) {
      Wakelock.enable();
    }
  }

  void screenKeepOff() async {
    if (await Wakelock.enabled) {
      Wakelock.disable();
    }
  }
}

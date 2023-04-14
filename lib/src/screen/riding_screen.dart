import 'dart:async';
import 'dart:core';
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:ridingpartner_flutter/src/models/my_location.dart';
import 'package:ridingpartner_flutter/src/provider/timer_provider.dart';
import 'package:ridingpartner_flutter/src/screen/riding_result_screen.dart';
import 'package:ridingpartner_flutter/src/style/palette.dart';
import 'package:ridingpartner_flutter/src/style/textstyle.dart';
import 'package:ridingpartner_flutter/src/utils/cal_distance.dart';
import 'package:ridingpartner_flutter/src/utils/timestampToText.dart';
import 'package:wakelock/wakelock.dart';
import '../models/position_stream.dart';
import '../models/record.dart';
import '../provider/record_provider.dart';
import '../widgets/dialog/riding_cancel_dialog.dart';

// 위치 정보 스트림
final StreamProvider<Position> positionStreamProvider =
    StreamProvider((ref) => PositionStream().controller.stream);

// 주행 거리 provider
final distanceProvider = StateProvider.autoDispose<double>((ref) => 0.0);

// 거리 계산 provider
final calProvider = Provider.autoDispose((ref) {
  final state = ref.watch(ridingStateProvider);
  final positionStream = ref.listen(positionStreamProvider, (previous, next) {
    if (state == RidingState.riding) {
      if (previous?.asData?.value != null) {
        ref.read(distanceProvider.notifier).state = ref.read(distanceProvider) +
            calDistance(previous!.asData!.value, next.asData!.value);
      }
    }
  });
});

final polylineCoordinatesProvider = StateProvider<List<LatLng>>((ref) {
  final coordinates = <LatLng>[];
  final positionStream = ref.watch(positionStreamProvider);
  if (positionStream.value != null) {
    coordinates.add(LatLng(
        positionStream.value!.latitude, positionStream.value!.longitude));
  }
  return coordinates;
});

// 주행 상태 provider
final ridingStateProvider =
    StateProvider.autoDispose((ref) => RidingState.before);

final recordProvider =
    StateNotifierProvider.autoDispose<RecordProvider, Record?>(
        (ref) => RecordProvider());

final timerProvider =
    StateNotifierProvider<TimerNotifier, int>((ref) => TimerNotifier());

class RidingScreen extends ConsumerStatefulWidget {
  const RidingScreen({super.key});

  @override
  RidingScreenState createState() => RidingScreenState();
}

class RidingScreenState extends ConsumerState<RidingScreen> {
  final LocationTrackingMode _locationTrackingMode = LocationTrackingMode.Face;
  late List<Marker> _markers = [];
  late OverlayImage _markerIcon;
  Completer<NaverMapController> _controller = Completer();
  @override
  void initState() {
    super.initState();
    try {
      setPosition();
    } catch (e) {
      ref.read(ridingStateProvider.notifier).state = RidingState.error;
      setPosition();
    }

    screenKeepOn();
  }

  Future<void> setPosition() async {
    try {
      MyLocation().getMyCurrentLocation();
      Position? position = MyLocation().position;
      if (position != null) {
      } else {
        throw Exception('위치 정보를 가져올 수 없습니다.');
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  void dispose() {
    super.dispose();
    screenKeepOff();
    ref.invalidate(polylineCoordinatesProvider);
    ref.invalidate(positionStreamProvider);
    ref.invalidate(distanceProvider);
    ref.invalidate(ridingStateProvider);
    ref.invalidate(calProvider);
    ref.invalidate(recordProvider);
    ref.invalidate(timerProvider);
  }

  int polylineWidth = 7;

  @override
  Widget build(BuildContext context) {
    final position = ref.watch(positionStreamProvider);
    final ridingState = ref.watch(ridingStateProvider);
    final polylineCoordinates = ref.watch(polylineCoordinatesProvider);

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
                  if (ridingState == RidingState.before) {
                    Navigator.pop(context);
                  } else {
                    backDialog('주행을 종료하시겠습니까?\n', '주행 종료');
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
                  pathOverlays: polylineCoordinates.length > 1
                      ? {
                          PathOverlay(
                              PathOverlayId('path'), polylineCoordinates,
                              width: polylineWidth,
                              outlineWidth: 0,
                              color:
                                  const Color.fromARGB(0xFF, 0xFB, 0x95, 0x32))
                        }
                      : {},
                  mapType: MapType.Basic,
                  initLocationTrackingMode: LocationTrackingMode.Face,
                  initialCameraPosition: CameraPosition(
                      target: LatLng(position.asData?.value.latitude ?? 0,
                          position.asData?.value.longitude ?? 0),
                      zoom: 14),
                  locationButtonEnable: false,
                  markers: _markers,
                ),
                Visibility(
                    visible: ridingState != RidingState.before,
                    child: Positioned(
                      bottom: 140,
                      left: 20,
                      child: FloatingActionButton(
                        heroTag: 'mypos',
                        backgroundColor: Colors.white,
                        child: const ImageIcon(
                            AssetImage(
                                'assets/icons/search_myLocation_button.png'),
                            color: Color.fromRGBO(240, 120, 5, 1)),
                        onPressed: () async {
                          final controller = await _controller.future;
                          await controller.moveCamera(
                              CameraUpdate.toCameraPosition(CameraPosition(
                                  target: LatLng(
                                      position.asData?.value.latitude ?? 0,
                                      position.asData?.value.longitude ?? 0),
                                  zoom: 18)));
                          controller.setLocationTrackingMode(
                              LocationTrackingMode.Face);
                        },
                      ),
                    )),
                Positioned(
                    bottom: 0,
                    child: ridingState == RidingState.before
                        ? InkWell(
                            onTap: () async {
                              try {
                                ref.read(ridingStateProvider.notifier).state =
                                    RidingState.riding;
                                ref.read(timerProvider.notifier).start();
                                ref.read(recordProvider.notifier).start();

                                final controller = await _controller.future;
                                await controller.moveCamera(CameraUpdate
                                    .toCameraPosition(CameraPosition(
                                        target: LatLng(
                                            position.asData?.value.latitude ??
                                                0,
                                            position.asData?.value.longitude ??
                                                0),
                                        zoom: 18)));
                                controller.setLocationTrackingMode(
                                    LocationTrackingMode.Face);
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('주행을 시작하는 데에 실패했습니다'),
                                  ),
                                );
                              }
                            },
                            child: Container(
                              color: Palette.appColor,
                              alignment: Alignment.center,
                              width: MediaQuery.of(context).size.width,
                              height: 61,
                              child: const Text(
                                '주행 시작',
                                style: TextStyles.modalButtonTextStyle,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          )
                        : const RecordBoxWidget())
              ],
            )),
        onWillPop: () async {
          if (ridingState == RidingState.before) {
            ref.refresh(ridingStateProvider);
            Navigator.pop(context);
            return true;
          } else {
            return backDialog('주행을 종료하시겠습니까?', '주행 종료');
          }
        });
  }

  void onMapCreated(NaverMapController controller) {
    if (_controller.isCompleted) _controller = Completer();
    _controller.complete(controller);
  }

  Future<bool> backDialog(String text, String btnText) async {
    return await showDialog(
        context: context,
        barrierDismissible: false,
        useRootNavigator: false,
        builder: (BuildContext context) => RidingCancelDialog(
            text: text,
            btnText: btnText,
            onOkClicked: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            onCancelClicked: () {
              Navigator.pop(context);
            }));
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

class RecordBoxWidget extends ConsumerStatefulWidget {
  const RecordBoxWidget({
    super.key,
  });

  @override
  RecordBoxWidgetState createState() => RecordBoxWidgetState();
}

class RecordBoxWidgetState extends ConsumerState<RecordBoxWidget> {
  bool visible = false;
  @override
  Widget build(BuildContext context) {
    final distance = ref.watch(distanceProvider);
    final time = ref.watch(timerProvider);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (visible) ...[
            RecordButton(changeVisible: () {
              setState(() {
                visible = !visible;
              });
            })
          ],
          Container(
              alignment: Alignment.center,
              width: MediaQuery.of(context).size.width - 40,
              padding: const EdgeInsets.symmetric(vertical: 20),
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
                      recordText(
                        '거리',
                        "${((distance / 10000).roundToDouble()) * 10}km",
                      ),
                      recordText('주행 속도',
                          time == 0 ? 'km/h' : "${distance / time * 3600}km/h"),
                      recordText('주행 시간', timestampToText(time, 1)),
                      IconButton(
                        onPressed: () => setState(() {
                          visible = !visible;
                        }),
                        icon: SizedBox(
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

  Widget recordText(String title, String data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(title, style: TextStyles.ridingTitleStyle),
        Text(data, style: TextStyles.ridingDataStyle)
      ],
    );
  }
}

class RecordButton extends ConsumerStatefulWidget {
  const RecordButton({super.key, required this.changeVisible});

  final Function changeVisible;

  @override
  RecordButtonState createState() => RecordButtonState();
}

class RecordButtonState extends ConsumerState<RecordButton> {
  @override
  Widget build(BuildContext context) {
    final ridingState = ref.watch(ridingStateProvider);
    final time = ref.watch(timerProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (ridingState == RidingState.riding) ...[
          ridingFloatingButton(() {
            widget.changeVisible();
            ref.read(timerProvider.notifier).pause();
            ref.read(ridingStateProvider.notifier).state = RidingState.pause;
          }, '일시중지')
        ] else ...[
          ridingFloatingButton(() {
            widget.changeVisible();
            ref.read(ridingStateProvider.notifier).state = RidingState.riding;
            ref.read(timerProvider.notifier).restart();
          }, '이어서 주행')
        ],
        ridingFloatingButton(() {
          ref.read(ridingStateProvider.notifier).state = RidingState.stop;
          final Record record = Record(
              distance: ref.read(distanceProvider).roundToDouble(),
              date: DateFormat('yyyy-MM-dd hh:mm:ss').format(DateTime.now()),
              timestamp: ref.read(timerProvider),
              kcal: (550 * (time) / 3600).roundToDouble());

          ref.read(recordProvider.notifier).saveData(record, []);
          ref.refresh(ridingStateProvider);
          ref.refresh(timerProvider);
          ref.refresh(polylineCoordinatesProvider);
          ref.refresh(distanceProvider);
          ref.refresh(recordProvider);

          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => RidingResultScreen(
                        date: record.date,
                      )));
        }, '주행 종료')
      ],
    );
  }

  Widget ridingFloatingButton(Function onTap, String text) {
    return InkWell(
        onTap: () => onTap(),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          margin: const EdgeInsets.only(bottom: 10),
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
          child: Text(text, style: TextStyles.ridingButtonStyle),
        ));
  }
}

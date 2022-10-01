import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:naver_map_plugin/naver_map_plugin.dart';

class NaverMapTest extends StatefulWidget {
  const NaverMapTest({super.key});

  @override
  _NaverMapTestState createState() => _NaverMapTestState();
}

class _NaverMapTestState extends State<NaverMapTest> {
  Completer<NaverMapController> _controller = Completer();
  MapType _mapType = MapType.Basic;
  CameraPosition _kIntialPosition = CameraPosition(target: LatLng(37.349741467772, 126.76182486561), zoom: 5);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:const CupertinoNavigationBar(middle: Text('NaverMap Test')),
      body: Container(
        child: NaverMap(
          onMapCreated: onMapCreated,
          mapType: _mapType,

        ),
      ),
    );
  }

  void onMapCreated(NaverMapController controller) {
    if (_controller.isCompleted) _controller = Completer();
    _controller.complete(controller);
  }
}
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:ridingpartner_flutter/src/utils/get_camera.dart';
import '../models/record.dart';
import '../provider/riding_result_provider.dart';

class RecordPage extends StatelessWidget {
  RecordPage(String _ridingDate, {super.key});

  late RidingResultProvider _recordProvider;

  @override
  Widget build(BuildContext context){
    _recordProvider = Provider.of<RidingResultProvider>(context);
    Record record = Record();
    _recordProvider.getRidingData(record);
    num _speed = record.distance!/3*3600;

    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child:Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("${record.distance!}", style: TextStyle(fontSize: 35), textAlign: TextAlign.left),
            Text("킬로미터", textAlign: TextAlign.left,),
            Container(
                height:1.0,
                width: 500.0,
                color:Colors.grey
            ),
            CameraExample(),
            Row(
              children:[
              Text("${record.timestamp!}"),
                Text("${_speed}km/h")
            ]
            ),Row(
                children:[
                  Text("주행 시간"),
                  Text("평균 속도")
                ]
            ),
            Row(
                children:[
                  Text("${record.distance!}km"),
                  Text("${record.kcal!}")
                ]
            ),
            Row(
                children:[
                  Text("주행 거리"),
                  Text("소모 칼로리")
                ]
            ),
            Container(
              height:1.0,
              width: 500.0,
              color:Colors.grey
            )
          ],
        )
      )
    );
  }
}

import 'package:flutter/material.dart';

Future<bool> backDialog(BuildContext context, String text) async {
  return await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0)),
            title: Column(children: [Text("뒤로가기")]),
            content: Column(children: [Text(text)]),
            actions: <Widget>[
              TextButton(
                  onPressed: () {
                    Navigator.pop(context, false);
                  },
                  child: Text("취소")),
              TextButton(
                  onPressed: () {
                    Navigator.pop(context, true);
                    Navigator.pop(context, true);
                  },
                  child: Text("확인")),
            ],
          ));
}

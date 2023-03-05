import 'package:flutter/material.dart';

Future<bool> permissionDialog(BuildContext context) async {
  return await showDialog(
      context: context,
      barrierDismissible: false,
      useRootNavigator: false,
      builder: (BuildContext context) => AlertDialog(
            buttonPadding: const EdgeInsets.all(20),
            alignment: Alignment.center,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0)),
            content: Container(
                margin: const EdgeInsets.only(top: 20),
                child: const Text.rich(
                  TextSpan(
                      text: '자전거 경로 트래킹을 위하여 백그라운드 위치 수집을 할 수 있습니다.\n동의하시겠습니까?',
                      style: TextStyle(
                          color: Color.fromARGB(255, 24, 24, 1),
                          fontFamily: 'Pretendard',
                          fontWeight: FontWeight.w600,
                          fontSize: 17),
                      children: <TextSpan>[
                        TextSpan(
                          text: '(이용약관에 동의하셔야 서비스를 이용하실 수 있습니다)',
                          style: TextStyle(
                              color: Color.fromARGB(150, 24, 24, 1),
                              fontFamily: 'Pretendard',
                              height: 1.5,
                              fontWeight: FontWeight.w600,
                              fontSize: 13),
                        )
                      ]),
                  textAlign: TextAlign.center,
                )),
            actions: <Widget>[
              SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: 55,
                  child: Row(
                    children: [
                      Flexible(
                          child: InkWell(
                        child: Container(
                          margin: const EdgeInsets.fromLTRB(0, 0, 6, 0),
                          alignment: Alignment.center,
                          height: 55,
                          decoration: BoxDecoration(
                            color: const Color.fromRGBO(234, 234, 234, 1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            '부동의',
                            style: TextStyle(
                                color: Color.fromRGBO(102, 102, 102, 1),
                                fontFamily: 'Pretendard',
                                fontWeight: FontWeight.w700,
                                fontSize: 16),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        onTap: () {
                          Navigator.pop(context, false);
                        },
                      )),
                      Flexible(
                          child: InkWell(
                        child: Container(
                          margin: EdgeInsets.fromLTRB(6, 0, 0, 0),
                          alignment: Alignment.center,
                          height: 55,
                          decoration: BoxDecoration(
                            color: const Color.fromRGBO(240, 120, 5, 1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            '동의',
                            style: TextStyle(
                                color: Colors.white,
                                fontFamily: 'Pretendard',
                                fontWeight: FontWeight.w700,
                                fontSize: 16),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        onTap: () {
                          Navigator.pop(context, true);
                          Navigator.pop(context, true);
                        },
                      ))
                    ],
                  ))
            ],
          ));
}

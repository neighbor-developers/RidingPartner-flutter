import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class WithDrawalDialog extends StatelessWidget {
  const WithDrawalDialog(
      {super.key, required this.onOkClicked, required this.onCancelClicked});

  final onOkClicked;
  final onCancelClicked;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      buttonPadding: const EdgeInsets.all(20),
      alignment: Alignment.center,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      content: Container(
          margin: const EdgeInsets.only(top: 20),
          child: const Text.rich(
            TextSpan(
                text: '계정 탈퇴하시겠습니까?\n',
                style: TextStyle(
                    color: Color.fromARGB(255, 24, 24, 1),
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w600,
                    fontSize: 17),
                children: <TextSpan>[
                  TextSpan(
                    text: '(모든 기록이 삭제됩니다)',
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
                        onTap: onCancelClicked,
                        child: Container(
                          margin: const EdgeInsets.fromLTRB(0, 0, 6, 0),
                          alignment: Alignment.center,
                          height: 55,
                          decoration: BoxDecoration(
                            color: const Color.fromRGBO(234, 234, 234, 1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            '취소',
                            style: TextStyle(
                                color: Color.fromRGBO(102, 102, 102, 1),
                                fontFamily: 'Pretendard',
                                fontWeight: FontWeight.w700,
                                fontSize: 16),
                            textAlign: TextAlign.center,
                          ),
                        ))),
                Flexible(
                    child: InkWell(
                        onTap: onOkClicked,
                        child: Container(
                          margin: EdgeInsets.fromLTRB(6, 0, 0, 0),
                          alignment: Alignment.center,
                          height: 55,
                          decoration: BoxDecoration(
                            color: const Color.fromRGBO(240, 120, 5, 1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            '탈퇴',
                            style: TextStyle(
                                color: Colors.white,
                                fontFamily: 'Pretendard',
                                fontWeight: FontWeight.w700,
                                fontSize: 16),
                            textAlign: TextAlign.center,
                          ),
                        )))
              ],
            ))
      ],
    );
  }
}

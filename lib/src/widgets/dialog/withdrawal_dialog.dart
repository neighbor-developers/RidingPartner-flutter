import 'package:flutter/material.dart';

import '../../style/textstyle.dart';

class WithDrawalDialog extends StatelessWidget {
  const WithDrawalDialog(
      {super.key, required this.onOkClicked, required this.onCancelClicked});

  final Function() onOkClicked;
  final Function() onCancelClicked;

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
                style: TextStyles.dialogTextStyle,
                children: <TextSpan>[
                  TextSpan(
                    text: '(모든 기록이 삭제됩니다)',
                    style: TextStyles.dialogTextStyle2,
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
                            style: TextStyles.dialogCancelBtnTextStyle,
                            textAlign: TextAlign.center,
                          ),
                        ))),
                Flexible(
                    child: InkWell(
                        onTap: onOkClicked,
                        child: Container(
                          margin: const EdgeInsets.fromLTRB(6, 0, 0, 0),
                          alignment: Alignment.center,
                          height: 55,
                          decoration: BoxDecoration(
                            color: const Color.fromRGBO(240, 120, 5, 1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            '탈퇴',
                            style: TextStyles.dialogConfirmBtnTextStyle,
                            textAlign: TextAlign.center,
                          ),
                        )))
              ],
            ))
      ],
    );
  }
}

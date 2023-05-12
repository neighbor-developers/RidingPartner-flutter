import 'package:flutter/material.dart';
import 'package:ridingpartner_flutter/style/textstyle.dart';

class RidingCancelDialog extends StatelessWidget {
  const RidingCancelDialog(
      {super.key,
      required this.text,
      required this.btnText,
      required this.onOkClicked,
      required this.onCancelClicked});

  final String text;
  final String btnText;
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
          child: Text.rich(
            TextSpan(
                text: text,
                style: TextStyles.dialogTextStyle,
                children: const <TextSpan>[
                  TextSpan(
                    text: '(기록이 삭제될 수 있습니다)',
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
                  ),
                  onTap: () {
                    Navigator.pop(context, false);
                  },
                )),
                Flexible(
                    child: InkWell(
                  child: Container(
                    margin: const EdgeInsets.only(left: 6),
                    alignment: Alignment.center,
                    height: 55,
                    decoration: BoxDecoration(
                      color: const Color.fromRGBO(240, 120, 5, 1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      btnText,
                      style: TextStyles.dialogConfirmBtnTextStyle,
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
    );
  }
}

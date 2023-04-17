import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

import '../../models/record.dart';
import '../dialog/riding_cancel_dialog.dart';

class RidingAppbar extends StatelessWidget with PreferredSizeWidget {
  const RidingAppbar(
      {super.key,
      required this.state,
      required this.type,
      required this.onTap});

  final RidingState state;
  final int type;

  final onTap;

  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
  @override
  Widget build(BuildContext context) {
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

    return AppBar(
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
          if (state == RidingState.before) {
            Navigator.pop(context);
          } else {
            type == 0
                ? backDialog('안내를 중단하시겠습니까?\n', '안내종료')
                : backDialog('주행를 중단하시겠습니까?\n', '주행종료');
          }
        },
        icon: const Icon(Icons.arrow_back),
        color: const Color.fromRGBO(240, 120, 5, 1),
      ),
      elevation: 10,
    );
    ;
  }
}

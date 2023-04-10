import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:ridingpartner_flutter/src/widgets/dialog/withdrawal_dialog.dart';

import '../../../service/social_login_service.dart';
import '../../../style/textstyle.dart';
import '../../splash_screen.dart';

final versionProvider = FutureProvider((ref) async {
  PackageInfo packageInfo = await PackageInfo.fromPlatform();

  return packageInfo.version;
});

class SettingWidget extends ConsumerStatefulWidget {
  const SettingWidget({super.key});

  @override
  SettingWidgetState createState() => SettingWidgetState();
}

class SettingWidgetState extends ConsumerState<SettingWidget> {
  @override
  Widget build(BuildContext context) {
    final version = ref.watch(versionProvider);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        version.when(
            data: (version) =>
                Text('앱 버전 : $version', style: TextStyles.settingStyle),
            loading: () =>
                const Text('앱 버전 : ...', style: TextStyles.settingStyle),
            error: (error, stack) =>
                const Text('앱 버전 : ...', style: TextStyles.settingStyle)),
        const Text('   |   '),
        InkWell(
          onTap: () async {
            bool result = await SocialLoginService().signOut();
            if (result) {
              toSplashScreen();
            } else {
              showSnakbar('로그아웃에 실패했습니다. 잠시후 다시 시도해주세요.');
            }
          },
          child: const Text('로그아웃', style: TextStyles.settingStyle),
        ),
        const Text('   |   '),
        InkWell(
          onTap: () => withdrawalDialog(),
          child: const Text('계정 탈퇴', style: TextStyles.settingStyle),
        ),
      ],
    );
  }

  void toSplashScreen() => Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const SplashScreen()),
      (route) => false);

  void showSnakbar(String message) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          message,
          style: TextStyles.settingSnakbarTextStyle,
        ),
      ));

  Future<bool> withdrawalDialog() async {
    return await showDialog(
        context: context,
        barrierDismissible: false,
        useRootNavigator: false,
        builder: (BuildContext context) => WithDrawalDialog(
              onOkClicked: () async {
                SocialLoginService().signOut();
                toSplashScreen();
              },
              onCancelClicked: () {
                Navigator.pop(context, false);
              },
            ));
  }
}

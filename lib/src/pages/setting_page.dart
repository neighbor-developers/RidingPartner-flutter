import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:provider/provider.dart';
import 'package:ridingpartner_flutter/src/pages/loding_page.dart';
import 'package:ridingpartner_flutter/src/provider/auth_provider.dart';
import 'package:ridingpartner_flutter/src/provider/setting_provider.dart';


class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  late SettingProvider _settingProvider;
  @override
  void initState() {
    super.initState();
    Provider.of<SettingProvider>(context, listen: false).Version();
  }

  @override
  Widget build(BuildContext context) {

    _settingProvider = Provider.of<SettingProvider>(context);

    return Scaffold(
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
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back),
            color: const Color.fromRGBO(240, 120, 5, 1),
          ),
          elevation: 10,
        ),
      body: Column(
        children: [
          settingBox('앱 정보'),
          Container(
            color: const Color.fromRGBO(255, 255, 255, 0.5),
            width: MediaQuery.of(context).size.width,
            height: 50,
            child: Container(
              padding: const EdgeInsets.only(left: 10),
              alignment: Alignment.centerLeft,
              width: MediaQuery.of(context).size.width,
              height: 50,
              child: Text('앱 버전 : ${_settingProvider.version}',
                style: const TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 16,
                    fontWeight: FontWeight.w400),
            ))),
          settingBox('계정 관리'),
          accountSettingWidget()
        ],
      ),
    );
  }

  Widget settingBox(String item) {
    return Container(
      padding: const EdgeInsets.only(left: 10),
      color: const Color.fromRGBO(173, 173, 174, 0.4),
      width: MediaQuery.of(context).size.width,
      height: 40,
      alignment: Alignment.centerLeft,
      child: Text(item,
          style: const TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 17,
              fontWeight: FontWeight.w500)),
    );
  }

  Widget accountSettingWidget() {
    return Column(children: [
      InkWell(
        child: Container(
          padding: const EdgeInsets.only(left: 10),
          width: MediaQuery.of(context).size.width,
          height: 40,
          alignment: Alignment.centerLeft,
          child: const Text('로그아웃',
            style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 16,
                fontWeight: FontWeight.w400)),
        ),
        onTap: () async {
          bool result = await _settingProvider.signOut();
          if (result) {
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                    builder: (context) => ChangeNotifierProvider(
                          create: (context) => AuthProvider(),
                          child: LodingPage(),
                        )),
                ((route) => false));
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('로그아웃에 실패했습니다. 잠시후 다시 시도해주세요.',
                  style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 16,
                      fontWeight: FontWeight.w400)),
              ),
            );
          }
        },
      ),
      const Divider(color: Colors.grey, thickness: 0.8),
      InkWell(
        child: Container(
          padding: const EdgeInsets.only(left: 10),
          alignment: Alignment.centerLeft,
          width: MediaQuery.of(context).size.width,
          height: 40,
          child: const Text('계정 탈퇴',
              style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 16,
                  fontWeight: FontWeight.w400)),
        ),
        onTap: () async {
          await _settingProvider.withdrawal();
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                  builder: (context) => ChangeNotifierProvider(
                        create: (context) => AuthProvider(),
                        child: LodingPage(),
                      )),
              ((route) => false));
        },
      ),
      const Divider(color: Colors.grey, thickness: 0.8),
    ]);
  }
}

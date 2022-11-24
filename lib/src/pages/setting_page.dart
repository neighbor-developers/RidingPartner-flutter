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
  }

  @override
  Widget build(BuildContext context) {
    _settingProvider = Provider.of<SettingProvider>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('설정'),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back),
          color: Colors.indigo.shade900,
        ),
      ),
      body: Column(
        children: [
          settingBox('앱 정보'),
          Container(
            child: Text('앱 버전 : ${_settingProvider.version}'),
            color: Colors.white,
            width: MediaQuery.of(context).size.width,
            height: 40,
          ),
          settingBox('계정 관리'),
          accountSettingWidget()
        ],
      ),
    );
  }

  Widget settingBox(String item) {
    return Container(
      padding: EdgeInsets.only(left: 10),
      child: Text(item),
      color: Colors.black26,
      width: MediaQuery.of(context).size.width,
      height: 25,
      alignment: Alignment.centerLeft,
    );
  }

  Widget accountSettingWidget() {
    return Column(children: [
      InkWell(
        child: Container(
          padding: EdgeInsets.only(left: 10),
          child: Text('로그아웃'),
          color: Colors.white,
          width: MediaQuery.of(context).size.width,
          height: 40,
          alignment: Alignment.centerLeft,
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
                content: Text('로그아웃에 실패했습니다. 잠시후 다시 시도해주세요.'),
              ),
            );
          }
        },
      ),
      InkWell(
        child: Container(
          padding: EdgeInsets.only(left: 10),
          child: Text('계정 탈퇴'),
          color: Colors.white,
          alignment: Alignment.centerLeft,
          width: MediaQuery.of(context).size.width,
          height: 40,
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
    ]);
  }
}

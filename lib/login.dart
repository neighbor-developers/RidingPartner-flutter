import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:ridingpartner_flutter/src/provider/social_login_provider.dart';

class Login extends StatelessWidget {
  const Login({super.key});

  // 로딩페이지와 동시에 사용할까 생각중
  // 페이지 들어오는 순간 2초로딩과 provider를 통한 유저 확인.
  // 2초 로딩, 유저 확인 둘다 ok 해야 화면 넘어감
  // 유저 없다고 판단시 false 이므로 조건 불충분으로 화면 안넘어감
  // 로그인 버튼들 보이기
  // 로그인 하는 순간 auth 생기고 provider를 통해 auth 관찰중이므로 조건 만족으로 로딩페이지 넘어감

  // ui 나 페이지 이동 아직 안만듬
  @override
  Widget build(BuildContext context) {
    KakaoSdk.init(nativeAppKey: 'b50ae09d3f49b62c4fba3b875e1b3458');
    final socialLogin = SignInAuthProvider();
    socialLogin.prepareUser(); // 이부분 좀 이상 오케 해결할지 고민중 (init 처리를 어케할지 고민)
    var _user = socialLogin.user;

    return Scaffold(
      body: Column(children: [
        CupertinoButton(
            child: Text('카카오 로그인'),
            color: Color.fromARGB(255, 213, 239, 15),
            onPressed: () {
              socialLogin.signInWithSocialLogin('kakao');
            }),
        CupertinoButton(
            child: Text('네이버 로그인'),
            color: Color.fromARGB(255, 64, 218, 79),
            onPressed: () {
              socialLogin.signInWithSocialLogin('naver');
            }),
        CupertinoButton(
            child: Text('구글 로그인'),
            color: Color.fromARGB(255, 89, 59, 237),
            onPressed: () {
              socialLogin.signInWithSocialLogin('google');
            })
      ]),
      appBar: AppBar(backgroundColor: Color.fromARGB(255, 25, 245, 83)),
    );
  }
}

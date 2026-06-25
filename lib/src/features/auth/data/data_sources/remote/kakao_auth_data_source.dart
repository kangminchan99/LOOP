import 'package:flutter/services.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';

class KakaoAuthDataSource {
  Future<String> login() async {
    OAuthToken kakaoToken;

    if (await isKakaoTalkInstalled()) {
      try {
        kakaoToken = await UserApi.instance.loginWithKakaoTalk();
      } catch (error) {
        if (error is PlatformException && error.code == 'CANCELED') {
          throw Exception('카카오 로그인이 취소되었습니다.');
        }

        kakaoToken = await UserApi.instance.loginWithKakaoAccount();
      }
    } else {
      kakaoToken = await UserApi.instance.loginWithKakaoAccount();
    }

    return kakaoToken.accessToken;
  }
}

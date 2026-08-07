import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/network/dio_client.dart';

class AuthService {
  final DioClient _dioClient;

  // 💡 Web Client ID จาก Firebase/Google Console
  static const String webClientId = '79528000892-78qtav0hc3eiilski43nd2tl5upd2pfl.apps.googleusercontent.com';

  AuthService({DioClient? dioClient})
      : _dioClient = dioClient ?? DioClient();

  Future<UserCredential?> signInWithGoogle() async {
    final GoogleSignIn googleSignIn = GoogleSignIn(
      clientId: kIsWeb ? webClientId : null,
    );

    // บังคับ disconnect และ signOut เพื่อให้ Google แสดงหน้าต่างเลือกบัญชี (Account Chooser) ใหม่เสมอ
    try {
      await googleSignIn.disconnect();
    } catch (_) {}
    try {
      await googleSignIn.signOut();
    } catch (_) {}

    final GoogleSignInAccount? googleUser =
        await googleSignIn.signIn();

    if (googleUser == null) {
      return null;
    }

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

  Future<Response> login({
    required String email,
    required String password,
  }) {
    return _dioClient.post(
      ApiConstants.login,
      data: {'email': email, 'password': password},
    );
  }

  /// เรียก API ส่ง access_token ที่ได้จาก Facebook SDK ไปให้ Backend
  Future<Response> loginWithFacebook({required String accessToken}) {
    return _dioClient.post(
      ApiConstants.loginFacebook,
      data: {'access_token': accessToken},
    );
  }

  /// เรียก API ส่ง access_token ที่ได้จาก LINE SDK ไปให้ Backend
  Future<Response> loginWithLine({required String accessToken}) {
    return _dioClient.post(
      ApiConstants.loginLine,
      data: {'access_token': accessToken},
    );
  }

  Future<Response> register({
    required String username,
    required String phone,
    required String email,
    required String password,
    required String confirmPassword,
  }) {
    return _dioClient.post(
      ApiConstants.register,
      data: {
        'username': username,
        'phone': phone,
        'email': email,
        'password': password,
        'password_confirmation': confirmPassword,
      },
    );
  }
}

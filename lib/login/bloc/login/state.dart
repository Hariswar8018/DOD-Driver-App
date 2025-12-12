import 'package:dio/dio.dart';
import 'package:dod_partner/login/bloc/login/view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../api.dart';
import '../../../home/navigation.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthInitial());

  final Dio dio = Dio(
    BaseOptions(
      validateStatus: (status) => status != null && status < 500,
    ),
  );

  Future<void> loginOrNavigate() async {
    emit(AuthLoading());
    print("Attempting login...");

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        emit(AuthFailure("Firebase user not found"));
        return;
      }

      // Clean mobile number
      String mobile = user.phoneNumber!
          .replaceAll("+", "")
          .trim();

      // 1️⃣ CHECK MOBILE
      final checkResponse = await dio.post(
        "${Api.apiurl}driver/check-mobile",
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
        ),
        data: {
          "mobile": mobile,
        },
      );

      print("Check Mobile Status: ${checkResponse.statusCode}");
      print("Check Mobile Response: ${checkResponse.data}");

      if (checkResponse.statusCode != 200 ||
          checkResponse.data["success"] == false) {
        emit(AuthNeedsRegistration());
        return;
      }

      // 2️⃣ LOGIN
      final loginResponse = await dio.post(
        "${Api.apiurl}driver/login",
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
        ),
        data: {
          "provider": "mobile",
          "firebase_id": user.uid,
          "mobile": mobile,
          "fcm_token": "hINSACXDBIACFNBHUIFCVNBFBCV",
        },
      );

      print("Login response: ${loginResponse.data}");

      if (loginResponse.statusCode == 200 &&
          loginResponse.data["status"] == true) {
        final authResponse = AuthResponse.fromJson(loginResponse.data);

        // save token and user data
        UserModel.token = authResponse.token;
        UserModel.user = authResponse.data;

        emit(AuthSuccess(authResponse.data));
        print("Login successful");
        return;
      }

      if (loginResponse.statusCode == 404 ||
          loginResponse.statusCode == 401) {
        emit(AuthNeedsRegistration());
        return;
      }

      emit(AuthFailure("Login failed: ${loginResponse.statusCode}"));

    } catch (e) {
      print("Exception: $e");
      emit(AuthFailure("Exception: $e"));
    }
  }
}

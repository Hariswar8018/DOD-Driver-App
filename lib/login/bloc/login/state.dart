
import 'package:dod_partner/login/bloc/login/view.dart' show UserModel;
import 'package:dod_partner/model/usermodel.dart' show UserData;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../api.dart';
import 'cubit.dart';

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
      final loginResponse = await dio.post(
        Api.apiurl + "driver/login",
        data: {
          "provider": "mobile",
          "firebase_id": FirebaseAuth.instance.currentUser!.uid,
          "mobile": "${FirebaseAuth.instance.currentUser!.phoneNumber}",
          "fcm_token": "gyhjhj",
        },
      );

      print("Login response: ${loginResponse.data}");

      print("--------------------------------------->");
      if (loginResponse.statusCode == 200) {
        final authResponse = AuthResponse.fromJson(loginResponse.data);

        UserModel.token = authResponse.token;
        emit(AuthSuccess(authResponse.data));
        print("Login successful");
      }
      // If login fails because user not found (commonly 404 or 401)
      else if (loginResponse.statusCode == 404 || loginResponse.statusCode == 401) {
        emit(AuthNeedsRegistration());
      }
      // Any other errors
      else {
        emit(AuthFailure("Login failed: ${loginResponse.statusMessage}"));
      }
    } catch (e) {
      emit(AuthFailure("Exception: $e"));
    }
  }
}

class AuthResponse {
  final bool status;
  final String message;
  final UserData data;
  final String token;
  final String tokenType;

  AuthResponse({
    required this.status,
    required this.message,
    required this.data,
    required this.token,
    required this.tokenType,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: UserData.fromJson(json['data'] ?? {}),
      token: json['token'] ?? '',
      tokenType: json['token_type'] ?? '',
    );
  }
}

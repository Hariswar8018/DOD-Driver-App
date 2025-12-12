



import 'package:dio/dio.dart';
import 'package:dod_partner/home/create.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shimmer/shimmer.dart';

import '../api.dart';
import '../global/global.dart';
import '../login/bloc/login/cubit.dart' show AuthState, AuthFailure, AuthSuccess, AuthLoading, AuthNeedsRegistration;
import '../login/bloc/login/state.dart';
import 'home.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../api.dart';
import 'package:dod_partner/login/bloc/login/view.dart' show UserModel;
import 'package:dod_partner/model/usermodel.dart' show UserData;

// ----- States -----
abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {
  final UserData userData;
  AuthSuccess(this.userData);
}

class AuthNeedsRegistration extends AuthState {}

class AuthFailure extends AuthState {
  final String error;
  AuthFailure(this.error);
}

// ----- Cubit -----
class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthInitial());

  final Dio dio = Dio(
    BaseOptions(validateStatus: (status) => status != null && status < 700),
  );

  Future<void> login() async {
    emit(AuthLoading());
    print("Attempting login...");

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        emit(AuthFailure("Firebase user not found"));
        return;
      }
      String mobile = user.phoneNumber!;

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

// ----- Response Model -----
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

class Navigation extends StatefulWidget {
  const Navigation({super.key});

  @override
  State<Navigation> createState() => _NavigationState();
}

class _NavigationState extends State<Navigation> {
  @override
  void dispose() {
    super.dispose();
  }

  Widget currentScreen = Home();
  @override
  Widget build(BuildContext context){
    return Scaffold(
      body: BlocProvider(
        create: (_) => AuthCubit()..login(),
        child: BlocConsumer<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state is AuthSuccess) {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=>Home()));
            } else if (state is AuthNeedsRegistration) {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=>CreateSeller()));
            } else if (state is AuthFailure) {
              errormessage=state.error;
              errortitle="Error 500 Issue !";
              Send.message(context, "505 Error ( Backend Unintended Issue ). Sending you to Driver Creation Page in 5 seconds !", false);
              Future.delayed(const Duration(seconds: 5), () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => CreateSeller()),
                );
              });
            }
          },
          builder: (context, state) {
            if (state is AuthLoading) {
              return LoadingScaffold();
            }
            return error();
          },
        ),
      ),
    );
  }
  String errortitle="";
  String errormessage="";
  bool iserror = false;
  Widget error(){
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color(0xff25252D),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(child: Image.network(width: 90,"https://www.shutterstock.com/image-vector/sad-red-car-cartoon-character-600nw-1969290883.jpg")),
          Center(child: Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: Text(errortitle,style: TextStyle(fontSize: 19,fontWeight: FontWeight.w800),),
          )),
          Center(child: Text(errormessage))
        ],
      ),
    );
  }
}
class LoadingScaffold extends StatelessWidget {
  LoadingScaffold({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff25252D),
        automaticallyImplyLeading: false,
      ),
      backgroundColor: Colors.white,
      body: Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(
                child: Container(
                  width: MediaQuery.of(context).size.width-15,
                  height: MediaQuery.of(context).size.height-160,
                  color: Colors.white,
                ),
              ),
              Center(
                child: Container(
                  width: MediaQuery.of(context).size.width-15,
                  height: 50,
                  color: Colors.white,
                ),
              ),
            ],
          )
      ),
    );
  }
  int currentTab = 0;
}

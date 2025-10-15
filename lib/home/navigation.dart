



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

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        emit(AuthFailure("Firebase user not found"));
        return;
      }

      final response = await dio.post(
        Api.apiurl + "driver/login",
        data: {
          "provider": "mobile",
          "firebase_id": user.uid,
          "mobile": "${user.phoneNumber}",
          "fcm_token": "hINSACXDBIACFNBHUIFCVNBFBCV",
        },
      );

      print("=================================");
      print(response.statusCode);
      print(response.statusMessage);
      if (response.statusCode == 200) {
        final authResponse = AuthResponse.fromJson(response.data);
        UserModel.token = authResponse.token;
        UserModel.user=authResponse.data;
        emit(AuthSuccess(authResponse.data));
      }
      else if (response.statusCode == 404 || response.statusCode == 401) {
        emit(AuthNeedsRegistration());
      }
      else {
        emit(AuthFailure(
            "Login failed: ${response.statusCode} - ${response.statusMessage}"));
      }
    } catch (e) {
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
        create: (_) => AuthCubit()..login(), // automatically call login
        child: BlocConsumer<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state is AuthSuccess) {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=>Home()));
            } else if (state is AuthNeedsRegistration) {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=>CreateSeller()));
            } else if (state is AuthFailure) {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=>CreateSeller()));

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.error)),
              );
            }
          },
          builder: (context, state) {
            if (state is AuthLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            return Scaffold(
              backgroundColor: Colors.white,
            ); // your login button or placeholder
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
            children: [
              Center(
                child: Container(
                  width: MediaQuery.of(context).size.width-15,
                  height: 290,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 10,),
              Center(
                child: Container(
                  width: MediaQuery.of(context).size.width-15,
                  height: 110,
                  color: Colors.white,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Fake thumbnail
                    Container(
                      width: 80,
                      height: 80,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 12),
                    // Fake text blocks
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(height: 16, width: double.infinity, color: Colors.white),
                          const SizedBox(height: 8),
                          Container(height: 16, width: 150, color: Colors.white),
                          const SizedBox(height: 8),
                          Container(height: 16, width: 30, color: Colors.white),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Fake thumbnail
                    Container(
                      width: 80,
                      height: 80,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 12),
                    // Fake text blocks
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(height: 16, width: double.infinity, color: Colors.white),
                          const SizedBox(height: 8),
                          Container(height: 16, width: 150, color: Colors.white),
                          const SizedBox(height: 8),
                          Container(height: 16, width: 30, color: Colors.white),
                        ],
                      ),
                    )
                  ],
                ),
              ),


            ],
          )
      ),
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        notchMargin: 4, color: Colors.white, surfaceTintColor: Colors.white,
        shadowColor:  Colors.white,
        child: Container(
          height: 20, color: Colors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              MaterialButton(
                  minWidth: 25, onPressed: (){
                currentTab = 0;
              },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        CupertinoIcons.home,
                        color: currentTab == 0? Colors.black : Colors.grey, size: 23,
                      ),
                      Text("Home", style: TextStyle(color: currentTab == 0?  Colors.black :Colors.grey, fontSize: 12))
                    ],
                  )
              ),
              MaterialButton(
                  minWidth: 25, onPressed: (){

                currentTab = 3;

              },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.two_wheeler,
                        color: currentTab == 3? Colors.black:Colors.grey, size: 23,
                      ),
                      Text("Drivers", style: TextStyle(color: currentTab == 3? Colors.black:Colors.grey, fontSize: 12))
                    ],
                  )
              ),
              MaterialButton(
                  minWidth: 25, onPressed: (){

                currentTab = 4;
              },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        CupertinoIcons.person,
                        color: currentTab == 4? Colors.black:Colors.grey, size: 23,
                      ),
                      Text("User", style: TextStyle(color: currentTab == 4? Colors.black:Colors.grey, fontSize: 12))
                    ],
                  )
              ),
            ],
          ),
        ),
      ),
    );
  }
  int currentTab = 0;
}

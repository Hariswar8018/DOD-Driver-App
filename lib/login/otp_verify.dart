import 'dart:async';
import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pinput/pinput.dart';
import 'package:smart_auth/smart_auth.dart' show SmartAuth;

import '../global/global.dart';
import '../main.dart';
import 'locationpermission.dart';

class OTP_Verify extends StatefulWidget {
  final String phone;String verificationid;
   OTP_Verify({super.key,required this.phone,required this.verificationid});

  @override
  State<OTP_Verify> createState() => _OTP_VerifyState();
}

class _OTP_VerifyState extends State<OTP_Verify> {
  late Timer _timer;
  int _start = 60;


  void listenToLogin() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) async {
      if (user != null) {
        print("User logged in: ${user.uid}");
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=>LocationPermission()));
        Send.message(context, "Phone number verified successfully!", true);
      } else {

      }
    });
  }


  void initState(){
    startTimer();
    super.initState();
    listenToLogin();
    // On web, disable the browser's context menu since this example uses a custom
    // Flutter-rendered context menu.
    if (kIsWeb) {
      BrowserContextMenu.disableContextMenu();
    }
    pinController = TextEditingController();
    focusNode = FocusNode();


  }
  void startTimer() {
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(
      oneSec,
          (Timer timer) {
        if (_start == 0) {
          setState(() {
            timer.cancel();
          });
        } else {
          setState(() {
            _start--;
          });
        }
      },
    );
  }


  @override
  void dispose() {
    _timer.cancel();
    if (kIsWeb) {
      BrowserContextMenu.enableContextMenu();
    }
    pinController.dispose();
    focusNode.dispose();
    super.dispose();
    super.dispose();
  }
  late final TextEditingController pinController;
  late final FocusNode focusNode;
  late final GlobalKey<FormState> formKey;

  void _verifyOTP(String otp, String verificationId) async {
    try {
      print(otp);
      setState(() {
        on=true;
      });
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otp,
      );
      await FirebaseAuth.instance.signInWithCredential(credential);
      Navigator.push(context, MaterialPageRoute(builder: (_)=>MyHomePage(title: "")));
      Send.message(context, "Phone number verified successfully!", true);
      setState(() {
        on=false;
      });

    } catch (e) {
      setState(() {
        on=false;
      });
      Send.message(context, "$e", true);
    }
  }


  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        centerTitle: true,
        leading: InkWell(
          onTap: (){
            Navigator.pop(context);
          },
          child: Center(child: Text("Back",style: TextStyle(color: Colors.grey.shade200),))),
        title: Text("VERIFY NUMBER",style: TextStyle(color: Colors.grey.shade200),
        ),
        actions: [
          InkWell(
              onTap: (){
                _verifyOTP(pinController.text, widget.verificationid);
              },
              child: Text("Next",style: TextStyle(color: Colors.grey.shade200),)),
          SizedBox(width: 10,)
        ],
      ),
      body: Column(
        children: [
          Container(
            width: w,
            height: 0.2,
            color: Colors.white,
          ),
          SizedBox(height: 35,),
          Center(
            child: Text("Enter the OTP sent to",style: TextStyle(color: Colors.grey.shade200),),
          ),
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: Center(
              child: Text("+91-${widget.phone}",style: TextStyle(color: Colors.white,fontWeight: FontWeight.w700,fontSize: 23),),
            ),
          ),
          SizedBox(height: 10,),
          Pinput(
            defaultPinTheme: defaultPinTheme,
            focusedPinTheme: focusedPinTheme,
            submittedPinTheme: submittedPinTheme,
            enableInteractiveSelection: true,
            controller: pinController,
            pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
            showCursor: true,length: 6,
            onChanged: (pin)=>(){

            },
            onCompleted: (pin) => (){

            },
          ),
          SizedBox(height: 30,),
          Center(
            child: Text("Didn't get Sms?",style: TextStyle(color: Colors.grey.shade200),),
          ),SizedBox(height: 15,),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white,
                width: 1
              )
            ),
            child: _start==0?InkWell(
              onTap: (){
                setState(() async {
                  try {
                    setState(() {
                      on=true;
                    });
                    final FirebaseAuth _auth = FirebaseAuth.instance;
                    await _auth.verifyPhoneNumber(
                      phoneNumber: "+91"+widget.phone,
                      timeout: const Duration(seconds: 60),
                      verificationCompleted: (PhoneAuthCredential credential) async {
                        setState(() {
                          on=false;
                        });
                        Navigator.push(context, MaterialPageRoute(builder: (_)=>MyHomePage(title: "")));
                        Send.message(context, "Phone number verified successfully!", true);
                      },
                      verificationFailed: (FirebaseAuthException e) {
                        setState(() {
                          on=false;
                        });
                        Send.message(context, "$e", false);
                      },
                      codeSent: (String verificationId, int? resendToken) {
                        setState(() {
                          on=false;
                        });
                        _start = 120;
                        startTimer();
                        widget.verificationid = verificationId;
                        Send.message(context, "OTP Resent to your Mobile Number", true);
                      },
                      codeAutoRetrievalTimeout: (String verificationId) {
                        setState(() {
                          on=false;
                        });
                        widget.verificationid = verificationId;
                        Send.message(context, "Time Out", false);
                      },
                    );
                  }catch(e){
                    setState(() {
                      on=false;
                    });
                    Send.message(context, "$e", false);
                  }

                });
              },
              child: on?SizedBox():Padding(
                padding: const EdgeInsets.symmetric(horizontal: 23.0,vertical: 10),
                child: Text("RESEND A NEW OTP",style: TextStyle(fontSize:17,color: Colors.white,fontWeight: FontWeight.w700),),
              ),
            ):Padding(
              padding: const EdgeInsets.symmetric(horizontal: 23.0,vertical: 10),
              child: Text("GET A NEW OTP IN : ${_start}",style: TextStyle(fontSize:17,color: Colors.white,fontWeight: FontWeight.w700),),
            ),
          ),
          Spacer(),
          on?CircularProgressIndicator():InkWell(
            onTap: (){
              _verifyOTP(pinController.text, widget.verificationid);
            },
            child: Center(
              child: Container(
                width: MediaQuery.of(context).size.width-60,
                height: 55,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(5)
                ),
                child: Center(child: Text("Next",
                  style: TextStyle(color: Colors.black,fontWeight: FontWeight.w700),)),
              ),
            ),
          ),
          SizedBox(height: 35,)
        ],
      ),
    );
  }
  bool on = false;

  final defaultPinTheme = PinTheme(
    width: 49,
    height: 49,
    textStyle: TextStyle(fontSize: 18, color: Colors.greenAccent, fontWeight: FontWeight.w600),
    decoration: BoxDecoration(
      border: Border.all(color: Color.fromRGBO(234, 239, 243, 1)),
      borderRadius: BorderRadius.circular(20),
    ),
  );

  final focusedPinTheme =PinTheme(
    width: 49,
    height: 49,
    textStyle: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.w600),
    decoration: BoxDecoration(
      border: Border.all(color: Color.fromRGBO(234, 239, 243, 1)),
      borderRadius: BorderRadius.circular(20),
    ),
  );

  final submittedPinTheme = PinTheme(
    width: 49,
    height: 49,
    textStyle: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.w600),
    decoration: BoxDecoration(
      border: Border.all(color: Color.fromRGBO(234, 239, 243, 1)),
      borderRadius: BorderRadius.circular(20),
    ),
  );

}

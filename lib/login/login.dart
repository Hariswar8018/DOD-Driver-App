
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../global/global.dart';
import 'otp_verify.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
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
        title: Text("GET STARTED",style: TextStyle(color: Colors.grey.shade200),
        ),
        actions: [
          InkWell(
              onTap: (){
                go(context);
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
            child: RichText(text: TextSpan(
              text: "Login",
              style: TextStyle(fontWeight: FontWeight.w800,fontSize: 23),
            children: [
              TextSpan(text: "   or   ",style: TextStyle(fontWeight: FontWeight.w300,fontSize: 17)),
              TextSpan(
                  text: "SignUp",
                  style: TextStyle(fontWeight: FontWeight.w800,fontSize: 23),),
            ]),

            ),
          ),
          SizedBox(height: 35,),
          Container(
            width: w-40,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(7),
              border: Border.all(color: Colors.grey.shade300, width: 2),
            ),
            alignment: Alignment.center,
            child: TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.left,
              maxLength: 10,
              style: TextStyle(
                  fontSize: 20,
                  color: Colors.black,
                  fontWeight: FontWeight.w800
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                counterText: "",
                prefixText: "    +91   ",
                prefixStyle: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.w800
                ),
                hintText: "Enter your 10 digits Number",
                hintStyle: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              onChanged: (value) {
                if (value.length > 10) {
                  _controller.text = value.substring(0, 10);
                  _controller.selection = TextSelection.fromPosition(
                      TextPosition(offset: _controller.text.length));
                }
              },
            ),
          ),
          Spacer(),
          Text("By continuing use to our App, you agree to :",style: TextStyle(color: Colors.white),),
          Padding(
            padding: const EdgeInsets.all(7.0),
            child: Text("Terms & Condition",style: TextStyle(color: Colors.blue,fontWeight: FontWeight.w500),),
          ),
          Text("Privacy Policy",style: TextStyle(color: Colors.blue,fontWeight: FontWeight.w500),),
          SizedBox(height: 35),
          on?CircularProgressIndicator(backgroundColor: Colors.white,):InkWell(
            onTap: (){
              go(context);
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

  Future<void> go(BuildContext context) async {
    if(_controller.text.length==10){
      try {
        final FirebaseAuth _auth = FirebaseAuth.instance;
        String _verificationId = '';
        setState(() {
          on=true;
        });
        await _auth.verifyPhoneNumber(
          phoneNumber: "+91"+_controller.text,
          timeout: const Duration(seconds: 60),
          verificationCompleted: (PhoneAuthCredential credential) async {
            setState(() {
              on=false;
            });
          },
          verificationFailed: (FirebaseAuthException e) {
            Send.message(context, "$e", false);
            setState(() {
              on=false;
            });
          },
          codeSent: (String verificationId, int? resendToken) {
            _verificationId = verificationId;
            setState(() {
              on=false;
            });
            Navigator.push(context, MaterialPageRoute(builder: (_) =>
                OTP_Verify(
                  phone: _controller.text, verificationid: verificationId,)));
            Send.message(context, "OTP Sent to your Mobile Number", true);
          },
          codeAutoRetrievalTimeout: (String verificationId) {
            setState(() {
              on=false;
            });
            _verificationId = verificationId;
            Send.message(context, "Time Out", false);
          },
        );

      }catch(e){
        setState(() {
          on=false;
        });
        Send.message(context, "$e", false);
      }
    }else{
      Send.message(context, "Please put your 10 Digit Mobile Number", false);
    }

  }
  bool on=false;
  TextEditingController _controller=TextEditingController();
}

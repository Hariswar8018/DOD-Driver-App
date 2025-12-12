


import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:dod_partner/login/bloc/login/view.dart';
import 'package:dod_partner/main.dart' show MyHomePage;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../api.dart';
import '../global/global.dart';
import '../login/locationpermission.dart';

class Update extends StatefulWidget {

  final String name,email; bool isemail;

   Update({super.key,required this.email,required this.name,required this.isemail});

  @override
  State<Update> createState() => _UpdateState();
}

class _UpdateState extends State<Update> {
  TextEditingController controller=TextEditingController();

  @override
  Widget build(BuildContext context) {
    double w=MediaQuery.of(context).size.width;
    return Scaffold(
      appBar:AppBar(
        backgroundColor: Global.bg,
        automaticallyImplyLeading:true,
        iconTheme: IconThemeData(
          color: Colors.white
        ),
        title: Text("Update ${widget.isemail?"Your Email Address":"Your Name"}",style: TextStyle(color: Colors.white,),),
      ),
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          on?LinearProgressIndicator():SizedBox(),
          SizedBox(height: 100,),
          Text("     ${widget.isemail?"Your Email Address":"Your Name"}",style: TextStyle(color: Color(0xff252520),fontSize: 19,fontWeight: FontWeight.w800),),
          SizedBox(height: 10,),
          Center(
            child: Container(
              width: w-40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(7),
                border: Border.all(color: Colors.grey.shade300, width: 2),
              ),
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: TextField(
                  controller: controller,
                  keyboardType: TextInputType.name,
                  textAlign: TextAlign.left,
                  style: TextStyle(
                      fontSize: 20,
                      color: Colors.black,
                      fontWeight: FontWeight.w800
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    prefixStyle: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.w800
                    ),
                    hintText: widget.isemail?"Your New Email Address":"Your New Name",
                    hintStyle: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      persistentFooterButtons: [
        InkWell(
          onTap: () async {
            setState(() {
              on=true;
            });
            try {
              final dio = Dio(
                BaseOptions(
                  responseType: ResponseType.plain,
                  validateStatus: (s) => true,
                ),
              );
              final formData = FormData.fromMap({
                "email": controller.text,
                "user_photo": null,
              });
              final response = await dio.post(
                "https://dod.brandeducer.host/api/driver/profile",
                data: formData,
                options: Options(
                  headers: {
                    "Authorization": "Bearer ${UserModel.token}",
                    "Accept": "application/json",
                  },
                ),
              );

              final raw = response.data.toString();
              print("RAW RESPONSE: $raw");

              // remove leading "11"
              final cleaned = raw.replaceFirst(RegExp(r'^\s*\d+'), '');
              print("CLEANED RESPONSE: $cleaned");

              final decoded = jsonDecode(cleaned);

              if (response.statusCode == 200) {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=>LocationPermission()));
                Send.message(context, "Profile Updated!", true);
              } else if (response.statusCode == 422) {
                // validation error
                final errorMessage = decoded["errors"]?["email"]?[0] ?? "Validation error";
                Send.message(context, errorMessage, false);
              } else {
                Send.message(context, decoded["message"] ?? "Unknown error", false);
              }

            } catch (e) {
              Send.message(context, "Something went wrong: $e", false);
            }
          },
          child: Container(
            width: w-10,
            height: 50,
            decoration: BoxDecoration(
              color:  Global.bg
            ),
            child: Center(child: Text("Update",style: TextStyle(color: Colors.white,fontWeight: FontWeight.w800,fontSize: 19),)),
          ),
        )
      ],
    );
  }

  bool on = false;
}

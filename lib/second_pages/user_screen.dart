

import 'dart:convert' show jsonDecode;

import 'package:dod_partner/login/locationpermission.dart' show LocationPermission;
import 'package:dod_partner/main.dart' show MyHomePage;
import 'package:dod_partner/second_pages/update_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../api.dart';
import '../global/global.dart';
import '../login/bloc/login/view.dart';

class User_Profile extends StatefulWidget {
   User_Profile({super.key});

  @override
  State<User_Profile> createState() => _User_ProfileState();
}

class _User_ProfileState extends State<User_Profile> {
   pickImage(ImageSource source) async {
     final ImagePicker _imagePicker = ImagePicker();
     XFile? _file = await _imagePicker.pickImage(source: source);
     if (_file != null) {
       return _file;
     }
     print('No Image Selected');
   }
   Future<MultipartFile> returnmul(XFile b) async {
     MultipartFile userPhoto = await MultipartFile.fromFile(
       b!.path,
       filename: b.name, // keeps the original filename
     );
     return userPhoto;
   }

   @override
  Widget build(BuildContext context) {
    double w=MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Global.grey,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: true,
        iconTheme: IconThemeData(
            color: Colors.black
        ),
        centerTitle: true,
        title: Text("PROFILE",style: TextStyle(color: Colors.black,fontWeight: FontWeight.w600),),
        actions: [
          TextButton(onPressed: () async {
            await FirebaseAuth.instance.signOut();
            await FirebaseAuth.instance.signOut();
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=>MyHomePage(title: "")));

            await FirebaseAuth.instance.signOut();
          }, child: Text("SIGN OUT",style: TextStyle(color: Colors.red,fontWeight: FontWeight.w800),)),
          SizedBox(width: 10,)
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          InkWell(
            onTap: () async {

            },
            child: Padding(
              padding: const EdgeInsets.all(13),
              child: Container(
                width: w,
                height: 240,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    UserModel.user.photo!.isEmpty?CircleAvatar(
                      radius: 35,
                      backgroundImage: NetworkImage("https://t4.ftcdn.net/jpg/00/84/67/19/360_F_84671939_jxymoYZO8Oeacc3JRBDE8bSXBWj0ZfA9.jpg"),
                    ):CircleAvatar(
                      radius: 35,
                      backgroundImage: NetworkImage(UserModel.user.photo!),
                    ),
                    SizedBox(height: 10,),
                    InkWell(
                        child: Text(UserModel.user.name,style: TextStyle(color: Colors.white,fontWeight: FontWeight.w500,fontSize: 17),)),
                    SizedBox(height: 10,),
                    Text("Member Since : ${formatDate(UserModel.user.createdAt.substring(0,10))}",style: TextStyle(color: Colors.white,fontWeight: FontWeight.w400),)
                  ],
                ),
              ),
            ),
          ),
          on?Center(child: CircularProgressIndicator()):Center(
            child: InkWell(
              onTap: () async {
                try {
                  final dio = Dio(
                  BaseOptions(
                    responseType: ResponseType.plain,
                    validateStatus: (s) => true,
                  ),
                );
                  XFile pic = await pickImage(ImageSource.gallery);

                  MultipartFile picture = await MultipartFile.fromFile(
                    pic.path,
                    filename: pic.name,
                  );
                  final formData = FormData.fromMap({
                    "email": UserModel.user.email,
                    "user_photo": picture,
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

              }
              ,
              child: Container(
                width: w/2+40,
                height: 45,
                color: Colors.black,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.upload,color: Colors.white,),
                    SizedBox(width: 5,),
                    Text("Update Profile Picture"
                      ,style: TextStyle(color: Colors.white),),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 10,),
          Text("   Your Details",style: TextStyle(fontWeight: FontWeight.w600,fontSize: 18),),
          ListTile(
            onTap: (){
              Navigator.push(context,MaterialPageRoute(builder: (_)=>Update(email: "", name: "",
                  isemail: true)));
            },
            leading: Icon(Icons.mail,color: Colors.grey,),
            title: Text(UserModel.user.email),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18.0),
            child: Divider(),
          ),
          ListTile(
            leading: Icon(Icons.call,color: Colors.grey,),
            title: Text(strreturn()),
          ),

        ],
      ),
    );
  }
  bool on = false;

   String strreturn(){
     try{
       String phone = FirebaseAuth.instance.currentUser!.phoneNumber??"+911111111111";
       return phone.substring(0,2)+"-"+phone.substring(2,-1);
     }catch(e){
       return "+91-1111111111";
     }
   }

   String formatDate(String dateStr) {
     try {
       // Parse the string to DateTime
       DateTime date = DateTime.parse(dateStr);
       // Format as "Month, Year"
       return DateFormat('MMMM, yyyy').format(date);
     } catch (e) {
       return dateStr; // fallback if parsing fails
     }
   }
}

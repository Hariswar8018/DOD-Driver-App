
import 'dart:async';


import 'package:dod_partner/home/navigation.dart' show Navigation;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import 'firebase_options.dart';
import 'login/locationpermission.dart' show LocationPermission;
import 'login/onboarding.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DOD Partner App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      debugShowCheckedModeBanner: false,
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  void initState(){
    if(FirebaseAuth.instance.currentUser==null){
      Timer(Duration(seconds: 3),(){
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=>Onboarding()));
      });
    }else{
      Timer(Duration(seconds: 3),(){
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=>LocationPermission()));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          SizedBox(height: 110,),
          Spacer(),
          Center(child: Image.asset("assets/logo_full.jpg",width: MediaQuery.of(context).size.width,)),
          Spacer(),
          Image.asset("assets/security.png",height: 30,),
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: Text("Trusted by",style: TextStyle(color: Colors.white,fontSize: 17),),
          ),
          Text("70,000+ Car Owners",style: TextStyle(color: Colors.white,fontSize: 15,fontWeight: FontWeight.w800),),
          SizedBox(height: 50,),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../global/global.dart';
import 'login.dart' show Login;
import 'dart:async';

class Onboarding extends StatefulWidget {
  const Onboarding({super.key});

  @override
  State<Onboarding> createState() => _OnboardingState();
}

class _OnboardingState extends State<Onboarding> {

  void initState(){
    startPeriodicTimer();
  }
  Timer? _periodicTimer; // Declare a nullable Timer variable to hold the timer instance

  void startPeriodicTimer() {
    _periodicTimer = Timer.periodic(
      const Duration(seconds: 4), // The interval at which the timer will tick
      _timerCallback,
    );
  }
  void _timerCallback(Timer timer) {
    setState(() {
      i+=1;
    });
  }

  String sends(){
    try {
      if (i > 4) {
        setState(() {
          i = 0;
        });
      } else if (i == 0) {

      } else {
        i += 1;
      }
      return name[i];
    }catch(e){
      return name[0];
    }
  }
  String feebackk(){
    try{
      return driverReviews[i];
    }catch(e){
      return driverReviews[0];
    }
  }
  String picreturn(){
    try{
      return pic[i];
    }catch(e){
      return pic[0];
    }
  }
  int i = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Global.bg,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 30,),
            Spacer(),
            Image.asset("assets/flat_logo.jpg",width: 120,),
            SizedBox(height: 10,),
            Text("Welcome to DOD Partner",style: TextStyle(color: Colors.white,fontWeight: FontWeight.w800,fontSize: 29),),
            SizedBox(height: 3,),
            Text("Drive and Earn with us on DOD. We provide Daily Payments, Travel Insurance and Zero Charges",
              style: TextStyle(color: Colors.white),),
            SizedBox(height: 45,),
            CircleAvatar(
              backgroundColor: Colors.white,
              radius: 35,
              child: Center(
                child: CircleAvatar(
                  radius: 34,
                  backgroundImage: AssetImage(picreturn()),
                ),
              ),
            ),
            SizedBox(height: 5,),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5.0),
              child: Text(sends(),style: TextStyle(
                  color: Colors.white,fontWeight: FontWeight.w800,fontSize: 18),),
            ),
            Text(feebackk(),style: TextStyle(
                color: Colors.white,fontWeight: FontWeight.w400,fontSize: 16),),
            Spacer(),
            InkWell(
              onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (_)=>Login()));
              },
              child: Center(
                child: Container(
                  width: MediaQuery.of(context).size.width-60,
                  height: 55,
                  decoration: BoxDecoration(
                    color: Colors.green.shade800,
                    borderRadius: BorderRadius.circular(5)
                  ),
                  child: Center(child: Text("Get Started",
                    style: TextStyle(color: Colors.white,fontWeight: FontWeight.w700,fontSize: 18),)),
                ),
              ),
            ),
            SizedBox(height: 30,),
          ],
        ),
      ),
    );
  }
  List<String> name = [
    "Aarav Sharma",
    "Ishita Verma",
    "Rohan Nair",
    "Priya Mehta"
  ];
  List<String> driverReviews = [
    "Being a driver with Driver on Demand has been amazing! The app makes it so easy to get rides and manage my schedule efficiently.",
    "I love working with Driver on Demand. Payments are always on time, and I get to choose when and where I want to drive.",
    "The support team at Driver on Demand is fantastic. They’re always quick to help if I face any issues while on the job.",
    "Thanks to Driver on Demand, I’ve been able to earn extra income while keeping my work flexible. Highly recommend it to other drivers!"
  ];

  List<String> pic = [
    "assets/pic1.jpg",
    "assets/pic2.jpg",
    "assets/pic3.webp",
    "assets/pic4.jpg",
  ];

}

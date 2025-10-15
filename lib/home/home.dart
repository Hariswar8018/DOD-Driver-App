import 'dart:async';
import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:dod_partner/global/global.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_widget/google_maps_widget.dart';

import '../api.dart';
import '../login/bloc/login/view.dart';
import '../model/booking_response.dart';
import '../model/ordermodel.dart' show OrderModel;

class LatLongModel {
  final double latitude;
  final double longitude;
  final String name;

  LatLongModel({
    required this.latitude,
    required this.longitude,
    required this.name,
  });
}


class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final mapsWidgetController = GlobalKey<GoogleMapsWidgetState>();

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Widget list(Widget q,String str)=>ListTile(
    leading: q,
    title: Text(str,style: TextStyle(fontWeight: FontWeight.w800,color: Colors.white,fontSize: 21),),
  );

  double size = 31;

  Future<void> gets() async {
    final Dio dio = Dio(
      BaseOptions(
        validateStatus: (status) => status != null && status < 500,
      ),
    );

    try {
      final response = await dio.get(
        Api.apiurl + "user-bookings",
        options: Options(
          headers: {
            "Authorization": "Bearer ${UserModel.token}",
          },
        ),
      );

      if (response.statusCode == 200) {
        print(response.data);
        print("----------------------------->");
        print(UserModel.token);
        final bookingsResponse = BookingsResponse.fromJson(response.data);
        print("✅ Total bookings: ${bookingsResponse.bookings.length}");
        for (var order in bookingsResponse.bookings) {
          print("📦 Booking ID: ${order.id}, Status: ${order.status}, User: ${order.user.name}");
          orders.add(order);
        }
      } else {
        print("❌ Error: ${response.statusMessage}");
      }
    } catch (e) {
      print("Error during API call: $e");
    }
  }

  List<OrderModel> orders = [];

  late GoogleMapController _controller ;

  final GlobalKey _mapKey = GlobalKey();

  List<LatLongModel> locations = [
    LatLongModel(latitude: 23.0225, longitude: 72.5714, name: "Ahmedabad"),
    LatLongModel(latitude: 23.0335, longitude: 72.5800, name: "Nearby Place"),
  ];

  Map<String, Offset> cardPositions = {};

  void updateCardPositions() async {
    try {
      print("a");
      if (_controller == null) return;
      Map<String, Offset> temp = {};
      print("b");
      RenderBox? mapBox =
      _mapKey.currentContext?.findRenderObject() as RenderBox?;
      if (mapBox == null) return;

      for (var loc in locations) {
        ScreenCoordinate screenCoordinate =
        await _controller!.getScreenCoordinate(
            LatLng(loc.latitude, loc.longitude));

        // Convert screen coordinate to widget relative position
        double dx = screenCoordinate.x.toDouble();
        double dy = screenCoordinate.y.toDouble();

        temp[loc.name] = Offset(dx, dy);
      }
      print("c");
      setState(() {
        cardPositions = temp;
      });
    }catch(e){
      print(e);
    }
  }



  @override
  Widget build(BuildContext context) {
    double w=MediaQuery.of(context).size.width;
    double h=MediaQuery.of(context).size.height;
    return Scaffold(
      key: _scaffoldKey,
      drawer: Drawer(
        child: Container(
          color: Colors.black,
          child: Column(
            children: [
              SizedBox(height: 30,),
              Image.asset("assets/logo_full.jpg",width: w/2,),
              list(Icon(Icons.home,color: Colors.white,size: size,), "Home"),
              list(Icon(Icons.person,color: Colors.white,size: size,), "My Profile"),
              list(Icon(Icons.car_crash_sharp,color: Colors.white,size: size,), "My Rides"),
              list(Icon(Icons.star,color: Colors.white,size: size,), "My Ratings"),
              list(Icon(Icons.account_balance_wallet,color: Colors.white,size: size,), "Wallet"),
              list(Icon(Icons.question_answer,color: Colors.white,size: size,), "FAQs"),
              list(Icon(Icons.support_agent,color: Colors.white,size: size,), "Contact Us"),
              Spacer(),
              Container(
                color: Colors.black12,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.blue,
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("${UserModel.user.name}",style: TextStyle(color: Colors.white,fontWeight: FontWeight.w700,fontSize: 18),),
                        Text("${UserModel.user.email}",style: TextStyle(color: Colors.white,fontWeight: FontWeight.w400,fontSize: 10),)
                        ,Text("${FirebaseAuth.instance.currentUser!.phoneNumber}",style: TextStyle(color: Colors.white,fontWeight: FontWeight.w400,fontSize: 10),)
                      ],
                    )
                  ],
                ),
              ),
              Spacer(),
            ],
          ),
        ),
      ),
      appBar: AppBar(
        backgroundColor: Global.bg,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: InkWell(
            onTap: () async {
              await FirebaseAuth.instance.signOut();
            },
            child: Text("Orders Around Me",style: TextStyle(color: Colors.white),)),
      ),
      body: Stack(
        children: [
          Container(
            width: w,
            height: h-85,
            child: Container(
              width: w,
              height: h-85,
            child: Stack(
              children: [
                Container(
                  key: _mapKey,
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: LatLng(23.0225, 72.5714),
                      zoom: 14,
                    ),
                    onMapCreated: (controller) {
                      _controller = controller;
                      // Wait for the first frame
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        updateCardPositions();
                      });
                    },
                    onCameraMove: (_) {
                      updateCardPositions(); // update cards on move/zoom
                    },
                  ),
                ),
                ...locations.map((loc) {
                  final pos = cardPositions[loc.name];
                  if (pos == null) return Container();
                  return Positioned(
                    left: pos.dx - 50, // adjust card width
                    top: pos.dy - 80,  // adjust card height
                    child: GestureDetector(
                      onTap: () {
                        print("Tapped ${loc.name}");
                      },
                      child: Card(
                        color: Colors.white,
                        child: Padding(
                          padding: EdgeInsets.all(8),
                          child: Text(loc.name),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ],
            )
            )
            ,
          ),
          Container(
            width: w,
            height: h-85,
            child: Column(
              children: [
                online?Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Container(
                      width: w-10,
                      height: 80,
                      color: Colors.white,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12.0),
                            child: Container(
                              width: 60,height: 60,
                              color: Colors.red,
                            ),
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("0 RIDES  |   ₹1,000",style: TextStyle(fontWeight: FontWeight.w800),),
                              Text("Today, ${DateTime.now()}",style: TextStyle(fontWeight: FontWeight.w700,color: Colors.grey),)
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ):SizedBox(),
                Spacer(),
                online?SizedBox():InkWell(
                  onTap: switches,
                  child: CircleAvatar(
                    radius: 65,
                    backgroundColor: progress?Colors.blue:Colors.black,
                    child: CircleAvatar(
                      radius: 63,
                      backgroundColor: Colors.white,
                      child: CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.black,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text("Go Online",style: TextStyle(color: Colors.white),),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20,),
                progress?LinearProgressIndicator(
                  backgroundColor: Colors.black,
                  color: !online?Colors.blue:Colors.red,
                ):SizedBox(),
                InkWell(
                  onTap: (){
                    setState(() {
                      full=!full;
                    });
                  },
                  child: Container(
                    width: w,
                    height: 50,
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          InkWell(
                              onTap: (){
                                _scaffoldKey.currentState!.openDrawer();
                              },
                              child: Icon(Icons.menu,color: Colors.green.shade800,)),
                          Spacer(),
                          Icon(Icons.circle,size: 20,color: online?Colors.green:Colors.red,),
                          Text(online?" YOU ARE ONLINE":" YOU ARE OFFLINE",style: TextStyle(fontWeight: FontWeight.w900,fontSize: 17),), Spacer(),
                          full? Icon(Icons.arrow_drop_down,color: Colors.black):Icon(Icons.arrow_drop_up,color: Colors.black),
                        ],
                      ),
                    ),
                  ),
                ),
                full ?InkWell(
                  onTap: switches,
                  child: Container(
                    width: w,
                    height: 50,
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [Spacer(),
                          Icon(Icons.circle,size: 20,color: !online?Colors.green:Colors.red,),
                          Text(!online?" GO ONLINE":" GO OFFLINE",style: TextStyle(fontWeight: FontWeight.w900,fontSize: 17),), Spacer(),
                        ],
                      ),
                    ),
                  ),
                ):SizedBox(),
              ],
            ),
          )
        ],
      ),
    );
  }
  
  void switches(){
    setState(() {
      progress=true;
    });
    Timer(Duration(seconds: 3),(){
      gets();
      updateCardPositions();
      setState(() {
        progress=false;
        online=!online;
        full=false;

      });
    });

  }
  bool progress=false;
  bool full=false;
  bool online = false;
}

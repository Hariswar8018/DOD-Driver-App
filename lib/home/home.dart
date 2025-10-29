import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:dod_partner/booking/booking_function.dart';
import 'package:dod_partner/booking/my_rides.dart';
import 'package:dod_partner/global/global.dart';
import 'package:dod_partner/second_pages/say_no.dart';
import 'package:dod_partner/second_pages/user_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_widget/google_maps_widget.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:visibility_detector/visibility_detector.dart'
    show VisibilityDetector;

import '../api.dart';
import '../booking/full.dart';
import '../login/bloc/login/view.dart';
import '../model/booking_response.dart';
import '../model/mybooking.dart';
import '../model/ordermodel.dart' show OrderModel;
import '../model/my_ordermodel.dart' as mine;

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

  Widget list(Widget q, String str) => ListTile(
    leading: q,
    title: Text(
      str,
      style: TextStyle(
        fontWeight: FontWeight.w800,
        color: Colors.white,
        fontSize: 21,
      ),
    ),
  );

  double size = 31;

  Future<void> getmyorders() async {
    final Dio dio = Dio(
      BaseOptions(validateStatus: (status) => status != null && status < 500),
    );
    try {
      final response = await dio.get(
        Api.apiurl + "user-bookings",
        options: Options(
          headers: {"Authorization": "Bearer ${UserModel.token}"},
        ),
      );
      if (response.statusCode == 200) {
        print(response.data);
        print("----------------------------->");
        print(UserModel.token);
        myorders=[];
        final bookingsResponse = MyBookingsResponse.fromJson(response.data);
        print(bookingsResponse.bookings);
        print("✅ Total bookings: ${bookingsResponse.bookings.length}");
        for (var order in bookingsResponse.bookings) {
          print(
            "📦 Booking ID: ${order.id}, Status: ${order.status}, User: ${order.user.name}",
          );
          myorders.add(order);
        }

      } else {
        print("❌ Error: ${response.statusMessage}");
      }
    } catch (e) {
      print("Error during API call: $e");
    }
  }
  List<mine.OrderModel> myorders = [];


  Future<void> getupcoming() async {
    final Dio dio = Dio(
      BaseOptions(validateStatus: (status) => status != null && status < 500),
    );
    try {
      final response = await dio.get(
        Api.apiurl + "open-bookings",
        options: Options(
          headers: {"Authorization": "Bearer ${UserModel.token}"},
        ),
      );
      if (response.statusCode == 200) {
        print(response.data);
        print("----------------------------->");
        print(UserModel.token);
        print("dmscskc");
        final bookingsResponse = BookingsResponse.fromJson(response.data);
        print("jcxjckx ");
        print(bookingsResponse.bookings);
        orders=[];
        print("✅ Total bookings: ${bookingsResponse.bookings.length}");
        for (var order in bookingsResponse.bookings) {
          print(
            "📦 Booking ID: ${order.id}, Status: ${order.status}, User: ${order.pickupLongitude}",
          );
          orders.add(order);
        }
        find(orders);
      } else {
        print("❌ Error: ${response.statusMessage}");
      }
    } catch (e) {
      print("Error during API call: $e");
    }
  }
  
  double price = 0;
  
  void find(List<OrderModel> or){
    double amount = 0;
    for( var i in or ){
      amount = amount + i.amount;
    }
    setState(() {
      price = amount;
    });
  }
  int review = 1;
  Widget f(double w, int yes)=>InkWell(
    onTap: (){
      setState(() {
        review=yes;
        on();
      });
      print(review);
    },
    child: Container(
      width: w/2-20,
      height: 40,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: yes==review?Colors.white:Colors.black,
      ),
      child: Center(
        child: Text(yiop(yes),
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: yes==review?Colors.black:Colors.white)),
      ),
    ),
  );

  String yiop(int y){
    if(y==0){
      return "All Trips";
    }else if(y==1){
      return "My Trips";
    }else {
      return "Invites";
    }
  }
  void on(){
    if(review==0){
      getupcoming();
    }else {
      getmyorders();
    }
  }
  List<OrderModel> orders = [];
  String formattedDateTime() {
    final now = DateTime.now();
    final time = DateFormat('hh:mm a').format(now);       // 10:43 AM
    final date = DateFormat('dd MMM yyyy').format(now);   // 21 Oct 2025
    return "$time   $date";
  }

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;
    return Scaffold(
      key: _scaffoldKey,
      drawer: Drawer(
        child: Container(
          color: Colors.black,
          child: Column(
            children: <Widget>[
              SizedBox(height: 30),
              Image.asset("assets/logo_full.jpg", width: w / 2),
              InkWell(
                  onTap: (){
                    Navigator.pop(context);
                  },
                  child: list(Icon(Icons.home, color: Colors.white, size: size), "Home")),
              InkWell(
                onTap: (){
                  Navigator.push(context, MaterialPageRoute(builder: (_)=>User_Profile()));
                },
                child: list(
                  Icon(Icons.person, color: Colors.white, size: size),
                  "My Profile",
                ),
              ),
              InkWell(
                onTap: (){
                  Navigator.push(context, MaterialPageRoute(builder: (_)=>MyRides()));
                },
                child: list(
                  Icon(Icons.car_crash_sharp, color: Colors.white, size: size),
                  "My Rides",
                ),
              ),
              InkWell(
                onTap: (){
                  Navigator.push(context, MaterialPageRoute(builder: (_)=>Say_No(
                      str: "My Ratings", description: "No Customer have Rate you")));
                },
                child: list(
                  Icon(Icons.star, color: Colors.white, size: size),
                  "My Ratings",
                ),
              ),
              InkWell(
                onTap: (){
                  Navigator.push(context, MaterialPageRoute(builder: (_)=>Say_No(
                      str: "My Wallets", description: "You don't have any Wallets Coins")));
                },
                child: list(
                  Icon(
                    Icons.account_balance_wallet,
                    color: Colors.white,
                    size: size,
                  ),
                  "Wallet",
                ),
              ),
              InkWell(
                onTap: (){
                  Navigator.push(context, MaterialPageRoute(builder: (_)=>Say_No(
                      str: "FAQs", description: "We haven't add amy FAQs")));
                },
                child: list(
                  Icon(Icons.question_answer, color: Colors.white, size: size),
                  "FAQs",
                ),
              ),
              InkWell(
                onTap: () async {
                  final Uri _url = Uri.parse('tel:+918269669272');
                  if (!await launchUrl(_url)) {
                  throw Exception('Could not launch $_url');
                  }
                },
                child: list(
                  Icon(Icons.support_agent, color: Colors.white, size: size),
                  "Contact Us",
                ),
              ),
              Spacer(),
              InkWell(
                onTap: (){
                  Navigator.push(context, MaterialPageRoute(builder: (_)=>User_Profile()));
                },
                child: Container(
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
                          Text(
                            "${UserModel.user.name}",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                            ),
                          ),
                          Text(
                            "${UserModel.user.email}",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w400,
                              fontSize: 10,
                            ),
                          ),
                          Text(
                            "${FirebaseAuth.instance.currentUser!.phoneNumber}",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w400,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
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
          child: Text(
            review==0?"Orders Around Me":"My Trips",
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
      body: Stack(
        children: [
          Container(
            width: w,
            height: h - 85,
            child: Container(
              width: w,
              height: h - 85,
              child: googlemaps? GoogleMap(
                initialCameraPosition: const CameraPosition(
                  target: LatLng(23.0225, 72.5714),
                  zoom: 14,
                ),
                onMapCreated: (controller) => mapController = controller,
                markers: _markers,
                polylines: _polylines,
              ):GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: LatLng(23.0225, 72.5714),
                  zoom: 14,
                ),
              ),
            ),
          ),
          Container(
            width: w,
            height: h - 85,
            child: Column(
              children: [
                SizedBox(height: 8,),
                online?Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: Center(
                    child: Container(
                        width: w-20,
                        height: 45,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10),
                            // specify the radius for the top-left corner
                            topRight: Radius.circular(10),
                            bottomRight: Radius.circular(10),
                            bottomLeft: Radius.circular(10),
                            // specify the radius for the top-right corner
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8.0,right: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              f(w, 0),
                              f(w, 1),
                            ],
                          ),
                        )
                    ),
                  ),
                ):SizedBox(),
                online
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Container(
                            width: w - 10,
                            height: 80,
                            color: Colors.white,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12.0,
                                  ),
                                  child: Container(
                                    width: 60,
                                    height: 60,
                                    color: Colors.yellow,
                                    child: Center(
                                      child: Text(UserModel.user.name.substring(0,1)
                                        ,style: TextStyle(fontWeight: FontWeight.w800,fontSize: 25),),
                                    ),
                                  ),
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      review==0?"${orders.length} RIDES  |   ₹${price.toStringAsFixed(1)}":"TOTAL ${myorders.length} RIDES",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    Text(
                                      "Today, ${formattedDateTime()}",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    : SizedBox(),
                Spacer(),
                review==0?(orders.isEmpty
                    ? SizedBox()
                    : Container(
                  width: w,
                  height: 200,
                  child: ListView.builder(
                    itemCount: orders.length,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (BuildContext context, int index) {
                      OrderModel myorder = orders[index];
                      return VisibilityDetector(
                        key: Key('order-$index'),
                        onVisibilityChanged: (info) {
                          double visiblePercentage =
                              info.visibleFraction * 100;
                          if (visiblePercentage > 50) {
                            // More than half visible → call your function
                            print(
                              "Card ${index + 1} is visible: ${"myorder.user.name"}",
                            );
                            updateRoute(myorder.pickupLatitude, myorder.pickupLongitude,
                                myorder.dropLatitude, myorder.dropLongitude);
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Center(
                            child: Container(
                              width: w - 50,
                              height: 200,
                              child: InkWell(
                                onTap: (){
                                  print(myorder.status);
                                  updateRoute(myorder.pickupLatitude, myorder.pickupLongitude,
                                      myorder.dropLatitude, myorder.dropLongitude);
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: const Text("Book this Booking"),
                                        content: const Text("Book Route for this Customer? You sure could take this Booking from the Customer"),
                                        actions: [
                                          TextButton(
                                            onPressed: () async {
                                              try {
                                                final s = await BookingFunction
                                                    .attachDriverBooking(
                                                    id: myorder.id
                                                        .toString());
                                                final d = await BookingFunction
                                                    .updateBookingStatus(
                                                    bookingId: myorder.id
                                                        .toString(),
                                                    status: BookingStatus.arriving);
                                                Navigator.pop(context);
                                                Send.message(context, "Success : ${d} ${s}",true);
                                                getupcoming();
                                              }catch(e){
                                                print(e);
                                                Navigator.pop(context);
                                                Send.message(context, "$e",false);
                                              }
                                            },
                                            child: const Text("OK"),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            child: const Text("CANCEL"),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                                child: Container(
                                  width: w - 60,
                                  height: 200,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                  ),
                                  child: Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          left: 8.0,
                                          top: 10,
                                        ),
                                        child: Row(
                                          children: [
                                            CircleAvatar(
                                              backgroundColor:
                                              Colors.yellow,
                                              child: Text(
                                                myorder.waitingHours,
                                              ),
                                            ),
                                            SizedBox(width: 8),
                                            Column(
                                              crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                              MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  "${myorder.waitingHours}hr Trip ${capitalizeFirst(myorder.bookingType)}",
                                                  style: TextStyle(
                                                    fontWeight:
                                                    FontWeight.w800,
                                                  ),
                                                ),
                                                Text(
                                                  "${getTimeLeft(myorder.bookingTime.toString())}",
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Spacer(),
                                            Container(
                                              width: w/5+10,
                                              height: 30,
                                              color: Global.bg,
                                              child: Center(child:
                                              Text("Accept",style: TextStyle(color: Colors.white,fontSize: 10),)),
                                            ),
                                            SizedBox(width: 9,),
                                          ],
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          SizedBox(width: 15),
                                          Container(
                                            width: 20,
                                            height: 90,
                                            child: Column(
                                              mainAxisAlignment:
                                              MainAxisAlignment.center,
                                              crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                              children: [
                                                CircleAvatar(
                                                  backgroundColor:
                                                  Colors.green,
                                                  radius: 6,
                                                ),
                                                SizedBox(width: 2),
                                                Container(
                                                  width: 2,
                                                  height: 25,
                                                  decoration: BoxDecoration(
                                                    color: Colors.black,
                                                    borderRadius:
                                                    BorderRadius.circular(
                                                      5,
                                                    ),
                                                  ),
                                                ),
                                                CircleAvatar(
                                                  backgroundColor:
                                                  Colors.white,
                                                  radius: 10,
                                                  child: Icon(
                                                    Icons.location_on_sharp,
                                                    color: Colors.red,
                                                    size: 18,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          SizedBox(width: 15),
                                          Container(
                                            width:
                                            w - 15 - 20 - 20 - 20 - 40,
                                            height: 90,
                                            child: Column(
                                              mainAxisAlignment:
                                              MainAxisAlignment.center,
                                              crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  "${myorder.pickupLocation} ",
                                                  maxLines: 1,
                                                  style: TextStyle(
                                                    fontWeight:
                                                    FontWeight.w800,
                                                  ),
                                                ),
                                                SizedBox(height: 8),
                                                Container(
                                                  width:
                                                  w -
                                                      15 -
                                                      20 -
                                                      20 -
                                                      20 -
                                                      30 -
                                                      20,
                                                  height: 2,
                                                  decoration: BoxDecoration(
                                                    color: Colors
                                                        .grey
                                                        .shade200,
                                                    borderRadius:
                                                    BorderRadius.circular(
                                                      15,
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(height: 8),
                                                Text(
                                                  "${myorder.dropLocation} ",
                                                  maxLines: 1,
                                                  style: TextStyle(
                                                    fontWeight:
                                                    FontWeight.w800,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),

                                      Padding(
                                        padding: const EdgeInsets.only(
                                          left: 15.0,
                                          top: 1,
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.calendar_month,
                                              color: Colors.black,
                                              size: 15,
                                            ),
                                            Text(
                                              " Sheduled for : ${formatDateTime(myorder.bookingTime.toString())}",
                                              style: TextStyle(
                                                fontWeight: FontWeight.w500,
                                                fontSize: 12,
                                              ),
                                            ),
                                            SizedBox(width: 15,),
                                            Icon(
                                              Icons.screen_rotation_alt_outlined,
                                              color: Colors.black,
                                              size: 15,
                                            ),
                                            t(
                                              "${calculateDistanceKm(myorder.dropLatitude, myorder.dropLongitude, myorder.pickupLatitude,myorder.pickupLongitude)} km",
                                            ),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          left: 15.0,
                                          top: 5,
                                          bottom: 15,
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.access_time_filled,
                                              color: Colors.grey,
                                              size: 13,
                                            ),
                                            t(
                                              "${myorder.waitingHours} Hour",
                                            ),
                                            Icon(
                                              Icons.add_road_sharp,
                                              color: Colors.grey,
                                              size: 13,
                                            ),
                                            t(
                                              "${capitalizeFirst(myorder.bookingType)}",
                                            ),
                                            Icon(
                                              Icons.safety_check_outlined,
                                              color: Colors.grey,
                                              size: 13,
                                            ),
                                            t("Status : ${myorder.status}"),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                )):(myorders.isEmpty
                    ? SizedBox()
                    : Container(
                        width: w,
                        height: 200,
                        child: ListView.builder(
                          itemCount: myorders.length,
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (BuildContext context, int index) {
                            mine.OrderModel myorder = myorders[index];
                            return VisibilityDetector(
                              key: Key('order-$index'),
                              onVisibilityChanged: (info) {
                                double visiblePercentage =
                                    info.visibleFraction * 100;
                                if (visiblePercentage > 50) {
                                  // More than half visible → call your function
                                  print(
                                    "Card ${index + 1} is visible: ${myorder.user.name}",
                                  );
                                  updateRoute(myorder.pickupLatitude, myorder.pickupLongitude,
                                      myorder.dropLatitude, myorder.dropLongitude);
                                }
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: Center(
                                  child: Container(
                                    width: w - 50,
                                    height: 200,
                                    child: InkWell(
                                      onTap: () async {
                                        Navigator.push(context,MaterialPageRoute(builder: (_)=>MyFull(id: myorder.id.toString())));
                                      },
                                      child: Container(
                                        width: w - 60,
                                        height: 200,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                        ),
                                        child: Column(
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                left: 8.0,
                                                top: 10,
                                              ),
                                              child: Row(
                                                children: [
                                                  CircleAvatar(
                                                    backgroundColor:
                                                        Colors.yellow,
                                                    child: Text(myorder.user.name
                                                          .substring(0, 1)
                                                          .substring(0, 1),
                                                    ),
                                                  ),
                                                  SizedBox(width: 8),
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.start,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.center,
                                                    children: [
                                                      Text(
                                                        myorder.user.name,
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w800,
                                                        ),
                                                      ),
                                                      Text(
                                                        myorder.user.mobile,
                                                        style: TextStyle(
                                                          fontSize: 11,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  Spacer(),
                                                  Container(
                                                    width: w/5+15,
                                                    height: 30,
                                                    color: Global.bg,
                                                    child: Center(child:
                                                    Text("${myorder.status}",style: TextStyle(color: Colors.white,fontSize: 10),)),
                                                  ),
                                                  SizedBox(width: 9,),
                                                ],
                                              ),
                                            ),
                                            Row(
                                              children: [
                                                SizedBox(width: 15),
                                                Container(
                                                  width: 20,
                                                  height: 90,
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.center,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.center,
                                                    children: [
                                                      CircleAvatar(
                                                        backgroundColor:
                                                            Colors.green,
                                                        radius: 6,
                                                      ),
                                                      SizedBox(width: 2),
                                                      Container(
                                                        width: 2,
                                                        height: 25,
                                                        decoration: BoxDecoration(
                                                          color: Colors.black,
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                5,
                                                              ),
                                                        ),
                                                      ),
                                                      CircleAvatar(
                                                        backgroundColor:
                                                            Colors.white,
                                                        radius: 10,
                                                        child: Icon(
                                                          Icons.location_on_sharp,
                                                          color: Colors.red,
                                                          size: 18,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                SizedBox(width: 15),
                                                Container(
                                                  width:
                                                      w - 15 - 20 - 20 - 20 - 40,
                                                  height: 90,
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.center,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        "${myorder.pickupLocation} ",
                                                        maxLines: 1,
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w800,
                                                        ),
                                                      ),
                                                      SizedBox(height: 8),
                                                      Container(
                                                        width:
                                                            w -
                                                            15 -
                                                            20 -
                                                            20 -
                                                            20 -
                                                            30 -
                                                            20,
                                                        height: 2,
                                                        decoration: BoxDecoration(
                                                          color: Colors
                                                              .grey
                                                              .shade200,
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                15,
                                                              ),
                                                        ),
                                                      ),
                                                      SizedBox(height: 8),
                                                      Text(
                                                        "${myorder.dropLocation} ",
                                                        maxLines: 1,
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w800,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),

                                            Padding(
                                              padding: const EdgeInsets.only(
                                                left: 15.0,
                                                top: 1,
                                              ),
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    Icons.calendar_month,
                                                    color: Colors.black,
                                                    size: 15,
                                                  ),
                                                  Text(
                                                    " Sheduled for : ${formatDateTime(myorder.bookingTime.toString())}",
                                                    style: TextStyle(
                                                      fontWeight: FontWeight.w500,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                  SizedBox(width: 15,),
                                                  Icon(
                                                    Icons.screen_rotation_alt_outlined,
                                                    color: Colors.black,
                                                    size: 15,
                                                  ),
                                                  t(
                                                    "${calculateDistanceKm(myorder.dropLatitude, myorder.dropLongitude, myorder.pickupLatitude,myorder.pickupLongitude)} km",
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                left: 15.0,
                                                top: 5,
                                                bottom: 15,
                                              ),
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    Icons.access_time_filled,
                                                    color: Colors.grey,
                                                    size: 13,
                                                  ),
                                                  t(
                                                    "${myorder.waitingHours} Hour",
                                                  ),
                                                  Icon(
                                                    Icons.add_road_sharp,
                                                    color: Colors.grey,
                                                    size: 13,
                                                  ),
                                                  t(
                                                    "${capitalizeFirst(myorder.bookingType)}",
                                                  ),
                                                  Icon(
                                                    Icons.safety_check_outlined,
                                                    color: Colors.grey,
                                                    size: 13,
                                                  ),
                                                  t("Status : ${myorder.status}"),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      )),
                online
                    ? SizedBox()
                    : InkWell(
                        onTap: switches,
                        child: CircleAvatar(
                          radius: 65,
                          backgroundColor: progress
                              ? Colors.blue
                              : Colors.black,
                          child: CircleAvatar(
                            radius: 63,
                            backgroundColor: Colors.white,
                            child: CircleAvatar(
                              radius: 60,
                              backgroundColor: Colors.black,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  "Go Online",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                SizedBox(height: 20),
                progress
                    ? LinearProgressIndicator(
                        backgroundColor: Colors.black,
                        color: !online ? Colors.blue : Colors.red,
                      )
                    : SizedBox(),
                InkWell(
                  onTap: () {
                    setState(() {
                      full = !full;
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
                            onTap: () {
                              _scaffoldKey.currentState!.openDrawer();
                            },
                            child: Icon(
                              Icons.menu,
                              color: Colors.green.shade800,
                            ),
                          ),
                          Spacer(),
                          Icon(
                            Icons.circle,
                            size: 20,
                            color: online ? Colors.green : Colors.red,
                          ),
                          Text(
                            online ? " YOU ARE ONLINE" : " YOU ARE OFFLINE",
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 17,
                            ),
                          ),
                          Spacer(),
                          full
                              ? Icon(Icons.arrow_drop_down, color: Colors.black)
                              : Icon(Icons.arrow_drop_up, color: Colors.black),
                        ],
                      ),
                    ),
                  ),
                ),
                full
                    ? InkWell(
                        onTap: switches,
                        child: Container(
                          width: w,
                          height: 50,
                          color: Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14.0,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Spacer(),
                                Icon(
                                  Icons.circle,
                                  size: 20,
                                  color: !online ? Colors.green : Colors.red,
                                ),
                                Text(
                                  !online ? " GO ONLINE" : " GO OFFLINE",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 17,
                                  ),
                                ),
                                Spacer(),
                              ],
                            ),
                          ),
                        ),
                      )
                    : SizedBox(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String calculateDistanceKm(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadiusKm = 6371; // Earth's radius in kilometers

    double dLat = _degreesToRadians(lat2 - lat1);
    double dLon = _degreesToRadians(lon2 - lon1);

    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(lat1)) *
            cos(_degreesToRadians(lat2)) *
            sin(dLon / 2) * sin(dLon / 2);

    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    double distance = earthRadiusKm * c;

    if(distance>100){
      return "100+";
    }
    return distance.toStringAsFixed(1); // rounded to 2 decimals
  }

  double _degreesToRadians(double degree) {
    return degree * pi / 180;
  }
  bool googlemaps = false;

  GoogleMapController? mapController;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};

  @override
  void initState() {
    super.initState();
  }

  Future<void> updateRoute(double lat1, double lon1, double lat2, double lon2) async {
    try {
      final start = LatLng(lat1, lon1);
      final end = LatLng(lat2, lon2);
      _markers.clear();
      _polylines.clear();
      _markers.add(Marker(
        markerId: const MarkerId('start'),
        position: start,
        infoWindow: const InfoWindow(title: "Start Point"),
      ));
      _markers.add(Marker(
        markerId: const MarkerId('end'),
        position: end,
        infoWindow: const InfoWindow(title: "End Point"),
      ));
      PolylinePoints polylinePoints = PolylinePoints(apiKey: Api.googlemap);
      PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
          request: PolylineRequest(
              origin: PointLatLng(lat1, lon1),
              destination: PointLatLng(lat2, lon2),
              mode: TravelMode.twoWheeler
          )
      );

      if (result.points.isNotEmpty) {
        List<LatLng> routeCoords =
        result.points.map((p) => LatLng(p.latitude, p.longitude)).toList();
        _polylines.add(Polyline(
          polylineId: const PolylineId('route'),
          color: Colors.blue,
          width: 5,
          points: routeCoords,
        ));
      }

      setState(() {
        googlemaps = true;
      });

      mapController?.animateCamera(CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(
            lat1 < lat2 ? lat1 : lat2,
            lon1 < lon2 ? lon1 : lon2,
          ),
          northeast: LatLng(
            lat1 > lat2 ? lat1 : lat2,
            lon1 > lon2 ? lon1 : lon2,
          ),
        ),
        50, // padding
      ));
    }catch(e){
      print(e);
    }
  }

  void switches() {
    setState(() {
      progress = true;
    });
    Timer(Duration(seconds: 3), () async {
      setState(() {
        progress = false;
        online = !online;
        full = false;
      });
      if (online) {
        await getmyorders();
        setState(() {});
      } else {
        orders = [];
        myorders=[];
        setState(() {});
      }
    });
  }

  bool progress = false;
  bool full = false;
  bool online = false;

  bool isAfter(String g) {
    try {
      DateTime now = DateTime.now();
      DateTime given = DateTime.parse(g);

      Duration diff = given.difference(now);

      // ✅ Return true only if 'given' is more than 20 minutes in the future
      return diff.inMinutes > 20;
    } catch (e) {
      print("Error parsing date: $e");
      return false;
    }
  }

  Widget t(String str) => Text(
    " $str    ",
    style: TextStyle(
      fontWeight: FontWeight.w600,
      color: Colors.black,
      fontSize: 12,
    ),
  );

  String formatDateTime(String dateTime) {
    try {
      print("---------------------This $dateTime");
      DateTime utcTime = DateTime.parse(dateTime);

      // Convert to local time (e.g., IST)
      DateTime localTime = utcTime.toLocal();

      final DateFormat formatter = DateFormat('dd MMMM, hh:mm a');
      return formatter.format(localTime);
    } catch (e) {
      return "Error";
    }
  }

  String getTimeLeft(String dateTimeString) {
    try {
      DateTime target = DateTime.parse(dateTimeString).toLocal();
      DateTime now = DateTime.now();

      Duration diff = target.difference(now);

      if (diff.isNegative) {
        return "Already Passed Due date";
      }

      int days = diff.inDays;
      int hours = diff.inHours % 24;
      int minutes = diff.inMinutes % 60;

      // Optional: months (approximate, since month lengths vary)
      int months = (days / 30).floor();
      days = days % 30;

      List<String> parts = [];

      if (months > 0) parts.add("$months month${months > 1 ? 's' : ''}");
      if (days > 0) parts.add("$days day${days > 1 ? 's' : ''}");
      if (hours > 0) parts.add("$hours hour${hours > 1 ? 's' : ''}");
      if (minutes > 0) parts.add("$minutes minute${minutes > 1 ? 's' : ''}");

      return parts.isEmpty ? "Less than a minute left" : "${parts.join(', ')} left";
    } catch (e) {
      return "Invalid Date";
    }
  }

  DateTime formatDate(String dateTime) {
    try {
      print("---------------------This $dateTime");
      DateTime utcTime = DateTime.parse(dateTime);

      // Convert to local time (e.g., IST)
      return utcTime.toLocal();
    } catch (e) {
      return DateTime.now();
    }
  }

  String capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }



}

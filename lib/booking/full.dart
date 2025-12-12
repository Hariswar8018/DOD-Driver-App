import 'dart:math';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:dod_partner/booking/booking_function.dart';
import 'package:dod_partner/global/animations.dart';
import 'package:dod_partner/global/orderhelper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_widget/google_maps_widget.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import '../api.dart';
import '../global/global.dart';
import '../login/bloc/login/view.dart';
import '../model/my_ordermodel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'dart:ui' as ui;

class MyFull extends StatefulWidget {
  String id ;
  MyFull({super.key,required this.id});

  @override
  State<MyFull> createState() => _MyFullState();
}

class _MyFullState extends State<MyFull> {

  Future<void> getr() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('id', widget.id);
  }
  void initState(){
    getr();
    getmyorders();
  }
  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(), targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!.buffer.asUint8List();
  }

  Future<void> getmyorders() async {
    final Dio dio = Dio(
      BaseOptions(validateStatus: (status) => status != null && status < 500),
    );

    try {
      final response = await dio.get(
        "${Api.apiurl}driver/booking-show/${widget.id}",
        options: Options(
          headers: {"Authorization": "Bearer ${UserModel.token}"},
        ),
      );

      if (response.statusCode == 200) {
        print(response.data);
        print("----------------------------->");
        print(UserModel.token);

        // ✅ Correct parsing
        order = OrderModel.fromJson(response.data['data']);
        setState(() {});
        updateRoute(order!.pickupLatitude, order!.pickupLongitude, order!.dropLatitude, order!.dropLongitude);
      } else {
        print("❌ Error: ${response.statusMessage}");
      }
    } catch (e) {
      print("Error during API call: $e");
    }
  }

  GoogleMapController? mapController;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};

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
        50,
      ));
      setState(() {

      });
    }catch(e){
      print(e);
    }
  }


  final _firestore = FirebaseFirestore.instance;
  StreamSubscription<Position>? _positionStream;


  GoogleMapController? _mapController;
  Marker? _bikeMarker;

  LatLng? _lastPosition;



  @override
  void dispose() {
    _positionStream?.cancel();
    _positionStream?.cancel();
    super.dispose();
  }
  void get(){
    showDialog(
      context: context,
      barrierDismissible: false, // prevents closing by tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero, // 👈 makes it rectangular
          ),
          backgroundColor: Colors.white,
          title:  Text(
            "Collected ₹${order!.amount} ?",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const Text("You sure that you collected the Amount by Cash"),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero, // keep buttons rectangular too
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                "No, Stop",
                style: TextStyle(color: Colors.white),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero, // keep buttons rectangular too
                ),
              ),
              onPressed: () async {
                try {
                  String str = sendstring(order!.status);
                  final d = await BookingFunction
                      .updateBookingStatus(
                      bookingId: order!.id.toString(),
                      status: str
                  );
                  await getmyorders();
                  Navigator.pop(context);
                  Send.message(context, "Success : ${d} ",true);
                  setState(() {
                    progress=false;
                  });
                }catch(e){
                  print(e);
                  Send.message(context, "$e",false);
                  setState(() {
                    progress=false;
                  });
                }
              },
              child: const Text("Yes, I Confirm ",style: TextStyle(color: Colors.white),),
            ),
          ],
        );
      },
    );
  }


  OrderModel? order ; bool zoom =false;
  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar:AppBar(
        backgroundColor: Color(0xff25252D),
        automaticallyImplyLeading: true,
        iconTheme: IconThemeData(
            color: Colors.white
        ),
        leading: IconButton(onPressed: (){
          showDialog(
            context: context,
            barrierDismissible: false, // prevents closing by tapping outside
            builder: (BuildContext context) {
              return AlertDialog(
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero, // 👈 makes it rectangular
                ),
                backgroundColor: Colors.white,
                title: const Text(
                  "Confirm Close ?",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                content: const Text("Are you sure you want to Close the Ride? Your Location Service will also be Closed"),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(false); // user chose "No"
                    },
                    child: const Text(
                      "No",
                      style: TextStyle(color: Colors.green),
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero, // keep buttons rectangular too
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop(true);
                      Navigator.pop(context);
                    },
                    child: const Text("Yes",style: TextStyle(color: Colors.white),),
                  ),
                ],
              );
            },
          );
        }, icon: Icon(Icons.close,color: Colors.white,)),
        title: Text("Booking ID #${widget.id}",style: TextStyle(color: Colors.white),),
      ),
      body: order==null?Shimmer.fromColors(
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
      ):
      Column(
        children: [
          Container(
            width: w,
            height: zoom? h-260: h/2-90,
            child: GoogleMap(
              initialCameraPosition: const CameraPosition(
                target: LatLng(23.0225, 72.5714),
                zoom: 14,
              ),
              onMapCreated: (controller) {
                mapController = controller;
              },
              markers: _markers,
              polylines: _polylines,
            )
          ),
          progress?LinearProgressIndicator():SizedBox(),
          zoom?Container(
            width: w,
            height: 100,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  backgroundColor:
                  Colors.yellow,
                  child: Text(order!.user.name
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
                      order!.user.name,
                      style: TextStyle(
                          fontWeight:
                          FontWeight.w800,fontSize: 17
                      ),
                    ),
                    Text(
                      order!.user.mobile,
                      style: TextStyle(
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                Spacer(),
                InkWell(
                    onTap: (){
                      setState(() {
                        zoom=!zoom;
                      });
                    },
                    child: Icon(Icons.arrow_upward,color: Colors.blue,size: 30,)),
                SizedBox(width: 10,),
              ],
            ),
          ):Container(
            width: w,
            height: h/2-90,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                            child: Text(order!.user.name
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
                                order!.user.name,
                                style: TextStyle(
                                  fontWeight:
                                  FontWeight.w800,fontSize: 17
                                ),
                              ),
                              Text(
                                order!.user.mobile,
                                style: TextStyle(
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                          Spacer(),
                          InkWell(
                              onTap: (){
                                setState(() {
                                  zoom=!zoom;
                                });
                              },
                              child: Icon(Icons.arrow_downward_sharp,color: Colors.red,size: 30,)),
                          SizedBox(width: 10,),
                        ],
                      ),
                    ),
                    d(10),
                    Text("  Contact Info : ",style: TextStyle(fontWeight: FontWeight.w400,),),d(3),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        InkWell(
                          onTap:() async {
                            final Uri _url = Uri.parse('tel:${order!.user.mobile}');
                            if (!await launchUrl(_url)) {
                            throw Exception('Could not launch $_url');
                            }
                          },
                          child: Container(
                            width: w/2-20,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(6)
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.call,color: Colors.white,),
                                Text("  Call User",style: TextStyle(color: Colors.white,fontWeight: FontWeight.w800),)
                              ],
                            ),
                          ),
                        ),
                        InkWell(
                          onTap:() async {
                            final Uri _url = Uri.parse('mailto:${order!.user.email}');
                            if (!await launchUrl(_url)) {
                              throw Exception('Could not launch $_url');
                            }
                          },
                          child: Container(
                            width: w/2-20,
                            height: 40,
                            decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(6)
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.email,color: Colors.white,),
                                Text("  Email User",style: TextStyle(color: Colors.white,fontWeight: FontWeight.w800),)
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                    d(10),
                    Text("  Basic Requirements :",style: TextStyle(fontWeight: FontWeight.w400,),),
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
                            "${order!.hours} Hour",
                          ),
                          Icon(
                            Icons.add_road_sharp,
                            color: Colors.grey,
                            size: 13,
                          ),
                          t(
                            order?.recurringBooking!=null?"Daily Driver  ":"${capitalizeFirst(order!.bookingType)}",
                          ),
                          Icon(
                            Icons.screen_rotation_alt_outlined,
                            color: Colors.black,
                            size: 15,
                          ),
                          t(
                            "${calculateDistanceKm(order!.dropLatitude, order!.dropLongitude,
                                order!.pickupLatitude,order!.pickupLongitude)} km",
                          ),
                        ],
                      ),
                    ),
                    Text("  Timing : ",style: TextStyle(fontWeight: FontWeight.w400,),),
                    order?.recurringBooking==null?Row(
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
                          w - 15 - 20 - 40 ,
                          height: 90,
                          child: Column(
                            mainAxisAlignment:
                            MainAxisAlignment.center,
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${formatDateTime(order!.bookingTime.toString())} ",
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
                                    40,
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
                                "${formatDateTimee(order!.bookingTime.toString())} ",
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
                    ):Row(
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
                          w - 15 - 20 - 40 ,
                          height: 90,
                          child: Column(
                            mainAxisAlignment:
                            MainAxisAlignment.center,
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${order!.recurringBooking!.startDate} from ${order!.recurringBooking!.routes.first.pickupTime} to ${l(order!.recurringBooking!.routes.first.pickupTime)}",
                                maxLines: 1,
                                style: TextStyle(
                                  fontWeight:
                                  FontWeight.w800,
                                ),
                              ),
                              SizedBox(height: 8),
                              Container(
                                width:
                                w - 15 - 20 - 40,
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
                                "${order!.recurringBooking!.endDate} from ${order!.recurringBooking!.routes.first.pickupTime} to ${l(order!.recurringBooking!.routes.first.pickupTime)}",
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
                    Text("  Location : ",style: TextStyle(fontWeight: FontWeight.w400,),),
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
                          w - 15 - 20 - 40 ,
                          height: 90,
                          child: Column(
                            mainAxisAlignment:
                            MainAxisAlignment.center,
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${order!.pickupLocation} ",
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
                                    40,
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
                                "${order!.dropLocation} ",
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
                    SizedBox(height: 30,)
                  ],
                ),
              ),
            ),
          )
        ],
      ),
      persistentFooterButtons: [
        order==null?Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Container(
              width: w,height: 82,
              color: Colors.white,
            )
        ):
        Container(
          width: w,
          height: 82,
          child: Column(
            children: [
              Row(
                children: [
                  Text("Current Status : ${capitalizeFirst(order!.status)}",style: TextStyle(fontWeight: FontWeight.w800,fontSize: 18),),
                  Spacer(),
                ],
              ),
              SizedBox(height: 3,),
              order!.status=="completed"?dg(w):InkWell(
                onLongPress: (){
                  String str = sendstring(order!.status);
                  print(str);
                },
                onTap: () async {
                  print(order!.status);
                  String str = sendstring(order!.status);
                  if(order!.status=="arrived"){
                    await getmyorders();
                    Send.message(context, "Status Refreshed Successful. Please check now the status of Order!",true);
                  }
                  if(order!.status=="payment-over-due"){
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero,
                          ),
                          backgroundColor: Colors.white,
                          title:  Text(
                            "Please Collect ₹${order!.amount}",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          content: const Text("Please Collect the Payment in cash from the User. If the User have done payment online, refresh the page to check status"),
                          actions: [
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.zero, // keep buttons rectangular too
                                ),
                              ),
                              onPressed: () async {
                                await getmyorders();
                                Navigator.pop(context);
                                Send.message(context,"Updated", true);
                              },
                              child: const Text(
                                "User Paid by Razorpay, Refresh",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.zero, // keep buttons rectangular too
                                ),
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                                get();
                              },
                              child: const Text("Yes, User Paid in Cash ",style: TextStyle(color: Colors.white),),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.zero, // keep buttons rectangular too
                                ),
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text("Close",style: TextStyle(color: Colors.white),),
                            ),
                          ],
                        );
                      },
                    );
                    return ;
                  }
                  if (str!="in-trip") {
                    setState(() {
                      progress=true;
                    });
                    print(str);
                    try {
                      final d = await BookingFunction
                          .updateBookingStatus(
                          bookingId: order!.id.toString(),
                          status: str);
                      await getmyorders();
                      Send.message(context, "Success : ${d} ",true);
                      setState(() {
                        progress=false;
                      });
                    }catch(e){
                      print(e);
                      Navigator.pop(context);
                      Send.message(context, "$e",false);
                      setState(() {
                        progress=false;
                      });
                    }
                  } else {
                    setState(() {
                      progress=false;
                    });
                    print("Already at final status");
                  }
                },
                child: Container(
                  width: w,
                  height: 50,
                 decoration: BoxDecoration(
                   color:order!.status=="arrived"?Colors.grey: Colors.red,
                   borderRadius: BorderRadius.circular(10)
                 ),
                  child: order!.status=="arrived"?Center(
                    child: Text("Waiting for Customer Verification"
                        ,style: TextStyle(
                            fontWeight: FontWeight.w900,color: Colors.white,fontSize: 19
                        )),
                  ):Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      getStatusIcon(order!.status),
                      SizedBox(width: 5,),
                      Text("Mark "+"${(getNextStatusString(order!.status))}",style: TextStyle(
                        fontWeight: FontWeight.w900,color: Colors.white,fontSize: 19
                      ),),
                    ],
                  ),
                ),
              )
            ],
          ),
        )
      ],
    );
  }

  String l(String timeString) {
    try {
      int hoursToAdd = int.parse(order!.hours);

      // Parse the time "8:00 AM"
      DateFormat format = DateFormat("h:mm a");
      DateTime time = format.parse(timeString);

      // Add the hours
      DateTime newTime = time.add(Duration(hours: hoursToAdd));

      // Format back to "1:00 PM"
      return format.format(newTime);
    } catch (e) {
      return "Error";
    }
  }



  Widget dg(double w){
    return Container(
      width: w,
      height: 50,
      decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(10)
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          getStatusIcon(order!.status),
          SizedBox(width: 5,),
          Text("Mark "+"${(getNextStatusString(order!.status))}",style: TextStyle(
              fontWeight: FontWeight.w900,color: Colors.white,fontSize: 19
          ),),
        ],
      ),
    );
  }
  bool progress = false;
  Icon getStatusIcon(String status) {
    switch (status) {
      case 'open':
        return Icon(Icons.radio_button_unchecked, color: Colors.white);
      case 'accepted':
        return Icon(Icons.thumb_up, color: Colors.white);
      case 'confirmed':
        return Icon(Icons.check_circle_outline, color: Colors.white);
      case 'arriving':
        return Icon(Icons.directions_bike, color: Colors.white);
      case 'arrived':
        return Icon(Icons.location_on, color: Colors.white);
      case 'in-trip':
        return Icon(Icons.directions_car, color: Colors.white);
      case 'over':
        return Icon(Icons.flag, color: Colors.white);
      case 'payment-over-due':
        return Icon(Icons.warning, color: Colors.white);
      case 'completed':
        return Icon(Icons.done_all, color: Colors.white);
      case 'issue-exists':
        return Icon(Icons.error_outline, color: Colors.white);
      case 'canceled':
        return Icon(Icons.cancel, color: Colors.white);
      default:
        return Icon(Icons.help_outline, color: Colors.white); // fallback
    }
  }
  String? getNextStatusString(String currentStatus) {
    const linearStatuses = [
      'pending',
      'open',
      'accepted',
      'confirmed',
      'arriving',
      'arrived',
      'in-trip',
      'payment-over-due',
      'completed',
      'issue-exists',
      'canceled',
    ];

    int index = linearStatuses.indexOf(currentStatus);

    if (index == -1 || index == linearStatuses.length - 1) {
      return "Open";
    }

    String next = linearStatuses[index + 1];

    // Capitalize the first letter
    return next[0].toUpperCase() + next.substring(1);
  }

  String sendstring(String status) {
    switch (status) {
      case 'pending':
        return 'accepted';
      case 'open':
        return 'accepted';
      case 'accepted':
        return 'confirmed';
      case 'confirmed':
        return 'arriving';
      case 'arriving':
        return 'arrived';
      case 'arrived':
        return 'in-trip';
      case 'in-trip':
        return 'over';
      case 'over':
        return 'payment-over-due';
      case 'payment-over-due':
        return 'completed';
      default:
        return 'issue-exist'; // fallback
    }
  }
  BookingStatus? bookingStatusFromString(String status) {
    try {
      return BookingStatus.values.firstWhere(
              (e) => e.apiValue == status,
          orElse: () => BookingStatus.open
      );
    } catch (_) {
      return null;
    }
  }

  static const linearStatuses = [
    BookingStatus.open,
    BookingStatus.accepted,
    BookingStatus.confirmed,
    BookingStatus.arriving,
    BookingStatus.arrived,
    BookingStatus.inTrip,
    BookingStatus.over,
    BookingStatus.paymentOverDue,
    BookingStatus.completed,
    BookingStatus.issueExists,
    BookingStatus.canceled,
  ];

  BookingStatus? getNextStatus(BookingStatus current) {
    if(current==BookingStatus.open){
      return BookingStatus.confirmed;
    }else if(current==BookingStatus.confirmed||current==BookingStatus.accepted){
      return BookingStatus.arriving;
    }else if(current==BookingStatus.arriving){
      return BookingStatus.arrived;
    }else if(current==BookingStatus.arrived){
      return BookingStatus.inTrip;
    }else if(current==BookingStatus.inTrip){
      return BookingStatus.paymentOverDue;
    }else if(current==BookingStatus.paymentOverDue){
      return BookingStatus.over;
    }else {
      return BookingStatus.completed;
    }
  }


  Widget d(double length)=>SizedBox(height: length);
  String formatDateTimehr(String dateTime, String give) {
    try {
      int addHours = int.parse(give);
      print("---------------------This $dateTime");

      // Parse the incoming date string (assumes ISO8601 format)
      DateTime utcTime = DateTime.parse(dateTime);

      // Convert to local time
      DateTime localTime = utcTime.toLocal();

      // Add extra hours if provided
      DateTime finalTime = localTime.add(Duration(hours: addHours));

      // Format the final datetime
      final DateFormat formatter = DateFormat('dd MMMM, hh:mm a');
      return formatter.format(finalTime);
    } catch (e) {
      return "Error";
    }
  }

  Widget t(String str) => Text(
    " $str    ",
    style: TextStyle(
      fontWeight: FontWeight.w600,
      color: Colors.black,
      fontSize: 15,
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
  String formatDateTimee(String dateTime) {
    try {
      DateTime utcTime = DateTime.parse(dateTime);

      DateTime localTime = utcTime.toLocal();

      final DateFormat timeFormatter = DateFormat('h:mm a');
      final DateFormat formatter = DateFormat('dd MMMM');

      String s = timeFormatter.format(localTime);
      String s1 = formatter.format(localTime);

      String ge = l(s);
      return "${s1}, $ge";
    } catch (e) {
      return "Error";
    }
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

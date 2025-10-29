import 'dart:math';

import 'package:dio/dio.dart' show Dio, BaseOptions, Options;
import 'package:dod_partner/booking/full.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../api.dart';
import '../global/global.dart' show Global;
import '../login/bloc/login/view.dart';
import '../model/my_ordermodel.dart' as mine;
import '../model/mybooking.dart';

class MyRides extends StatefulWidget {
  const MyRides({super.key});

  @override
  State<MyRides> createState() => _MyRidesState();
}

class _MyRidesState extends State<MyRides> {
  void initState(){
    getmyorders();
  }
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
        final bookingsResponse = MyBookingsResponse.fromJson(response.data);
        print(bookingsResponse.bookings);
        print("✅ Total bookings: ${bookingsResponse.bookings.length}");
        for (var order in bookingsResponse.bookings) {
          print(
            "📦 Booking ID: ${order.id}, Status: ${order.status}, User: ${order.user.name}",
          );
          myorders.add(order);
        }
        setState(() {

        });
      } else {
        print("❌ Error: ${response.statusMessage}");
      }
    } catch (e) {
      print("Error during API call: $e");
    }
  }
  List<mine.OrderModel> myorders = [];
  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;
    return Scaffold(
        appBar:AppBar(
          backgroundColor: Color(0xff25252D),
          automaticallyImplyLeading: true,
          iconTheme: IconThemeData(
              color: Colors.white
          ),
          title: Text("My Rides",style: TextStyle(color: Colors.white),),
        ),
      body: Container(
        width: w,
        height: h,
        child: ListView.builder(
          itemCount: myorders.length,
          scrollDirection: Axis.vertical,
          itemBuilder: (BuildContext context, int index) {
            mine.OrderModel myorder = myorders[index];
            return  Padding(
                padding: const EdgeInsets.all(10),
                child: Center(
                  child: InkWell(
                    onTap: () async {
                      Navigator.push(context,MaterialPageRoute(builder: (_)=>MyFull(id: myorder.id.toString())));
                    },
                    child: Container(
                      width: w - 10,
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
                                  width: w/5+10,
                                  height: 30,
                                  color: Global.bg,
                                  child: Center(child:
                                  Text("Accept (${myorder.waitingHours}hr)",style: TextStyle(color: Colors.white,fontSize: 10),)),
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
            );
          },
        ),
      )
    );
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

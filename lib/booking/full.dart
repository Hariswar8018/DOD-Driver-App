import 'dart:math';

import 'package:dio/dio.dart';
import 'package:dod_partner/booking/booking_function.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_widget/google_maps_widget.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import '../api.dart';
import '../global/global.dart';
import '../login/bloc/login/view.dart';
import '../model/my_ordermodel.dart';

class MyFull extends StatefulWidget {
  String id ;
  MyFull({super.key,required this.id});

  @override
  State<MyFull> createState() => _MyFullState();
}

class _MyFullState extends State<MyFull> {

  void initState(){

    getmyorders();
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
        getCurrentLocation();
        showUserLocation();
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
        50, // padding
      ));
    }catch(e){
      print(e);
    }
  }

  Future<Position> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, cannot request.');
    }

    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }
  LatLng? userLocation;

  Future<void> showUserLocation() async {
    try {
      Position position = await getCurrentLocation();
      userLocation = LatLng(position.latitude, position.longitude);

      _markers.add(
        Marker(
          markerId: MarkerId('user'),
          position: userLocation!,
          infoWindow: InfoWindow(title: "You are here"),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        ),
      );

      mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(userLocation!, 15),
      );

      setState(() {});
    } catch (e) {
      print("Error getting location: $e");
    }
  }


  OrderModel? order ;
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
            height: h/2-90,
            child: GoogleMap(
              initialCameraPosition: const CameraPosition(
                target: LatLng(23.0225, 72.5714),
                zoom: 14,
              ),
              onMapCreated: (controller) {
                mapController = controller;
                showUserLocation(); // show user location when map is ready
              },
              markers: _markers,
              polylines: _polylines,
            )
          ),
          progress?LinearProgressIndicator():SizedBox(),
          Container(
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
                          SizedBox(width: 1,),
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
                            "${order!.waitingHours} Hour",
                          ),
                          Icon(
                            Icons.add_road_sharp,
                            color: Colors.grey,
                            size: 13,
                          ),
                          t(
                            "${capitalizeFirst(order!.bookingType)}",
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
                                "${formatDateTimehr(order!.bookingTime.toString(),order!.waitingHours)} ",
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
              InkWell(
                onTap: () async {
                  String currentStatusStr = order!.status;
                  BookingStatus? currentStatus = bookingStatusFromString(currentStatusStr);
                  BookingStatus? nextStatus;
                  if (currentStatus != null) {
                    nextStatus = getNextStatus(currentStatus);
                  }
                  if (nextStatus != null) {
                    setState(() {
                      progress=true;
                    });
                    try {
                      final d = await BookingFunction
                          .updateBookingStatus(
                          bookingId: order!.id
                              .toString(),
                          status: BookingStatus.arriving);
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
                   color: Colors.red,
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
                ),
              )
            ],
          ),
        )
      ],
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
      'open',
      'accepted',
      'confirmed',
      'arriving',
      'arrived',
      'in-trip',
      'over',
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
    int index = linearStatuses.indexOf(current);
    if (index == -1 || index == linearStatuses.length - 1) return null;
    return linearStatuses[index + 1];
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

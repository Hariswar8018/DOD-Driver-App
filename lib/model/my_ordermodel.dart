




import 'dart:convert';
class OrderModel {
  final int id;
  final int userId;
  final int? driverId;
  final int? carId;
  final int? couponId;

  final String bookingType;
  final String tripType;
  final String hours;
  final String waitingHours;

  final DateTime? bookingTime;
  final double distanceKm;

  final String pickupLocation;
  final double pickupLatitude;
  final double pickupLongitude;

  final String dropLocation;
  final double dropLatitude;
  final double dropLongitude;

  final String paymentMethod;

  final double amount;
  final double subTotal;
  final double discountAmount;
  final double paidAmount;

  final double perHourCharge;
  final double foodAllowance;
  final double stayAllowance;

  final String status;
  final DateTime createdAt;
  final DateTime? updatedAt;

  final User user;
  final User? driver;
  final RecurringBooking? recurringBooking;

  OrderModel({
    required this.id,
    required this.userId,
    this.driverId,
    this.carId,
    this.couponId,
    required this.bookingType,
    required this.tripType,
    required this.hours,
    required this.waitingHours,
    this.bookingTime,
    required this.distanceKm,
    required this.pickupLocation,
    required this.pickupLatitude,
    required this.pickupLongitude,
    required this.dropLocation,
    required this.dropLatitude,
    required this.dropLongitude,
    required this.paymentMethod,
    required this.amount,
    required this.subTotal,
    required this.discountAmount,
    required this.paidAmount,
    required this.perHourCharge,
    required this.foodAllowance,
    required this.stayAllowance,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    required this.user,
    this.driver,
    this.recurringBooking,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: _parseInt(json['id']),
      userId: _parseInt(json['user_id']),
      driverId: _tryInt(json['driver_id']),
      carId: _tryInt(json['car_id']),
      couponId: _tryInt(json['coupon_id']),

      bookingType: json['booking_type'] ?? '',
      tripType: json['trip_type'] ?? '',
      hours: json['hours']?.toString() ?? "",
      waitingHours: json['waiting_hours']?.toString() ?? "",

      bookingTime: DateTime.tryParse(json['booking_time'] ?? ""),
      distanceKm: _parseDouble(json['distance_km']),

      pickupLocation: json['pickup_location'] ?? '',
      pickupLatitude: _parseDouble(json['pickup_latitude']),
      pickupLongitude: _parseDouble(json['pickup_longitude']),

      dropLocation: json['drop_location'] ?? '',
      dropLatitude: _parseDouble(json['drop_latitude']),
      dropLongitude: _parseDouble(json['drop_longitude']),

      paymentMethod: json['paymentmethod'] ?? '',

      amount: _parseDouble(json['amount']),
      subTotal: _parseDouble(json['sub_total']),
      discountAmount: _parseDouble(json['discountamount']),
      paidAmount: _parseDouble(json['paid_amount']),

      perHourCharge: _parseDouble(json['per_hour_charge']),
      foodAllowance: _parseDouble(json['food_allowance']),
      stayAllowance: _parseDouble(json['stay_allowance']),

      status: json['status'] ?? '',

      createdAt: DateTime.tryParse(json['created_at'] ?? "") ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? ""),

      user: User.fromJson(json['user'] ?? {}),
      driver: json['driver'] != null ? User.fromJson(json['driver']) : null,
      recurringBooking: json['recurring_booking'] != null
          ? RecurringBooking.fromJson(json['recurring_booking'])
          : null,
    );
  }

  static int _parseInt(dynamic value) =>
      value is int ? value : int.tryParse(value.toString()) ?? 0;

  static int? _tryInt(dynamic value) =>
      value == null ? null : int.tryParse(value.toString());

  static double _parseDouble(dynamic value) =>
      value is double ? value : double.tryParse(value.toString()) ?? 0.0;
}

class User {
  final int id;
  final String firebaseId;
  final String provider;
  final String referralNumber;
  final String name;
  final String? username;
  final String role;
  final String email;
  final String mobile;
  final int? coins;
  final String? emailVerifiedAt;
  final String? fcmToken;
  final String platformType;
  final String status;
  final String createdAt;
  final String updatedAt;
  final double? latitude;
  final double? longitude;
  final String? joined;
  final String? lastOnline;
  final String online;

  User({
    required this.id,
    required this.firebaseId,
    required this.provider,
    required this.referralNumber,
    required this.name,
    required this.username,
    required this.role,
    required this.email,
    required this.mobile,
    required this.coins,
    required this.emailVerifiedAt,
    required this.fcmToken,
    required this.platformType,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.latitude,
    required this.longitude,
    required this.joined,
    required this.lastOnline,
    required this.online,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: OrderModel._parseInt(json['id']),
      firebaseId: json['firebase_id'] ?? '',
      provider: json['provider'] ?? '',
      referralNumber: json['referral_number'] ?? '',
      name: json['name'] ?? '',
      username: json['username'],
      role: json['role'] ?? '',
      email: json['email'] ?? '',
      mobile: json['mobile']?.toString() ?? '',
      coins: OrderModel._tryInt(json['coins']),
      emailVerifiedAt: json['email_verified_at'],
      fcmToken: json['fcm_token'],
      platformType: json['platform_type'] ?? '',
      status: json['status'] ?? '',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      latitude: json['latitude'] != null ? double.tryParse(json['latitude'].toString()) : null,
      longitude: json['longitude'] != null ? double.tryParse(json['longitude'].toString()) : null,
      joined: json['joined'],
      lastOnline: json['last_online'],
      online: json['online']?.toString() ?? "0",
    );
  }
}
class RecurringBooking {
  final int id;
  final int userId;
  final String bookingType;
  final List<RouteModel> routes;
  final List<String> days;
  final String startDate;
  final String endDate;
  final String status;

  RecurringBooking({
    required this.id,
    required this.userId,
    required this.bookingType,
    required this.routes,
    required this.days,
    required this.startDate,
    required this.endDate,
    required this.status,
  });

  factory RecurringBooking.fromJson(Map<String, dynamic> json) {
    // decode routes (string → list)
    final routesString = json['routes'] ?? '[]';
    final routesJson = jsonDecode(routesString) as List;

    // decode days
    final daysString = json['days'] ?? '[]';
    final daysJson = jsonDecode(daysString) as List;

    return RecurringBooking(
      id: OrderModel._parseInt(json['id']),
      userId: OrderModel._parseInt(json['user_id']),
      bookingType: json['booking_type'] ?? '',
      routes: routesJson.map((e) => RouteModel.fromJson(e)).toList(),
      days: daysJson.map((e) => e.toString()).toList(),
      startDate: json['start_date'] ?? '',
      endDate: json['end_date'] ?? '',
      status: json['status'] ?? '',
    );
  }
}

class RouteModel {
  final String pickupLocation;
  final double pickupLatitude;
  final double pickupLongitude;
  final String dropLocation;
  final double dropLatitude;
  final double dropLongitude;
  final String pickupTime;
  final String dropTime;

  RouteModel({
    required this.pickupLocation,
    required this.pickupLatitude,
    required this.pickupLongitude,
    required this.dropLocation,
    required this.dropLatitude,
    required this.dropLongitude,
    required this.pickupTime,
    required this.dropTime,
  });

  factory RouteModel.fromJson(Map<String, dynamic> json) {
    return RouteModel(
      pickupLocation: json['pickup_location'] ?? '',
      pickupLatitude: (json['pickup_latitude'] ?? 0).toDouble(),
      pickupLongitude: (json['pickup_longitude'] ?? 0).toDouble(),
      dropLocation: json['drop_location'] ?? '',
      dropLatitude: (json['drop_latitude'] ?? 0).toDouble(),
      dropLongitude: (json['drop_longitude'] ?? 0).toDouble(),
      pickupTime: json['pickup_time'] ?? '',
      dropTime: json['drop_time'] ?? '',
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'pickup_location': pickupLocation,
      'pickup_latitude': pickupLatitude,
      'pickup_longitude': pickupLongitude,
      'drop_location': dropLocation,
      'drop_latitude': dropLatitude,
      'drop_longitude': dropLongitude,
      'pickup_time': pickupTime,
      'drop_time': dropTime,
    };
  }
}

class OrderModel {
  final int id;
  final int userId;
  final int? recurringBookingId;
  final int? driverId;
  final int? carId;
  final int? couponId;
  final String bookingType;
  final String tripType;
  final String? waitingHours;
  final DateTime? bookingTime;
  final double distanceKm;
  final String pickupLocation;
  final double pickupLatitude;
  final double pickupLongitude;
  final String dropLocation;
  final double dropLatitude;
  final double dropLongitude;
  final String paymentMethod;
  final double paidAmount;
  final double amount;
  final double discountAmount;
  final String status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String hours;

  OrderModel({
    required this.id,
    required this.userId,
    this.recurringBookingId,
    this.driverId,
    this.carId,
    this.couponId,
    required this.bookingType,
    required this.tripType,
    this.waitingHours,
    this.bookingTime,
    required this.distanceKm,
    required this.pickupLocation,
    required this.pickupLatitude,
    required this.pickupLongitude,
    required this.dropLocation,
    required this.dropLatitude,
    required this.dropLongitude,
    required this.paymentMethod,
    required this.paidAmount,
    required this.amount,
    required this.discountAmount,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    required this.hours
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: _parseInt(json['id']),
      userId: _parseInt(json['user_id']),
      recurringBookingId: _tryInt(json['recurring_booking_id']),
      driverId: _tryInt(json['driver_id']),
      hours: json['hours']?.toString() ?? "1",
      carId: _tryInt(json['car_id']),
      couponId: _tryInt(json['coupon_id']),
      bookingType: json['booking_type'] ?? '',
      tripType: json['trip_type'] ?? '',
      waitingHours: json['waiting_hours']?.toString(),
      bookingTime: DateTime.tryParse(json['booking_time'] ?? ''),
      distanceKm: _parseDouble(json['distance_km']),
      pickupLocation: json['pickup_location'] ?? '',
      pickupLatitude: _parseDouble(json['pickup_latitude']),
      pickupLongitude: _parseDouble(json['pickup_longitude']),
      dropLocation: json['drop_location'] ?? '',
      dropLatitude: _parseDouble(json['drop_latitude']),
      dropLongitude: _parseDouble(json['drop_longitude']),
      paymentMethod: json['paymentmethod'] ?? '',
      paidAmount: _parseDouble(json['paid_amount']),
      amount: _parseDouble(json['amount']),
      discountAmount: _parseDouble(json['discountamount']),
      status: json['status'] ?? '',
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? ''),
    );
  }

  static int _parseInt(dynamic value) =>
      value is int ? value : int.tryParse(value.toString()) ?? 0;

  static int? _tryInt(dynamic value) =>
      value == null ? null : int.tryParse(value.toString());

  static double _parseDouble(dynamic value) =>
      value is double ? value : double.tryParse(value.toString()) ?? 0.0;
}

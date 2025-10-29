

import 'my_ordermodel.dart' show OrderModel;

class MyBookingsResponse {
  final bool success;
  final String message;
  final List<OrderModel> bookings;

  MyBookingsResponse({
    required this.success,
    required this.message,
    required this.bookings,
  });

  factory MyBookingsResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data']?['data'] as List? ?? [];
    return MyBookingsResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      bookings: data.map((e) => OrderModel.fromJson(e)).toList(),
    );
  }
}
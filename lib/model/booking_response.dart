import 'ordermodel.dart';

class BookingsResponse {
  final bool success;
  final String message;
  final List<OrderModel> bookings;

  BookingsResponse({
    required this.success,
    required this.message,
    required this.bookings,
  });

  factory BookingsResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data']?['data'] as List? ?? [];
    return BookingsResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      bookings: data.map((e) => OrderModel.fromJson(e)).toList(),
    );
  }
}

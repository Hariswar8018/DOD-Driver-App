




import 'package:dio/dio.dart';
import 'package:dod_partner/api.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../login/bloc/login/view.dart';


class BookingFunction{

  static final Dio dio = Dio(
    BaseOptions(validateStatus: (status) => status != null && status < 500),
  );

  static Future<String?> attachDriverBooking({
    required String id,
  }) async {

    try {
      final response = await dio.put(
        '${Api.apiurl}driver/booking-update/$id',
        options: Options(
          headers: {"Authorization": "Bearer ${UserModel.token}"},
        ),
      );

      print('Driver Booking Update Response: ${response.data}');
      return '✅ Booking status updated successfully ';
    } on DioException catch (e) {
      print('Error updating driver booking: $e');
      return e.toString();
    }
  }


  static Future<String?> updateBookingStatus({
    required String bookingId,
    required String status,
  }) async {
    const allowedStatuses = [
      'open',
      'accepted',
      'confirmed',
      'arriving',
      'arrived',
      'in-trip',
      'over',
      'payment-over-due',
      'completed',
    ];

    try {
      print("|---------------------------------");
      final response = await dio.put(
        '${Api.apiurl}driver/booking-update/${bookingId}',
        options: Options(
          headers: {"Authorization": "Bearer ${UserModel.token}"},
        ),
        data: {
          'booking_id': bookingId,
          'status': status,
          'driver_id': UserModel.user.id,
        },
      );
      print(response);
      return '✅ Booking status updated successfully ${response.statusCode} with ${response.statusMessage}';
    } on DioException catch (e) {
      print('❌ Error updating booking status: ${e.response?.data ?? e.message}');
      return e.toString();
    }
  }

}

enum BookingStatus {
  open,
  accepted,
  confirmed,
  arriving,
  arrived,
  inTrip,
  over,
  paymentOverDue,
  completed,
  issueExists,
  canceled,
}
extension BookingStatusExtension on BookingStatus {
  String get apiValue {
    switch (this) {
      case BookingStatus.open:
        return 'open';
      case BookingStatus.accepted:
        return 'accepted';
      case BookingStatus.confirmed:
        return 'confirmed';
      case BookingStatus.arriving:
        return 'arriving';
      case BookingStatus.arrived:
        return 'arrived';
      case BookingStatus.inTrip:
        return 'in-trip';
      case BookingStatus.over:
        return 'over';
      case BookingStatus.paymentOverDue:
        return 'payment-over-due';
      case BookingStatus.completed:
        return 'completed';
      case BookingStatus.issueExists:
        return 'issue-exists';
      case BookingStatus.canceled:
        return 'canceled';
    }
  }
}






import 'package:dio/dio.dart';
import 'package:dod_partner/api.dart';


class BookingFunction{


  Future<Response?> updateBookingStatus({
    required String bookingId,
    required String status,
    required String driverId,
    required String authToken,
  }) async {
    // ✅ Valid allowed statuses
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
      'issue-exists',
      'canceled',
    ];

    // ✅ Check if status is valid
    if (!allowedStatuses.contains(status)) {
      throw ArgumentError(
          'Invalid status "$status". Must be one of: ${allowedStatuses.join(", ")}');
    }

    final dio = Dio();

    try {
      final response = await dio.post(
        '${Api.apiurl}booking-status',
        options: Options(
          headers: {
            'Authorization': authToken, // Pass token directly
          },
        ),
        data: {
          'booking_id': bookingId,
          'status': status,
          'driver_id': driverId,
        },
      );

      print('✅ Booking status updated successfully: ${response.data}');
      return response;
    } on DioException catch (e) {
      // Log or rethrow error
      print('❌ Error updating booking status: ${e.response?.data ?? e.message}');
      return e.response;
    }
  }

}
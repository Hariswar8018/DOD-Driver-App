class ReviewModel {
  final int id;
  final int userId;
  final int driverId;
  final int bookingId;
  final double reviews;
  final String message;
  final DateTime createdAt;
  final DateTime updatedAt;

  ReviewModel({
    required this.id,
    required this.userId,
    required this.driverId,
    required this.bookingId,
    required this.reviews,
    required this.message,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: _parseInt(json['id']),
      userId: _parseInt(json['user_id']),
      driverId: _parseInt(json['driver_id']),
      bookingId: _parseInt(json['booking_id']),
      reviews: _parseDouble(json['reviews']),
      message: json['message'] ?? '',
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
    );
  }

  static int _parseInt(dynamic value) =>
      value == null ? 0 : int.tryParse(value.toString()) ?? 0;

  static double _parseDouble(dynamic value) =>
      value == null ? 0.0 : double.tryParse(value.toString()) ?? 0.0;
}
class ReviewResponse {
  final bool success;
  final String message;
  final Pagination pagination;

  ReviewResponse({
    required this.success,
    required this.message,
    required this.pagination,
  });

  factory ReviewResponse.fromJson(Map<String, dynamic> json) {
    return ReviewResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      pagination: Pagination.fromJson(json['data']),
    );
  }
}
class Pagination {
  final int currentPage;
  final List<ReviewModel> data;
  final int from;
  final int lastPage;
  final int perPage;
  final int to;
  final int total;

  Pagination({
    required this.currentPage,
    required this.data,
    required this.from,
    required this.lastPage,
    required this.perPage,
    required this.to,
    required this.total,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      currentPage: json['current_page'] ?? 1,
      data: (json['data'] as List)
          .map((e) => ReviewModel.fromJson(e))
          .toList(),
      from: json['from'] ?? 0,
      lastPage: json['last_page'] ?? 1,
      perPage: json['per_page'] ?? 0,
      to: json['to'] ?? 0,
      total: json['total'] ?? 0,
    );
  }
}

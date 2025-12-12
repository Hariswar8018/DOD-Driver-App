class UserData {
  final int id;
  final String provider;
  final String firebaseId;
  final String fcmToken;
  final String name;
  final String? username;
  final String email;
  final String mobile;
  final String platformType;
  final String referralNumber;
  final String role;
  final String online;
  final String? latitude;
  final String? longitude;
  final String? joined;
  final String? lastOnline;
  final String createdAt;
  final String updatedAt;
  final String coins;
  final String walletBalance;
  final String status;
  final String? photo;
  final Profile? profile;

  UserData({
    required this.id,
    required this.provider,
    required this.firebaseId,
    required this.fcmToken,
    required this.name,
    this.username,
    required this.email,
    required this.mobile,
    required this.platformType,
    required this.referralNumber,
    required this.role,
    required this.online,
    this.latitude,
    this.longitude,
    this.joined,
    this.lastOnline,
    required this.createdAt,
    required this.updatedAt,
    required this.coins,
    required this.walletBalance,
    required this.status,
    this.photo,
    this.profile,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      provider: json['provider'] ?? '',
      firebaseId: json['firebase_id'] ?? '',
      fcmToken: json['fcm_token'] ?? '',
      name: json['name'] ?? '',
      username: json['username'],
      email: json['email'] ?? '',
      mobile: json['mobile'] ?? '',
      platformType: json['platform_type'] ?? '',
      referralNumber: json['referral_number'] ?? '',
      role: json['role'] ?? '',
      online: json['online']?.toString() ?? '0',
      latitude: json['latitude']?.toString(),
      longitude: json['longitude']?.toString(),
      joined: json['joined']?.toString(),
      lastOnline: json['last_online']?.toString(),
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      coins: json['coins']?.toString() ?? '0',
      walletBalance: json['wallet_balance']?.toString() ?? '0.00',
      status: json['status'] ?? '',
      photo: json['photo'],
      profile: json['profile'] != null
          ? Profile.fromJson(json['profile'])
          : null,
    );
  }
}


class Profile {
  final int id;
  final int userId;
  final String rating;
  final String rides;
  final String alternateEmail;
  final String? photo;
  final String alternateContact;
  final String fatherName;
  final String homeAddress;
  final String currentAddress;
  final String adhaarNumber;
  final String? adhaarPic1;
  final String? adhaarPic2;
  final String driverLicense;
  final String? driverLicensePic;
  final String experience;
  final String createdAt;
  final String updatedAt;

  Profile({
    required this.id,
    required this.userId,
    required this.rating,
    required this.rides,
    required this.alternateEmail,
    this.photo,
    required this.alternateContact,
    required this.fatherName,
    required this.homeAddress,
    required this.currentAddress,
    required this.adhaarNumber,
    this.adhaarPic1,
    this.adhaarPic2,
    required this.driverLicense,
    this.driverLicensePic,
    required this.experience,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      userId: int.tryParse(json['user_id']?.toString() ?? '') ?? 0,
      rating: json['rating'] ?? '',
      rides: json['rides'] ?? '',
      alternateEmail: json['alternate_email'] ?? '',
      photo: json['photo'],
      alternateContact: json['alternate_contact'] ?? '',
      fatherName: json['father_name'] ?? '',
      homeAddress: json['home_address'] ?? '',
      currentAddress: json['current_address'] ?? '',
      adhaarNumber: json['adhaar_number'] ?? '',
      adhaarPic1: json['adhaar_pic1'],
      adhaarPic2: json['adhaar_pic2'],
      driverLicense: json['driver_license'] ?? '',
      driverLicensePic: json['driver_license_pic'],
      experience: json['experience'] ?? '',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }
}

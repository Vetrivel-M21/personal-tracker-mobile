class UserModel {
  final String id;
  final String displayName;
  final int xp;
  final int level;
  final int xpIntoLevel;
  final int xpForNextLevel;
  final bool hasPassword;
  final String? dateOfBirth;
  final int? age;
  final bool profilePrivate;
  final bool hideHabits;
  final String? area;
  final String? district;
  final String? state;
  final String? countryCode;
  final String? region;
  final String? city;
  final bool locationVisible;
  final String referralCode;
  final bool isAdmin;
  final String createdAt;

  const UserModel({
    required this.id,
    required this.displayName,
    required this.xp,
    required this.level,
    required this.xpIntoLevel,
    required this.xpForNextLevel,
    required this.hasPassword,
    this.dateOfBirth,
    this.age,
    required this.profilePrivate,
    required this.hideHabits,
    this.area,
    this.district,
    this.state,
    this.countryCode,
    this.region,
    this.city,
    this.locationVisible = true,
    required this.referralCode,
    required this.isAdmin,
    required this.createdAt,
  });

  bool get hasLocation =>
      (countryCode != null && countryCode!.isNotEmpty) ||
      (district != null && district!.isNotEmpty);

  String get locationDisplay {
    final globalParts = [city, region, countryCode]
        .where((p) => p != null && p.isNotEmpty)
        .toList();
    if (globalParts.isNotEmpty) return globalParts.join(', ');

    final legacyParts = [area, district, state]
        .where((p) => p != null && p.isNotEmpty)
        .toList();
    if (legacyParts.isNotEmpty) return legacyParts.join(', ');

    return 'Location Not Set';
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String? ?? '',
      displayName: json['display_name'] as String? ?? '',
      xp: json['xp'] as int? ?? 0,
      level: json['level'] as int? ?? 1,
      xpIntoLevel: json['xp_into_level'] as int? ?? 0,
      xpForNextLevel: json['xp_for_next_level'] as int? ?? 100,
      hasPassword: json['has_password'] as bool? ?? false,
      dateOfBirth: json['date_of_birth'] as String?,
      age: json['age'] as int?,
      profilePrivate: json['profile_private'] as bool? ?? false,
      hideHabits: json['hide_habits'] as bool? ?? false,
      area: json['area'] as String?,
      district: json['district'] as String?,
      state: json['state'] as String?,
      countryCode: json['country_code'] as String?,
      region: json['region'] as String?,
      city: json['city'] as String?,
      locationVisible: json['location_visible'] as bool? ?? true,
      referralCode: json['referral_code'] as String? ?? '',
      isAdmin: json['is_admin'] as bool? ?? false,
      createdAt: json['created_at'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'display_name': displayName,
      'xp': xp,
      'level': level,
      'xp_into_level': xpIntoLevel,
      'xp_for_next_level': xpForNextLevel,
      'has_password': hasPassword,
      'date_of_birth': dateOfBirth,
      'age': age,
      'profile_private': profilePrivate,
      'hide_habits': hideHabits,
      'area': area,
      'district': district,
      'state': state,
      'country_code': countryCode,
      'region': region,
      'city': city,
      'location_visible': locationVisible,
      'referral_code': referralCode,
      'is_admin': isAdmin,
      'created_at': createdAt,
    };
  }
}

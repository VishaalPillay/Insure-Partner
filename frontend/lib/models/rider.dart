class Rider {
  final String id;
  final String phoneNumber;
  final String? platformWorkerId;
  final String? fullName;
  final int? age;
  final String? platform;
  final String? currentGeohash;
  final DateTime? createdAt;

  Rider({
    required this.id,
    required this.phoneNumber,
    this.platformWorkerId,
    this.fullName,
    this.age,
    this.platform,
    this.currentGeohash,
    this.createdAt,
  });

  factory Rider.fromJson(Map<String, dynamic> json) {
    return Rider(
      id: json['id'] as String,
      phoneNumber: json['phone_number'] as String,
      platformWorkerId: json['platform_worker_id'] as String?,
      fullName: json['full_name'] as String?,
      age: json['age'] as int?,
      platform: json['platform'] as String?,
      currentGeohash: json['current_geohash'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phone_number': phoneNumber,
      'platform_worker_id': platformWorkerId,
      'full_name': fullName,
      'age': age,
      'platform': platform,
      'current_geohash': currentGeohash,
    };
  }
}

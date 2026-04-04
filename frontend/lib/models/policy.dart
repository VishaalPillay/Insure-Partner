class Policy {
  final String? id;
  final String riderId;
  final DateTime startDate;
  final DateTime endDate;
  final double weeklyPremiumInr;
  final bool isActive;
  final bool isPaid;
  final DateTime? createdAt;

  Policy({
    this.id,
    required this.riderId,
    required this.startDate,
    required this.endDate,
    required this.weeklyPremiumInr,
    this.isActive = true,
    this.isPaid = false,
    this.createdAt,
  });

  factory Policy.fromJson(Map<String, dynamic> json) {
    return Policy(
      id: json['id'] as String?,
      riderId: json['rider_id'] as String,
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
      weeklyPremiumInr: (json['weekly_premium_inr'] as num).toDouble(),
      isActive: json['is_active'] as bool? ?? true,
      isPaid: json['is_paid'] as bool? ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'rider_id': riderId,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'weekly_premium_inr': weeklyPremiumInr,
      'is_active': isActive,
      'is_paid': isPaid,
    };
  }
}

class PremiumResult {
  final String status;
  final String riderId;
  final double weeklyPremiumInr;
  final String message;

  PremiumResult({
    required this.status,
    required this.riderId,
    required this.weeklyPremiumInr,
    required this.message,
  });

  factory PremiumResult.fromJson(Map<String, dynamic> json) {
    return PremiumResult(
      status: json['status'] as String? ?? 'unknown',
      riderId: json['rider_id'] as String? ?? '',
      weeklyPremiumInr: (json['weekly_premium_inr'] as num?)?.toDouble() ?? 0.0,
      message: json['message'] as String? ?? '',
    );
  }
}

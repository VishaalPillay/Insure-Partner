import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants.dart';
import '../models/premium_result.dart';

/// Dumb terminal — only sends rider_id and geohash.
/// The backend does all risk scoring, weather lookup, and ML inference.
class PricingService {
  /// POST to the Render-deployed FastAPI pricing endpoint.
  ///
  /// Request body: `{"rider_id": "...", "geohash": "..."}`
  /// Response:     `{"status": "success", "rider_id": "...", "weekly_premium_inr": 245.50, "message": "..."}`
  Future<PremiumResult> calculatePremium({
    required String riderId,
    required String geohash,
  }) async {
    final url = Uri.parse(AppConstants.pricingApiUrl);

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'rider_id': riderId,
        'geohash': geohash,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return PremiumResult.fromJson(data);
    } else {
      throw Exception(
        'Premium calculation failed (${response.statusCode}): ${response.body}',
      );
    }
  }
}

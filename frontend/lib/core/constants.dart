import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConstants {
  // ── API ──
  static String get pricingApiUrl =>
      dotenv.env['PRICING_API_URL'] ??
      'http://localhost:8000/api/v1/pricing/calculate-premium';

  static String get supabaseUrl =>
      dotenv.env['SUPABASE_URL'] ?? '';

  static String get supabaseAnonKey =>
      dotenv.env['SUPABASE_ANON_KEY'] ?? '';

  // ── Chennai Geohash Zones ──
  static const Map<String, String> chennaiZones = {
    'tdr5x': 'T. Nagar',
    'tdr5w': 'Velachery',
    'tdr6n': 'Anna Nagar',
    'tdr5z': 'Adyar',
    'tdr5y': 'Mylapore',
    'tdr6p': 'Ambattur',
    'tdr68': 'Guindy',
    'tdr6j': 'Perambur',
  };

  // ── Platforms ──
  static const List<PlatformInfo> platforms = [
    PlatformInfo(
      id: 'zepto',
      name: 'Zepto',
      icon: '⚡',
      tagline: '10-min grocery delivery',
    ),
    PlatformInfo(
      id: 'swiggy_instamart',
      name: 'Swiggy Instamart',
      icon: '🛒',
      tagline: 'Instant essentials',
    ),
    PlatformInfo(
      id: 'blinkit',
      name: 'Blinkit',
      icon: '🚀',
      tagline: 'Everything in minutes',
    ),
  ];
}

class PlatformInfo {
  final String id;
  final String name;
  final String icon;
  final String tagline;

  const PlatformInfo({
    required this.id,
    required this.name,
    required this.icon,
    required this.tagline,
  });
}

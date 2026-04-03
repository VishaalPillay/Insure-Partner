import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/rider.dart';
import '../services/supabase_service.dart';

/// Auth states that drive navigation in main.dart.
enum AppAuthState {
  unauthenticated,  // → show LoginScreen
  otpSent,          // → show OTP input on LoginScreen
  detailsRequired,  // → show UserDetailsScreen
  platformConnect,  // → show PlatformConnectScreen
  authenticated,    // → show DashboardScreen
}

class AuthProvider extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  final SupabaseService _db = SupabaseService();

  AppAuthState _state = AppAuthState.unauthenticated;
  AppAuthState get state => _state;

  Rider? _rider;
  Rider? get rider => _rider;

  String _phoneNumber = '';
  String get phoneNumber => _phoneNumber;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  AuthProvider() {
    _checkExistingSession();
  }

  /// On app start, check if user already has a valid Supabase session.
  Future<void> _checkExistingSession() async {
    final session = _supabase.auth.currentSession;
    if (session != null) {
      final userId = session.user.id;
      _rider = await _db.getRider(userId);
      if (_rider != null && _rider!.fullName != null && _rider!.platform != null) {
        _state = AppAuthState.authenticated;
      } else if (_rider != null && _rider!.fullName != null) {
        _state = AppAuthState.platformConnect;
      } else if (_rider != null) {
        _state = AppAuthState.detailsRequired;
      } else {
        // Session exists but no rider row yet — need details
        _phoneNumber = session.user.phone ?? '';
        _state = AppAuthState.detailsRequired;
      }
      notifyListeners();
    }
  }

  /// Step 1a — Send OTP via Supabase Auth (uses test phone numbers).
  /// Enable "test phone numbers" in Supabase Dashboard → Authentication → Phone.
  /// Hardcode +919999999999 / 123456 for demo.
  Future<void> sendOtp(String phone) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _phoneNumber = phone;
      await _supabase.auth.signInWithOtp(phone: phone);
      _state = AppAuthState.otpSent;
    } on AuthApiException catch (e) {
      if (e.message.contains('phone_provider_disabled') || e.code == 'phone_provider_disabled') {
        _errorMessage = 'Supabase Setup Required:\n1. Go to Supabase Dashboard\n2. Authentication → Providers → Phone\n3. Toggle "Enable Phone provider" ON\n(You can use fake Twilio credentials to save).';
      } else {
        _errorMessage = 'Failed to send OTP: ${e.message}';
      }
    } catch (e) {
      _errorMessage = 'Failed to send OTP: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Step 1b — Verify the OTP code.
  Future<void> verifyOtp(String otpCode) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _supabase.auth.verifyOTP(
        type: OtpType.sms,
        token: otpCode,
        phone: _phoneNumber,
      );

      if (response.session != null) {
        // Check if rider row already exists
        _rider = await _db.getRider(response.session!.user.id);
        if (_rider != null && _rider!.fullName != null && _rider!.platform != null) {
          _state = AppAuthState.authenticated;
        } else {
          _state = AppAuthState.detailsRequired;
        }
      } else {
        _errorMessage = 'Verification failed. Please try again.';
      }
    } catch (e) {
      _errorMessage = 'OTP verification error: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Step 2 — Save user details (name, age, geohash) to Supabase riders table.
  Future<void> saveUserDetails({
    required String fullName,
    required int age,
    required String geohash,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final userId = _supabase.auth.currentUser!.id;
      final phone = _phoneNumber.isNotEmpty
          ? _phoneNumber
          : (_supabase.auth.currentUser!.phone ?? '');

      _rider = Rider(
        id: userId,
        phoneNumber: phone,
        platformWorkerId: 'IP-${phone.replaceAll('+', '').substring(phone.length > 6 ? phone.length - 6 : 0)}',
        fullName: fullName,
        age: age,
        currentGeohash: geohash,
      );

      await _db.upsertRider(_rider!);
      _state = AppAuthState.platformConnect;
    } catch (e) {
      _errorMessage = 'Failed to save details: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Step 3 — Connect a delivery platform.
  Future<void> connectPlatform(String platformId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (_rider == null) throw Exception('Rider not found');

      _rider = Rider(
        id: _rider!.id,
        phoneNumber: _rider!.phoneNumber,
        platformWorkerId: _rider!.platformWorkerId,
        fullName: _rider!.fullName,
        age: _rider!.age,
        platform: platformId,
        currentGeohash: _rider!.currentGeohash,
      );

      await _db.upsertRider(_rider!);
      _state = AppAuthState.authenticated;
    } catch (e) {
      _errorMessage = 'Failed to connect platform: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Sign out and reset state.
  Future<void> signOut() async {
    await _supabase.auth.signOut();
    _rider = null;
    _phoneNumber = '';
    _state = AppAuthState.unauthenticated;
    _errorMessage = null;
    notifyListeners();
  }
}

import 'package:flutter/material.dart';
import '../models/premium_result.dart';
import '../models/policy.dart';
import '../services/pricing_service.dart';
import '../services/supabase_service.dart';

class PremiumProvider extends ChangeNotifier {
  final PricingService _pricingService = PricingService();
  final SupabaseService _db = SupabaseService();

  PremiumResult? _premiumResult;
  PremiumResult? get premiumResult => _premiumResult;

  List<Policy> _activePolicies = [];
  List<Policy> get activePolicies => _activePolicies;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isPolicyAccepted = false;
  bool get isPolicyAccepted => _isPolicyAccepted;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  /// Call the backend pricing endpoint — sends only rider_id + geohash.
  Future<void> fetchPremium({
    required String riderId,
    required String geohash,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    _isPolicyAccepted = false;
    notifyListeners();

    try {
      _premiumResult = await _pricingService.calculatePremium(
        riderId: riderId,
        geohash: geohash,
      );
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Accept the quoted premium and write a policy to Supabase.
  Future<void> acceptPolicy({required String riderId}) async {
    if (_premiumResult == null) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final now = DateTime.now();
      final policy = Policy(
        riderId: riderId,
        startDate: now,
        endDate: now.add(const Duration(days: 7)),
        weeklyPremiumInr: _premiumResult!.weeklyPremiumInr,
        isActive: true,
      );

      await _db.createPolicy(policy);
      _isPolicyAccepted = true;

      // Refresh active policies list
      await loadActivePolicies(riderId);
    } catch (e) {
      _errorMessage = 'Failed to accept policy: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load all active policies for the rider.
  Future<void> loadActivePolicies(String riderId) async {
    try {
      _activePolicies = await _db.getActivePolicies(riderId);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load policies: ${e.toString()}';
    }
  }
}

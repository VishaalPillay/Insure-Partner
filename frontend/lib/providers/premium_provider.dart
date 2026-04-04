import 'dart:async';
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

  Policy? _latestActivePolicy;
  Policy? get latestActivePolicy => _latestActivePolicy;

  StreamSubscription<List<Map<String, dynamic>>>? _policySubscription;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isPolicyAccepted = false;
  bool get isPolicyAccepted => _isPolicyAccepted;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  /// Call the backend pricing endpoint — sends only rider_id + geohash.
  Future<void> fetchPremium({
    required String riderId,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    _isPolicyAccepted = false;
    notifyListeners();

    try {
      _premiumResult = await _pricingService.calculatePremium(
        riderId: riderId,
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

  /// Mark the policy as paid natively via Supabase trigger.
  Future<void> payPolicy(String policyId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _db.markPolicyPaid(policyId);
      // Supabase realtime stream handles the UI update automatically!
    } catch (e) {
      _errorMessage = 'Payment execution failed: ${e.toString()}';
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

  /// Listen to the real-time stream of the latest policy for the rider.
  void listenToLatestPolicy(String riderId) {
    _policySubscription?.cancel();

    _policySubscription = _db.getLatestPolicyStream(riderId).listen((data) {
      if (data.isNotEmpty) {
        final policy = Policy.fromJson(data.first);
        if (policy.isActive) {
          _latestActivePolicy = policy;
          // If a paid policy arrives, clear any old calculation errors
          if (policy.isPaid) {
            _errorMessage = null;
          }
        } else {
          _latestActivePolicy = null;
        }
      } else {
        _latestActivePolicy = null;
      }
      notifyListeners();
    }, onError: (error) {
      _errorMessage = 'Policy stream error: ${error.toString()}';
      notifyListeners();
    });
  }

  void stopListening() {
    _policySubscription?.cancel();
    _policySubscription = null;
  }

  @override
  void dispose() {
    stopListening();
    super.dispose();
  }
}

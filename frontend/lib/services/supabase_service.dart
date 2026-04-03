import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/rider.dart';
import '../models/policy.dart';

class SupabaseService {
  final SupabaseClient _client = Supabase.instance.client;

  // ── Riders ──

  /// Upsert a rider row (keyed on phone_number).
  Future<void> upsertRider(Rider rider) async {
    await _client.from('riders').upsert(
      rider.toJson(),
      onConflict: 'id',
    );
  }

  /// Fetch a rider by their auth-user UUID.
  Future<Rider?> getRider(String id) async {
    final response = await _client
        .from('riders')
        .select()
        .eq('id', id)
        .maybeSingle();

    if (response == null) return null;
    return Rider.fromJson(response);
  }

  /// Fetch a rider by phone number.
  Future<Rider?> getRiderByPhone(String phone) async {
    final response = await _client
        .from('riders')
        .select()
        .eq('phone_number', phone)
        .maybeSingle();

    if (response == null) return null;
    return Rider.fromJson(response);
  }

  // ── Policies ──

  /// Insert a new policy row.
  Future<Policy> createPolicy(Policy policy) async {
    final response = await _client
        .from('policies')
        .insert(policy.toInsertJson())
        .select()
        .single();

    return Policy.fromJson(response);
  }

  /// Fetch all active policies for a rider.
  Future<List<Policy>> getActivePolicies(String riderId) async {
    final response = await _client
        .from('policies')
        .select()
        .eq('rider_id', riderId)
        .eq('is_active', true)
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => Policy.fromJson(json))
        .toList();
  }

  /// Get a real-time stream of the latest active policy for a rider.
  Stream<List<Map<String, dynamic>>> getLatestPolicyStream(String riderId) {
    return _client
        .from('policies')
        .stream(primaryKey: ['id'])
        .eq('rider_id', riderId)
        .order('created_at', ascending: false)
        .limit(1);
  }
}

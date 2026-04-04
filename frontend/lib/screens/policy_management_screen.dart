import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_theme.dart';
import '../providers/premium_provider.dart';
import '../shared/glass_card.dart';

class PolicyManagementScreen extends StatelessWidget {
  const PolicyManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final premium = context.watch<PremiumProvider>();
    final activePolicy = premium.latestActivePolicy;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0A0A1A), Color(0xFF0F1B2D), Color(0xFF0A0A1A)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                Text(
                  'Claims & Policies',
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                const SizedBox(height: 10),
                const Text(
                  'Manage your coverage and track claims',
                  style: TextStyle(color: AppTheme.textSecondary),
                ),
                const SizedBox(height: 30),
                
                if (activePolicy != null && activePolicy.isPaid) ...[
                  _buildActivePolicyCard(context, activePolicy),
                  const SizedBox(height: 24),
                  const Text(
                    'Active Claims',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Mock Claim Card
                  _buildMockClaimCard(context),
                ] else ...[
                  _buildEmptyState(context),
                ],
                
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActivePolicyCard(BuildContext context, dynamic policy) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.success.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.verified_user_rounded, color: AppTheme.success, size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                'Active Coverage',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildPolicyRow('Premium paid', '₹${policy.weeklyPremiumInr.toStringAsFixed(0)}'),
          _buildPolicyRow('Start Date', _formatDate(policy.startDate)),
          _buildPolicyRow('Expiry Date', _formatDate(policy.endDate)),
          const SizedBox(height: 10),
          const Divider(color: Colors.white10),
          const SizedBox(height: 10),
          const Text(
            'You are currently protected against weather-based disruptions in your zone.',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildPolicyRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
          Text(value, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildMockClaimCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Column(
            children: [
              Icon(Icons.history_rounded, color: AppTheme.textSecondary, size: 32),
              SizedBox(height: 12),
              Text(
                'No Claims Filed Yet',
                style: TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 4),
              Text(
                'Disruptions will automatically trigger claims.',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 60),
          Icon(Icons.policy_outlined, color: AppTheme.textSecondary.withOpacity(0.2), size: 100),
          const SizedBox(height: 20),
          const Text(
            'No Active Paid Policy',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Please pay your premium on the dashboard to activate coverage and track claims.',
              style: TextStyle(color: AppTheme.textSecondary),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

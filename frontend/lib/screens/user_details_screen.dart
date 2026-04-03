import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../core/app_theme.dart';
import '../core/constants.dart';
import '../providers/auth_provider.dart';
import '../shared/glass_card.dart';
import '../shared/gradient_button.dart';
import '../shared/step_progress_indicator.dart';

class UserDetailsScreen extends StatefulWidget {
  const UserDetailsScreen({super.key});

  @override
  State<UserDetailsScreen> createState() => _UserDetailsScreenState();
}

class _UserDetailsScreenState extends State<UserDetailsScreen>
    with SingleTickerProviderStateMixin {
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  String? _selectedGeohash;
  final _formKey = GlobalKey<FormState>();

  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )..forward();
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.3, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

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
          child: SlideTransition(
            position: _slideAnimation,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const SizedBox(height: 40),

                    // ── Header ──
                    _buildHeader(),
                    const SizedBox(height: 36),

                    // ── Step Progress ──
                    const StepProgressIndicator(currentStep: 1),
                    const SizedBox(height: 36),

                    // ── Details Card ──
                    GlassCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Personal Details',
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Help us personalize your coverage',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 28),

                          // ── Full Name ──
                          _buildLabel('Full Name'),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _nameController,
                            style: const TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 16,
                            ),
                            textCapitalization: TextCapitalization.words,
                            decoration: const InputDecoration(
                              hintText: 'e.g. Arjun Kumar',
                              prefixIcon: Icon(
                                Icons.person_outline_rounded,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                            validator: (v) =>
                                (v == null || v.trim().isEmpty) ? 'Name is required' : null,
                          ),
                          const SizedBox(height: 20),

                          // ── Age ──
                          _buildLabel('Age'),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _ageController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(2),
                            ],
                            style: const TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 16,
                            ),
                            decoration: const InputDecoration(
                              hintText: 'e.g. 28',
                              prefixIcon: Icon(
                                Icons.cake_outlined,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'Age is required';
                              final age = int.tryParse(v);
                              if (age == null || age < 18 || age > 65) {
                                return 'Age must be between 18 and 65';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),

                          // ── Delivery Zone ──
                          _buildLabel('Delivery Zone'),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            value: _selectedGeohash,
                            dropdownColor: AppTheme.surfaceLight,
                            icon: const Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: AppTheme.textSecondary,
                            ),
                            style: const TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 16,
                            ),
                            decoration: const InputDecoration(
                              hintText: 'Select your area',
                              prefixIcon: Icon(
                                Icons.location_on_outlined,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                            items: AppConstants.chennaiZones.entries.map((e) {
                              return DropdownMenuItem(
                                value: e.key,
                                child: Text('${e.value}  (${e.key})'),
                              );
                            }).toList(),
                            onChanged: (v) => setState(() => _selectedGeohash = v),
                            validator: (v) =>
                                v == null ? 'Please select a delivery zone' : null,
                          ),
                          const SizedBox(height: 32),

                          // ── Continue Button ──
                          GradientButton(
                            text: 'Continue',
                            icon: Icons.arrow_forward_rounded,
                            isLoading: auth.isLoading,
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                auth.saveUserDetails(
                                  fullName: _nameController.text.trim(),
                                  age: int.parse(_ageController.text.trim()),
                                  geohash: _selectedGeohash!,
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ),

                    // ── Error Message ──
                    if (auth.errorMessage != null) ...[
                      const SizedBox(height: 16),
                      _buildError(auth.errorMessage!),
                    ],

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppTheme.accent.withOpacity(0.15),
          ),
          child: const Icon(
            Icons.badge_outlined,
            color: AppTheme.accent,
            size: 32,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Tell Us About You',
          style: Theme.of(context).textTheme.headlineLarge,
        ),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: AppTheme.textSecondary,
        fontSize: 13,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildError(String message) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.error.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppTheme.error, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: AppTheme.error, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/app_theme.dart';

import 'dashboard_screen.dart';
import 'policy_management_screen.dart';
import 'user_profile_screen.dart';

class HomeNavigation extends StatefulWidget {
  const HomeNavigation({super.key});

  @override
  State<HomeNavigation> createState() => _HomeNavigationState();
}

class _HomeNavigationState extends State<HomeNavigation> {
  int _currentIndex = 0;
  StreamSubscription? _claimsSubscription;
  bool _hasShownDisasterModal = false;

  final List<Widget> _screens = const [
    DashboardScreen(),
    PolicyManagementScreen(),
    UserProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _initGlobalDisasterListener();
  }

  void _initGlobalDisasterListener() {
    final client = Supabase.instance.client;
    // Listen to the 'claims' table for any zero-touch triggers injected by the admin backend
    _claimsSubscription = client
        .from('claims')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .listen((data) {
      if (data.isNotEmpty && !_hasShownDisasterModal) {
        // If we see a claim record pop up, trigger the intense modal globally.
        _showDisasterModal();
        _hasShownDisasterModal = true;
      }
    }, onError: (err) {
      debugPrint("Claims stream error: $err");
    });
  }

  void _showDisasterModal() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.error.withOpacity(0.95),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.redAccent.withOpacity(0.5), width: 2),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.warning_rounded, color: Colors.white, size: 64),
                const SizedBox(height: 16),
                const Text(
                  '⚠️ SEVERE DISRUPTION DETECTED',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  '₹500 ESCROWED.\nZero-touch claim has been triggered on your active policy.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppTheme.error,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    // Force the user onto the Claims tab to see the details
                    setState(() {
                      _currentIndex = 1;
                    });
                  },
                  child: const Text('View Claim Status'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _claimsSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: Colors.white.withOpacity(0.05),
              width: 1,
            ),
          ),
        ),
        child: Theme(
          data: ThemeData(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
          child: BottomNavigationBar(
            backgroundColor: AppTheme.surface,
            elevation: 0,
            currentIndex: _currentIndex,
            onTap: (index) => setState(() => _currentIndex = index),
            selectedItemColor: AppTheme.accent,
            unselectedItemColor: AppTheme.textSecondary,
            selectedFontSize: 12,
            unselectedFontSize: 12,
            type: BottomNavigationBarType.fixed,
            items: const [
              BottomNavigationBarItem(
                icon: Padding(
                  padding: EdgeInsets.only(bottom: 4.0),
                  child: Icon(Icons.dashboard_rounded),
                ),
                label: 'Dashboard',
              ),
              BottomNavigationBarItem(
                icon: Padding(
                  padding: EdgeInsets.only(bottom: 4.0),
                  child: Icon(Icons.shield_rounded),
                ),
                label: 'Claims',
              ),
              BottomNavigationBarItem(
                icon: Padding(
                  padding: EdgeInsets.only(bottom: 4.0),
                  child: Icon(Icons.person_rounded),
                ),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

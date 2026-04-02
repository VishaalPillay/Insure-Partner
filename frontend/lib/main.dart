import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/app_theme.dart';
import 'core/constants.dart';
import 'providers/auth_provider.dart';
import 'providers/premium_provider.dart';
import 'screens/login_screen.dart';
import 'screens/user_details_screen.dart';
import 'screens/platform_connect_screen.dart';
import 'screens/dashboard_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables from .env asset
  await dotenv.load(fileName: '.env');

  // Initialize Supabase
  await Supabase.initialize(
    url: AppConstants.supabaseUrl,
    anonKey: AppConstants.supabaseAnonKey,
  );

  runApp(const InsurePartnerApp());
}

class InsurePartnerApp extends StatelessWidget {
  const InsurePartnerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => PremiumProvider()),
      ],
      child: MaterialApp(
        title: 'Insure-Partner',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const AuthGate(),
      ),
    );
  }
}

/// Routes to the correct screen based on auth state.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthProvider>().state;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 350),
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
      child: _buildScreen(authState),
    );
  }

  Widget _buildScreen(AppAuthState state) {
    switch (state) {
      case AppAuthState.unauthenticated:
      case AppAuthState.otpSent:
        return const LoginScreen(key: ValueKey('login'));
      case AppAuthState.detailsRequired:
        return const UserDetailsScreen(key: ValueKey('details'));
      case AppAuthState.platformConnect:
        return const PlatformConnectScreen(key: ValueKey('platform'));
      case AppAuthState.authenticated:
        return const DashboardScreen(key: ValueKey('dashboard'));
    }
    return const SizedBox();
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/premium_provider.dart';
import 'screens/login_screen.dart';
import 'screens/user_details_screen.dart';
import 'screens/platform_connect_screen.dart';
import 'screens/home_navigation.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load .env file
  await dotenv.load(fileName: '.env');

  // Debug check (remove later if you want)
  print("SUPABASE_URL: ${dotenv.env['SUPABASE_URL']}");
  print("SUPABASE_KEY: ${dotenv.env['SUPABASE_ANON_KEY']}");

  // Initialize Supabase safely
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  runApp(const InsurePartnerApp());
}

class InsurePartnerApp extends StatelessWidget {
  const InsurePartnerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(),
        ),
        ChangeNotifierProvider<PremiumProvider>(
          create: (_) => PremiumProvider(),
        ),
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

/// Handles routing based on authentication state
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
        return const HomeNavigation(key: ValueKey('navigation'));
    }
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/pages/onboarding_page.dart';
import 'features/home/presentation/pages/home_page.dart';
import 'features/auth/presentation/providers/auth_provider.dart';

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    print('🔵 MyApp: Building...');

    final authState = ref.watch(authStateProvider);

    return MaterialApp(
      title: 'Voice of Faith',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      // Utiliser navigatorKey pour pouvoir naviguer depuis n'importe où
      home: authState.when(
        data: (user) {
          print('🔵 MyApp: AuthState DATA - User: ${user?.uid ?? "null"}');

          // Navigation immédiate basée sur l'état d'auth
          if (user != null) {
            print('🔵 MyApp: Showing HomePage');
            return const HomePage();
          } else {
            print('🔵 MyApp: Showing OnboardingPage');
            return const OnboardingPage();
          }
        },
        loading: () {
          print('🔵 MyApp: AuthState LOADING');
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        },
        error: (error, stack) {
          print('🔴 MyApp: AuthState ERROR: $error');
          return const OnboardingPage();
        },
      ),
    );
  }
}
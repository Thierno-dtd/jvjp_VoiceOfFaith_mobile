import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/navigation/app_router.dart';
import 'features/auth/presentation/providers/auth_provider.dart';

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    print('🔵 MyApp: Building...');

    // Écouter l'état d'authentification
    ref.listen<AsyncValue<dynamic>>(authStateProvider, (previous, next) {
      next.whenData((user) {
        print('🔵 MyApp: Auth state changed - User: ${user?.uid ?? "null"}');

        // Naviguer en fonction de l'état d'auth
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (navigatorKey.currentState != null) {
            if (user != null) {
              print('🔵 MyApp: Navigating to HomePage');
              AppRouter.navigateAndRemoveUntil(
                navigatorKey.currentContext!,
                AppRoutes.home,
              );
            } else {
              print('🔵 MyApp: Navigating to OnboardingPage');
              AppRouter.navigateAndRemoveUntil(
                navigatorKey.currentContext!,
                AppRoutes.onboarding,
              );
            }
          }
        });
      });
    });

    final authState = ref.watch(authStateProvider);

    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Voice of Faith',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      routes: AppRouter.routes,
      initialRoute: authState.when(
        data: (user) {
          print('🔵 MyApp: Initial route - User: ${user?.uid ?? "null"}');
          return user != null ? AppRoutes.home : AppRoutes.onboarding;
        },
        loading: () {
          print('🔵 MyApp: Initial route - Loading');
          return AppRoutes.splash;
        },
        error: (error, stack) {
          print('🔴 MyApp: Initial route - Error: $error');
          return AppRoutes.onboarding;
        },
      ),
    );
  }
}
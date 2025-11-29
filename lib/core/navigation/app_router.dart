import 'package:flutter/material.dart';
import '../../features/auth/presentation/pages/onboarding_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/audios/presentation/pages/audios_list_page.dart';
import '../../features/sermons/presentation/pages/sermons_page.dart';
import '../../features/events/presentation/pages/events_page.dart';

/// Routes de l'application
class AppRoutes {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String audios = '/audios';
  static const String sermons = '/sermons';
  static const String events = '/events';
}

/// Configuration des routes de l'application
class AppRouter {
  static Map<String, WidgetBuilder> get routes => {
    AppRoutes.splash: (context) => const SplashPage(),
    AppRoutes.onboarding: (context) => const OnboardingPage(),
    AppRoutes.login: (context) => const LoginPage(),
    AppRoutes.register: (context) => const RegisterPage(),
    AppRoutes.home: (context) => const HomePage(),
    AppRoutes.audios: (context) => const AudiosListPage(),
    AppRoutes.sermons: (context) => const SermonsPage(),
    AppRoutes.events: (context) => const EventsPage(),
  };

  /// Navigation vers une route en supprimant toutes les routes précédentes
  static void navigateAndRemoveUntil(
      BuildContext context,
      String routeName,
      ) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      routeName,
          (route) => false,
    );
  }

  /// Navigation vers une route en gardant uniquement la première route
  static void navigateAndRemoveUntilFirst(
      BuildContext context,
      String routeName,
      ) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      routeName,
          (route) => route.isFirst,
    );
  }

  /// Navigation simple
  static Future<T?> navigateTo<T>(
      BuildContext context,
      String routeName, {
        Object? arguments,
      }) {
    return Navigator.pushNamed<T>(
      context,
      routeName,
      arguments: arguments,
    );
  }

  /// Remplacement de la route courante
  static Future<T?> navigateReplaceTo<T>(
      BuildContext context,
      String routeName, {
        Object? arguments,
      }) {
    return Navigator.pushReplacementNamed<T, void>(
      context,
      routeName,
      arguments: arguments,
    );
  }
}

/// Page Splash simple qui décide où naviguer
class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
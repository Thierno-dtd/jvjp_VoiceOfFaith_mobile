import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../mockTest/app_config.dart';
import '../../../../mockTest/mock_auth_service.dart';
import '../../../../models/user_model.dart';

// Provider du service d'authentification
final authServiceProvider = Provider<dynamic>((ref) {
  if (AppConfig.useMockData) {
    return MockAuthService();
  }
  return AuthService();
});

// Provider du stream d'état d'authentification
final authStateProvider = StreamProvider<dynamic>((ref) {
  final authService = ref.watch(authServiceProvider);
  if (AppConfig.useMockData) {
    return (authService as MockAuthService).authStateChanges;
  }
  return (authService as AuthService).authStateChanges;
});

// Provider des données utilisateur actuelles
final currentUserDataProvider = StreamProvider<UserModel?>((ref) {
  final authState = ref.watch(authStateProvider);

  return authState.when(
    data: (user) {
      if (user == null) return Stream.value(null);
      final authService = ref.watch(authServiceProvider);

      if (AppConfig.useMockData) {
        final mockService = authService as MockAuthService;
        final mockUser = user as MockUser;
        return mockService.getUserDataStream(mockUser.uid);
      } else {
        final realService = authService as AuthService;
        final firebaseUser = user as User;
        return realService.getUserDataStream(firebaseUser.uid);
      }
    },
    loading: () => Stream.value(null),
    error: (_, __) => Stream.value(null),
  );
});

// Provider pour l'inscription
final signUpProvider =
StateNotifierProvider<SignUpNotifier, AsyncValue<void>>((ref) {
  return SignUpNotifier(ref.watch(authServiceProvider));
});

class SignUpNotifier extends StateNotifier<AsyncValue<void>> {
  final dynamic _authService;

  SignUpNotifier(this._authService) : super(const AsyncValue.data(null));

  Future<void> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      print('🔵 SignUp: Starting for $email');

      if (AppConfig.useMockData) {
        await (_authService as MockAuthService).signUp(
          email: email,
          password: password,
          displayName: displayName,
        );
      } else {
        await (_authService as AuthService).signUp(
          email: email,
          password: password,
          displayName: displayName,
        );
      }

      print('🔵 SignUp: Success, waiting for auth state to propagate');
      // Attendre que l'état d'auth se propage
      await Future.delayed(const Duration(milliseconds: 1500));
      print('🔵 SignUp: Complete');
    });
  }
}

// Provider pour la connexion
final signInProvider =
StateNotifierProvider<SignInNotifier, AsyncValue<void>>((ref) {
  return SignInNotifier(ref.watch(authServiceProvider));
});

class SignInNotifier extends StateNotifier<AsyncValue<void>> {
  final dynamic _authService;

  SignInNotifier(this._authService) : super(const AsyncValue.data(null));

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      print('🔵 SignIn: Starting for $email');

      if (AppConfig.useMockData) {
        await (_authService as MockAuthService).signIn(
          email: email,
          password: password,
        );
      } else {
        await (_authService as AuthService).signIn(
          email: email,
          password: password,
        );
      }

      print('🔵 SignIn: Success - User authenticated');
      // Ne pas attendre ici, Firebase Auth propagera automatiquement
    });
  }
}

// Provider pour la déconnexion
final signOutProvider = Provider<Future<void> Function()>((ref) {
  final authService = ref.watch(authServiceProvider);
  return () {
    if (AppConfig.useMockData) {
      return (authService as MockAuthService).signOut();
    }
    return (authService as AuthService).signOut();
  };
});